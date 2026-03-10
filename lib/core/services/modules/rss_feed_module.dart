import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/rss_source.dart';
import '../rss_sources_service.dart';
import '../rss_health_check_service.dart';
import '../rss_feed_validator.dart';

/// RSS Feed Modülü - Kaynak yönetimi, sağlık kontrolü ve doğrulamayı birleştirir
///
/// Birleştirilen servisler:
/// - RssSourcesService (kaynak CRUD)
/// - RssHealthCheckService (sağlık kontrolü, alternatif URL'ler)
/// - RssFeedValidator (URL doğrulama)
///
/// Kullanım:
/// ```dart
/// final module = RssFeedModule();
/// final sources = module.getAllSources();
/// await module.addAndValidateSource(source);
/// final report = await module.checkAllFeedsHealth();
/// ```
class RssFeedModule {
  static final RssFeedModule _instance = RssFeedModule._internal();
  factory RssFeedModule() => _instance;

  final RssHealthCheckService _healthCheck = RssHealthCheckService();
  late final RssFeedValidator _validator;

  RssFeedModule._internal() {
    _validator = RssFeedValidator(Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    )));
  }

  // ========================================================================
  // KAYNAK YÖNETİMİ (RssSourcesService delegate)
  // ========================================================================

  /// Servisi başlat
  Future<void> init() async {
    await RssSourcesService.init();
  }

  /// Tüm kaynakları getir
  List<RssSource> getAllSources() => RssSourcesService.getAllSources();

  /// Aktif kaynakları getir
  List<RssSource> getActiveSources() => RssSourcesService.getActiveSources();

  /// Kategoriye göre kaynakları getir
  List<RssSource> getSourcesByCategory(String category) =>
      RssSourcesService.getSourcesByCategory(category);

  /// ID'ye göre kaynak getir
  RssSource? getSourceById(String id) => RssSourcesService.getSourceById(id);

  /// Kaynak ekle
  Future<bool> addSource(RssSource source) => RssSourcesService.addSource(source);

  /// Kaynak güncelle
  Future<bool> updateSource(RssSource source) => RssSourcesService.updateSource(source);

  /// Kaynak sil
  Future<bool> deleteSource(String id) => RssSourcesService.deleteSource(id);

  /// Kaynak toggle
  Future<bool> toggleSourceStatus(String id) => RssSourcesService.toggleSourceStatus(id);

  /// Tüm kategorileri getir
  List<String> getAllCategories() => RssSourcesService.getAllCategories();

  /// Kaynak sayısı
  int getSourceCount() => RssSourcesService.getSourceCount();

  /// Aktif kaynak sayısı
  int getActiveSourceCount() => RssSourcesService.getActiveSourceCount();

  /// Varsayılanlara sıfırla
  Future<bool> resetToDefaults() => RssSourcesService.resetToDefaults();

  // ========================================================================
  // URL DOĞRULAMA (RssFeedValidator delegate)
  // ========================================================================

  /// URL formatı geçerli mi?
  bool isValidUrl(String url) => RssSourcesService.isValidRssUrl(url);

  /// RSS feed'i doğrula (URL'ye bağlanıp XML formatını kontrol et)
  Future<RssFeedValidationResult> validateFeed(String url) async {
    return await _validator.validateFeedUrl(url);
  }

  // ========================================================================
  // SAĞLIK KONTROLÜ (RssHealthCheckService delegate)
  // ========================================================================

  /// Periyodik sağlık kontrolünü başlat
  void startPeriodicHealthCheck({Duration interval = const Duration(hours: 6)}) {
    _healthCheck.startPeriodicHealthCheck(interval: interval);
  }

  /// Periyodik sağlık kontrolünü durdur
  void stopPeriodicHealthCheck() {
    _healthCheck.stopPeriodicHealthCheck();
  }

  /// Tüm feed'leri kontrol et
  Future<RssHealthReport> checkAllFeedsHealth() async {
    return await _healthCheck.checkAllFeeds();
  }

  /// Son sağlık raporunu getir
  Future<RssHealthReport?> getLastHealthReport() async {
    return await _healthCheck.getLastHealthReport();
  }

  /// Devre dışı feed'leri getir
  Future<List<String>> getDisabledFeeds() async {
    return await _healthCheck.getDisabledFeeds();
  }

  /// Feed'i devre dışı bırak
  Future<void> disableFeed(String feedKey) => _healthCheck.disableFeed(feedKey);

  /// Feed'i etkinleştir
  Future<void> enableFeed(String feedKey) => _healthCheck.enableFeed(feedKey);

  /// Tüm feed'leri etkinleştir
  Future<void> enableAllFeeds() => _healthCheck.enableAllFeeds();

  /// Belirli feed için çalışan URL'yi getir
  String? getWorkingUrl(String feedKey) => _healthCheck.getWorkingUrl(feedKey);

  // ========================================================================
  // BİRLEŞİK İŞLEMLER
  // ========================================================================

  /// Kaynak ekle ve doğrula (tek adımda)
  Future<AddSourceResult> addAndValidateSource(RssSource source) async {
    // 1. URL formatını kontrol et
    if (!isValidUrl(source.url)) {
      return AddSourceResult(
        success: false,
        error: 'Geçersiz URL formatı',
      );
    }

    // 2. RSS feed'i doğrula
    final validation = await validateFeed(source.url);
    if (!validation.isValid) {
      return AddSourceResult(
        success: false,
        error: 'RSS feed doğrulanamadı: ${validation.errorMessage}',
      );
    }

    // 3. Kaynağı ekle
    final added = await addSource(source);
    if (!added) {
      return AddSourceResult(
        success: false,
        error: 'Kaynak eklenemedi (ID zaten mevcut olabilir)',
      );
    }

    return AddSourceResult(
      success: true,
      validationResult: validation,
    );
  }

  /// Kaynak sağlığı özet bilgisi
  Future<SourceHealthSummary> getSourceHealthSummary() async {
    final sources = getAllSources();
    final disabledFeeds = await getDisabledFeeds();
    final lastReport = await getLastHealthReport();

    return SourceHealthSummary(
      totalSources: sources.length,
      activeSources: getActiveSourceCount(),
      disabledFeeds: disabledFeeds.length,
      lastCheckTime: lastReport?.timestamp,
      healthPercentage: lastReport?.healthPercentage,
    );
  }
}

/// Kaynak ekleme sonucu
class AddSourceResult {
  final bool success;
  final String? error;
  final RssFeedValidationResult? validationResult;

  const AddSourceResult({
    required this.success,
    this.error,
    this.validationResult,
  });
}

/// Kaynak sağlığı özet bilgisi
class SourceHealthSummary {
  final int totalSources;
  final int activeSources;
  final int disabledFeeds;
  final DateTime? lastCheckTime;
  final double? healthPercentage;

  const SourceHealthSummary({
    required this.totalSources,
    required this.activeSources,
    required this.disabledFeeds,
    this.lastCheckTime,
    this.healthPercentage,
  });

  bool get isHealthy => (healthPercentage ?? 0) >= 80;
}