import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Crashlytics servis sınıfı
/// Production'da hata izleme ve raporlama için kullanılır
class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Kullanıcı ID'sini ayarla
  /// Hata raporlarında kullanıcı bilgisini görmek için
  static Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  /// Custom key-value çiftleri ekle
  /// Hata raporlarına ek bağlam bilgisi eklemek için
  static Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Hata logla
  /// @param error - Hata nesnesi
  /// @param stackTrace - Stack trace bilgisi
  /// @param reason - Hatanın nedeni (opsiyonel)
  /// @param fatal - Fatal hata mı? (varsayılan: false)
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      // Debug modda console'a yaz
      debugPrint('❌ Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      if (reason != null) {
        debugPrint('Reason: $reason');
      }
    }
    
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Log mesajı ekle
  /// Hata öncesi olayların izlenmesi için breadcrumb oluşturur
  static Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// Test crash (development için)
  /// NOT: Sadece test amaçlı kullanılmalı, production'da KULLANMAYIN
  static void testCrash() {
    _crashlytics.crash();
  }

  /// Crashlytics'i etkinleştir/devre dışı bırak
  /// @param enabled - true ise etkinleştirir, false ise devre dışı bırakır
  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  /// Kullanıcı oturumu bilgisi ekle
  /// @param sessionData - Oturum bilgileri (örn: uygulama versiyonu, cihaz bilgisi)
  static Future<void> setSessionData(Map<String, dynamic> sessionData) async {
    for (final entry in sessionData.entries) {
      await setCustomKey(entry.key, entry.value);
    }
  }
}