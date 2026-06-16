import 'package:flutter/foundation.dart';

/// Gelişmiş Logger Servisi
///
/// Farklı log seviyeleri destekler:
/// - [LogLevel.debug]: Geliştirme aşamasında detaylı log
/// - [LogLevel.info]: Bilgilendirme amaçlı log
/// - [LogLevel.warning]: Uyarı seviyesinde log
/// - [LogLevel.error]: Hata seviyesinde log
/// - [LogLevel.critical]: Kritik hata - Firebase Crashlytics'e gönderilir
///
/// Debug modda renkli console çıktısı verir.
/// Release modda sadece warning ve üstü loglanır.
/// Critical loglar Firebase Crashlytics'e gönderilir.
class LoggerService {
  LoggerService._internal();

  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;

  /// Minimum log seviyesi - bu seviyenin altındaki loglar gösterilmez
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.warning;

  /// Crashlytics callback - kritik hataları Firebase'e gönderir
  /// DI ile inject edilir, böylece CrashlyticsService'e doğrudan bağımlılık yoktur
  Future<void> Function(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal,
  })?
  _crashlyticsCallback;

  /// Log geçmişi (debug modda son N log tutulur)
  final List<LogEntry> _logHistory = [];
  static const int _maxHistorySize = 100;

  /// Minimum log seviyesini ayarla
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Crashlytics callback'ini ayarla
  ///
  /// Kullanım:
  /// ```dart
  /// loggerService.setCrashlyticsCallback(
  ///   (error, stackTrace, {reason, fatal = false}) async {
  ///     await CrashlyticsService.logError(error, stackTrace, reason: reason, fatal: fatal);
  ///   },
  /// );
  /// ```
  void setCrashlyticsCallback(
    Future<void> Function(
      dynamic error,
      StackTrace? stackTrace, {
      String? reason,
      bool fatal,
    })
    callback,
  ) {
    _crashlyticsCallback = callback;
  }

  /// Debug log - geliştirme aşamasında detaylı bilgi
  void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// Info log - bilgilendirme amaçlı
  void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// Warning log - uyarı seviyesi
  void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  /// Error log - hata seviyesi
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Critical log - kritik hata, Firebase Crashlytics'e gönderilir
  void critical(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.critical,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    // Release modda kritik logları Firebase Crashlytics'e gönder
    if (!kDebugMode && _crashlyticsCallback != null) {
      _crashlyticsCallback!(
        error ?? Exception(message),
        stackTrace,
        reason: message,
        fatal: false,
      );
    }
  }

  /// Network log - ağ işlemleri için
  void network(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag ?? 'NETWORK', icon: '🌐');
  }

  /// Performance log - performans metrikleri için
  void performance(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag ?? 'PERF', icon: '⚡');
  }

  /// Success log - başarılı işlemler için
  void success(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag, icon: '✅');
  }

  /// Log geçmişini al
  List<LogEntry> getHistory() => List.unmodifiable(_logHistory);

  /// Log geçmişini temizle
  void clearHistory() => _logHistory.clear();

  /// Ana log metodu
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    String? icon,
  }) {
    // Minimum seviye kontrolü
    if (level.index < _minLevel.index) return;

    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    // Geçmişe ekle
    if (kDebugMode) {
      _logHistory.add(entry);
      if (_logHistory.length > _maxHistorySize) {
        _logHistory.removeAt(0);
      }
    }

    // Console'a yaz
    final effectiveIcon = icon ?? level.icon;
    final tagPrefix = tag != null ? '[$tag] ' : '';
    final logMessage = '$effectiveIcon $tagPrefix$message';

    debugPrint(logMessage);

    if (error != null) {
      debugPrint('  Error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('  StackTrace: $stackTrace');
    }
  }
}

/// Log seviyeleri
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical;

  /// Log seviyesine ait ikon
  String get icon {
    switch (this) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🔥';
    }
  }

  /// Log seviyesi adı
  String get label {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.critical:
        return 'CRITICAL';
    }
  }
}

/// Tek bir log kaydı
class LogEntry {
  final LogLevel level;
  final String message;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  const LogEntry({
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
    required this.timestamp,
  });

  @override
  String toString() {
    final tagStr = tag != null ? '[$tag] ' : '';
    return '${level.icon} ${timestamp.toIso8601String()} $tagStr$message';
  }
}
