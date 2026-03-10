import 'package:flutter/foundation.dart';
import '../../../domain/entities/article.dart';
import '../recommendation_service.dart';
import '../ml_recommendation_service.dart';
import '../interest_matching_service.dart';
import '../related_articles_service.dart';
import 'article_scoring.dart';

/// Öneri Modülü - 4 servisi tek bir facade altında birleştirir
///
/// Birleştirilen servisler:
/// - RecommendationService (basit öneri)
/// - MLRecommendationService (gelişmiş ML öneri)
/// - InterestMatchingService (ilgi alanı eşleştirme)
/// - RelatedArticlesService (ilgili haberler)
///
/// Kullanım:
/// ```dart
/// final module = RecommendationModule();
/// final recommended = await module.getRecommendations(limit: 20);
/// final related = await module.findRelatedArticles(article);
/// final filtered = module.filterByInterests(articles, interestIds);
/// ```
class RecommendationModule {
  static final RecommendationModule _instance = RecommendationModule._internal();
  factory RecommendationModule() => _instance;
  RecommendationModule._internal();

  final MLRecommendationService _mlService = MLRecommendationService();

  // ========================================================================
  // ÖNERI METODLARI
  // ========================================================================

  /// Basit öneri algoritması ile önerilen haberleri getir
  Future<List<Article>> getBasicRecommendations({int limit = 20}) async {
    return await RecommendationService.getRecommendedArticles(limit: limit);
  }

  /// Gelişmiş ML tabanlı öneriler (hibrit: içerik + davranış + güncellik + kalite)
  Future<List<Article>> getAdvancedRecommendations({
    int limit = 20,
    double diversityFactor = 0.3,
  }) async {
    return await _mlService.getAdvancedRecommendations(
      limit: limit,
      diversityFactor: diversityFactor,
    );
  }

  /// Otomatik seçim: Yeterli veri varsa ML, yoksa basit öneri
  Future<List<Article>> getRecommendations({int limit = 20}) async {
    try {
      final advanced = await getAdvancedRecommendations(limit: limit);
      if (advanced.isNotEmpty) return advanced;
    } catch (e) {
      debugPrint('⚠️ ML öneri hatası, basit öneriye düşülüyor: $e');
    }
    return await getBasicRecommendations(limit: limit);
  }

  // ========================================================================
  // İLGİ ALANI EŞLEŞTİRME
  // ========================================================================

  /// Haberleri ilgi alanlarına göre filtrele
  List<Article> filterByInterests(
    List<Article> articles,
    List<String> interestTagIds, {
    double threshold = 30.0,
  }) {
    return InterestMatchingService.filterArticlesByInterest(
      articles,
      interestTagIds,
      threshold: threshold,
    );
  }

  /// Haberleri ilgi alanlarına göre sırala (en uygun önce)
  List<Article> sortByInterests(
    List<Article> articles,
    List<String> interestTagIds,
  ) {
    return InterestMatchingService.sortArticlesByInterest(articles, interestTagIds);
  }

  /// Bir haberin ilgi alanlarına uygun olup olmadığını kontrol et
  bool isArticleRelevant(
    Article article,
    List<String> interestTagIds, {
    double threshold = 30.0,
  }) {
    return InterestMatchingService.isArticleRelevant(
      article,
      interestTagIds,
      threshold: threshold,
    );
  }

  // ========================================================================
  // İLGİLİ HABERLER
  // ========================================================================

  /// Bir habere benzer/ilgili haberleri bul
  Future<List<Article>> findRelatedArticles(
    Article currentArticle, {
    int limit = 5,
  }) async {
    return await RelatedArticlesService.findRelatedArticles(
      currentArticle,
      limit: limit,
    );
  }

  // ========================================================================
  // KEŞİF
  // ========================================================================

  /// Yeni kaynaklar keşfet (henüz okunmamış kaynaklar)
  List<String> discoverNewSources({int limit = 5}) {
    return RecommendationService.discoverNewSources(limit: limit);
  }
}