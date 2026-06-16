import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:haber_merkezi/core/services/logger_service.dart';

/// İstek öncelik seviyeleri
enum RequestPriority {
  /// Son dakika haberleri, kritik güncellemeler
  critical,

  /// Normal haberler, kullanıcı etkileşimi
  high,

  /// Arka plan senkronizasyonu
  normal,

  /// Analitik, prefetch
  low,
}

/// Bağlantı kalitesi
enum ConnectionQuality {
  /// WiFi bağlantısı
  wifi,

  /// Hücresel veri
  cellular,

  /// Bağlantı yok
  none,
}

/// Network optimizasyon servisi
///
/// Request debouncing, deduplication, retry logic, circuit breaker,
/// priority queue ve bağlantı kalitesine göre strateji sağlar.
class NetworkOptimizerService {
  NetworkOptimizerService._();

  static final NetworkOptimizerService _instance = NetworkOptimizerService._();
  factory NetworkOptimizerService() => _instance;

  final LoggerService _logger = LoggerService();

  // --- Request Debouncing ---
  final Map<String, Timer> _debounceTimers = {};

  // --- Request Deduplication ---
  final Map<String, Future<dynamic>> _pendingRequests = {};

  // --- Circuit Breaker ---
  final Map<String, _CircuitBreakerState> _circuitBreakers = {};
  static const int _circuitBreakerThreshold = 5;
  static const Duration _circuitBreakerCooldown = Duration(minutes: 1);

  // --- Priority Queue ---
  final SplayTreeMap<int, List<_PriorityRequest>> _requestQueue =
      SplayTreeMap<int, List<_PriorityRequest>>();
  bool _isProcessingQueue = false;

  // --- Connection Quality ---
  ConnectionQuality _currentQuality = ConnectionQuality.wifi;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Servisi başlat
  void initialize() {
    _startConnectivityMonitoring();
    _logger.info('NetworkOptimizer başlatıldı', tag: 'NET_OPT');
  }

  /// Servisi durdur
  void dispose() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _connectivitySubscription?.cancel();
    _logger.info('NetworkOptimizer durduruldu', tag: 'NET_OPT');
  }

  // ==================== Request Debouncing ====================

  /// Belirli bir süre içinde aynı key ile yapılan istekleri tek bir istekte birleştirir
  ///
  /// [key]: İstek tanımlayıcısı (örn: arama sorgusu)
  /// [duration]: Bekleme süresi
  /// [action]: Gerçekleştirilecek işlem
  void debounce(
    String key, {
    Duration duration = const Duration(milliseconds: 500),
    required VoidCallback action,
  }) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(duration, () {
      _debounceTimers.remove(key);
      action();
    });
  }

  /// Debounce timer'ı iptal et
  void cancelDebounce(String key) {
    _debounceTimers[key]?.cancel();
    _debounceTimers.remove(key);
  }

  // ==================== Request Deduplication ====================

  /// Aynı URL'ye birden fazla istek yapılmasını engeller.
  /// İlk istek devam ederken aynı key ile gelen istekler ilk isteğin
  /// sonucunu paylaşır.
  Future<T> deduplicate<T>(
    String key,
    Future<T> Function() requestFactory,
  ) async {
    if (_pendingRequests.containsKey(key)) {
      _logger.debug('Dedup: mevcut istek paylaşılıyor → $key', tag: 'NET_OPT');
      return await _pendingRequests[key] as T;
    }

    final future = requestFactory();
    _pendingRequests[key] = future;

    try {
      final result = await future;
      return result;
    } finally {
      _pendingRequests.remove(key);
    }
  }

  /// Bekleyen istek var mı kontrol et
  bool hasPendingRequest(String key) => _pendingRequests.containsKey(key);

  // ==================== Retry Logic with Exponential Backoff ====================

  /// Exponential backoff ile retry mekanizması
  ///
  /// [maxRetries]: Maksimum deneme sayısı
  /// [initialDelay]: İlk bekleme süresi
  /// [maxDelay]: Maksimum bekleme süresi
  /// [retryIf]: Hangi hatalarda retry yapılacağını belirler
  Future<T> retryWithBackoff<T>(
    Future<T> Function() action, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    bool Function(Exception)? retryIf,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await action();
      } on Exception catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          _logger.error(
            'Retry başarısız ($attempt/$maxRetries deneme): $e',
            tag: 'NET_OPT',
          );
          rethrow;
        }

        if (retryIf != null && !retryIf(e)) {
          rethrow;
        }

        _logger.warning(
          'Retry ($attempt/$maxRetries): ${delay.inMilliseconds}ms bekleniyor...',
          tag: 'NET_OPT',
        );

        await Future.delayed(delay);

        // Exponential backoff: her denemede süreyi 2x artır
        delay = Duration(
          milliseconds: (delay.inMilliseconds * 2).clamp(
            0,
            maxDelay.inMilliseconds,
          ),
        );
      }
    }
  }

  // ==================== Circuit Breaker ====================

  /// Circuit breaker durumunu kontrol et
  ///
  /// Belirli bir endpoint için hata sayısı threshold'u aşarsa
  /// istek yapmadan engeller (circuit open). Cooldown süresi
  /// dolduktan sonra tekrar dener (half-open).
  bool isCircuitOpen(String endpoint) {
    final state = _circuitBreakers[endpoint];
    if (state == null) return false;

    if (state.isOpen) {
      // Cooldown süresi dolduysa half-open durumuna geç
      if (DateTime.now().difference(state.lastFailure) >
          _circuitBreakerCooldown) {
        state.isOpen = false;
        state.failureCount = 0;
        _logger.info('Circuit breaker HALF-OPEN: $endpoint', tag: 'CIRCUIT');
        return false;
      }
      return true;
    }
    return false;
  }

  /// Başarılı istek bildirimi
  void recordSuccess(String endpoint) {
    _circuitBreakers[endpoint]?.failureCount = 0;
    _circuitBreakers[endpoint]?.isOpen = false;
  }

  /// Başarısız istek bildirimi
  void recordFailure(String endpoint) {
    final state = _circuitBreakers.putIfAbsent(
      endpoint,
      () => _CircuitBreakerState(),
    );

    state.failureCount++;
    state.lastFailure = DateTime.now();

    if (state.failureCount >= _circuitBreakerThreshold) {
      state.isOpen = true;
      _logger.warning(
        'Circuit breaker OPEN: $endpoint (${state.failureCount} hata)',
        tag: 'CIRCUIT',
      );
    }
  }

  /// Circuit breaker ile korumalı istek
  Future<T> withCircuitBreaker<T>(
    String endpoint,
    Future<T> Function() action,
  ) async {
    if (isCircuitOpen(endpoint)) {
      throw CircuitBreakerOpenException(
        'Circuit breaker açık: $endpoint. Lütfen daha sonra tekrar deneyin.',
      );
    }

    try {
      final result = await action();
      recordSuccess(endpoint);
      return result;
    } catch (e) {
      recordFailure(endpoint);
      rethrow;
    }
  }

  // ==================== Request Priority Queue ====================

  /// Öncelikli istek kuyruğuna ekle
  void enqueueRequest(
    RequestPriority priority,
    Future<void> Function() action,
    String label,
  ) {
    final priorityValue = priority.index;
    _requestQueue.putIfAbsent(priorityValue, () => []);
    _requestQueue[priorityValue]!.add(
      _PriorityRequest(action: action, label: label, addedAt: DateTime.now()),
    );

    _logger.debug('Kuyruğa eklendi [${priority.name}]: $label', tag: 'QUEUE');

    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    try {
      while (_requestQueue.isNotEmpty) {
        final highestPriority = _requestQueue.firstKey();
        if (highestPriority == null) break;

        final requests = _requestQueue[highestPriority];
        if (requests == null || requests.isEmpty) {
          _requestQueue.remove(highestPriority);
          continue;
        }

        final request = requests.removeAt(0);
        if (requests.isEmpty) {
          _requestQueue.remove(highestPriority);
        }

        try {
          await request.action();
        } catch (e) {
          _logger.error(
            'Kuyruk isteği başarısız [${request.label}]: $e',
            tag: 'QUEUE',
          );
        }
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  // ==================== Connection Quality ====================

  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      _updateConnectionQuality(results);
    });

    // İlk durumu kontrol et
    Connectivity().checkConnectivity().then(_updateConnectionQuality);
  }

  void _updateConnectionQuality(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      _currentQuality = ConnectionQuality.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      _currentQuality = ConnectionQuality.cellular;
    } else if (results.contains(ConnectivityResult.none)) {
      _currentQuality = ConnectionQuality.none;
    }

    _logger.network(
      'Bağlantı kalitesi: ${_currentQuality.name}',
      tag: 'NET_OPT',
    );
  }

  /// Mevcut bağlantı kalitesini al
  ConnectionQuality get connectionQuality => _currentQuality;

  /// Bağlantı kalitesine göre resim kalitesi ayarla
  int getImageQualityForConnection() {
    switch (_currentQuality) {
      case ConnectionQuality.wifi:
        return 90; // Yüksek kalite
      case ConnectionQuality.cellular:
        return 60; // Orta kalite
      case ConnectionQuality.none:
        return 0; // Resim yükleme
    }
  }

  /// Bağlantı kalitesine göre prefetch stratejisi
  bool shouldPrefetch() {
    return _currentQuality == ConnectionQuality.wifi;
  }

  /// Bağlantı kalitesine göre video otomatik oynatma
  bool shouldAutoPlayVideo() {
    return _currentQuality == ConnectionQuality.wifi;
  }

  // ==================== İstatistikler ====================

  Map<String, dynamic> getStats() {
    return {
      'pendingRequests': _pendingRequests.length,
      'activeDebounces': _debounceTimers.length,
      'circuitBreakers': _circuitBreakers.map(
        (k, v) =>
            MapEntry(k, {'isOpen': v.isOpen, 'failureCount': v.failureCount}),
      ),
      'queueSize': _requestQueue.values.fold<int>(
        0,
        (sum, list) => sum + list.length,
      ),
      'connectionQuality': _currentQuality.name,
    };
  }
}

/// Circuit breaker iç durum
class _CircuitBreakerState {
  int failureCount = 0;
  bool isOpen = false;
  DateTime lastFailure = DateTime.now();
}

/// Öncelikli istek modeli
class _PriorityRequest {
  final Future<void> Function() action;
  final String label;
  final DateTime addedAt;

  const _PriorityRequest({
    required this.action,
    required this.label,
    required this.addedAt,
  });
}

/// Circuit breaker açık olduğunda fırlatılan exception
class CircuitBreakerOpenException implements Exception {
  final String message;
  const CircuitBreakerOpenException(this.message);

  @override
  String toString() => 'CircuitBreakerOpenException: $message';
}

/// Riverpod provider
final networkOptimizerProvider = Provider<NetworkOptimizerService>((ref) {
  final service = NetworkOptimizerService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});
