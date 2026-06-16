import 'package:flutter/foundation.dart';

/// Uygulama logger'ı - production'da debug log'ları kapatır
class AppLogger {
  AppLogger._();

  /// Debug mode kontrolü
  static bool get isDebugMode {
    bool debug = false;
    assert(debug = true);
    return debug;
  }

  /// Debug log - sadece debug mode'da çalışır
  static void debug(String message) {
    if (isDebugMode) {
      debugPrint(message);
    }
  }

  /// Info log - önemli bilgiler için (production'da da çalışır ama minimal)
  static void info(String message) {
    if (isDebugMode) {
      debugPrint('ℹ️ $message');
    }
  }

  /// Warning log - uyarılar için (her zaman çalışır)
  static void warning(String message) {
    debugPrint('⚠️ $message');
  }

  /// Error log - hatalar için (her zaman çalışır)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('❌ $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null && isDebugMode) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Success log - başarılı işlemler için (sadece debug mode)
  static void success(String message) {
    if (isDebugMode) {
      debugPrint('✅ $message');
    }
  }

  /// Network log - network işlemleri için (sadece debug mode)
  static void network(String message) {
    if (isDebugMode) {
      debugPrint('🌐 $message');
    }
  }

  /// Performance log - performans metrikleri için (sadece debug mode)
  static void performance(String message) {
    if (isDebugMode) {
      debugPrint('⚡ $message');
    }
  }
}
