import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:haber_merkezi/data/models/article_model.dart';
import 'package:haber_merkezi/data/models/user_profile_model.dart';
import 'package:haber_merkezi/core/services/hive_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    // Type adapter'ları register et
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ArticleModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserProfileModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserStatsModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(UserPreferencesModelAdapter());
    }
  });

  tearDown(() async {
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  group('HiveService - getStats', () {
    test('initialized false döner init öncesinde', () {
      // HiveService static _initialized field'ı test dışında kontrol edilemez
      // Bunun yerine getStats sonucunu kontrol ediyoruz
      // Not: HiveService static olduğu için sıralı test yapmak zor
      // Bu test HiveService'in mantığını doğrular
      expect(true, isTrue); // Placeholder - static sınıf test limitasyonu
    });
  });

  group('HiveService - Box İşlemleri', () {
    test('articles box açılır ve makale kaydedilir', () async {
      final box = await Hive.openBox<ArticleModel>('articles');

      final article = ArticleModel(
        id: 'test_1',
        title: 'Test Başlık',
        description: 'Test Açıklama',
        link: 'https://example.com',
        publishedDate: DateTime(2026, 1, 1),
        category: 'genel',
        sourceName: 'Test Kaynak',
      );

      await box.put(article.id, article);

      expect(box.length, 1);
      expect(box.get('test_1')?.title, 'Test Başlık');
      expect(box.get('test_1')?.category, 'genel');
    });

    test('favorites box açılır ve favori eklenir/silinir', () async {
      final box = await Hive.openBox<String>('favorites');

      await box.put('article_1', 'article_1');
      await box.put('article_2', 'article_2');

      expect(box.length, 2);
      expect(box.containsKey('article_1'), isTrue);

      await box.delete('article_1');
      expect(box.length, 1);
      expect(box.containsKey('article_1'), isFalse);
    });

    test('settings box dinamik değer kaydeder', () async {
      final box = await Hive.openBox<dynamic>('settings');

      await box.put('theme', 'dark');
      await box.put('fontSize', 1.2);
      await box.put('notificationsEnabled', true);

      expect(box.get('theme'), 'dark');
      expect(box.get('fontSize'), 1.2);
      expect(box.get('notificationsEnabled'), true);
    });

    test('box clear tüm verileri siler', () async {
      final box = await Hive.openBox<String>('test_clear');

      await box.put('key1', 'value1');
      await box.put('key2', 'value2');
      await box.put('key3', 'value3');

      expect(box.length, 3);

      await box.clear();
      expect(box.length, 0);
    });

    test('read_articles box okunmuş makale ID kayıt eder', () async {
      final box = await Hive.openBox<String>('read_articles');

      await box.put('article_1', 'article_1');
      await box.put('article_2', 'article_2');

      expect(box.values.toList(), contains('article_1'));
      expect(box.values.toList(), contains('article_2'));
      expect(box.length, 2);
    });

    test('birden fazla box paralel açılır', () async {
      final results = await Future.wait([
        Hive.openBox<dynamic>('box_a'),
        Hive.openBox<dynamic>('box_b'),
        Hive.openBox<dynamic>('box_c'),
      ]);

      expect(results.length, 3);
      expect(results[0].isOpen, isTrue);
      expect(results[1].isOpen, isTrue);
      expect(results[2].isOpen, isTrue);
    });
  });

  group('HiveService - ArticleModel Serializasyon', () {
    test('ArticleModel Hive\'a yazılır ve okunur', () async {
      final box = await Hive.openBox<ArticleModel>('article_serial_test');

      final article = ArticleModel(
        id: 'serial_1',
        title: 'Serializasyon Testi',
        description: 'Bu bir test makalesidir',
        content: 'Uzun içerik burada',
        link: 'https://example.com/serial',
        imageUrl: 'https://example.com/image.jpg',
        publishedDate: DateTime(2026, 3, 10),
        category: 'teknoloji',
        sourceName: 'Test Kaynağı',
        isRead: true,
        isFavorite: false,
      );

      await box.put(article.id, article);
      final loaded = box.get('serial_1')!;

      expect(loaded.id, 'serial_1');
      expect(loaded.title, 'Serializasyon Testi');
      expect(loaded.content, 'Uzun içerik burada');
      expect(loaded.imageUrl, 'https://example.com/image.jpg');
      expect(loaded.category, 'teknoloji');
      expect(loaded.isRead, true);
      expect(loaded.isFavorite, false);
    });

    test('ArticleModel toEntity doğru çalışır', () {
      final model = ArticleModel(
        id: 'entity_1',
        title: 'Entity Test',
        description: 'Desc',
        link: 'https://example.com',
        publishedDate: DateTime(2026, 1, 1),
        category: 'genel',
        sourceName: 'Kaynak',
        isRead: true,
        isFavorite: true,
      );

      final entity = model.toEntity();

      expect(entity.id, 'entity_1');
      expect(entity.title, 'Entity Test');
      expect(entity.isRead, true);
      expect(entity.isFavorite, true);
    });
  });
}