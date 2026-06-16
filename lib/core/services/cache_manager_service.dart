import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haber_merkezi/core/services/logger_service.dart';

/// Cache giriş bilgisi
class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final Duration ttl;

  CacheEntry({
    required this.value,
    required this.ttl,
  }) : createdAt = DateTime.now();

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;

  DateTime get expiresAt => createdAt.add(ttl);

  int get remainingMs =>
      expiresAt.difference(DateTime.now()).inMilliseconds.clamp(0, ttl.inMilliseconds);
}

/// Cache istatistikleri
class CacheStats {
  int hits = 0;
  int misses = 0;
  int evictions = 0;
  int memoryItems = 0;
  int diskItems = 0;

  double get hitRate => (hits + misses) == 0 ? 0.0 : hits / (hits + misses);

  void reset() {
    hits = 0;
    misses = 0;
    evictions = 0;
  }

  Map<String, dynamic> toJson() => {
        'hits': hits,
        'misses': misses,
        'evictions': evictions,
        'hitRate': '${(hitRate * 100).toStringAsFixed(1)}%',
        'memoryItems': memoryItems,
        'diskItems': diskItems,
      };

  @override
  String toString() =>
      'CacheStats(hits: $hits, misses: $misses, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
      'evictions: $evictions, memory: $memoryItems, disk: $diskItems)';
}

/// Multi-level cache yöneticisi
/// 
/// Memory → Disk şeklinde iki katmanlı cache sunar.
/// - LRU eviction ile bellek yönetimi
/// - TTL bazlı otomatik invalidation
/// - Hit/miss istatistikleri
class CacheManagerService {
  final LoggerService _logger;
  final int maxMemoryItems;
  final Duration defaultTtl;

  /// LRU memory cache - LinkedHashMap erişim sırasını korur
  final LinkedHashMap<String, CacheEntry<dynamic>> _memoryCache =
      LinkedHashMap<String, CacheEntry<dynamic>>();

  /// Disk cache prefix
  static const String _diskPrefix = 'cache_mgr_';

  /// İstatistikler
  final CacheStats stats = CacheStats();

  /// SharedPreferences instance (lazy)
  SharedPreferences? _prefs;

  CacheManagerService({
    LoggerService? logger,
    this.maxMemoryItems = 100,
    this.defaultTtl = const Duration(minutes: 30),
  }) : _logger = logger ?? LoggerService();

  /// SharedPreferences'ı lazy olarak al
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Cache'e veri yaz (memory + disk)
  Future<void> put<T>(
    String key, 
    T value, {
    Duration? ttl,
    bool persistToDisk = true,
  }) async {
    final effectiveTtl = ttl ?? defaultTtl;

    // Memory cache'e yaz
    _memoryCache[key] = CacheEntry<T>(value: value, ttl: effectiveTtl);
    _enforceMemoryLimit();
    stats.memoryItems = _memoryCache.length;

    // Disk cache'e yaz
    if (persistToDisk && value is Map || value is List || value is String || value is num || value is bool) {
      try {
        final prefs = await _preferences;
        final wrapper = {
          'value': value,
          'ttl': effectiveTtl.inMilliseconds,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        };
        await prefs.setString('$_diskPrefix$key', jsonEncode(wrapper));
      } catch (e) {
        _logger.warning('Disk cache yazma hatası: $key - $e', tag: 'CacheManager');
      }
    }

    _logger.debug('Cache PUT: $key (TTL: ${effectiveTtl.inSeconds}s)', tag: 'CacheManager');
  }

  /// Cache'den veri oku (memory → disk sırasıyla)
  Future<T?> get<T>(String key) async {
    // 1. Memory cache'den bak
    final memEntry = _memoryCache[key];
    if (memEntry != null) {
      if (!memEntry.isExpired) {
        stats.hits++;
        // LRU: erişilen öğeyi sona taşı
        _memoryCache.remove(key);
        _memoryCache[key] = memEntry;
        _logger.debug('Cache HIT (memory): $key', tag: 'CacheManager');
        return memEntry.value as T?;
      } else {
        // Süresi dolmuş, sil
        _memoryCache.remove(key);
        stats.memoryItems = _memoryCache.length;
      }
    }

    // 2. Disk cache'den bak
    try {
      final prefs = await _preferences;
      final raw = prefs.getString('$_diskPrefix$key');
      if (raw != null) {
        final wrapper = jsonDecode(raw) as Map<String, dynamic>;
        final createdAt = DateTime.fromMillisecondsSinceEpoch(wrapper['createdAt'] as int);
        final ttl = Duration(milliseconds: wrapper['ttl'] as int);

        if (DateTime.now().difference(createdAt) <= ttl) {
          final value = wrapper['value'];
          // Memory cache'e geri yükle
          _memoryCache[key] = CacheEntry<dynamic>(value: value, ttl: ttl);
          _enforceMemoryLimit();
          stats.memoryItems = _memoryCache.length;
          stats.hits++;
          _logger.debug('Cache HIT (disk): $key', tag: 'CacheManager');
          return value as T?;
        } else {
          // Süresi dolmuş, sil
          await prefs.remove('$_diskPrefix$key');
        }
      }
    } catch (e) {
      _logger.warning('Disk cache okuma hatası: $key - $e', tag: 'CacheManager');
    }

    stats.misses++;
    _logger.debug('Cache MISS: $key', tag: 'CacheManager');
    return null;
  }

  /// Cache'den veri al, yoksa factory ile oluştur
  Future<T> getOrPut<T>(
    String key,
    Future<T> Function() factory, {
    Duration? ttl,
    bool persistToDisk = true,
  }) async {
    final cached = await get<T>(key);
    if (cached != null) return cached;

    final value = await factory();
    await put<T>(key, value, ttl: ttl, persistToDisk: persistToDisk);
    return value;
  }

  /// Belirli bir anahtarı sil
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    stats.memoryItems = _memoryCache.length;

    try {
      final prefs = await _preferences;
      await prefs.remove('$_diskPrefix$key');
    } catch (e) {
      _logger.warning('Cache silme hatası: $key - $e', tag: 'CacheManager');
    }
  }

  /// Belirli bir pattern'e uyan anahtarları sil
  Future<void> removeWhere(bool Function(String key) predicate) async {
    final keysToRemove = _memoryCache.keys.where(predicate).toList();
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }
    stats.memoryItems = _memoryCache.length;

    try {
      final prefs = await _preferences;
      final diskKeys = prefs.getKeys().where((k) => k.startsWith(_diskPrefix));
      for (final diskKey in diskKeys) {
        final actualKey = diskKey.substring(_diskPrefix.length);
        if (predicate(actualKey)) {
          await prefs.remove(diskKey);
        }
      }
    } catch (e) {
      _logger.warning('Cache pattern silme hatası: $e', tag: 'CacheManager');
    }
  }

  /// Tüm cache'i temizle
  Future<void> clearAll() async {
    _memoryCache.clear();
    stats.memoryItems = 0;

    try {
      final prefs = await _preferences;
      final diskKeys = prefs.getKeys().where((k) => k.startsWith(_diskPrefix)).toList();
      for (final key in diskKeys) {
        await prefs.remove(key);
      }
      stats.diskItems = 0;
    } catch (e) {
      _logger.warning('Cache temizleme hatası: $e', tag: 'CacheManager');
    }

    _logger.info('Tüm cache temizlendi', tag: 'CacheManager');
  }

  /// Sadece memory cache'i temizle
  void clearMemory() {
    _memoryCache.clear();
    stats.memoryItems = 0;
    _logger.info('Memory cache temizlendi', tag: 'CacheManager');
  }

  /// Süresi dolmuş girişleri temizle
  Future<void> evictExpired() async {
    int evicted = 0;

    // Memory
    final expiredKeys = _memoryCache.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toList();
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      evicted++;
    }
    stats.memoryItems = _memoryCache.length;

    // Disk
    try {
      final prefs = await _preferences;
      final diskKeys = prefs.getKeys().where((k) => k.startsWith(_diskPrefix));
      for (final diskKey in diskKeys) {
        final raw = prefs.getString(diskKey);
        if (raw != null) {
          try {
            final wrapper = jsonDecode(raw) as Map<String, dynamic>;
            final createdAt = DateTime.fromMillisecondsSinceEpoch(wrapper['createdAt'] as int);
            final ttl = Duration(milliseconds: wrapper['ttl'] as int);
            if (DateTime.now().difference(createdAt) > ttl) {
              await prefs.remove(diskKey);
              evicted++;
            }
          } catch (_) {
            await prefs.remove(diskKey);
            evicted++;
          }
        }
      }
    } catch (e) {
      _logger.warning('Expired cache temizleme hatası: $e', tag: 'CacheManager');
    }

    stats.evictions += evicted;
    if (evicted > 0) {
      _logger.info('$evicted expired cache girişi temizlendi', tag: 'CacheManager');
    }
  }

  /// Bir anahtarın cache'de olup olmadığını kontrol et
  bool containsKey(String key) {
    final entry = _memoryCache[key];
    return entry != null && !entry.isExpired;
  }

  /// İstatistikleri al
  CacheStats getStats() {
    stats.memoryItems = _memoryCache.length;
    return stats;
  }

  /// İstatistikleri sıfırla
  void resetStats() {
    stats.reset();
  }

  /// LRU eviction - bellek limitini aşarsa en eski öğeleri sil
  void _enforceMemoryLimit() {
    while (_memoryCache.length > maxMemoryItems) {
      final firstKey = _memoryCache.keys.first;
      _memoryCache.remove(firstKey);
      stats.evictions++;
    }
  }
}

/// Cache manager provider
final cacheManagerServiceProvider = Provider<CacheManagerService>((ref) {
  return CacheManagerService(
    logger: LoggerService(),
    maxMemoryItems: 100,
    defaultTtl: const Duration(minutes: 30),
  );
});