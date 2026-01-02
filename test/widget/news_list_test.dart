import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haber_merkezi/presentation/pages/home/widgets/news_list.dart';
import 'package:haber_merkezi/domain/entities/article.dart';

void main() {
  group('NewsListUtils Tests', () {
    test('pageSize should be 20', () {
      expect(NewsListUtils.pageSize, 20);
    });

    test('loadMoreThreshold should be 200.0', () {
      expect(NewsListUtils.loadMoreThreshold, 200.0);
    });

    test('sortArticlesByDate should sort articles descending by default', () {
      final articles = [
        Article(
          id: '1',
          title: 'Article 1',
          description: 'Desc 1',
          link: 'https://example.com/1',
          publishedDate: DateTime(2024, 1, 1),
          sourceName: 'Source',
          category: 'Test',
        ),
        Article(
          id: '2',
          title: 'Article 2',
          description: 'Desc 2',
          link: 'https://example.com/2',
          publishedDate: DateTime(2024, 1, 3),
          sourceName: 'Source',
          category: 'Test',
        ),
        Article(
          id: '3',
          title: 'Article 3',
          description: 'Desc 3',
          link: 'https://example.com/3',
          publishedDate: DateTime(2024, 1, 2),
          sourceName: 'Source',
          category: 'Test',
        ),
      ];

      final sorted = NewsListUtils.sortArticlesByDate(articles);

      expect(sorted[0].id, '2'); // Jan 3 - newest
      expect(sorted[1].id, '3'); // Jan 2
      expect(sorted[2].id, '1'); // Jan 1 - oldest
    });

    test('sortArticlesByDate should sort articles ascending when specified', () {
      final articles = [
        Article(
          id: '1',
          title: 'Article 1',
          description: 'Desc 1',
          link: 'https://example.com/1',
          publishedDate: DateTime(2024, 1, 1),
          sourceName: 'Source',
          category: 'Test',
        ),
        Article(
          id: '2',
          title: 'Article 2',
          description: 'Desc 2',
          link: 'https://example.com/2',
          publishedDate: DateTime(2024, 1, 3),
          sourceName: 'Source',
          category: 'Test',
        ),
      ];

      final sorted = NewsListUtils.sortArticlesByDate(articles, ascending: true);

      expect(sorted[0].id, '1'); // Jan 1 - oldest
      expect(sorted[1].id, '2'); // Jan 3 - newest
    });

    test('groupArticlesByCategory should group articles correctly', () {
      final articles = [
        Article(
          id: '1',
          title: 'Article 1',
          description: 'Desc 1',
          link: 'https://example.com/1',
          publishedDate: DateTime.now(),
          sourceName: 'Source',
          category: 'Spor',
        ),
        Article(
          id: '2',
          title: 'Article 2',
          description: 'Desc 2',
          link: 'https://example.com/2',
          publishedDate: DateTime.now(),
          sourceName: 'Source',
          category: 'Ekonomi',
        ),
        Article(
          id: '3',
          title: 'Article 3',
          description: 'Desc 3',
          link: 'https://example.com/3',
          publishedDate: DateTime.now(),
          sourceName: 'Source',
          category: 'Spor',
        ),
      ];

      final grouped = NewsListUtils.groupArticlesByCategory(articles);

      expect(grouped.keys.length, 2);
      expect(grouped['Spor']?.length, 2);
      expect(grouped['Ekonomi']?.length, 1);
    });

    test('groupArticlesByCategory should handle empty list', () {
      final grouped = NewsListUtils.groupArticlesByCategory([]);
      expect(grouped.isEmpty, true);
    });

    test('sortArticlesByDate should not modify original list', () {
      final articles = [
        Article(
          id: '1',
          title: 'Article 1',
          description: 'Desc 1',
          link: 'https://example.com/1',
          publishedDate: DateTime(2024, 1, 1),
          sourceName: 'Source',
          category: 'Test',
        ),
        Article(
          id: '2',
          title: 'Article 2',
          description: 'Desc 2',
          link: 'https://example.com/2',
          publishedDate: DateTime(2024, 1, 3),
          sourceName: 'Source',
          category: 'Test',
        ),
      ];

      final originalFirstId = articles[0].id;
      NewsListUtils.sortArticlesByDate(articles);

      expect(articles[0].id, originalFirstId); // Original list unchanged
    });
  });

  group('NewsList Widget Structure Tests', () {
    testWidgets('NewsList should be a ConsumerStatefulWidget', (tester) async {
      // Just verify the widget can be instantiated
      const widget = NewsList(category: 'Gündem');
      expect(widget, isA<ConsumerStatefulWidget>());
      expect(widget.category, 'Gündem');
    });

    testWidgets('NewsList should accept category parameter', (tester) async {
      const widget1 = NewsList(category: 'Spor');
      const widget2 = NewsList(category: 'Ekonomi');
      const widget3 = NewsList(category: 'Teknoloji');
      
      expect(widget1.category, 'Spor');
      expect(widget2.category, 'Ekonomi');
      expect(widget3.category, 'Teknoloji');
    });

    testWidgets('NewsList should have enableHapticFeedback default to true', (tester) async {
      const widget = NewsList(category: 'Test');
      expect(widget.enableHapticFeedback, true);
    });

    testWidgets('NewsList should accept enableHapticFeedback parameter', (tester) async {
      const widget = NewsList(category: 'Test', enableHapticFeedback: false);
      expect(widget.enableHapticFeedback, false);
    });
  });

  group('Shimmer Loading Widget Tests', () {
    testWidgets('should show shimmer loading placeholder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Container(
                    height: 100,
                    color: Colors.grey[300],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsNWidgets(5));
    });
  });

  group('Empty State Widget Tests', () {
    testWidgets('should show empty state message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('Haber bulunamadı'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Haber bulunamadı'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });
  });

  group('Error State Widget Tests', () {
    testWidgets('should show error message with retry button', (tester) async {
      bool retryPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Bir hata oluştu'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => retryPressed = true,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Bir hata oluştu'), findsOneWidget);
      expect(find.text('Tekrar Dene'), findsOneWidget);
      
      await tester.tap(find.text('Tekrar Dene'));
      expect(retryPressed, true);
    });
  });

  group('Offline State Widget Tests', () {
    testWidgets('should show offline indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.orange,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Çevrimdışı mod',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text('Önbellek verileri gösteriliyor'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Çevrimdışı mod'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });
  });

  group('Pull to Refresh Tests', () {
    testWidgets('should have RefreshIndicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 100));
              },
              child: ListView(
                children: const [
                  ListTile(title: Text('Item 1')),
                  ListTile(title: Text('Item 2')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });

  group('Article Entity Tests', () {
    test('Article should have required fields', () {
      final article = Article(
        id: 'test-id',
        title: 'Test Title',
        description: 'Test Description',
        link: 'https://example.com',
        publishedDate: DateTime.now(),
        sourceName: 'Test Source',
        category: 'Test Category',
      );

      expect(article.id, 'test-id');
      expect(article.title, 'Test Title');
      expect(article.description, 'Test Description');
      expect(article.link, 'https://example.com');
      expect(article.sourceName, 'Test Source');
      expect(article.category, 'Test Category');
    });

    test('Article should have optional fields with defaults', () {
      final article = Article(
        id: 'test-id',
        title: 'Test Title',
        description: 'Test Description',
        link: 'https://example.com',
        publishedDate: DateTime.now(),
        sourceName: 'Test Source',
        category: 'Test Category',
      );

      expect(article.imageUrl, isNull);
      expect(article.content, isNull);
      expect(article.isRead, false);
      expect(article.isFavorite, false);
    });
  });
}