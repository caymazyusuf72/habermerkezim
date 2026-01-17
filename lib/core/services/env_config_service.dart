import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration service
/// Manages environment variables loaded from .env file
class EnvConfigService {
  static final EnvConfigService _instance = EnvConfigService._internal();
  factory EnvConfigService() => _instance;
  EnvConfigService._internal();

  bool _isInitialized = false;

  /// Initialize the environment configuration
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
    } catch (e) {
      // .env file might not exist in production
      // Use default values instead
      _isInitialized = true;
    }
  }

  /// Get a string value from environment
  String getString(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }

  /// Get an integer value from environment
  int getInt(String key, {int defaultValue = 0}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Get a boolean value from environment
  bool getBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Get a double value from environment
  double getDouble(String key, {double defaultValue = 0.0}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
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
    return Map.from(dotenv.env);
  }

  /// Check if environment is initialized
  bool get isInitialized => _isInitialized;
}