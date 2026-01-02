import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/services/article_popularity_service.dart';

void main() {
  group('ArticlePopularity Tests', () {
    test('should create ArticlePopularity with required fields', () {
      final now = DateTime.now();
      final popularity = ArticlePopularity(
        articleId: 'test-123',
        title: 'Test Article',
        sourceName: 'Test Source',
        category: 'Gündem',
        lastViewed: now,
        firstViewed: now,
      );

      expect(popularity.articleId, 'test-123');
      expect(popularity.title, 'Test Article');
      expect(popularity.sourceName, 'Test Source');
      expect(popularity.category, 'Gündem');
      expect(popularity.viewCount, 0);
      expect(popularity.shareCount, 0);
      expect(popularity.favoriteCount, 0);
    });

    test('should calculate popularity score correctly', () {
      final now = DateTime.now();
      final popularity = ArticlePopularity(
        articleId: 'test-123',
        title: 'Test Article',
        sourceName: 'Test Source',
        category: 'Gündem',
        viewCount: 10,
        shareCount: 5,
        favoriteCount: 3,
        lastViewed: now,
        firstViewed: now,
      );

      // Base score: 10*1 + 5*3 + 3*2 = 10 + 15 + 6 = 31
      // Time factor depends on lastViewed (recent = 1.5x bonus)
      // Expected: 31 * 1.5 = 46.5
      expect(popularity.popularityScore, greaterThan(0));
      expect(popularity.popularityScore, closeTo(46.5, 1.0));
    });

    test('should copy with new values', () {
      final now = DateTime.now();
      final original = ArticlePopularity(
        articleId: 'test-123',
        title: 'Test Article',
        sourceName: 'Test Source',
        category: 'Gündem',
        viewCount: 5,
        lastViewed: now,
        firstViewed: now,
      );

      final updated = original.copyWith(
        viewCount: 10,
        shareCount: 2,
      );

      expect(updated.articleId, 'test-123');
      expect(updated.viewCount, 10);
      expect(updated.shareCount, 2);
      expect(original.viewCount, 5); // Original unchanged
    });

    test('should serialize to and from Map', () {
      final now = DateTime.now();
      final popularity = ArticlePopularity(
        articleId: 'test-789',
        title: 'Map Test',
        sourceName: 'Source',
        category: 'Teknoloji',
        viewCount: 15,
        shareCount: 3,
        favoriteCount: 7,
        imageUrl: 'https://example.com/image.jpg',
        lastViewed: now,
        firstViewed: now,
      );

      final map = popularity.toMap();
      final restored = ArticlePopularity.fromMap(map);

      expect(restored.articleId, popularity.articleId);
      expect(restored.title, popularity.title);
      expect(restored.viewCount, popularity.viewCount);
      expect(restored.shareCount, popularity.shareCount);
      expect(restored.favoriteCount, popularity.favoriteCount);
      expect(restored.imageUrl, popularity.imageUrl);
    });
  });

  group('ArticlePopularity Edge Cases', () {
    test('should handle zero counts', () {
      final now = DateTime.now();
      final popularity = ArticlePopularity(
        articleId: 'zero-test',
        title: 'Zero Test',
        sourceName: 'Source',
        category: 'Test',
        viewCount: 0,
        shareCount: 0,
        favoriteCount: 0,
        lastViewed: now,
        firstViewed: now,
      );

      // Zero base score with time bonus = 0
      expect(popularity.popularityScore, 0);
    });

    test('should handle large counts', () {
      final now = DateTime.now();
      final popularity = ArticlePopularity(
        articleId: 'large-test',
        title: 'Large Test',
        sourceName: 'Source',
        category: 'Test',
        viewCount: 1000000,
        shareCount: 500000,
        favoriteCount: 250000,
        lastViewed: now,
        firstViewed: now,
      );

      expect(popularity.popularityScore, greaterThan(0));
      expect(popularity.popularityScore.isFinite, true);
    });

    test('should handle null imageUrl', () {
      final now = DateTime.now();
      final popularity = ArticlePopularity(
        articleId: 'null-image',
        title: 'No Image',
        sourceName: 'Source',
        category: 'Test',
        imageUrl: null,
        lastViewed: now,
        firstViewed: now,
      );

      expect(popularity.imageUrl, isNull);
    });

    test('should detect trending articles', () {
      final now = DateTime.now();
      final trending = ArticlePopularity(
        articleId: 'trending',
        title: 'Trending Article',
        sourceName: 'Source',
        category: 'Test',
        viewCount: 5,
        lastViewed: now,
        firstViewed: now,
      );

      final notTrending = ArticlePopularity(
        articleId: 'not-trending',
        title: 'Not Trending',
        sourceName: 'Source',
        category: 'Test',
        viewCount: 1,
        lastViewed: now,
        firstViewed: now,
      );

      expect(trending.isTrending, true);
      expect(notTrending.isTrending, false);
    });

    test('should apply time decay for old articles', () {
      final now = DateTime.now();
      final oldDate = now.subtract(const Duration(days: 10));
      
      final recentArticle = ArticlePopularity(
        articleId: 'recent',
        title: 'Recent',
        sourceName: 'Source',
        category: 'Test',
        viewCount: 10,
        lastViewed: now,
        firstViewed: now,
      );

      final oldArticle = ArticlePopularity(
        articleId: 'old',
        title: 'Old',
        sourceName: 'Source',
        category: 'Test',
        viewCount: 10,
        lastViewed: oldDate,
        firstViewed: oldDate,
      );

      // Recent article should have higher score due to time bonus
      expect(recentArticle.popularityScore, greaterThan(oldArticle.popularityScore));
    });
  });
}