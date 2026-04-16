import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/data/models/article_model.dart';
import 'package:haber_merkezi/domain/entities/article.dart';
import 'package:haber_merkezi/domain/entities/category.dart';

/// Test için ArticleModel oluşturur
ArticleModel createTestArticleModel({
  String? id,
  String? title,
  String? description,
  String? content,
  String? link,
  String? imageUrl,
  DateTime? publishedDate,
  String? category,
  String? sourceName,
  bool isRead = false,
  bool isFavorite = false,
}) {
  final now = DateTime(2026, 1, 15, 10, 30);
  return ArticleModel(
    id: id ?? 'test-article-${DateTime.now().microsecondsSinceEpoch}',
    title: title ?? 'Test Haber Başlığı',
    description: description ?? 'Test haber açıklaması içeriği burada yer alır.',
    content: content ?? 'Test haber içeriği detaylı açıklama.',
    link: link ?? 'https://example.com/test-article',
    imageUrl: imageUrl ?? 'https://example.com/images/test.jpg',
    publishedDate: publishedDate ?? now,
    category: category ?? 'teknoloji',
    sourceName: sourceName ?? 'Test Kaynak',
    isRead: isRead,
    isFavorite: isFavorite,
  );
}

/// Test için Article entity oluşturur
Article createTestArticle({
  String? id,
  String? title,
  String? description,
  String? content,
  String? link,
  String? imageUrl,
  DateTime? publishedDate,
  String? category,
  String? sourceName,
  bool isRead = false,
  bool isFavorite = false,
}) {
  final now = DateTime(2026, 1, 15, 10, 30);
  return Article(
    id: id ?? 'test-article-${DateTime.now().microsecondsSinceEpoch}',
    title: title ?? 'Test Haber Başlığı',
    description: description ?? 'Test haber açıklaması içeriği burada yer alır.',
    content: content ?? 'Test haber içeriği detaylı açıklama.',
    link: link ?? 'https://example.com/test-article',
    imageUrl: imageUrl ?? 'https://example.com/images/test.jpg',
    publishedDate: publishedDate ?? now,
    category: category ?? 'teknoloji',
    sourceName: sourceName ?? 'Test Kaynak',
    isRead: isRead,
    isFavorite: isFavorite,
  );
}

/// Birden fazla test ArticleModel listesi oluşturur
List<ArticleModel> createTestArticleModelList(int count) {
  return List.generate(
    count,
    (index) => createTestArticleModel(
      id: 'test-article-$index',
      title: 'Test Haber $index',
      description: 'Açıklama $index',
      link: 'https://example.com/article-$index',
      category: ['teknoloji', 'spor', 'ekonomi', 'sağlık'][index % 4],
      sourceName: 'Kaynak ${index % 3}',
      publishedDate: DateTime(2026, 1, 15).subtract(Duration(hours: index)),
    ),
  );
}

/// Birden fazla test Article listesi oluşturur
List<Article> createTestArticleList(int count) {
  return List.generate(
    count,
    (index) => createTestArticle(
      id: 'test-article-$index',
      title: 'Test Haber $index',
      description: 'Açıklama $index',
      link: 'https://example.com/article-$index',
      category: ['teknoloji', 'spor', 'ekonomi', 'sağlık'][index % 4],
      sourceName: 'Kaynak ${index % 3}',
      publishedDate: DateTime(2026, 1, 15).subtract(Duration(hours: index)),
    ),
  );
}

/// Test için Category oluşturur
Category createTestCategory({
  String? id,
  String? name,
  String? displayName,
  String? iconName,
  String? color,
  bool isActive = true,
  int articleCount = 0,
}) {
  return Category(
    id: id ?? 'test-category',
    name: name ?? 'test',
    displayName: displayName ?? 'Test Kategori',
    iconName: iconName ?? 'category',
    color: color ?? '#FF5722',
    isActive: isActive,
    articleCount: articleCount,
  );
}

/// Birden fazla test Category listesi oluşturur
List<Category> createTestCategoryList(int count) {
  final colors = ['#F44336', '#2196F3', '#4CAF50', '#9C27B0', '#FF9800'];
  return List.generate(
    count,
    (index) => createTestCategory(
      id: 'category-$index',
      name: 'kategori_$index',
      displayName: 'Kategori $index',
      color: colors[index % colors.length],
      articleCount: (index + 1) * 5,
    ),
  );
}

/// MaterialApp wrapper ile widget test - widget'ı MaterialApp içinde pump eder
Future<void> pumpApp(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: widget),
    ),
  );
}

/// MaterialApp wrapper (tema destekli) ile widget test
Future<void> pumpAppWithTheme(
  WidgetTester tester,
  Widget widget, {
  ThemeData? theme,
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ??
          ThemeData(
            brightness: brightness,
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
          ),
      home: Scaffold(body: widget),
    ),
  );
}