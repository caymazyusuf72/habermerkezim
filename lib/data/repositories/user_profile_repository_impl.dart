import '../../core/services/analytics_service.dart';
import '../../core/services/hive_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/reading_analytics.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/local/user_profile_local_data_source.dart';

import 'package:flutter/foundation.dart';
/// UserProfileRepository interface'inin implementasyonu
/// Analytics service'ten veri çekerek istatistikleri hesaplar
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileLocalDataSource localDataSource;

  UserProfileRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<UserProfile> getProfile() async {
    try {
      final profile = await localDataSource.getProfile();
      
      if (profile == null) {
        // Profil yoksa varsayılan profil oluştur ve kaydet
        final defaultProfile = UserProfile.defaultProfile;
        await localDataSource.saveProfile(defaultProfile);
        return defaultProfile;
      }
      
      // İstatistikleri güncelle
      final updatedStats = await calculateStats();
      final updatedProfile = profile.copyWith(stats: updatedStats);
      
      // Güncellenmiş profili kaydet
      await localDataSource.updateProfile(updatedProfile);
      
      return updatedProfile;
    } catch (e) {
      debugPrint('💥 Profil getirme hatası: $e');
      // Hata durumunda varsayılan profil döndür
      return UserProfile.defaultProfile;
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    try {
      await localDataSource.saveProfile(profile);
    } catch (e) {
      debugPrint('💥 Profil kaydetme hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      await localDataSource.updateProfile(profile);
    } catch (e) {
      debugPrint('💥 Profil güncelleme hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStatsFromAnalytics() async {
    try {
      final stats = await calculateStats();
      await localDataSource.updateStats(stats);
    } catch (e) {
      debugPrint('💥 İstatistik güncelleme hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      await localDataSource.updatePreferences(preferences);
    } catch (e) {
      debugPrint('💥 Tercih güncelleme hatası: $e');
      rethrow;
    }
  }

  @override
  Future<UserStats> calculateStats() async {
    try {
      // Analytics'ten veri çek
      final monthlySummary = AnalyticsService.createSummary(AnalyticsTimeRange.month);
      final weeklySummary = AnalyticsService.createSummary(AnalyticsTimeRange.week);
      
      // Hive'dan favori ve okuma listesi sayılarını al
      final favoritesCount = HiveService.favoritesBox.length;
      final readingListCount = HiveService.readingListBox.length;
      
      // Okunan makale sayısı - monthly summary'den
      final totalArticlesRead = monthlySummary.totalArticlesRead;
      
      // Streak günleri - weekly summary'den
      final streakDays = weeklySummary.streakDays;
      
      // Kategori bazlı okuma sayıları
      final categoryReadCount = <String, int>{};
      final monthlyAnalytics = AnalyticsService.getLast30DaysAnalytics();
      
      for (final analytics in monthlyAnalytics) {
        for (final entry in analytics.categoriesRead.entries) {
          categoryReadCount[entry.key] = 
              (categoryReadCount[entry.key] ?? 0) + entry.value;
        }
      }
      
      // Son okuma tarihi
      DateTime? lastReadDate;
      if (monthlyAnalytics.isNotEmpty) {
        // En son okunan makale tarihini bul
        final lastAnalytics = monthlyAnalytics.last;
        if (lastAnalytics.articlesRead > 0) {
          lastReadDate = lastAnalytics.date;
        }
      }
      
      return UserStats(
        totalArticlesRead: totalArticlesRead,
        totalFavorites: favoritesCount,
        totalReadingList: readingListCount,
        streakDays: streakDays,
        categoryReadCount: categoryReadCount,
        lastReadDate: lastReadDate,
      );
    } catch (e) {
      debugPrint('💥 İstatistik hesaplama hatası: $e');
      // Hata durumunda boş istatistikler döndür
      return UserStats.empty;
    }
  }
}

