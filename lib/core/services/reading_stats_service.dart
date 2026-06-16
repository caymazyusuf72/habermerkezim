import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hive_service.dart';

/// Okuma istatistikleri zaman aralığı
enum StatsTimeRange { daily, weekly, monthly }

/// Günlük okuma verisi
class DailyReadingData {
  final DateTime date;
  final int articleCount;
  final int readingMinutes;

  const DailyReadingData({
    required this.date,
    this.articleCount = 0,
    this.readingMinutes = 0,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'articleCount': articleCount,
    'readingMinutes': readingMinutes,
  };

  factory DailyReadingData.fromJson(Map<String, dynamic> json) {
    return DailyReadingData(
      date: DateTime.parse(json['date']),
      articleCount: json['articleCount'] ?? 0,
      readingMinutes: json['readingMinutes'] ?? 0,
    );
  }
}

/// Okuma istatistikleri özet modeli
class ReadingStatsSummary {
  final int totalArticlesRead;
  final int totalReadingMinutes;
  final int currentStreak;
  final int longestStreak;
  final int weeklyGoal;
  final int weeklyProgress;
  final Map<String, int> categoryReadCounts;
  final List<DailyReadingData> dailyData;

  const ReadingStatsSummary({
    this.totalArticlesRead = 0,
    this.totalReadingMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.weeklyGoal = 20,
    this.weeklyProgress = 0,
    this.categoryReadCounts = const {},
    this.dailyData = const [],
  });

  double get averageReadingMinutes {
    if (dailyData.isEmpty) return 0;
    final totalMinutes = dailyData.fold<int>(
      0,
      (sum, data) => sum + data.readingMinutes,
    );
    return totalMinutes / dailyData.length;
  }

  double get weeklyGoalProgress {
    if (weeklyGoal <= 0) return 0;
    return (weeklyProgress / weeklyGoal).clamp(0, 1);
  }
}

/// Okuma İstatistikleri Servisi
/// Okuma takibi, streak, kategori bazlı istatistikler
class ReadingStatsService {
  static final ReadingStatsService _instance = ReadingStatsService._internal();
  factory ReadingStatsService() => _instance;
  ReadingStatsService._internal();

  static const String _dailyDataKey = 'reading_stats_daily';
  static const String _totalStatsKey = 'reading_stats_total';
  static const String _streakKey = 'reading_stats_streak';
  static const String _weeklyGoalKey = 'reading_stats_weekly_goal';
  static const String _categoryStatsKey = 'reading_stats_categories';
  static const String _readingStartTimeKey = 'reading_start_time';

  // ─── Okuma Takibi ────────────────────────────────────────────────────────

  /// Haber okundu olarak kaydet
  Future<void> recordArticleRead(String category) async {
    try {
      final today = _todayKey();
      final box = HiveService.settingsBox;

      // Günlük veri güncelle
      final dailyData = _getDailyDataMap();
      final todayData =
          dailyData[today] ??
          {
            'date': DateTime.now().toIso8601String(),
            'articleCount': 0,
            'readingMinutes': 0,
          };
      todayData['articleCount'] = (todayData['articleCount'] as int) + 1;
      dailyData[today] = todayData;
      await box.put(_dailyDataKey, jsonEncode(dailyData));

      // Toplam istatistik güncelle
      final totalStats = _getTotalStats();
      totalStats['totalArticlesRead'] =
          (totalStats['totalArticlesRead'] ?? 0) + 1;
      await box.put(_totalStatsKey, jsonEncode(totalStats));

      // Kategori istatistik güncelle
      final categoryStats = _getCategoryStats();
      categoryStats[category] = (categoryStats[category] ?? 0) + 1;
      await box.put(_categoryStatsKey, jsonEncode(categoryStats));

      // Streak güncelle
      await _updateStreak();

      debugPrint('📊 Okuma kaydedildi: $category');
    } catch (e) {
      debugPrint('❌ Okuma kaydetme hatası: $e');
    }
  }

  /// Okuma süresi takibi başlat
  void startReadingTimer() {
    try {
      final box = HiveService.settingsBox;
      box.put(_readingStartTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('❌ Okuma zamanlayıcı başlatma hatası: $e');
    }
  }

  /// Okuma süresi takibi durdur ve kaydet
  Future<void> stopReadingTimer() async {
    try {
      final box = HiveService.settingsBox;
      final startTimeStr = box.get(_readingStartTimeKey);
      if (startTimeStr == null) return;

      final startTime = DateTime.parse(startTimeStr.toString());
      final minutes = DateTime.now().difference(startTime).inMinutes;

      if (minutes > 0 && minutes < 120) {
        // Max 2 saat
        final today = _todayKey();
        final dailyData = _getDailyDataMap();
        final todayData =
            dailyData[today] ??
            {
              'date': DateTime.now().toIso8601String(),
              'articleCount': 0,
              'readingMinutes': 0,
            };
        todayData['readingMinutes'] =
            (todayData['readingMinutes'] as int) + minutes;
        dailyData[today] = todayData;
        await box.put(_dailyDataKey, jsonEncode(dailyData));

        // Toplam süreyi güncelle
        final totalStats = _getTotalStats();
        totalStats['totalReadingMinutes'] =
            (totalStats['totalReadingMinutes'] ?? 0) + minutes;
        await box.put(_totalStatsKey, jsonEncode(totalStats));
      }

      await box.delete(_readingStartTimeKey);
    } catch (e) {
      debugPrint('❌ Okuma zamanlayıcı durdurma hatası: $e');
    }
  }

  // ─── Streak Takibi ───────────────────────────────────────────────────────

  /// Streak güncelle
  Future<void> _updateStreak() async {
    try {
      final box = HiveService.settingsBox;
      final streakData = _getStreakData();

      final today = DateTime.now();
      final todayStr = _todayKey();
      final lastReadStr = streakData['lastReadDate'] as String?;

      if (lastReadStr == todayStr) {
        // Bugün zaten okuma yapılmış
        return;
      }

      int currentStreak = streakData['currentStreak'] ?? 0;
      int longestStreak = streakData['longestStreak'] ?? 0;

      if (lastReadStr != null) {
        final lastRead = DateTime.parse(lastReadStr);
        final diff = today
            .difference(DateTime(lastRead.year, lastRead.month, lastRead.day))
            .inDays;

        if (diff == 1) {
          // Art arda gün - streak devam
          currentStreak++;
        } else if (diff > 1) {
          // Streak kırıldı
          currentStreak = 1;
        }
      } else {
        currentStreak = 1;
      }

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }

      final newStreakData = {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastReadDate': todayStr,
      };

      await box.put(_streakKey, jsonEncode(newStreakData));
    } catch (e) {
      debugPrint('❌ Streak güncelleme hatası: $e');
    }
  }

  // ─── Haftalık Hedef ──────────────────────────────────────────────────────

  /// Haftalık hedefi al
  int getWeeklyGoal() {
    try {
      return HiveService.settingsBox.get(_weeklyGoalKey, defaultValue: 20)
          as int;
    } catch (e) {
      return 20;
    }
  }

  /// Haftalık hedefi ayarla
  Future<void> setWeeklyGoal(int goal) async {
    await HiveService.settingsBox.put(_weeklyGoalKey, goal);
  }

  /// Bu haftaki ilerleme
  int getWeeklyProgress() {
    try {
      final dailyData = _getDailyDataMap();
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      int total = 0;
      for (int i = 0; i < 7; i++) {
        final day = startOfWeek.add(Duration(days: i));
        final key = _dateKey(day);
        final data = dailyData[key];
        if (data != null) {
          total += (data['articleCount'] as int? ?? 0);
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  // ─── İstatistik Özeti ────────────────────────────────────────────────────

  /// Tam istatistik özeti oluştur
  ReadingStatsSummary getSummary({
    StatsTimeRange range = StatsTimeRange.weekly,
  }) {
    try {
      final totalStats = _getTotalStats();
      final streakData = _getStreakData();
      final categoryStats = _getCategoryStats();
      final dailyData = _getDailyDataForRange(range);

      return ReadingStatsSummary(
        totalArticlesRead: totalStats['totalArticlesRead'] ?? 0,
        totalReadingMinutes: totalStats['totalReadingMinutes'] ?? 0,
        currentStreak: streakData['currentStreak'] ?? 0,
        longestStreak: streakData['longestStreak'] ?? 0,
        weeklyGoal: getWeeklyGoal(),
        weeklyProgress: getWeeklyProgress(),
        categoryReadCounts: categoryStats,
        dailyData: dailyData,
      );
    } catch (e) {
      debugPrint('❌ İstatistik özeti oluşturma hatası: $e');
      return const ReadingStatsSummary();
    }
  }

  /// Belirtilen zaman aralığı için günlük verileri getir
  List<DailyReadingData> _getDailyDataForRange(StatsTimeRange range) {
    final dailyDataMap = _getDailyDataMap();
    final now = DateTime.now();
    int days;

    switch (range) {
      case StatsTimeRange.daily:
        days = 1;
        break;
      case StatsTimeRange.weekly:
        days = 7;
        break;
      case StatsTimeRange.monthly:
        days = 30;
        break;
    }

    final result = <DailyReadingData>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      final data = dailyDataMap[key];

      result.add(
        DailyReadingData(
          date: DateTime(date.year, date.month, date.day),
          articleCount: data != null ? (data['articleCount'] as int? ?? 0) : 0,
          readingMinutes: data != null
              ? (data['readingMinutes'] as int? ?? 0)
              : 0,
        ),
      );
    }

    return result;
  }

  /// İstatistikleri sıfırla
  Future<void> resetStats() async {
    try {
      final box = HiveService.settingsBox;
      await box.delete(_dailyDataKey);
      await box.delete(_totalStatsKey);
      await box.delete(_streakKey);
      await box.delete(_categoryStatsKey);
      debugPrint('📊 Okuma istatistikleri sıfırlandı');
    } catch (e) {
      debugPrint('❌ İstatistik sıfırlama hatası: $e');
    }
  }

  // ─── Yardımcı Metotlar ───────────────────────────────────────────────────

  String _todayKey() => _dateKey(DateTime.now());

  String _dateKey(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Map<String, dynamic> _getDailyDataMap() {
    try {
      final box = HiveService.settingsBox;
      final data = box.get(_dailyDataKey);
      if (data is String && data.isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(data));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> _getTotalStats() {
    try {
      final box = HiveService.settingsBox;
      final data = box.get(_totalStatsKey);
      if (data is String && data.isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(data));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> _getStreakData() {
    try {
      final box = HiveService.settingsBox;
      final data = box.get(_streakKey);
      if (data is String && data.isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(data));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Map<String, int> _getCategoryStats() {
    try {
      final box = HiveService.settingsBox;
      final data = box.get(_categoryStatsKey);
      if (data is String && data.isNotEmpty) {
        return Map<String, int>.from(jsonDecode(data));
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}

// ─── Riverpod Provider'ları ─────────────────────────────────────────────────

/// ReadingStatsService provider
final readingStatsServiceProvider = Provider<ReadingStatsService>((ref) {
  return ReadingStatsService();
});

/// Okuma istatistikleri özeti provider
final readingStatsSummaryProvider =
    Provider.family<ReadingStatsSummary, StatsTimeRange>((ref, range) {
      final service = ref.watch(readingStatsServiceProvider);
      return service.getSummary(range: range);
    });

/// Haftalık hedef provider
final weeklyGoalProvider = Provider<int>((ref) {
  final service = ref.watch(readingStatsServiceProvider);
  return service.getWeeklyGoal();
});

/// Haftalık ilerleme provider
final weeklyProgressProvider = Provider<int>((ref) {
  final service = ref.watch(readingStatsServiceProvider);
  return service.getWeeklyProgress();
});
