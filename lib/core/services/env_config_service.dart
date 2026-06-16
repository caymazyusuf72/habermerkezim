import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/env.dart';

/// Environment configuration service
/// Compile-time Env sınıfını birincil kaynak olarak kullanır.
/// flutter_dotenv yalnızca runtime override ihtiyacı için yedek olarak kalır.
class EnvConfigService {
  static final EnvConfigService _instance = EnvConfigService._internal();
  factory EnvConfigService() => _instance;
  EnvConfigService._internal();

  bool _isInitialized = false;
  bool _dotenvLoaded = false;

  /// Initialize the environment configuration
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await dotenv.load(fileName: '.env');
      _dotenvLoaded = true;
    } catch (e) {
      // .env dosyası yoksa (production APK gibi) compile-time değerler kullanılır
      _dotenvLoaded = false;
    }
    _isInitialized = true;
  }

  /// Get a string value - önce dotenv, sonra compile-time Env
  String getString(String key, {String defaultValue = ''}) {
    if (_dotenvLoaded) {
      final dotenvValue = dotenv.env[key];
      if (dotenvValue != null) return dotenvValue;
    }
    return _getEnvValue(key) ?? defaultValue;
  }

  /// Get an integer value from environment
  int getInt(String key, {int defaultValue = 0}) {
    final value = getString(key);
    if (value.isEmpty) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Get a boolean value from environment
  bool getBool(String key, {bool defaultValue = false}) {
    final value = getString(key);
    if (value.isEmpty) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Get a double value from environment
  double getDouble(String key, {double defaultValue = 0.0}) {
    final value = getString(key);
    if (value.isEmpty) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  /// Compile-time Env sınıfından değer döndürür
  String? _getEnvValue(String key) {
    switch (key) {
      case 'APP_NAME':
        return Env.appName;
      case 'APP_VERSION':
        return Env.appVersion;
      case 'DEBUG_MODE':
        return Env.debugMode;
      case 'RSS_CACHE_DURATION_MINUTES':
        return Env.rssCacheDurationMinutes;
      case 'RSS_REQUEST_TIMEOUT_SECONDS':
        return Env.rssRequestTimeoutSeconds;
      case 'ANALYTICS_ENABLED':
        return Env.analyticsEnabled;
      case 'FEATURE_GAMIFICATION':
        return Env.featureGamification;
      case 'FEATURE_DARK_MODE':
        return Env.featureDarkMode;
      case 'FEATURE_NOTIFICATIONS':
        return Env.featureNotifications;
      case 'FEATURE_OFFLINE_MODE':
        return Env.featureOfflineMode;
      case 'NEWS_API_KEY':
        return Env.newsApiKey;
      case 'WEATHER_API_KEY':
        return Env.weatherApiKey;
      case 'FIREBASE_API_KEY':
        return Env.firebaseApiKey;
      case 'FIREBASE_PROJECT_ID':
        return Env.firebaseProjectId;
      default:
        return null;
    }
  }

  // App Configuration
  String get appName => getString('APP_NAME', defaultValue: 'Haber Merkezi');
  String get appVersion => getString('APP_VERSION', defaultValue: '1.0.0');
  bool get debugMode => getBool('DEBUG_MODE', defaultValue: false);

  // API Keys
  String get newsApiKey => getString('NEWS_API_KEY');
  String get weatherApiKey => getString('WEATHER_API_KEY');

  // Firebase Configuration
  String get firebaseApiKey => getString('FIREBASE_API_KEY');
  String get firebaseProjectId => getString('FIREBASE_PROJECT_ID');

  // RSS Feed Configuration
  int get rssCacheDurationMinutes =>
      getInt('RSS_CACHE_DURATION_MINUTES', defaultValue: 15);
  int get rssRequestTimeoutSeconds =>
      getInt('RSS_REQUEST_TIMEOUT_SECONDS', defaultValue: 10);

  // Analytics
  bool get analyticsEnabled => getBool('ANALYTICS_ENABLED', defaultValue: true);

  // Feature Flags
  bool get featureGamification =>
      getBool('FEATURE_GAMIFICATION', defaultValue: true);
  bool get featureDarkMode => getBool('FEATURE_DARK_MODE', defaultValue: true);
  bool get featureNotifications =>
      getBool('FEATURE_NOTIFICATIONS', defaultValue: true);
  bool get featureOfflineMode =>
      getBool('FEATURE_OFFLINE_MODE', defaultValue: true);

  /// Check if a feature is enabled
  bool isFeatureEnabled(String featureName) {
    return getBool('FEATURE_$featureName', defaultValue: false);
  }

  /// Get all environment variables (for debugging)
  Map<String, String> getAllVariables() {
    if (!_isInitialized) return {};
    if (_dotenvLoaded) {
      return Map.from(dotenv.env);
    }
    return {};
  }

  /// Check if environment is initialized
  bool get isInitialized => _isInitialized;
}
