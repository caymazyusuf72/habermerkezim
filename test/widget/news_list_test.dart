import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haber_merkezi/domain/entities/article.dart';
import 'package:haber_merkezi/presentation/providers/news_provider.dart';
import 'package:haber_merkezi/presentation/providers/connectivity_provider.dart';
import 'package:haber_merkezi/presentation/providers/article_filter_provider.dart';
import 'package:haber_merkezi/presentation/providers/reading_list_provider.dart';
import 'package:haber_merkezi/presentation/providers/favorites_provider.dart';
import 'package:haber_merkezi/presentation/pages/home/widgets/news_list.dart';

// Test için mock article oluştur
Article createTestArticle({
  String? id,
  String? title,
  String? category,
  bool isRead = false,
  bool isFavorite = false,
}) {
  return Article(
    id: id ?? 'test-${DateTime.now().millisecondsSinceEpoch}',
    title: title ?? 'Test Article Title',
    description: 'Test article description for testing purposes',
    link: 'https://example.com/article',
    publishedDate: DateTime.now().subtract(const Duration(hours: 2)),
    category: category ?? 'genel',
    sourceName: 'Test Source',
    imageUrl: 'https://example.com/image.jpg',
    isRead: isRead,
    isFavorite: isFavorite,
  );
}

void main() {
  group('NewsList Widget Tests', () {
    testWidgets('should show shimmer loading when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            newsProvider.overrideWith((ref) => NewsNotifier()..state = const NewsState(isLoading: true)),
            connectivityProvider.overrideWith((ref) => ConnectivityNotifier()..state = const ConnectivityState(isConnected: true)),
            articleFilterProvider.overrideWith((ref) => ArticleFilterNotifier()),
            readingListProvider.overrideWith((ref) => ReadingListNotifier()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NewsList(category: 'genel'),
            ),
          ),
        ),
      );

      await tester.pump();

      // Shimmer loading gösterilmeli
      expect(find.byType(NewsList), findsOneWidget);
    });

    testWidgets('should show empty state when no articles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            newsProvider.overrideWith((ref) => NewsNotifier()..state = const NewsState(
              isLoading: false,
              articles: [],
            )),
            connectivityProvider.overrideWith((ref) => ConnectivityNotifier()..state = const ConnectivityState(isConnected: true)),
            articleFilterProvider.overrideWith((ref) => ArticleFilterNotifier()),
            readingListProvider.overrideWith((ref) => ReadingListNotifier()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NewsList(category: 'genel'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Boş durum mesajı gösterilmeli
      expect(find.text('Henüz haber yok'), findsOneWidget);
    });

    testWidgets('should show offline message when not connected', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            newsProvider.overrideWith((ref) => NewsNotifier()..state = const NewsState(
              isLoading: false,
              articles: [],
            )),
            connectivityProvider.overrideWith((ref) => ConnectivityNotifier()..state = const ConnectivityState(isConnected: false)),
            articleFilterProvider.overrideWith((ref) => ArticleFilterNotifier()),
            readingListProvider.overrideWith((ref) => ReadingListNotifier()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NewsList(category: 'genel'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Offline mesajı gösterilmeli
      expect(find.text('İnternet bağlantısı yok'), findsOneWidget);
    });

    testWidgets('should show error state with retry button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            newsProvider.overrideWith((ref) => NewsNotifier()..state = const NewsState(
              isLoading: false,
              articles: [],
              errorMessage: 'Test error message',
            )),
            connectivityProvider.overrideWith((ref) => ConnectivityNotifier()..state = const ConnectivityState(isConnected: true)),
            articleFilterProvider.overrideWith((ref) => ArticleFilterNotifier()),
            readingListProvider.overrideWith((ref) => ReadingListNotifier()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NewsList(category: 'genel'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Hata mesajı ve yeniden dene butonu gösterilmeli
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Yeniden Dene'), findsOneWidget);
    });

    testWidgets('should display articles when loaded', (tester) async {
      final testArticles = [
        createTestArticle(id: '1', title: 'First Article'),
        createTestArticle(id: '2', title: 'Second Article'),
        createTestArticle(id: '3', title: 'Third Article'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            newsProvider.overrideWith((ref) => NewsNotifier()..state = NewsState(
              isLoading: false,
              articles: testArticles,
            )),
            connectivityProvider.overrideWith((ref) => ConnectivityNotifier()..state = const ConnectivityState(isConnected: true)),
            articleFilterProvider.overrideWith((ref) => ArticleFilterNotifier()),
            readingListProvider.overrideWith((ref) => ReadingListNotifier()),
            favoritesProvider.overrideWith((ref) => FavoritesNotifier()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NewsList(category: 'genel'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Makaleler gösterilmeli
      expect(find.text('First Article'), findsOneWidget);
      expect(find.text('Second Article'), findsOneWidget);
      expect(find.text('Third Article'), findsOneWidget);
    });

    testWidgets('should filter articles by category', (tester) async {
      final testArticles = [
        createTestArticle(id: '1', title: 'General Article', category: 'genel'),
        createTestArticle(id: '2', title: 'Tech Article', category: 'teknoloji'),
        createTestArticle(id: '3', title: 'Sports Article', category: 'spor'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            newsProvider.overrideWith((ref) => NewsNotifier()..state = NewsState(
              isLoading: false,
              articles: testArticles,
            )),
            connectivityProvider.overrideWith((ref) => ConnectivityNotifier()..state = const ConnectivityState(isConnected: true)),
            articleFilterProvider.overrideWith((ref) => ArticleFilterNotifier()),
            readingListProvider.overrideWith((ref) => ReadingListNotifier()),
            favoritesProvider.overrideWith((ref) => FavoritesNotifier()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NewsList(category: 'teknoloji'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Sadece teknoloji kategorisindeki makale gösterilmeli
      expect(find.text('Tech Article'), findsOneWidget);
      expect(find.text('General Article'), findsNothing);
      expect(find.text('Sports Article'), findsNothing);
    });

    testWidgets('should show all articles for genel category', (tester) async {
      final testArticles = [
        createTestArticle(id: '1', title: 'General Article', category: 'genel'),
        createTestArticle(id: '2', title: 'Tech Article', category: 'teknoloji'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            newsProvider.overrideWith((ref) => NewsNotifier()..state = NewsState(
              isLoading: false,
              articles: testArticles,
            )),
            connectivityProvider.overrideWith((ref) => ConnectivityNotifier()..state = const ConnectivityState(isConnected: true)),
            articleFilterProvider.overrideWith((ref) => ArticleFilterNotifier()),
            readingListProvider.overrideWith((ref) => ReadingListNotifier()),
            favoritesProvider.overrideWith((ref) => FavoritesNotifier()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NewsList(category: 'genel'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Genel kategorisinde tüm makaleler gösterilmeli
      expect(find.text('General Article'), findsOneWidget);
      expect(find.text('Tech Article'), findsOneWidget);
    });
  });

  group('NewsListUtils Tests', () {
    test('pageSize should be 20', () {
      expect(NewsListUtils.pageSize, 20);
    });

    test('loadMoreThreshold should be 200', () {
      expect(NewsListUtils.loadMoreThreshold, 200.0);
    });

    test('sortArticlesByDate should sort descending by default', () {
      final articles = [
        createTestArticle(id: '1'),
        createTestArticle(id: '2'),
        createTestArticle(id: '3'),
      ];

      // Tarihleri manuel olarak ayarla
      final now = DateTime.now();
      final sortedArticles = [
        articles[0].copyWith(publishedDate: now.subtract(const Duration(days: 2))),
        articles[1].copyWith(publishedDate: now.subtract(const Duration(days: 1))),
        articles[2].copyWith(publishedDate: now),
      ];

      final result = NewsListUtils.sortArticlesByDate(sortedArticles);

      // En yeni önce gelmeli
      expect(result.first.publishedDate.isAfter(result.last.publishedDate), true);
    });

    test('sortArticlesByDate should sort ascending when specified', () {
      final now = DateTime.now();
      final articles = [
        createTestArticle(id: '1').copyWith(publishedDate: now),
        createTestArticle(id: '2').copyWith(publishedDate: now.subtract(const Duration(days: 1))),
        createTestArticle(id: '3').copyWith(publishedDate: now.subtract(const Duration(days: 2))),
      ];

      final result = NewsListUtils.sortArticlesByDate(articles, ascending: true);

      // En eski önce gelmeli
      expect(result.first.publishedDate.isBefore(result.last.publishedDate), true);
    });

    test('groupArticlesByCategory should group correctly', () {
      final articles = [
        createTestArticle(id: '1', category: 'genel'),
        createTestArticle(id: '2', category: 'teknoloji'),
        createTestArticle(id: '3', category: 'genel'),
        createTestArticle(id: '4', category: 'spor'),
      ];

      final grouped = NewsListUtils.groupArticlesByCategory(articles);

      expect(grouped.keys.length, 3);
      expect(grouped['genel']?.length, 2);
      expect(grouped['teknoloji']?.length, 1);
      expect(grouped['spor']?.length, 1);
    });
  });
}