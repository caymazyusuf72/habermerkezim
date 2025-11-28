import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/presentation/providers/news_provider.dart';
import 'package:haber_merkezi/domain/entities/article.dart';

void main() {
  group('NewsState Tests', () {
    test('NewsState should have default values', () {
      const state = NewsState();

      expect(state.articles, isEmpty);
      expect(state.allArticles, isEmpty);
      expect(state.isLoading, false);
      expect(state.isLoadingMore, false);
      expect(state.hasMore, true);
      expect(state.currentPage, 1);
      expect(state.isEmpty, true);
      expect(state.hasError, false);
    });

    test('NewsState copyWith should update specified fields', () {
      const initialState = NewsState();
      final updated = initialState.copyWith(
        isLoading: true,
        currentPage: 2,
      );

      expect(updated.isLoading, true);
      expect(updated.currentPage, 2);
      expect(updated.articles, initialState.articles); // Other fields unchanged
    });

    test('NewsState isEmpty should return true when no articles and not loading', () {
      const state = NewsState(articles: [], isLoading: false);
      expect(state.isEmpty, true);
    });

    test('NewsState isEmpty should return false when loading', () {
      const state = NewsState(articles: [], isLoading: true);
      expect(state.isEmpty, false);
    });

    test('NewsState hasError should return true when errorMessage is set', () {
      const state = NewsState(errorMessage: 'Test error');
      expect(state.hasError, true);
      expect(state.isError, true);
    });

    test('NewsState hasData should return true when articles exist', () {
      final testArticle = Article(
        id: '1',
        title: 'Test',
        description: 'Test',
        link: 'https://example.com',
        publishedDate: DateTime.now(),
        category: 'genel',
        sourceName: 'Source',
      );

      final state = NewsState(articles: [testArticle]);
      expect(state.hasData, true);
      expect(state.hasArticles, true);
    });

    test('NewsState pageSize should be 20', () {
      expect(NewsState.pageSize, 20);
    });
  });
}

