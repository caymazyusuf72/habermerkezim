import '../entities/user_profile.dart';

/// UserProfileRepository - Domain layer interface
/// Clean Architecture'da business logic'in data layer'a dependency'si
abstract class UserProfileRepository {
  /// Profili getir
  Future<UserProfile> getProfile();

  /// Profili kaydet
  Future<void> saveProfile(UserProfile profile);

  /// Profili güncelle
  Future<void> updateProfile(UserProfile profile);

  /// İstatistikleri güncelle (analytics'ten veri çekerek)
  Future<void> updateStatsFromAnalytics();

  /// Tercihleri güncelle
  Future<void> updatePreferences(UserPreferences preferences);

  /// İstatistikleri hesapla ve güncelle
  Future<UserStats> calculateStats();
}
