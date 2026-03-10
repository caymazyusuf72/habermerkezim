import 'package:flutter/foundation.dart';
import '../../../domain/entities/article.dart';
import '../trending_service.dart';
import '../breaking_news_service.dart';
import '../article_popularity_service.dart';

/// Makale Keşif Modülü - Popülerlik, trend ve son dakika servislerini birleştirir
///
/// Birleştirilen servisler:
/// - TrendingService (trend haberleri)
/// - BreakingNewsService (son dakika algılama)
/// - ArticlePopularityService (popülerlik skorlama)
///
/// Kullanım:
/// ```dart
/// final module = ArticleDiscoveryModule();
/// final trending = await module.getTrendingArticles();
/// final breaking = module.filterBreakingNews(articles);
/// await module.recordArticleView(articleId: id, ...);
/// ```
class ArticleDiscoveryModule {
  static final ArticleDiscoveryModule _instance = ArticleDiscoveryModule._internal();
  factory ArticleDiscoveryModule() => _instance;
  ArticleDiscoveryModule._internal();

  final BreakingNewsService _breakingService = BreakingNewsService();

  // ========================================================================
  // TREND HABERLER
  // ========================================================================

  /// Trend haberleri getir
  Future<List<Article>> getTrendingArticles({
    String timeRange = 'week',
    int limit = 20,
  }) async {
    return await TrendingService.getTrendingArticles(
      timeRange: timeRange,
      limit: limit,
    );
  }

  /// Bugünün trend haberleri
  Future<List<Article>> getTodayTrending({int limit = 10}) async {
    return await getTrendingArticles(timeRange: 'today', limit: limit);
  }

  /// Bu haftanın trend haberleri
  Future<List<Article>> getWeeklyTrending({int limit = 20}) async {
    return await getTrendingArticles(timeRange: 'week', limit: limit);
  }

  /// En popüler kategorileri getir
  List<String> getTopCategories({int limit = 5}) {
    return TrendingService.getTopCategories(limit: limit);
  }

  // ========================================================================
  // SON DAKİKA
  // ========================================================================

  /// Haber son dakika mı kontrol et
  bool isBreakingNews(Article article) {
    return _breakingService.isBreakingNews(article);
  }

  /// Haberler listesinden son dakika haberlerini filtrele
  List<Article> filterBreakingNews(List<Article> articles) {
    return _breakingService.filterBreakingNews(articles);
  }

  /// Son dakika haber öncelik skoru hesapla (0-100)
  int calculateBreakingPriority(Article article) {
    return _breakingService.calculatePriority(article);
  }

  // ========================================================================
  // POPÜLERLİK TAKİBİ
  // ========================================================================

  /// Makale görüntüleme kaydet
  Future<bool> recordArticleView({
    required String articleId,
    required String title,
    String? imageUrl,
    required String sourceName,
    required String category,
  }) async {
    return await ArticlePopularityService.recordView(
      articleId: articleId,
      title: title,
      imageUrl: imageUrl,
      sourceName: sourceName,
      category: category,
    );
  }

  /// Makale paylaşım kaydet
  Future<bool> recordArticleShare(String articleId) async {
    return await ArticlePopularityService.recordShare(articleId);
  }

  /// Makale favori kaydet
  Future<bool> recordArticleFavorite(String articleId) async {
    return await ArticlePopularityService.recordFavorite(articleId);
  }

  /// En popüler makaleleri getir
  List<ArticlePopularity> getPopularArticles({
    int limit = 20,
    String? category,
    Duration? timeRange,
  }) {
    return ArticlePopularityService.getPopularArticles(
      limit: limit,
      category: category,
      timeRange: timeRange,
    );
  }

  /// Haftalık popüler makaleler
  List<ArticlePopularity> getWeeklyPopular({int limit = 20}) {
    return ArticlePopularityService.getWeeklyPopular(limit: limit);
  }

  /// Toplam görüntülenme sayısı
  int getTotalViews() {
    return ArticlePopularityService.getTotalViews();
  }

  /// Eski popülerlik verilerini temizle
  Future<int> cleanupOldData({int daysOld = 30}) async {
    return await ArticlePopularityService.cleanupOldData(daysOld: daysOld);
  }

  // ========================================================================
  // BİRLEŞİK SORGULAR
  // ========================================================================

  /// Keşif sayfası için birleşik veri: trending + breaking + popüler
  Future<DiscoveryData> getDiscoveryData() async {
    try {
      final trending = await getTodayTrending(limit: 5);
      final popular = getWeeklyPopular(limit: 10);
      final topCategories = getTopCategories(limit: 5);

      return DiscoveryData(
        trendingArticles: trending,
        popularArticles: popular,
        topCategories: topCategories,
      );
    } catch (e) {
      debugPrint('⚠️ Discovery data hatası: $e');
      return DiscoveryData.empty();
    }
  }
}

/// Keşif sayfası birleşik veri modeli
class DiscoveryData {
  final List<Article> trendingArticles;
  final List<ArticlePopularity> popularArticles;
  final List<String> topCategories;

  const DiscoveryData({
    required this.trendingArticles,
    required this.popularArticles,
    required this.topCategories,
  });

  factory DiscoveryData.empty() => const DiscoveryData(
    trendingArticles: [],
    popularArticles: [],
    topCategories: [],
  );

  bool get isEmpty => trendingArticles.isEmpty && popularArticles.isEmpty;
}