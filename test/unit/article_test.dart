import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/domain/entities/article.dart';

void main() {
  group('Article Entity Tests', () {
    final testArticle = Article(
      id: 'test-id-1',
      title: 'Test Article Title',
      description: 'Test article description',
      link: 'https://example.com/article',
      publishedDate: DateTime(2025, 1, 15, 10, 30),
      category: 'genel',
      sourceName: 'Test Source',
    );

    test('Article should be created with required fields', () {
      expect(testArticle.id, 'test-id-1');
      expect(testArticle.title, 'Test Article Title');
      expect(testArticle.description, 'Test article description');
      expect(testArticle.category, 'genel');
      expect(testArticle.sourceName, 'Test Source');
    });

    test('Article copyWith should create new instance with updated fields', () {
      final updated = testArticle.copyWith(
        title: 'Updated Title',
        isRead: true,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.isRead, true);
      expect(updated.id, testArticle.id); // Other fields should remain same
    });

    test('Article equality should be based on id', () {
      final article1 = Article(
        id: 'same-id',
        title: 'Title 1',
        description: 'Desc 1',
        link: 'https://example.com/1',
        publishedDate: DateTime.now(),
        category: 'genel',
        sourceName: 'Source 1',
      );

      final article2 = Article(
        id: 'same-id',
        title: 'Title 2',
        description: 'Desc 2',
        link: 'https://example.com/2',
        publishedDate: DateTime.now(),
        category: 'ekonomi',
        sourceName: 'Source 2',
      );

      expect(article1 == article2, true);
      expect(article1.hashCode, article2.hashCode);
    });

    test('Article timeAgo should return correct format', () {
      final now = DateTime.now();
      final recentArticle = Article(
        id: 'recent',
        title: 'Recent',
        description: 'Recent article',
        link: 'https://example.com',
        publishedDate: now.subtract(const Duration(minutes: 5)),
        category: 'genel',
        sourceName: 'Source',
      );

      expect(recentArticle.timeAgo, contains('dakika önce'));
    });

    test('Article truncatedTitle should limit title length', () {
      final longTitle = 'A' * 100;
      final article = testArticle.copyWith(title: longTitle);

      expect(article.truncatedTitle.length, lessThanOrEqualTo(83)); // 80 + '...'
      expect(article.truncatedTitle, endsWith('...'));
    });

    test('Article truncatedDescription should limit description length', () {
      final longDesc = 'B' * 150;
      final article = testArticle.copyWith(description: longDesc);

      expect(article.truncatedDescription.length, lessThanOrEqualTo(123)); // 120 + '...'
      expect(article.truncatedDescription, endsWith('...'));
    });
  });
}

