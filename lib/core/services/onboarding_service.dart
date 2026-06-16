import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding durumunu yöneten servis
/// İlk giriş kontrolü yapar
class OnboardingService {
  OnboardingService._();

  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';

  /// Onboarding tamamlanmış mı kontrol et
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  /// Onboarding'i tamamlandı olarak işaretle
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, true);
  }

  /// Onboarding durumunu sıfırla (test/debug için)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasCompletedOnboardingKey);
  }
}
