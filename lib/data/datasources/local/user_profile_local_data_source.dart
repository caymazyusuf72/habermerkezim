import 'package:hive/hive.dart';

import '../../../core/services/hive_service.dart';
import '../../../domain/entities/user_profile.dart';
import '../../models/user_profile_model.dart';

import 'package:flutter/foundation.dart';

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
      debugPrint('💾 Profil kaydediliyor: ${profile.id}');
      final model = UserProfileModel.fromEntity(profile);
      await _box.put(_profileKey, model);
      debugPrint('✅ Profil başarıyla kaydedildi');
    } catch (e) {
      debugPrint('💥 Profil kaydetme hatası: $e');
      throw Exception('Profil kaydedilemedi: ${e.toString()}');
    }
  }

  @override
  Future<UserProfile?> getProfile() async {
    try {
      debugPrint('💾 Profil okunuyor...');
      final model = _box.get(_profileKey);

      if (model == null) {
        debugPrint('⚠️ Profil bulunamadı, varsayılan profil döndürülüyor');
        return null;
      }

      final profile = model.toEntity();
      debugPrint('✅ Profil başarıyla okundu: ${profile.id}');
      return profile;
    } catch (e) {
      debugPrint('💥 Profil okuma hatası: $e');
      throw Exception('Profil okunamadı: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      debugPrint('🔄 Profil güncelleniyor: ${profile.id}');
      final model = UserProfileModel.fromEntity(profile);
      await _box.put(_profileKey, model);
      debugPrint('✅ Profil başarıyla güncellendi');
    } catch (e) {
      debugPrint('💥 Profil güncelleme hatası: $e');
      throw Exception('Profil güncellenemedi: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProfile() async {
    try {
      debugPrint('🗑️ Profil siliniyor...');
      await _box.delete(_profileKey);
      debugPrint('✅ Profil başarıyla silindi');
    } catch (e) {
      debugPrint('💥 Profil silme hatası: $e');
      throw Exception('Profil silinemedi: ${e.toString()}');
    }
  }

  @override
  Future<void> updateStats(UserStats stats) async {
    try {
      debugPrint('📊 İstatistikler güncelleniyor...');
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
      debugPrint('✅ İstatistikler başarıyla güncellendi');
    } catch (e) {
      debugPrint('💥 İstatistik güncelleme hatası: $e');
      throw Exception('İstatistikler güncellenemedi: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      debugPrint('⚙️ Tercihler güncelleniyor...');
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
      debugPrint('✅ Tercihler başarıyla güncellendi');
    } catch (e) {
      debugPrint('💥 Tercih güncelleme hatası: $e');
      throw Exception('Tercihler güncellenemedi: ${e.toString()}');
    }
  }
}
