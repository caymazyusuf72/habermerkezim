import '../../domain/entities/article.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/analytics_service.dart';

import 'package:flutter/foundation.dart';

/// Trending servisi - trend hesaplama (okunma/paylaşım sayısı, zaman bazlı)
class TrendingService {
  /// Trend haberleri hesapla
  ///
  /// [timeRange] - Zaman aralığı (today, week, month)
  /// [limit] - Maksimum döndürülecek haber sayısı
  static Future<List<Article>> getTrendingArticles({
    String timeRange = 'week',
    int limit = 20,
  }) async {
    try {
      // Cache'den tüm makaleleri al
      final allArticles = HiveService.articlesBox.values.toList();

      if (allArticles.isEmpty) {
        return [];
      }

      // Zaman aralığını belirle
      final now = DateTime.now();
      DateTime startDate;

      switch (timeRange) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = now.subtract(const Duration(days: 30));
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      // Zaman aralığına göre filtrele
      final recentArticles = allArticles
          .where((model) => model.publishedDate.isAfter(startDate))
          .map((model) => model.toEntity())
          .toList();

      if (recentArticles.isEmpty) {
        return [];
      }

      // Trend skorunu hesapla
      final scoredArticles = <_TrendingArticle>[];

      for (final article in recentArticles) {
        double score = 0.0;

        // 1. Okunma sayısı (analytics'ten)
        final readCount = _getReadCount(article.id);
        score += readCount * 2.0;

        // 2. Favori sayısı (Hive'dan)
        final isFavorite = HiveService.favoritesBox.containsKey(article.id);
        if (isFavorite) {
          score += 5.0;
        }

        // 3. Zaman faktörü (daha yeni haberler daha yüksek skor)
        final hoursSincePublished = now
            .difference(article.publishedDate)
            .inHours;
        if (hoursSincePublished < 24) {
          score += 10.0; // Son 24 saat
        } else if (hoursSincePublished < 48) {
          score += 5.0; // Son 48 saat
        } else if (hoursSincePublished < 72) {
          score += 2.0; // Son 72 saat
        }

        // 4. Kategori popülerliği
        final categoryPopularity = _getCategoryPopularity(article.category);
        score += categoryPopularity * 1.5;

        // 5. Görsel olanlar (daha çok tıklanır)
        if (article.imageUrl != null && article.imageUrl!.isNotEmpty) {
          score += 1.0;
        }

        scoredArticles.add(_TrendingArticle(article: article, score: score));
      }

      // Skora göre sırala ve limit uygula
      scoredArticles.sort((a, b) => b.score.compareTo(a.score));

      return scoredArticles
          .take(limit)
          .map((scored) => scored.article)
          .toList();
    } catch (e) {
      debugPrint('💥 Trend haber hesaplama hatası: $e');
      return [];
    }
  }

  /// Makale okunma sayısını al (analytics'ten)
  static int _getReadCount(String articleId) {
    try {
      // Analytics service'ten okunma sayısını al
      // Şimdilik basit bir hesaplama
      final readArticles = HiveService.readArticlesBox;
      return readArticles.containsKey(articleId) ? 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Kategori popülerliğini hesapla
  static double _getCategoryPopularity(String category) {
    try {
      // Analytics'ten kategori bazlı okunma sayısını al
      final monthlyAnalytics = AnalyticsService.getLast30DaysAnalytics();
      int categoryReadCount = 0;

      for (final analytics in monthlyAnalytics) {
        categoryReadCount += analytics.categoriesRead[category] ?? 0;
      }

      // Normalize et (0-10 arası)
      return categoryReadCount.clamp(0, 100).toDouble() / 10.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// En popüler kategorileri getir
  static List<String> getTopCategories({int limit = 5}) {
    try {
      final monthlyAnalytics = AnalyticsService.getLast30DaysAnalytics();
      final categoryCounts = <String, int>{};

      for (final analytics in monthlyAnalytics) {
        for (final entry in analytics.categoriesRead.entries) {
          categoryCounts[entry.key] =
              (categoryCounts[entry.key] ?? 0) + entry.value;
        }
      }

      final sortedCategories = categoryCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedCategories.take(limit).map((e) => e.key).toList();
    } catch (e) {
      return [];
    }
  }
}

/// Trend skorlanmış makale (internal helper class)
class _TrendingArticle {
  final Article article;
  final double score;

  _TrendingArticle({required this.article, required this.score});
}
