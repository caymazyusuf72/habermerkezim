import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/data/models/article_model.dart';
import 'package:haber_merkezi/domain/entities/article.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('ArticleModel', () {
    group('fromJson()', () {
      test('tüm alanları doğru şekilde parse etmeli', () {
        // Arrange
        final json = {
          'id': 'test-id-123',
          'title': 'Test Başlık',
          'description': 'Test açıklama',
          'content': 'Test içerik',
          'link': 'https://example.com/article',
          'imageUrl': 'https://example.com/image.jpg',
          'publishedDate': '2026-01-15T10:30:00.000',
          'category': 'teknoloji',
          'sourceName': 'Test Kaynak',
          'isRead': true,
          'isFavorite': false,
        };

        // Act
        final model = ArticleModel.fromJson(json);

        // Assert
        expect(model.id, 'test-id-123');
        expect(model.title, 'Test Başlık');
        expect(model.description, 'Test açıklama');
        expect(model.content, 'Test içerik');
        expect(model.link, 'https://example.com/article');
        expect(model.imageUrl, 'https://example.com/image.jpg');
        expect(model.publishedDate, DateTime(2026, 1, 15, 10, 30));
        expect(model.category, 'teknoloji');
        expect(model.sourceName, 'Test Kaynak');
        expect(model.isRead, true);
        expect(model.isFavorite, false);
      });

      test('null/eksik alanları varsayılan değerlerle doldurmalı', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final model = ArticleModel.fromJson(json);

        // Assert
        expect(model.id, '');
        expect(model.title, '');
        expect(model.description, '');
        expect(model.content, isNull);
        expect(model.link, '');
        expect(model.imageUrl, isNull);
        expect(model.category, '');
        expect(model.sourceName, '');
        expect(model.isRead, false);
        expect(model.isFavorite, false);
        // publishedDate null olduğunda DateTime.now() kullanılır
        expect(model.publishedDate, isA<DateTime>());
      });

      test('sadece zorunlu alanlar verildiğinde çalışmalı', () {
        // Arrange
        final json = {
          'id': 'minimal-id',
          'title': 'Minimal',
          'link': 'https://example.com',
          'publishedDate': '2026-06-01T00:00:00.000',
        };

        // Act
        final model = ArticleModel.fromJson(json);

        // Assert
        expect(model.id, 'minimal-id');
        expect(model.title, 'Minimal');
        expect(model.description, '');
        expect(model.isRead, false);
        expect(model.isFavorite, false);
      });
    });

    group('toJson()', () {
      test('tüm alanları JSON\'a doğru çevirmeli', () {
        // Arrange
        final model = createTestArticleModel(
          id: 'json-test-id',
          title: 'JSON Test',
          description: 'JSON açıklama',
          content: 'JSON içerik',
          link: 'https://example.com/json',
          imageUrl: 'https://example.com/img.jpg',
          publishedDate: DateTime(2026, 3, 20, 14, 0),
          category: 'spor',
          sourceName: 'Spor Kaynağı',
          isRead: true,
          isFavorite: true,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'json-test-id');
        expect(json['title'], 'JSON Test');
        expect(json['description'], 'JSON açıklama');
        expect(json['content'], 'JSON içerik');
        expect(json['link'], 'https://example.com/json');
        expect(json['imageUrl'], 'https://example.com/img.jpg');
        expect(json['publishedDate'], '2026-03-20T14:00:00.000');
        expect(json['category'], 'spor');
        expect(json['sourceName'], 'Spor Kaynağı');
        expect(json['isRead'], true);
        expect(json['isFavorite'], true);
      });

      test('null alanlar JSON\'da null olmalı', () {
        // Arrange
        final model = ArticleModel(
          id: 'null-test',
          title: 'Null Test',
          description: 'Desc',
          link: 'https://example.com',
          publishedDate: DateTime(2026, 1, 1),
          category: 'genel',
          sourceName: 'Kaynak',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['content'], isNull);
        expect(json['imageUrl'], isNull);
      });
    });

    group('fromJson() → toJson() round-trip', () {
      test('JSON serileştirme geri dönüşümlü olmalı', () {
        // Arrange
        final originalJson = {
          'id': 'roundtrip-id',
          'title': 'Round Trip Test',
          'description': 'Test açıklama',
          'content': 'Test içerik',
          'link': 'https://example.com/roundtrip',
          'imageUrl': 'https://example.com/roundtrip.jpg',
          'publishedDate': '2026-05-10T08:15:00.000',
          'category': 'ekonomi',
          'sourceName': 'Ekonomi Kaynağı',
          'isRead': false,
          'isFavorite': true,
        };

        // Act
        final model = ArticleModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson['id'], originalJson['id']);
        expect(resultJson['title'], originalJson['title']);
        expect(resultJson['description'], originalJson['description']);
        expect(resultJson['content'], originalJson['content']);
        expect(resultJson['link'], originalJson['link']);
        expect(resultJson['imageUrl'], originalJson['imageUrl']);
        expect(resultJson['publishedDate'], originalJson['publishedDate']);
        expect(resultJson['category'], originalJson['category']);
        expect(resultJson['sourceName'], originalJson['sourceName']);
        expect(resultJson['isRead'], originalJson['isRead']);
        expect(resultJson['isFavorite'], originalJson['isFavorite']);
      });
    });

    group('fromRssItem()', () {
      test('RSS item\'ından doğru ArticleModel oluşturmalı', () {
        // Arrange
        final rssItem = {
          'title': 'RSS Haber Başlığı',
          'description': 'RSS haber açıklaması',
          'link': 'https://example.com/rss-article',
          'pubDate': '2026-01-15T10:30:00.000Z',
          'content': 'RSS haber içeriği',
        };

        // Act
        final model = ArticleModel.fromRssItem(
          rssItem: rssItem,
          category: 'teknoloji',
          sourceName: 'RSS Kaynak',
        );

        // Assert
        expect(model.id, isNotEmpty);
        expect(model.title, 'RSS Haber Başlığı');
        expect(model.description, 'RSS haber açıklaması');
        expect(model.link, 'https://example.com/rss-article');
        expect(model.category, 'teknoloji');
        expect(model.sourceName, 'RSS Kaynak');
      });

      test('HTML taglerini temizlemeli', () {
        // Arrange
        final rssItem = {
          'title': '<b>Kalın Başlık</b>',
          'description': '<p>Paragraf <a href="#">link</a></p>',
          'link': 'https://example.com/html-clean',
          'pubDate': '2026-01-15T10:30:00.000Z',
        };

        // Act
        final model = ArticleModel.fromRssItem(
          rssItem: rssItem,
          category: 'genel',
          sourceName: 'Kaynak',
        );

        // Assert
        expect(model.title, 'Kalın Başlık');
        expect(model.description, 'Paragraf link');
      });

      test('HTML entity\'lerini decode etmeli', () {
        // Arrange
        final rssItem = {
          'title': 'Test &amp; Deneme &lt;özel&gt;',
          'description': '&quot;Alıntı&quot; ve &nbsp; boşluk',
          'link': 'https://example.com/entity',
          'pubDate': '2026-01-15T10:30:00.000Z',
        };

        // Act
        final model = ArticleModel.fromRssItem(
          rssItem: rssItem,
          category: 'genel',
          sourceName: 'Kaynak',
        );

        // Assert
        expect(model.title, 'Test & Deneme <özel>');
        expect(model.description, '"Alıntı" ve   boşluk');
      });

      test('mediaContent\'ten görsel URL çıkarmalı', () {
        // Arrange
        final rssItem = {
          'title': 'Görsel Test',
          'description': 'Açıklama',
          'link': 'https://example.com/media',
          'pubDate': '2026-01-15T10:30:00.000Z',
          'mediaContent': 'https://cdn.example.com/image.jpg',
        };

        // Act
        final model = ArticleModel.fromRssItem(
          rssItem: rssItem,
          category: 'genel',
          sourceName: 'Kaynak',
        );

        // Assert
        expect(model.imageUrl, 'https://cdn.example.com/image.jpg');
      });

      test('description içindeki img tag\'inden görsel URL çıkarmalı', () {
        // Arrange
        final rssItem = {
          'title': 'Img Test',
          'description': '<p>Text <img src="https://example.com/photo.png" alt="foto"> more text</p>',
          'link': 'https://example.com/img-test',
          'pubDate': '2026-01-15T10:30:00.000Z',
        };

        // Act
        final model = ArticleModel.fromRssItem(
          rssItem: rssItem,
          category: 'genel',
          sourceName: 'Kaynak',
        );

        // Assert
        expect(model.imageUrl, 'https://example.com/photo.png');
      });

      test('boş RSS item\'ı için varsayılan değerler kullanmalı', () {
        // Arrange
        final rssItem = <String, dynamic>{};

        // Act
        final model = ArticleModel.fromRssItem(
          rssItem: rssItem,
          category: 'genel',
          sourceName: 'Kaynak',
        );

        // Assert
        expect(model.id, isNotEmpty);
        expect(model.title, '');
        expect(model.description, '');
        expect(model.link, '');
        expect(model.imageUrl, isNull);
      });
    });

    group('_generateId() - deterministic UUID', () {
      test('aynı girdi her zaman aynı ID üretmeli', () {
        // Arrange & Act
        final rssItem = {
          'title': 'Aynı Haber',
          'description': 'Açıklama',
          'link': 'https://example.com/same',
          'pubDate': '2026-01-15T10:30:00.000Z',
        };

        final model1 = ArticleModel.fromRssItem(
          rssItem: rssItem,
          category: 'genel',
          sourceName: 'Kaynak',
        );

        final model2 = ArticleModel.fromRssItem(
          rssItem: rssItem,
          category: 'genel',
          sourceName: 'Kaynak',
        );

        // Assert
        expect(model1.id, model2.id);
      });

      test('farklı girdi farklı ID üretmeli', () {
        // Arrange & Act
        final model1 = ArticleModel.fromRssItem(
          rssItem: {
            'title': 'Haber 1',
            'link': 'https://example.com/1',
            'pubDate': '2026-01-15T10:30:00.000Z',
          },
          category: 'genel',
          sourceName: 'Kaynak',
        );

        final model2 = ArticleModel.fromRssItem(
          rssItem: {
            'title': 'Haber 2',
            'link': 'https://example.com/2',
            'pubDate': '2026-01-15T10:30:00.000Z',
          },
          category: 'genel',
          sourceName: 'Kaynak',
        );

        // Assert
        expect(model1.id, isNot(model2.id));
      });

      test('aynı link farklı kaynak = farklı ID', () {
        // Arrange & Act
        final rssItem = {
          'title': 'Aynı Haber',
          'link': 'https://example.com/same',
          'pubDate': '2026-01-15T10:30:00.000Z',
        };

        final model1 = ArticleModel.fromRssItem(
          rssItem: rssItem,
          category: 'genel',
          sourceName: 'Kaynak A',
        );

        final model2 = ArticleModel.fromRssItem(
          rssItem: rssItem,
          category: 'genel',
          sourceName: 'Kaynak B',
        );

        // Assert
        expect(model1.id, isNot(model2.id));
      });
    });

    group('toEntity()', () {
      test('Article entity\'ye doğru dönüşüm yapmalı', () {
        // Arrange
        final model = createTestArticleModel(
          id: 'entity-test',
          title: 'Entity Test',
          category: 'spor',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<Article>());
        expect(entity.id, 'entity-test');
        expect(entity.title, 'Entity Test');
        expect(entity.category, 'spor');
      });
    });

    group('fromEntity()', () {
      test('Article entity\'den doğru model oluşturmalı', () {
        // Arrange
        final entity = createTestArticle(
          id: 'from-entity-test',
          title: 'From Entity',
          category: 'ekonomi',
        );

        // Act
        final model = ArticleModel.fromEntity(entity);

        // Assert
        expect(model.id, 'from-entity-test');
        expect(model.title, 'From Entity');
        expect(model.category, 'ekonomi');
      });

      test('entity → model → entity round-trip tutarlı olmalı', () {
        // Arrange
        final original = createTestArticle(
          id: 'round-trip',
          title: 'Round Trip',
          description: 'Açıklama',
          content: 'İçerik',
          link: 'https://example.com',
          imageUrl: 'https://example.com/img.jpg',
          publishedDate: DateTime(2026, 6, 15),
          category: 'teknoloji',
          sourceName: 'Kaynak',
          isRead: true,
          isFavorite: false,
        );

        // Act
        final result = ArticleModel.fromEntity(original).toEntity();

        // Assert
        expect(result.id, original.id);
        expect(result.title, original.title);
        expect(result.description, original.description);
        expect(result.content, original.content);
        expect(result.link, original.link);
        expect(result.imageUrl, original.imageUrl);
        expect(result.publishedDate, original.publishedDate);
        expect(result.category, original.category);
        expect(result.sourceName, original.sourceName);
        expect(result.isRead, original.isRead);
        expect(result.isFavorite, original.isFavorite);
      });
    });

    group('toString()', () {
      test('doğru string temsili döndürmeli', () {
        // Arrange
        final model = createTestArticleModel(
          id: 'str-test',
          title: 'String Test',
          category: 'genel',
        );

        // Act
        final result = model.toString();

        // Assert
        expect(result, contains('str-test'));
        expect(result, contains('String Test'));
        expect(result, contains('genel'));
      });
    });
  });
}