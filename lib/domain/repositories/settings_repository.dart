/// SettingsRepository - Domain layer interface
/// Uygulama ayarları işlemlerini yönetir
/// Clean Architecture'da business logic katmanının data katmanına bağımlılığı
abstract class SettingsRepository {
  /// Tüm ayarları getir
  Future<Map<String, dynamic>> getSettings();

  /// Belirli bir ayarı getir
  Future<T?> getSetting<T>(String key);

  /// Ayarı güncelle
  Future<void> updateSetting(String key, dynamic value);

  /// Birden fazla ayarı toplu güncelle
  Future<void> updateSettings(Map<String, dynamic> settings);

  /// Tema modunu getir (light/dark/system)
  Future<String> getThemeMode();

  /// Tema modunu güncelle
  Future<void> updateThemeMode(String themeMode);

  /// Dil tercihini getir
  Future<String> getLocale();

  /// Dil tercihini güncelle
  Future<void> updateLocale(String locale);

  /// Bildirim ayarlarını getir
  Future<Map<String, bool>> getNotificationSettings();

  /// Bildirim ayarlarını güncelle
  Future<void> updateNotificationSettings(Map<String, bool> settings);

  /// Tüm ayarları varsayılana sıfırla
  Future<void> resetToDefaults();
}