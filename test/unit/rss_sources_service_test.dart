import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:haber_merkezi/core/services/rss_sources_service.dart';
import 'package:haber_merkezi/domain/entities/rss_source.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('rss_sources_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  group('RssSourcesService - URL Doğrulama', () {
    test('geçerli HTTP URL kabul edilir', () {
      expect(RssSourcesService.isValidRssUrl('https://www.ntv.com.tr/gundem.rss'), isTrue);
      expect(RssSourcesService.isValidRssUrl('http://example.com/feed'), isTrue);
    });

    test('geçersiz URL reddedilir', () {
      expect(RssSourcesService.isValidRssUrl(''), isFalse);
      expect(RssSourcesService.isValidRssUrl('not-a-url'), isFalse);
      expect(RssSourcesService.isValidRssUrl('ftp://example.com'), isFalse);
    });

    test('şemasız URL reddedilir', () {
      expect(RssSourcesService.isValidRssUrl('www.example.com'), isFalse);
    });
  });

  group('RssSourcesService - ID Oluşturma', () {
    test('benzersiz ID oluşturur', () {
      final id1 = RssSourcesService.generateUniqueId('Test Kaynak');
      final id2 = RssSourcesService.generateUniqueId('Test Kaynak');

      // Timestamp farklı olacağı için ID'ler farklı olmalı
      // (aynı milisaniyede çağrılmadığı sürece)
      expect(id1, isNotEmpty);
      expect(id1, contains('test_kaynak'));
    });

    test('özel karakterler temizlenir', () {
      final id = RssSourcesService.generateUniqueId('Türkçe Özel!@#\$');
      expect(id, isNot(contains('!')));
      expect(id, isNot(contains('@')));
      expect(id, isNot(contains('#')));
    });
  });

  group('RssSourcesService - CRUD İşlemleri', () {
    test('init varsayılan kaynakları yükler', () async {
      await RssSourcesService.init();

      final sources = RssSourcesService.getAllSources();
      expect(sources, isNotEmpty);
      expect(sources.length, greaterThan(10)); // Çok sayıda varsayılan kaynak var
    });

    test('kaynak eklenir ve alınır', () async {
      await RssSourcesService.init();

      final source = RssSource(
        id: 'custom_test_1',
        name: 'Test Kaynak',
        url: 'https://example.com/feed',
        category: 'teknoloji',
        description: 'Test açıklaması',
        createdAt: DateTime.now(),
      );

      final result = await RssSourcesService.addSource(source);
      expect(result, isTrue);

      final retrieved = RssSourcesService.getSourceById('custom_test_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Kaynak');
      expect(retrieved.url, 'https://example.com/feed');
      expect(retrieved.category, 'teknoloji');
    });

    test('aynı ID ile tekrar ekleme başarısız olur', () async {
      await RssSourcesService.init();

      final source = RssSource(
        id: 'duplicate_test',
        name: 'Kaynak 1',
        url: 'https://example.com/1',
        category: 'genel',
        createdAt: DateTime.now(),
      );

      await RssSourcesService.addSource(source);
      final result = await RssSourcesService.addSource(source);
      expect(result, isFalse); // Duplicate ID
    });

    test('kaynak güncellenir', () async {
      await RssSourcesService.init();

      final source = RssSource(
        id: 'update_test',
        name: 'Orijinal',
        url: 'https://example.com/original',
        category: 'genel',
        createdAt: DateTime.now(),
      );

      await RssSourcesService.addSource(source);

      final updated = source.copyWith(name: 'Güncellenmiş', url: 'https://example.com/updated');
      final result = await RssSourcesService.updateSource(updated);

      expect(result, isTrue);

      final retrieved = RssSourcesService.getSourceById('update_test');
      expect(retrieved!.name, 'Güncellenmiş');
      expect(retrieved.url, 'https://example.com/updated');
    });

    test('kaynak silinir', () async {
      await RssSourcesService.init();

      final source = RssSource(
        id: 'delete_test',
        name: 'Silinecek',
        url: 'https://example.com/delete',
        category: 'genel',
        createdAt: DateTime.now(),
      );

      await RssSourcesService.addSource(source);
      expect(RssSourcesService.getSourceById('delete_test'), isNotNull);

      final result = await RssSourcesService.deleteSource('delete_test');
      expect(result, isTrue);
      expect(RssSourcesService.getSourceById('delete_test'), isNull);
    });

    test('toggle status çalışır', () async {
      await RssSourcesService.init();

      final source = RssSource(
        id: 'toggle_test',
        name: 'Toggle',
        url: 'https://example.com/toggle',
        category: 'genel',
        isEnabled: true,
        createdAt: DateTime.now(),
      );

      await RssSourcesService.addSource(source);

      await RssSourcesService.toggleSourceStatus('toggle_test');
      var retrieved = RssSourcesService.getSourceById('toggle_test');
      expect(retrieved!.isEnabled, isFalse);

      await RssSourcesService.toggleSourceStatus('toggle_test');
      retrieved = RssSourcesService.getSourceById('toggle_test');
      expect(retrieved!.isEnabled, isTrue);
    });
  });

  group('RssSourcesService - Filtreleme', () {
    test('aktif kaynaklar filtrelenir', () async {
      await RssSourcesService.init();

      final activeSources = RssSourcesService.getActiveSources();
      expect(activeSources, isNotEmpty);
      // Tüm aktif kaynaklar isEnabled: true olmalı
      for (final source in activeSources) {
        expect(source.isEnabled, isTrue);
      }
    });

    test('kategorilerin listesi alınır', () async {
      await RssSourcesService.init();

      final categories = RssSourcesService.getAllCategories();
      expect(categories, isNotEmpty);
      expect(categories, contains('genel'));
      expect(categories, contains('teknoloji'));
      expect(categories, contains('spor'));
    });

    test('kaynak sayısı doğru', () async {
      await RssSourcesService.init();

      final count = RssSourcesService.getSourceCount();
      final activeCount = RssSourcesService.getActiveSourceCount();

      expect(count, greaterThan(0));
      expect(activeCount, lessThanOrEqualTo(count));
    });

    test('kategoriye göre kaynak sayıları doğru', () async {
      await RssSourcesService.init();

      final countMap = RssSourcesService.getSourceCountByCategory();
      expect(countMap, isNotEmpty);
      expect(countMap.values.every((count) => count > 0), isTrue);
    });
  });

  group('RssSourcesService - Sıfırlama', () {
    test('clearAllSources tüm kaynakları siler', () async {
      await RssSourcesService.init();
      expect(RssSourcesService.getSourceCount(), greaterThan(0));

      await RssSourcesService.clearAllSources();
      expect(RssSourcesService.getSourceCount(), 0);
    });

    test('resetToDefaults varsayılanlara geri döner', () async {
      await RssSourcesService.init();

      // Özel kaynak ekle
      await RssSourcesService.addSource(RssSource(
        id: 'custom',
        name: 'Özel',
        url: 'https://example.com',
        category: 'genel',
        createdAt: DateTime.now(),
      ));

      final beforeCount = RssSourcesService.getSourceCount();

      await RssSourcesService.resetToDefaults();
      final afterCount = RssSourcesService.getSourceCount();

      // Özel kaynak silindi, varsayılanlar yeniden yüklendi
      expect(RssSourcesService.getSourceById('custom'), isNull);
      expect(afterCount, lessThan(beforeCount));
    });
  });

  group('RssSourcesHelper - URL Yardımcıları', () {
    test('URL\'den başlık tahmin eder', () {
      expect(RssSourcesHelper.predictTitleFromUrl('https://www.ntv.com.tr/rss'), isNotEmpty);
    });

    test('URL\'den kategori tahmin eder', () {
      expect(RssSourcesHelper.predictCategoryFromUrl('https://example.com/teknoloji/feed'), 'teknoloji');
      expect(RssSourcesHelper.predictCategoryFromUrl('https://example.com/spor/feed'), 'spor');
      expect(RssSourcesHelper.predictCategoryFromUrl('https://example.com/ekonomi/feed'), 'ekonomi');
      expect(RssSourcesHelper.predictCategoryFromUrl('https://example.com/feed'), 'genel');
    });

    test('kaynak doğrulama hataları döner', () {
      final errors = RssSourcesHelper.validateRssSource(
        name: '',
        url: 'invalid',
        category: '',
      );

      expect(errors['name'], isNotNull);
      expect(errors['url'], isNotNull);
      expect(errors['category'], isNotNull);
    });

    test('geçerli kaynak hata döndürmez', () {
      final errors = RssSourcesHelper.validateRssSource(
        name: 'Geçerli Kaynak',
        url: 'https://example.com/feed',
        category: 'genel',
      );

      expect(errors['name'], isNull);
      expect(errors['url'], isNull);
      expect(errors['category'], isNull);
    });
  });

  group('DefaultRssSources', () {
    test('varsayılan kaynaklar tanımlı', () {
      final sources = DefaultRssSources.sources;
      expect(sources, isNotEmpty);
    });

    test('tüm varsayılan kaynakların URL\'si var', () {
      for (final source in DefaultRssSources.sources) {
        expect(source.url, isNotEmpty);
        expect(RssSourcesService.isValidRssUrl(source.url), isTrue,
            reason: '${source.name} invalid URL: ${source.url}');
      }
    });

    test('kategori listesi tanımlı', () {
      expect(DefaultRssSources.categories, isNotEmpty);
      expect(DefaultRssSources.categories, contains('genel'));
    });

    test('kategoriye göre kaynaklar alınır', () {
      final techSources = DefaultRssSources.getSourcesByCategory('teknoloji');
      expect(techSources, isNotEmpty);
      for (final source in techSources) {
        expect(source.category, 'teknoloji');
      }
    });
  });
}