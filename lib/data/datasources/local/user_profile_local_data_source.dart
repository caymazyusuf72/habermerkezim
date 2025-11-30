import 'package:hive/hive.dart';

import '../../../core/services/hive_service.dart';
import '../../../domain/entities/user_profile.dart';
import '../../models/user_profile_model.dart';

/// Kullanıcı profil verilerini yerel olarak saklayan data source
/// Hive database kullanır
abstract class UserProfileLocalDataSource {
  Future<void> saveProfile(UserProfile profile);
  Future<UserProfile?> getProfile();
  Future<void> updateProfile(UserProfile profile);
  Future<void> deleteProfile();
  Future<void> updateStats(UserStats stats);
  Future<void> updatePreferences(UserPreferences preferences);
}

class UserProfileLocalDataSourceImpl implements UserProfileLocalDataSource {
  static const String _profileKey = 'current_profile';

  /// Hive box'ını al
  Box<UserProfileModel> get _box => HiveService.userProfileBox;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    try {
      print('💾 Profil kaydediliyor: ${profile.id}');
      final model = UserProfileModel.fromEntity(profile);
      await _box.put(_profileKey, model);
      print('✅ Profil başarıyla kaydedildi');
    } catch (e) {
      print('💥 Profil kaydetme hatası: $e');
      throw Exception('Profil kaydedilemedi: ${e.toString()}');
    }
  }

  @override
  Future<UserProfile?> getProfile() async {
    try {
      print('💾 Profil okunuyor...');
      final model = _box.get(_profileKey);
      
      if (model == null) {
        print('⚠️ Profil bulunamadı, varsayılan profil döndürülüyor');
        return null;
      }
      
      final profile = model.toEntity();
      print('✅ Profil başarıyla okundu: ${profile.id}');
      return profile;
    } catch (e) {
      print('💥 Profil okuma hatası: $e');
      throw Exception('Profil okunamadı: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      print('🔄 Profil güncelleniyor: ${profile.id}');
      final model = UserProfileModel.fromEntity(profile);
      await _box.put(_profileKey, model);
      print('✅ Profil başarıyla güncellendi');
    } catch (e) {
      print('💥 Profil güncelleme hatası: $e');
      throw Exception('Profil güncellenemedi: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProfile() async {
    try {
      print('🗑️ Profil siliniyor...');
      await _box.delete(_profileKey);
      print('✅ Profil başarıyla silindi');
    } catch (e) {
      print('💥 Profil silme hatası: $e');
      throw Exception('Profil silinemedi: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStats(UserStats stats) async {
    try {
      print('📊 İstatistikler güncelleniyor...');
      final currentModel = _box.get(_profileKey);
      
      if (currentModel == null) {
        // Profil yoksa varsayılan profil oluştur
        final defaultProfile = UserProfile.defaultProfile.copyWith(
          stats: stats,
        );
        await saveProfile(defaultProfile);
        return;
      }
      
      final currentProfile = currentModel.toEntity();
      final updatedProfile = currentProfile.copyWith(stats: stats);
      await updateProfile(updatedProfile);
      print('✅ İstatistikler başarıyla güncellendi');
    } catch (e) {
      print('💥 İstatistik güncelleme hatası: $e');
      throw Exception('İstatistikler güncellenemedi: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      print('⚙️ Tercihler güncelleniyor...');
      final currentModel = _box.get(_profileKey);
      
      if (currentModel == null) {
        // Profil yoksa varsayılan profil oluştur
        final defaultProfile = UserProfile.defaultProfile.copyWith(
          preferences: preferences,
        );
        await saveProfile(defaultProfile);
        return;
      }
      
      final currentProfile = currentModel.toEntity();
      final updatedProfile = currentProfile.copyWith(preferences: preferences);
      await updateProfile(updatedProfile);
      print('✅ Tercihler başarıyla güncellendi');
    } catch (e) {
      print('💥 Tercih güncelleme hatası: $e');
      throw Exception('Tercihler güncellenemedi: ${e.toString()}');
    }
  }
}

