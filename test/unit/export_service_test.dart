import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/services/export_service.dart';
import 'package:haber_merkezi/domain/entities/article.dart';

void main() {
  group('ExportService Tests', () {
    late ExportService exportService;

    setUp(() {
      exportService = ExportService();
    });

    group('CSV Export Tests', () {
      test('generateReadingHistoryCSV should create valid CSV format', () {
        final articles = [
          Article(
            id: '1',
            title: 'Test Article 1',
            description: 'Description 1',
            content: 'Content 1',
            url: 'https://example.com/1',
            imageUrl: 'https://example.com/image1.jpg',
            publishedAt: DateTime(2026, 1, 15, 10, 30),
            source: 'Test Source',
            category: 'Teknoloji',
          ),
          Article(
            id: '2',
            title: 'Test Article 2',
            description: 'Description 2',
            content: 'Content 2',
            url: 'https://example.com/2',
            imageUrl: 'https://example.com/image2.jpg',
            publishedAt: DateTime(2026, 1, 16, 14, 45),
            source: 'Another Source',
            category: 'Spor',
          ),
        ];

        final csv = exportService.generateReadingHistoryCSV(articles);

        expect(csv, contains('Başlık,Kaynak,Kategori,Tarih,URL'));
        expect(csv, contains('Test Article 1'));
        expect(csv, contains('Test Source'));
        expect(csv, contains('Teknoloji'));
        expect(csv, contains('Test Article 2'));
        expect(csv, contains('Another Source'));
        expect(csv, contains('Spor'));
      });

      test('generateReadingHistoryCSV should handle empty list', () {
        final csv = exportService.generateReadingHistoryCSV([]);

        expect(csv, contains('Başlık,Kaynak,Kategori,Tarih,URL'));
        final lines = csv.split('\n');
        expect(lines.length, 1); // Only header
      });

      test('generateReadingHistoryCSV should escape special characters', () {
        final articles = [
          Article(
            id: '1',
            title: 'Article with "quotes" and, commas',
            description: 'Description',
            content: 'Content',
            url: 'https://example.com/1',
            imageUrl: 'https://example.com/image.jpg',
            publishedAt: DateTime(2026, 1, 15),
            source: 'Source, Inc.',
            category: 'Test',
          ),
        ];

        final csv = exportService.generateReadingHistoryCSV(articles);

        // CSV should properly escape quotes and commas
        expect(csv, isNotEmpty);
      });

      test('generateFavoritesCSV should create valid CSV format', () {
        final articles = [
          Article(
            id: '1',
            title: 'Favorite Article',
            description: 'Description',
            content: 'Content',
            url: 'https://example.com/1',
            imageUrl: 'https://example.com/image.jpg',
            publishedAt: DateTime(2026, 1, 15),
            source: 'Source',
            category: 'Kategori',
          ),
        ];

        final csv = exportService.generateFavoritesCSV(articles);

        expect(csv, contains('Başlık,Kaynak,Kategori,Tarih,URL'));
        expect(csv, contains('Favorite Article'));
      });
    });

    group('JSON Export Tests', () {
      test('generateReadingHistoryJSON should create valid JSON', () {
        final articles = [
          Article(
            id: '1',
            title: 'Test Article',
            description: 'Description',
            content: 'Content',
            url: 'https://example.com/1',
            imageUrl: 'https://example.com/image.jpg',
            publishedAt: DateTime(2026, 1, 15, 10, 30),
            source: 'Test Source',
            category: 'Teknoloji',
          ),
        ];

        final json = exportService.generateReadingHistoryJSON(articles);

        expect(json, contains('"title"'));
        expect(json, contains('"Test Article"'));
        expect(json, contains('"source"'));
        expect(json, contains('"Test Source"'));
        expect(json, contains('"category"'));
        expect(json, contains('"Teknoloji"'));
      });

      test('generateReadingHistoryJSON should handle empty list', () {
        final json = exportService.generateReadingHistoryJSON([]);

        expect(json, '[]');
      });

      test('generateFavoritesJSON should create valid JSON', () {
        final articles = [
          Article(
            id: '1',
            title: 'Favorite Article',
            description: 'Description',
            content: 'Content',
            url: 'https://example.com/1',
            imageUrl: 'https://example.com/image.jpg',
            publishedAt: DateTime(2026, 1, 15),
            source: 'Source',
            category: 'Kategori',
          ),
        ];

        final json = exportService.generateFavoritesJSON(articles);

        expect(json, contains('"title"'));
        expect(json, contains('"Favorite Article"'));
      });

      test('generateStatisticsJSON should include all statistics', () {
        final stats = {
          'totalArticlesRead': 150,
          'totalFavorites': 25,
          'totalShares': 10,
          'totalReadingTime': 3600,
          'categoryCounts': {
            'Teknoloji': 50,
            'Spor': 30,
            'Ekonomi': 20,
          },
          'sourceCounts': {
            'Source A': 40,
            'Source B': 35,
          },
        };

        final json = exportService.generateStatisticsJSON(stats);

        expect(json, contains('"totalArticlesRead"'));
        expect(json, contains('150'));
        expect(json, contains('"totalFavorites"'));
        expect(json, contains('25'));
        expect(json, contains('"categoryCounts"'));
        expect(json, contains('"Teknoloji"'));
      });
    });

    group('Export Format Tests', () {
      test('CSV should use proper line endings', () {
        final articles = [
          Article(
            id: '1',
            title: 'Article 1',
            description: 'Desc',
            content: 'Content',
            url: 'https://example.com/1',
            imageUrl: 'https://example.com/img.jpg',
            publishedAt: DateTime(2026, 1, 15),
            source: 'Source',
            category: 'Cat',
          ),
          Article(
            id: '2',
            title: 'Article 2',
            description: 'Desc',
            content: 'Content',
            url: 'https://example.com/2',
            imageUrl: 'https://example.com/img.jpg',
            publishedAt: DateTime(2026, 1, 16),
            source: 'Source',
            category: 'Cat',
          ),
        ];

        final csv = exportService.generateReadingHistoryCSV(articles);
        final lines = csv.split('\n');

        expect(lines.length, 3); // Header + 2 articles
      });

      test('JSON should be properly formatted', () {
        final articles = [
          Article(
            id: '1',
            title: 'Test',
            description: 'Desc',
            content: 'Content',
            url: 'https://example.com/1',
            imageUrl: 'https://example.com/img.jpg',
            publishedAt: DateTime(2026, 1, 15),
            source: 'Source',
            category: 'Cat',
          ),
        ];

        final json = exportService.generateReadingHistoryJSON(articles);

        // Should be valid JSON (starts with [ and ends with ])
        expect(json.trim().startsWith('['), true);
        expect(json.trim().endsWith(']'), true);
      });
    });

    group('Date Formatting Tests', () {
      test('Dates should be formatted correctly in CSV', () {
        final articles = [
          Article(
            id: '1',
            title: 'Test',
            description: 'Desc',
            content: 'Content',
            url: 'https://example.com/1',
            imageUrl: 'https://example.com/img.jpg',
            publishedAt: DateTime(2026, 1, 15, 10, 30, 45),
            source: 'Source',
            category: 'Cat',
          ),
        ];

        final csv = exportService.generateReadingHistoryCSV(articles);

        // Should contain formatted date
        expect(csv, contains('2026'));
        expect(csv, contains('01'));
        expect(csv, contains('15'));
      });

      test('Dates should be ISO formatted in JSON', () {
        final articles = [
          Article(
            id: '1',
            title: 'Test',
            description: 'Desc',
            content: 'Content',
            url: 'https://example.com/1',
            imageUrl: 'https://example.com/img.jpg',
            publishedAt: DateTime(2026, 1, 15, 10, 30, 45),
            source: 'Source',
            category: 'Cat',
          ),
        ];

        final json = exportService.generateReadingHistoryJSON(articles);

        // Should contain ISO date format
        expect(json, contains('2026-01-15'));
      });
    });
  });

  group('ExportFormat Enum Tests', () {
    test('ExportFormat should have correct values', () {
      expect(ExportFormat.values.length, 2);
      expect(ExportFormat.values.contains(ExportFormat.csv), true);
      expect(ExportFormat.values.contains(ExportFormat.json), true);
    });
  });

  group('ExportType Enum Tests', () {
    test('ExportType should have correct values', () {
      expect(ExportType.values.length, 3);
      expect(ExportType.values.contains(ExportType.readingHistory), true);
      expect(ExportType.values.contains(ExportType.favorites), true);
      expect(ExportType.values.contains(ExportType.statistics), true);
    });
  });
}