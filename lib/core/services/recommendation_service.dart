import '../../domain/entities/article.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/analytics_service.dart';

/// Öneri servisi - kullanıcı davranış analizi, öneri algoritması
class RecommendationService {
  /// Kullanıcı için önerilen haberleri getir
  /// 
  /// [limit] - Maksimum döndürülecek haber sayısı
  static Future<List<Article>> getRecommendedArticles({int limit = 20}) async {
    try {
      // Cache'den tüm makaleleri al
      final allArticles = HiveService.articlesBox.values.toList();
      
      if (allArticles.isEmpty) {
        return [];
      }
      
      final entities = allArticles.map((model) => model.toEntity()).toList();
      
      // Kullanıcı davranış analizi
      final userPreferences = _analyzeUserBehavior();
      
      // Öneri skorunu hesapla
      final scoredArticles = <_RecommendedArticle>[];
      
      for (final article in entities) {
        double score = 0.0;
        
        // 1. Kategori tercihi (en çok okunan kategoriler)
        if (userPreferences.favoriteCategories.contains(article.category)) {
          score += 10.0;
        }
        
        // 2. Kaynak tercihi (en çok okunan kaynaklar)
        if (userPreferences.favoriteSources.contains(article.sourceName)) {
          score += 5.0;
        }
        
        // 3. Okunmamış haberler (yeni içerik)
        if (!article.isRead) {
          score += 3.0;
        }
        
        // 4. Görsel olanlar (daha çok tıklanır)
        if (article.imageUrl != null && article.imageUrl!.isNotEmpty) {
          score += 2.0;
        }
        
        // 5. Yakın tarihli haberler
        final hoursSincePublished = DateTime.now()
            .difference(article.publishedDate)
            .inHours;
        if (hoursSincePublished < 24) {
          score += 5.0;
        } else if (hoursSincePublished < 48) {
          score += 2.0;
        }
        
        // 6. Favori olmayanlar (yeni içerik keşfet)
        final isFavorite = HiveService.favoritesBox.containsKey(article.id);
        if (!isFavorite) {
          score += 1.0;
        }
        
        scoredArticles.add(_RecommendedArticle(article: article, score: score));
      }
      
      // Skora göre sırala ve limit uygula
      scoredArticles.sort((a, b) => b.score.compareTo(a.score));
      
      return scoredArticles
          .take(limit)
          .map((scored) => scored.article)
          .toList();
    } catch (e) {
      print('💥 Öneri hesaplama hatası: $e');
      return [];
    }
  }
  
  /// Kullanıcı davranışını analiz et
  static _UserPreferences _analyzeUserBehavior() {
    try {
      // Analytics'ten kullanıcı tercihlerini çıkar
      final monthlyAnalytics = AnalyticsService.getLast30DaysAnalytics();
      
      final categoryCounts = <String, int>{};
      final sourceCounts = <String, int>{};
      
      for (final analytics in monthlyAnalytics) {
        // Kategori sayıları
        for (final entry in analytics.categoriesBreakdown.entries) {
          categoryCounts[entry.key] = (categoryCounts[entry.key] ?? 0) + entry.value;
        }
        
        // Kaynak sayıları
        for (final entry in analytics.sourcesBreakdown.entries) {
          sourceCounts[entry.key] = (sourceCounts[entry.key] ?? 0) + entry.value;
        }
      }
      
      // En çok okunan kategoriler (top 3)
      final topCategories = categoryCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final favoriteCategories = topCategories.take(3).map((e) => e.key).toList();
      
      // En çok okunan kaynaklar (top 3)
      final topSources = sourceCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final favoriteSources = topSources.take(3).map((e) => e.key).toList();
      
      return _UserPreferences(
        favoriteCategories: favoriteCategories,
        favoriteSources: favoriteSources,
      );
    } catch (e) {
      return _UserPreferences(favoriteCategories: [], favoriteSources: []);
    }
  }
  
  /// Yeni kaynakları keşfet (henüz okunmamış kaynaklar)
  static List<String> discoverNewSources({int limit = 5}) {
    try {
      final allArticles = HiveService.articlesBox.values.toList();
      final readSources = <String>{};
      
      // Okunan haberlerin kaynaklarını topla
      for (final article in allArticles) {
        if (HiveService.readArticlesBox.containsKey(article.id)) {
          readSources.add(article.sourceName);
        }
      }
      
      // Tüm kaynakları bul
      final allSources = allArticles.map((a) => a.sourceName).toSet();
      
      // Okunmamış kaynakları bul
      final newSources = allSources.difference(readSources).toList();
      
      return newSources.take(limit).toList();
    } catch (e) {
      return [];
    }
  }
}

/// Kullanıcı tercihleri (internal helper class)
class _UserPreferences {
  final List<String> favoriteCategories;
  final List<String> favoriteSources;
  
  _UserPreferences({
    required this.favoriteCategories,
    required this.favoriteSources,
  });
}

/// Öneri skorlanmış makale (internal helper class)
class _RecommendedArticle {
  final Article article;
  final double score;
  
  _RecommendedArticle({
    required this.article,
    required this.score,
  });
}

