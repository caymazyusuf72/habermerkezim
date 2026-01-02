import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/services/article_popularity_service.dart';
import 'package:haber_merkezi/domain/entities/article.dart';

void main() {
  group('ArticlePopularity Tests', () {
    test('ArticlePopularity should be created with default values', () {
      final popularity = ArticlePopularity(
        articleId: 'test-id',
        title: 'Test Title',
        sourceName: 'Test Source',
        category: 'genel',
      );

      expect(popularity.articleId, 'test-id');
      expect(popularity.title, 'Test Title');
      expect(popularity.sourceName, 'Test Source');
      expect(popularity.category, 'genel');
      expect(popularity.viewCount, 0);
      expect(popularity.shareCount, 0);
      expect(popularity.favoriteCount, 0);
      expect(popularity.imageUrl, isNull);
      expect(popularity.link, isNull);
    });

    test('ArticlePopularity should calculate popularity score correctly', () {
      final popularity = ArticlePopularity(
        articleId: 'test-id',
        title: 'Test Title',
        sourceName: 'Test Source',
        category: 'genel',
        viewCount: 10,
        shareCount: 5,
        favoriteCount: 3,
      );

      // Score = viewCount * 1 + shareCount * 3 + favoriteCount * 2
      // Score = 10 * 1 + 5 * 3 + 3 * 2 = 10 + 15 + 6 = 31
      expect(popularity.popularityScore, 31);
    });

    test('ArticlePopularity copyWith should update specified fields', () {
      final original = ArticlePopularity(
        articleId: 'test-id',
        title: 'Test Title',
        sourceName: 'Test Source',
        category: 'genel',
        viewCount: 5,
      );

      final updated = original.copyWith(
        viewCount: 10,
        shareCount: 2,
      );

      expect(updated.articleId, 'test-id'); // Unchanged
      expect(updated.viewCount, 10); // Updated
      expect(updated.shareCount, 2); // Updated
      expect(updated.favoriteCount, 0); // Unchanged (default)
    });

    test('ArticlePopularity fromArticle should create from Article entity', () {
      final article = Article(
        id: 'article-123',
        title: 'Article Title',
        description: 'Article description',
        link: 'https://example.com/article',
        publishedDate: DateTime.now(),
        category: 'teknoloji',
        sourceName: 'Tech News',
        imageUrl: 'https://example.com/image.jpg',
      );

      final popularity = ArticlePopularity.fromArticle(article);

      expect(popularity.articleId, 'article-123');
      expect(popularity.title, 'Article Title');
      expect(popularity.sourceName, 'Tech News');
      expect(popularity.category, 'teknoloji');
      expect(popularity.imageUrl, 'https://example.com/image.jpg');
      expect(popularity.link, 'https://example.com/article');
      expect(popularity.viewCount, 0);
      expect(popularity.shareCount, 0);
      expect(popularity.favoriteCount, 0);
    });

    test('ArticlePopularity toJson and fromJson should work correctly', () {
      final original = ArticlePopularity(
        articleId: 'test-id',
        title: 'Test Title',
        sourceName: 'Test Source',
        category: 'genel',
        viewCount: 10,
        shareCount: 5,
        favoriteCount: 3,
        imageUrl: 'https://example.com/image.jpg',
        link: 'https://example.com/article',
        lastViewedAt: DateTime(2025, 1, 15, 10, 30),
        firstViewedAt: DateTime(2025, 1, 10, 8, 0),
      );

      final json = original.toJson();
      final restored = ArticlePopularity.fromJson(json);

      expect(restored.articleId, original.articleId);
      expect(restored.title, original.title);
      expect(restored.sourceName, original.sourceName);
      expect(restored.category, original.category);
      expect(restored.viewCount, original.viewCount);
      expect(restored.shareCount, original.shareCount);
      expect(restored.favoriteCount, original.favoriteCount);
      expect(restored.imageUrl, original.imageUrl);
      expect(restored.link, original.link);
      expect(restored.popularityScore, original.popularityScore);
    });
  });

  group('PopularTimeRange Tests', () {
    test('PopularTimeRange enum should have correct values', () {
      expect(PopularTimeRange.values.length, 4);
      expect(PopularTimeRange.values.contains(PopularTimeRange.today), true);
      expect(PopularTimeRange.values.contains(PopularTimeRange.thisWeek), true);
      expect(PopularTimeRange.values.contains(PopularTimeRange.thisMonth), true);
      expect(PopularTimeRange.values.contains(PopularTimeRange.allTime), true);
    });

    test('PopularTimeRange displayName should return correct Turkish names', () {
      expect(PopularTimeRange.today.displayName, 'Bugün');
      expect(PopularTimeRange.thisWeek.displayName, 'Bu Hafta');
      expect(PopularTimeRange.thisMonth.displayName, 'Bu Ay');
      expect(PopularTimeRange.allTime.displayName, 'Tüm Zamanlar');
    });

    test('PopularTimeRange duration should return correct Duration', () {
      expect(PopularTimeRange.today.duration, const Duration(days: 1));
      expect(PopularTimeRange.thisWeek.duration, const Duration(days: 7));
      expect(PopularTimeRange.thisMonth.duration, const Duration(days: 30));
      expect(PopularTimeRange.allTime.duration, const Duration(days: 365 * 10));
    });
  });

  group('Popularity Score Calculation Tests', () {
    test('View only should give score of viewCount', () {
      final popularity = ArticlePopularity(
        articleId: 'test',
        title: 'Test',
        sourceName: 'Source',
        category: 'genel',
        viewCount: 100,
        shareCount: 0,
        favoriteCount: 0,
      );

      expect(popularity.popularityScore, 100);
    });

    test('Share should give 3x weight', () {
      final popularity = ArticlePopularity(
        articleId: 'test',
        title: 'Test',
        sourceName: 'Source',
        category: 'genel',
        viewCount: 0,
        shareCount: 10,
        favoriteCount: 0,
      );

      expect(popularity.popularityScore, 30); // 10 * 3
    });

    test('Favorite should give 2x weight', () {
      final popularity = ArticlePopularity(
        articleId: 'test',
        title: 'Test',
        sourceName: 'Source',
        category: 'genel',
        viewCount: 0,
        shareCount: 0,
        favoriteCount: 10,
      );

      expect(popularity.popularityScore, 20); // 10 * 2
    });

    test('Combined actions should calculate correctly', () {
      final popularity = ArticlePopularity(
        articleId: 'test',
        title: 'Test',
        sourceName: 'Source',
        category: 'genel',
        viewCount: 50,   // 50 * 1 = 50
        shareCount: 20,  // 20 * 3 = 60
        favoriteCount: 15, // 15 * 2 = 30
      );

      expect(popularity.popularityScore, 140); // 50 + 60 + 30
    });
  });
}