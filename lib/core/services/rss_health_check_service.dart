import 'dart:async';
import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../error/exceptions.dart';
import 'hive_service.dart';

/// RSS kaynaklarının sağlığını kontrol eden servis
/// Periyodik olarak feed'leri test eder ve başarısız olanları takip eder
class RssHealthCheckService {
  static final RssHealthCheckService _instance = RssHealthCheckService._internal();
  factory RssHealthCheckService() => _instance;
  RssHealthCheckService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'User-Agent': 'Haber Merkezi RSS Health Check',
    },
  ));

  Timer? _healthCheckTimer;
  bool _isRunning = false;

  /// Health check'i başlatır (periyodik kontrol)
  void startPeriodicHealthCheck({Duration interval = const Duration(hours: 6)}) {
    if (_isRunning) {
      print('⚕️ Health check zaten çalışıyor');
      return;
    }

    print('⚕️ RSS Health Check başlatılıyor (${interval.inHours} saatte bir)');
    _isRunning = true;

    // İlk kontrolü hemen yap
    checkAllFeeds();

    // Periyodik kontrol timer'ı
    _healthCheckTimer = Timer.periodic(interval, (_) {
      checkAllFeeds();
    });
  }

  /// Health check'i durdurur
  void stopPeriodicHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    _isRunning = false;
    print('⚕️ RSS Health Check durduruldu');
  }

  /// Tüm RSS feed'lerini kontrol eder
  Future<RssHealthReport> checkAllFeeds() async {
    print('⚕️ Tüm RSS kaynakları kontrol ediliyor...');
    
    final startTime = DateTime.now();
    final results = <String, FeedHealthStatus>{};
    
    // Tüm feed'leri paralel olarak kontrol et
    final futures = ApiEndpoints.rssFeedUrls.entries.map((entry) async {
      final feedKey = entry.key;
      final feedUrl = entry.value;
      
      final status = await _checkSingleFeed(feedKey, feedUrl);
      results[feedKey] = status;
    });

    await Future.wait(futures);
    
    final duration = DateTime.now().difference(startTime);
    
    // Sonuçları analiz et
    final healthy = results.values.where((s) => s.isHealthy).length;
    final unhealthy = results.values.where((s) => !s.isHealthy).length;
    final total = results.length;
    
    final report = RssHealthReport(
      timestamp: DateTime.now(),
      totalFeeds: total,
      healthyFeeds: healthy,
      unhealthyFeeds: unhealthy,
      feedStatuses: results,
      checkDuration: duration,
    );
    
    // Raporu kaydet
    await _saveHealthReport(report);
    
    // Sonuçları logla
    print('⚕️ Health Check Tamamlandı:');
    print('   ✅ Sağlıklı: $healthy/$total (${(healthy/total*100).toStringAsFixed(1)}%)');
    print('   ❌ Sorunlu: $unhealthy/$total');
    print('   ⏱️ Süre: ${duration.inSeconds}s');
    
    // Sorunlu feed'leri devre dışı bırak
    if (unhealthy > 0) {
      await _handleUnhealthyFeeds(report);
    }
    
    return report;
  }

  /// Tek bir feed'i kontrol eder
  Future<FeedHealthStatus> _checkSingleFeed(String feedKey, String feedUrl) async {
    try {
      final startTime = DateTime.now();
      
      final response = await _dio.get(feedUrl);
      final responseTime = DateTime.now().difference(startTime);
      
      if (response.statusCode == 200) {
        // XML parse kontrolü
        final xmlString = response.data as String;
        if (xmlString.isEmpty || !xmlString.trim().startsWith('<')) {
          return FeedHealthStatus(
            feedKey: feedKey,
            feedUrl: feedUrl,
            isHealthy: false,
            statusCode: 200,
            errorMessage: 'Invalid XML format',
            responseTime: responseTime,
            lastChecked: DateTime.now(),
          );
        }
        
        return FeedHealthStatus(
          feedKey: feedKey,
          feedUrl: feedUrl,
          isHealthy: true,
          statusCode: response.statusCode,
          responseTime: responseTime,
          lastChecked: DateTime.now(),
        );
      } else {
        return FeedHealthStatus(
          feedKey: feedKey,
          feedUrl: feedUrl,
          isHealthy: false,
          statusCode: response.statusCode,
          errorMessage: 'HTTP ${response.statusCode}',
          responseTime: responseTime,
          lastChecked: DateTime.now(),
        );
      }
    } on DioException catch (e) {
      return FeedHealthStatus(
        feedKey: feedKey,
        feedUrl: feedUrl,
        isHealthy: false,
        errorMessage: _getDioErrorMessage(e),
        lastChecked: DateTime.now(),
      );
    } catch (e) {
      return FeedHealthStatus(
        feedKey: feedKey,
        feedUrl: feedUrl,
        isHealthy: false,
        errorMessage: e.toString(),
        lastChecked: DateTime.now(),
      );
    }
  }

  /// DioException'dan anlamlı mesaj çıkarır
  String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.connectionError:
        return 'Connection error';
      case DioExceptionType.badResponse:
        return 'Bad response: ${error.response?.statusCode}';
      default:
        return 'Network error: ${error.message}';
    }
  }

  /// Health report'u Hive'a kaydeder
  Future<void> _saveHealthReport(RssHealthReport report) async {
    try {
      final box = HiveService.settingsBox;
      
      // Son 10 raporu tut
      final reports = box.get('health_reports', defaultValue: <Map<String, dynamic>>[]) as List;
      final reportList = List<Map<String, dynamic>>.from(reports);
      
      reportList.add(report.toJson());
      
      // En fazla 10 rapor tut
      if (reportList.length > 10) {
        reportList.removeAt(0);
      }
      
      await box.put('health_reports', reportList);
      
      // En son raporu da ayrıca kaydet
      await box.put('last_health_report', report.toJson());
    } catch (e) {
      print('⚠️ Health report kaydedilemedi: $e');
    }
  }

  /// Sorunlu feed'leri işler
  Future<void> _handleUnhealthyFeeds(RssHealthReport report) async {
    try {
      final box = HiveService.settingsBox;
      
      // Disabled feed'leri al
      final disabledFeeds = box.get('disabled_feeds', defaultValue: <String>[]) as List;
      final disabledList = List<String>.from(disabledFeeds);
      
      // Failure count'ları al
      final failureCounts = box.get('feed_failure_counts', defaultValue: <String, int>{}) as Map;
      final countMap = Map<String, int>.from(failureCounts);
      
      for (final entry in report.feedStatuses.entries) {
        final feedKey = entry.key;
        final status = entry.value;
        
        if (!status.isHealthy) {
          // Failure count'u artır
          countMap[feedKey] = (countMap[feedKey] ?? 0) + 1;
          
          // 3 kez üst üste başarısız olursa devre dışı bırak
          if (countMap[feedKey]! >= 3 && !disabledList.contains(feedKey)) {
            disabledList.add(feedKey);
            print('⚠️ Feed devre dışı bırakıldı: $feedKey (${countMap[feedKey]} başarısızlık)');
          }
        } else {
          // Başarılı ise count'u sıfırla
          countMap[feedKey] = 0;
          
          // Eğer disabled ise tekrar etkinleştir
          if (disabledList.contains(feedKey)) {
            disabledList.remove(feedKey);
            print('✅ Feed tekrar etkinleştirildi: $feedKey');
          }
        }
      }
      
      // Güncellenmiş listeleri kaydet
      await box.put('disabled_feeds', disabledList);
      await box.put('feed_failure_counts', countMap);
      
    } catch (e) {
      print('⚠️ Unhealthy feedler işlenemedi: $e');
    }
  }

  /// En son health report'u döndürür
  Future<RssHealthReport?> getLastHealthReport() async {
    try {
      final box = HiveService.settingsBox;
      final reportData = box.get('last_health_report') as Map<String, dynamic>?;
      
      if (reportData != null) {
        return RssHealthReport.fromJson(reportData);
      }
    } catch (e) {
      print('⚠️ Last health report alınamadı: $e');
    }
    return null;
  }

  /// Tüm health report'ları döndürür
  Future<List<RssHealthReport>> getAllHealthReports() async {
    try {
      final box = HiveService.settingsBox;
      final reports = box.get('health_reports', defaultValue: <Map<String, dynamic>>[]) as List;
      
      return reports
          .map((r) => RssHealthReport.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('⚠️ Health reports alınamadı: $e');
      return [];
    }
  }

  /// Devre dışı bırakılmış feed'leri döndürür
  Future<List<String>> getDisabledFeeds() async {
    try {
      final box = HiveService.settingsBox;
      final disabled = box.get('disabled_feeds', defaultValue: <String>[]) as List;
      return List<String>.from(disabled);
    } catch (e) {
      print('⚠️ Disabled feeds alınamadı: $e');
      return [];
    }
  }

  /// Bir feed'i manuel olarak devre dışı bırakır
  Future<void> disableFeed(String feedKey) async {
    try {
      final box = HiveService.settingsBox;
      final disabled = box.get('disabled_feeds', defaultValue: <String>[]) as List;
      final disabledList = List<String>.from(disabled);
      
      if (!disabledList.contains(feedKey)) {
        disabledList.add(feedKey);
        await box.put('disabled_feeds', disabledList);
        print('⚠️ Feed manuel olarak devre dışı bırakıldı: $feedKey');
      }
    } catch (e) {
      print('⚠️ Feed devre dışı bırakılamadı: $e');
    }
  }

  /// Bir feed'i manuel olarak etkinleştirir
  Future<void> enableFeed(String feedKey) async {
    try {
      final box = HiveService.settingsBox;
      final disabled = box.get('disabled_feeds', defaultValue: <String>[]) as List;
      final disabledList = List<String>.from(disabled);
      
      if (disabledList.contains(feedKey)) {
        disabledList.remove(feedKey);
        await box.put('disabled_feeds', disabledList);
        
        // Failure count'u da sıfırla
        final counts = box.get('feed_failure_counts', defaultValue: <String, int>{}) as Map;
        final countMap = Map<String, int>.from(counts);
        countMap[feedKey] = 0;
        await box.put('feed_failure_counts', countMap);
        
        print('✅ Feed manuel olarak etkinleştirildi: $feedKey');
      }
    } catch (e) {
      print('⚠️ Feed etkinleştirilemedi: $e');
    }
  }

  /// Tüm failure count'ları sıfırlar
  Future<void> resetFailureCounts() async {
    try {
      final box = HiveService.settingsBox;
      await box.put('feed_failure_counts', <String, int>{});
      print('✅ Tüm failure countlar sıfırlandı');
    } catch (e) {
      print('⚠️ Failure countlar sıfırlanamadı: $e');
    }
  }

  /// Tüm disabled feed'leri etkinleştirir
  Future<void> enableAllFeeds() async {
    try {
      final box = HiveService.settingsBox;
      await box.put('disabled_feeds', <String>[]);
      await resetFailureCounts();
      print('✅ Tüm feedler etkinleştirildi');
    } catch (e) {
      print('⚠️ Feedler etkinleştirilemedi: $e');
    }
  }
}

/// RSS Health Report - kontrol sonuçlarını tutar
class RssHealthReport {
  final DateTime timestamp;
  final int totalFeeds;
  final int healthyFeeds;
  final int unhealthyFeeds;
  final Map<String, FeedHealthStatus> feedStatuses;
  final Duration checkDuration;

  RssHealthReport({
    required this.timestamp,
    required this.totalFeeds,
    required this.healthyFeeds,
    required this.unhealthyFeeds,
    required this.feedStatuses,
    required this.checkDuration,
  });

  double get healthPercentage => (healthyFeeds / totalFeeds) * 100;
  
  bool get isHealthy => healthPercentage >= 90;

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'totalFeeds': totalFeeds,
    'healthyFeeds': healthyFeeds,
    'unhealthyFeeds': unhealthyFeeds,
    'feedStatuses': feedStatuses.map((k, v) => MapEntry(k, v.toJson())),
    'checkDurationMs': checkDuration.inMilliseconds,
  };

  factory RssHealthReport.fromJson(Map<String, dynamic> json) {
    return RssHealthReport(
      timestamp: DateTime.parse(json['timestamp'] as String),
      totalFeeds: json['totalFeeds'] as int,
      healthyFeeds: json['healthyFeeds'] as int,
      unhealthyFeeds: json['unhealthyFeeds'] as int,
      feedStatuses: (json['feedStatuses'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, FeedHealthStatus.fromJson(v as Map<String, dynamic>)),
      ),
      checkDuration: Duration(milliseconds: json['checkDurationMs'] as int),
    );
  }
}

/// Feed Health Status - tek bir feed'in durumu
class FeedHealthStatus {
  final String feedKey;
  final String feedUrl;
  final bool isHealthy;
  final int? statusCode;
  final String? errorMessage;
  final Duration? responseTime;
  final DateTime lastChecked;

  FeedHealthStatus({
    required this.feedKey,
    required this.feedUrl,
    required this.isHealthy,
    this.statusCode,
    this.errorMessage,
    this.responseTime,
    required this.lastChecked,
  });

  Map<String, dynamic> toJson() => {
    'feedKey': feedKey,
    'feedUrl': feedUrl,
    'isHealthy': isHealthy,
    'statusCode': statusCode,
    'errorMessage': errorMessage,
    'responseTimeMs': responseTime?.inMilliseconds,
    'lastChecked': lastChecked.toIso8601String(),
  };

  factory FeedHealthStatus.fromJson(Map<String, dynamic> json) {
    return FeedHealthStatus(
      feedKey: json['feedKey'] as String,
      feedUrl: json['feedUrl'] as String,
      isHealthy: json['isHealthy'] as bool,
      statusCode: json['statusCode'] as int?,
      errorMessage: json['errorMessage'] as String?,
      responseTime: json['responseTimeMs'] != null 
          ? Duration(milliseconds: json['responseTimeMs'] as int)
          : null,
      lastChecked: DateTime.parse(json['lastChecked'] as String),
    );
  }
}