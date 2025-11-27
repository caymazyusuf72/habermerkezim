import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/reading_analytics.dart';

/// Okuma analytics servisi
class AnalyticsService {
  static const String _boxName = 'reading_analytics';
  static Box<Map>? _box;

  /// Servisi başlat
  static Future<void> init() async {
    try {
      if (_box == null || !_box!.isOpen) {
        _box = await Hive.openBox<Map>(_boxName);
      }
    } catch (e) {
      print('Analytics Service başlatma hatası: $e');
      rethrow;
    }
  }

  /// Bugünün analytics'ini al
  static ReadingAnalytics getTodayAnalytics() {
    try {
      final todayId = ReadingAnalytics.getTodayId();
      final map = _box!.get(todayId);
      
      if (map != null) {
        final convertedMap = Map<String, dynamic>.from(map);
        return ReadingAnalytics.fromMap(convertedMap);
      }
      
      // Bugün için analytics yoksa boş oluştur
      return ReadingAnalytics.empty();
    } catch (e) {
      print('Bugün analytics alma hatası: $e');
      return ReadingAnalytics.empty();
    }
  }

  /// Analytics kaydet
  static Future<bool> saveAnalytics(ReadingAnalytics analytics) async {
    try {
      await _box!.put(analytics.id, analytics.toMap());
      return true;
    } catch (e) {
      print('Analytics kaydetme hatası: $e');
      return false;
    }
  }

  /// Makale okundu olayını kaydet
  static Future<bool> recordArticleRead(String category, String source, {int timeSpent = 0}) async {
    try {
      final today = getTodayAnalytics();
      final updated = today.incrementArticleRead(category, source, timeSpent: timeSpent);
      return await saveAnalytics(updated);
    } catch (e) {
      print('Makale okuma kaydı hatası: $e');
      return false;
    }
  }

  /// Favori eklendi olayını kaydet
  static Future<bool> recordFavoriteAdded() async {
    try {
      final today = getTodayAnalytics();
      final updated = today.incrementFavorite();
      return await saveAnalytics(updated);
    } catch (e) {
      print('Favori ekleme kaydı hatası: $e');
      return false;
    }
  }

  /// Arama yapıldı olayını kaydet
  static Future<bool> recordSearchPerformed() async {
    try {
      final today = getTodayAnalytics();
      final updated = today.incrementSearch();
      return await saveAnalytics(updated);
    } catch (e) {
      print('Arama kaydı hatası: $e');
      return false;
    }
  }

  /// Paylaşım yapıldı olayını kaydet
  static Future<bool> recordSharePerformed() async {
    try {
      final today = getTodayAnalytics();
      final updated = today.incrementShare();
      return await saveAnalytics(updated);
    } catch (e) {
      print('Paylaşım kaydı hatası: $e');
      return false;
    }
  }

  /// Tarih aralığına göre analytics al
  static List<ReadingAnalytics> getAnalyticsInRange(AnalyticsTimeRange range) {
    try {
      final startDate = range.getStartDate();
      final endDate = DateTime.now();
      
      final analytics = <ReadingAnalytics>[];
      
      for (final map in _box!.values) {
        if (map is Map<String, dynamic>) {
          final analytic = ReadingAnalytics.fromMap(map);
          if (analytic.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              analytic.date.isBefore(endDate.add(const Duration(days: 1)))) {
            analytics.add(analytic);
          }
        } else if (map is Map) {
          final convertedMap = Map<String, dynamic>.from(map);
          final analytic = ReadingAnalytics.fromMap(convertedMap);
          if (analytic.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              analytic.date.isBefore(endDate.add(const Duration(days: 1)))) {
            analytics.add(analytic);
          }
        }
      }
      
      // Tarihe göre sırala
      analytics.sort((a, b) => a.date.compareTo(b.date));
      return analytics;
    } catch (e) {
      print('Analytics aralık alma hatası: $e');
      return [];
    }
  }

  /// Tüm analytics'i al
  static List<ReadingAnalytics> getAllAnalytics() {
    try {
      final analytics = <ReadingAnalytics>[];
      
      for (final map in _box!.values) {
        if (map is Map<String, dynamic>) {
          analytics.add(ReadingAnalytics.fromMap(map));
        } else if (map is Map) {
          final convertedMap = Map<String, dynamic>.from(map);
          analytics.add(ReadingAnalytics.fromMap(convertedMap));
        }
      }
      
      // Tarihe göre sırala
      analytics.sort((a, b) => a.date.compareTo(b.date));
      return analytics;
    } catch (e) {
      print('Tüm analytics alma hatası: $e');
      return [];
    }
  }

  /// Analytics özeti oluştur
  static AnalyticsSummary createSummary(AnalyticsTimeRange range) {
    try {
      final analytics = getAnalyticsInRange(range);
      
      if (analytics.isEmpty) {
        return AnalyticsSummary.empty;
      }

      int totalArticlesRead = 0;
      int totalTimeSpent = 0;
      int totalFavorites = 0;
      int totalSearches = 0;
      int totalShares = 0;
      
      final Map<String, int> categoriesBreakdown = {};
      final Map<String, int> sourcesBreakdown = {};
      
      for (final analytic in analytics) {
        totalArticlesRead += analytic.articlesRead;
        totalTimeSpent += analytic.timeSpentMinutes;
        totalFavorites += analytic.favoriteCount;
        totalSearches += analytic.searchCount;
        totalShares += analytic.shareCount;
        
        // Kategorileri birleştir
        analytic.categoriesRead.forEach((category, count) {
          categoriesBreakdown[category] = (categoriesBreakdown[category] ?? 0) + count;
        });
        
        // Kaynakları birleştir
        analytic.sourcesRead.forEach((source, count) {
          sourcesBreakdown[source] = (sourcesBreakdown[source] ?? 0) + count;
        });
      }
      
      // Okuma streak'i hesapla
      final streakDays = _calculateReadingStreak(analytics);

      return AnalyticsSummary(
        totalArticlesRead: totalArticlesRead,
        totalTimeSpent: totalTimeSpent,
        totalFavorites: totalFavorites,
        totalSearches: totalSearches,
        totalShares: totalShares,
        categoriesBreakdown: categoriesBreakdown,
        sourcesBreakdown: sourcesBreakdown,
        dailyData: analytics,
        streakDays: streakDays,
      );
    } catch (e) {
      print('Analytics özeti oluşturma hatası: $e');
      return AnalyticsSummary.empty;
    }
  }

  /// Okuma streak'i hesapla
  static int _calculateReadingStreak(List<ReadingAnalytics> analytics) {
    if (analytics.isEmpty) return 0;
    
    // Son günden geriye doğru gidip streak'i hesapla
    int streak = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final checkId = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      
      final dayAnalytic = analytics.where((a) => a.id == checkId).firstOrNull;
      
      if (dayAnalytic != null && dayAnalytic.articlesRead > 0) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  /// Son 7 günün analitik verilerini al
  static List<ReadingAnalytics> getLast7DaysAnalytics() {
    final analytics = <ReadingAnalytics>[];
    final today = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final id = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      try {
        final map = _box!.get(id);
        if (map != null) {
          final convertedMap = Map<String, dynamic>.from(map);
          analytics.add(ReadingAnalytics.fromMap(convertedMap));
        } else {
          // O gün için veri yoksa boş analytics ekle
          analytics.add(ReadingAnalytics(
            id: id,
            date: date,
          ));
        }
      } catch (e) {
        // Hata durumunda boş analytics ekle
        analytics.add(ReadingAnalytics(
          id: id,
          date: date,
        ));
      }
    }
    
    return analytics;
  }

  /// Son 30 günün analitik verilerini al
  static List<ReadingAnalytics> getLast30DaysAnalytics() {
    final analytics = <ReadingAnalytics>[];
    final today = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final id = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      try {
        final map = _box!.get(id);
        if (map != null) {
          final convertedMap = Map<String, dynamic>.from(map);
          analytics.add(ReadingAnalytics.fromMap(convertedMap));
        } else {
          // O gün için veri yoksa boş analytics ekle
          analytics.add(ReadingAnalytics(
            id: id,
            date: date,
          ));
        }
      } catch (e) {
        // Hata durumunda boş analytics ekle
        analytics.add(ReadingAnalytics(
          id: id,
          date: date,
        ));
      }
    }
    
    return analytics;
  }

  /// Toplam kaydedilmiş gün sayısı
  static int getTotalTrackedDays() {
    try {
      return _box!.length;
    } catch (e) {
      return 0;
    }
  }

  /// Analytics'i sil
  static Future<bool> deleteAnalytics(String id) async {
    try {
      await _box!.delete(id);
      return true;
    } catch (e) {
      print('Analytics silme hatası: $e');
      return false;
    }
  }

  /// Tüm analytics'i temizle
  static Future<bool> clearAllAnalytics() async {
    try {
      await _box!.clear();
      return true;
    } catch (e) {
      print('Analytics temizleme hatası: $e');
      return false;
    }
  }

  /// Servisi kapat
  static Future<void> dispose() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }

  /// Analytics verilerini export et
  static Map<String, dynamic> exportAnalytics() {
    try {
      final allAnalytics = getAllAnalytics();
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalDays': allAnalytics.length,
        'analytics': allAnalytics.map((a) => a.toMap()).toList(),
      };
      
      return exportData;
    } catch (e) {
      print('Analytics export hatası: $e');
      return {};
    }
  }

  /// Analytics verilerini import et
  static Future<bool> importAnalytics(Map<String, dynamic> data) async {
    try {
      final analyticsData = data['analytics'] as List?;
      if (analyticsData == null) return false;
      
      for (final analyticMap in analyticsData) {
        if (analyticMap is Map<String, dynamic>) {
          final analytics = ReadingAnalytics.fromMap(analyticMap);
          await saveAnalytics(analytics);
        }
      }
      
      return true;
    } catch (e) {
      print('Analytics import hatası: $e');
      return false;
    }
  }
}

/// Analytics yardımcı sınıfı
class AnalyticsHelper {
  AnalyticsHelper._();

  /// Haftalık okuma hedefi kontrolü
  static bool checkWeeklyReadingGoal(List<ReadingAnalytics> weeklyData, int goalArticles) {
    final totalArticles = weeklyData.fold(0, (sum, day) => sum + day.articlesRead);
    return totalArticles >= goalArticles;
  }

  /// Günlük okuma hedefi kontrolü
  static bool checkDailyReadingGoal(ReadingAnalytics dayData, int goalArticles) {
    return dayData.articlesRead >= goalArticles;
  }

  /// Okuma tutarlılığı puanı (0-100)
  static double calculateConsistencyScore(List<ReadingAnalytics> analytics) {
    if (analytics.isEmpty) return 0;
    
    final daysWithReading = analytics.where((day) => day.articlesRead > 0).length;
    return (daysWithReading / analytics.length) * 100;
  }

  /// Okuma trendini hesapla (+1: artış, 0: stabil, -1: azalış)
  static int calculateReadingTrend(List<ReadingAnalytics> analytics) {
    if (analytics.length < 2) return 0;
    
    final halfPoint = analytics.length ~/ 2;
    final firstHalf = analytics.take(halfPoint).fold(0, (sum, day) => sum + day.articlesRead);
    final secondHalf = analytics.skip(halfPoint).fold(0, (sum, day) => sum + day.articlesRead);
    
    if (secondHalf > firstHalf) return 1;
    if (secondHalf < firstHalf) return -1;
    return 0;
  }

  /// En verimli okuma saati (şu an için rastgele, gerçekte kullanıcı davranışından çıkarılabilir)
  static String getMostProductiveReadingTime() {
    // Bu gerçek bir uygulamada makale okuma zamanlarından analiz edilebilir
    final hours = ['08:00', '12:00', '18:00', '20:00', '21:00'];
    return hours[(DateTime.now().day) % hours.length];
  }

  /// Okuma motivasyonu mesajı
  static String getMotivationMessage(ReadingAnalytics todayData, int streakDays) {
    if (streakDays >= 7) {
      return '🔥 Muhteşem! ${streakDays} günlük okuma seriniz devam ediyor!';
    } else if (todayData.articlesRead >= 5) {
      return '📚 Bugün çok aktifsiniz! ${todayData.articlesRead} makale okudunuz.';
    } else if (todayData.articlesRead > 0) {
      return '👍 İyi başlangıç! Okuma hedefinize doğru ilerliyorsunuz.';
    } else {
      return '📖 Bugün ilk makalenizi okumaya hazır mısınız?';
    }
  }
}