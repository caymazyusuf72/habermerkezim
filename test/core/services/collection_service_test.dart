import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/services/collection_service.dart';

void main() {
  group('ArticleCollection', () {
    group('constructor ve varsayılan değerler', () {
      test('zorunlu alanlarla oluşturulabilmeli', () {
        // Act
        final collection = ArticleCollection(
          id: 'test-col',
          name: 'Test Koleksiyon',
          createdAt: DateTime(2026, 1, 15),
          updatedAt: DateTime(2026, 1, 15),
        );

        // Assert
        expect(collection.id, 'test-col');
        expect(collection.name, 'Test Koleksiyon');
        expect(collection.description, isNull);
        expect(collection.coverImageUrl, isNull);
        expect(collection.articleIds, isEmpty);
        expect(collection.isDefault, false);
        expect(collection.articleCount, 0);
      });

      test('tüm alanlarla oluşturulabilmeli', () {
        // Act
        final collection = ArticleCollection(
          id: 'full-col',
          name: 'Tam Koleksiyon',
          description: 'Açıklama',
          coverImageUrl: 'https://example.com/cover.jpg',
          createdAt: DateTime(2026, 1, 15),
          updatedAt: DateTime(2026, 1, 16),
          articleIds: ['art1', 'art2', 'art3'],
          isDefault: true,
        );

        // Assert
        expect(collection.description, 'Açıklama');
        expect(collection.coverImageUrl, 'https://example.com/cover.jpg');
        expect(collection.articleIds, hasLength(3));
        expect(collection.isDefault, true);
        expect(collection.articleCount, 3);
      });
    });

    group('copyWith()', () {
      test('belirtilen alanları değiştirmeli', () {
        // Arrange
        final original = ArticleCollection(
          id: 'orig',
          name: 'Orijinal',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );

        // Act
        final modified = original.copyWith(
          name: 'Değiştirilmiş',
          description: 'Yeni açıklama',
        );

        // Assert
        expect(modified.id, 'orig'); // değişmemeli
        expect(modified.name, 'Değiştirilmiş');
        expect(modified.description, 'Yeni açıklama');
      });

      test('belirtilmeyen alanları korumalı', () {
        // Arrange
        final original = ArticleCollection(
          id: 'keep',
          name: 'Korunacak',
          description: 'Eski açıklama',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          articleIds: ['art1'],
          isDefault: true,
        );

        // Act
        final modified = original.copyWith(name: 'Yeni Ad');

        // Assert
        expect(modified.description, 'Eski açıklama');
        expect(modified.articleIds, ['art1']);
        expect(modified.isDefault, true);
      });
    });

    group('toJson()', () {
      test('tüm alanları JSON\'a dönüştürmeli', () {
        // Arrange
        final collection = ArticleCollection(
          id: 'json-test',
          name: 'JSON Test',
          description: 'Test açıklama',
          coverImageUrl: 'https://example.com/cover.jpg',
          createdAt: DateTime(2026, 1, 15, 10, 0),
          updatedAt: DateTime(2026, 1, 16, 12, 0),
          articleIds: ['art1', 'art2'],
          isDefault: false,
        );

        // Act
        final json = collection.toJson();

        // Assert
        expect(json['id'], 'json-test');
        expect(json['name'], 'JSON Test');
        expect(json['description'], 'Test açıklama');
        expect(json['coverImageUrl'], 'https://example.com/cover.jpg');
        expect(json['articleIds'], ['art1', 'art2']);
        expect(json['isDefault'], false);
      });
    });

    group('fromJson()', () {
      test('JSON\'dan doğru şekilde oluşturulmalı', () {
        // Arrange
        final json = {
          'id': 'from-json',
          'name': 'From JSON',
          'description': 'JSON açıklama',
          'coverImageUrl': 'https://example.com/img.jpg',
          'createdAt': '2026-01-15T10:00:00.000',
          'updatedAt': '2026-01-16T12:00:00.000',
          'articleIds': ['art1', 'art2', 'art3'],
          'isDefault': true,
        };

        // Act
        final collection = ArticleCollection.fromJson(json);

        // Assert
        expect(collection.id, 'from-json');
        expect(collection.name, 'From JSON');
        expect(collection.description, 'JSON açıklama');
        expect(collection.articleIds, hasLength(3));
        expect(collection.isDefault, true);
      });

      test('eksik alanlar için varsayılan değerler kullanmalı', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final collection = ArticleCollection.fromJson(json);

        // Assert
        expect(collection.id, '');
        expect(collection.name, '');
        expect(collection.description, isNull);
        expect(collection.articleIds, isEmpty);
        expect(collection.isDefault, false);
      });
    });

    group('toJson() → fromJson() round-trip', () {
      test('serileştirme geri dönüşümlü olmalı', () {
        // Arrange
        final original = ArticleCollection(
          id: 'roundtrip',
          name: 'Round Trip',
          description: 'Test',
          createdAt: DateTime(2026, 3, 1),
          updatedAt: DateTime(2026, 3, 2),
          articleIds: ['a1', 'a2'],
          isDefault: false,
        );

        // Act
        final json = original.toJson();
        final restored = ArticleCollection.fromJson(json);

        // Assert
        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.description, original.description);
        expect(restored.articleIds, original.articleIds);
        expect(restored.isDefault, original.isDefault);
      });
    });

    group('articleCount', () {
      test('articleIds uzunluğunu döndürmeli', () {
        // Arrange
        final collection = ArticleCollection(
          id: 'count-test',
          name: 'Count Test',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          articleIds: ['a1', 'a2', 'a3', 'a4'],
        );

        // Assert
        expect(collection.articleCount, 4);
      });

      test('boş koleksiyon için 0 döndürmeli', () {
        // Arrange
        final collection = ArticleCollection(
          id: 'empty',
          name: 'Boş',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );

        // Assert
        expect(collection.articleCount, 0);
      });
    });
  });

  group('CollectionService - Sabitler', () {
    test('varsayılan koleksiyon ID\'leri tanımlı olmalı', () {
      expect(CollectionService.favoritesCollectionId, 'default_favorites');
      expect(CollectionService.readLaterCollectionId, 'default_read_later');
    });
  });
}
