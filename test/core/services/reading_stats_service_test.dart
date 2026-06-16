import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/services/reading_stats_service.dart';

void main() {
  group('DailyReadingData', () {
    test('toJson doğru değerler döndürmeli', () {
      // Arrange
      final data = DailyReadingData(
        date: DateTime(2026, 1, 15),
        articleCount: 5,
        readingMinutes: 30,
      );

      // Act
      final json = data.toJson();

      // Assert
      expect(json['date'], '2026-01-15T00:00:00.000');
      expect(json['articleCount'], 5);
      expect(json['readingMinutes'], 30);
    });

    test('fromJson doğru değerler oluşturmalı', () {
      // Arrange
      final json = {
        'date': '2026-01-15T00:00:00.000',
        'articleCount': 10,
        'readingMinutes': 45,
      };

      // Act
      final data = DailyReadingData.fromJson(json);

      // Assert
      expect(data.date, DateTime(2026, 1, 15));
      expect(data.articleCount, 10);
      expect(data.readingMinutes, 45);
    });

    test('fromJson null alanlarla varsayılan değerler kullanmalı', () {
      // Arrange
      final json = {
        'date': '2026-01-15T00:00:00.000',
      };

      // Act
      final data = DailyReadingData.fromJson(json);

      // Assert
      expect(data.articleCount, 0);
      expect(data.readingMinutes, 0);
    });

    test('varsayılan değerler doğru olmalı', () {
      // Act
      final data = DailyReadingData(date: DateTime(2026, 1, 1));

      // Assert
      expect(data.articleCount, 0);
      expect(data.readingMinutes, 0);
    });
  });

  group('ReadingStatsSummary', () {
    test('varsayılan değerler doğru olmalı', () {
      // Act
      const summary = ReadingStatsSummary();

      // Assert
      expect(summary.totalArticlesRead, 0);
      expect(summary.totalReadingMinutes, 0);
      expect(summary.currentStreak, 0);
      expect(summary.longestStreak, 0);
      expect(summary.weeklyGoal, 20);
      expect(summary.weeklyProgress, 0);
      expect(summary.categoryReadCounts, isEmpty);
      expect(summary.dailyData, isEmpty);
    });

    test('averageReadingMinutes boş veri için 0 döndürmeli', () {
      // Arrange
      const summary = ReadingStatsSummary(dailyData: []);

      // Act & Assert
      expect(summary.averageReadingMinutes, 0);
    });

    test('averageReadingMinutes doğru hesaplamalı', () {
      // Arrange
      final summary = ReadingStatsSummary(
        dailyData: [
          DailyReadingData(
            date: DateTime(2026, 1, 1),
            readingMinutes: 30,
          ),
          DailyReadingData(
            date: DateTime(2026, 1, 2),
            readingMinutes: 60,
          ),
          DailyReadingData(
            date: DateTime(2026, 1, 3),
            readingMinutes: 0,
          ),
        ],
      );

      // Act & Assert
      expect(summary.averageReadingMinutes, 30.0); // (30+60+0)/3
    });

    test('weeklyGoalProgress doğru hesaplamalı', () {
      // Arrange
      const summary = ReadingStatsSummary(
        weeklyGoal: 20,
        weeklyProgress: 10,
      );

      // Act & Assert
      expect(summary.weeklyGoalProgress, 0.5); // 10/20
    });

    test('weeklyGoalProgress 1.0 üstüne çıkmamalı', () {
      // Arrange
      const summary = ReadingStatsSummary(
        weeklyGoal: 10,
        weeklyProgress: 20,
      );

      // Act & Assert
      expect(summary.weeklyGoalProgress, 1.0);
    });

    test('weeklyGoalProgress sıfır hedef için 0 döndürmeli', () {
      // Arrange
      const summary = ReadingStatsSummary(
        weeklyGoal: 0,
        weeklyProgress: 5,
      );

      // Act & Assert
      expect(summary.weeklyGoalProgress, 0);
    });
  });

  group('StatsTimeRange', () {
    test('tüm zaman aralıkları tanımlı olmalı', () {
      expect(StatsTimeRange.values, hasLength(3));
      expect(StatsTimeRange.values, contains(StatsTimeRange.daily));
      expect(StatsTimeRange.values, contains(StatsTimeRange.weekly));
      expect(StatsTimeRange.values, contains(StatsTimeRange.monthly));
    });
  });
}