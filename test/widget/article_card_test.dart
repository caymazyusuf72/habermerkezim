import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haber_merkezi/presentation/pages/home/widgets/article_card.dart';
import 'package:haber_merkezi/domain/entities/article.dart';

void main() {
  group('ArticleCard Widget Tests', () {
    final testArticle = Article(
      id: 'test-1',
      title: 'Test Article Title',
      description: 'Test article description that is long enough',
      link: 'https://example.com/article',
      imageUrl: 'https://example.com/image.jpg',
      publishedDate: DateTime.now(),
      category: 'genel',
      sourceName: 'Test Source',
    );

    testWidgets('ArticleCard should display article title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              child: ArticleCard(
                article: testArticle,
                onTap: () {},
                onFavoriteToggle: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Article Title'), findsOneWidget);
    });

    testWidgets('ArticleCard should display article description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              child: ArticleCard(
                article: testArticle,
                onTap: () {},
                onFavoriteToggle: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('Test article description'), findsOneWidget);
    });

    testWidgets('ArticleCard should call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              child: ArticleCard(
                article: testArticle,
                onTap: () {
                  tapped = true;
                },
                onFavoriteToggle: () {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ArticleCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('ArticleCard should show favorite button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              child: ArticleCard(
                article: testArticle,
                onTap: () {},
                onFavoriteToggle: () {},
              ),
            ),
          ),
        ),
      );

      // Favorite button should be present (IconButton with favorite icon)
      expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
    });
  });
}

