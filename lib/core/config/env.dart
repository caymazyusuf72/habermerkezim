import 'package:envied/envied.dart';

part 'env.g.dart';

/// Compile-time environment variable yönetimi
/// .env dosyasındaki değişkenler build sırasında koda gömülür
/// Bu sayede .env dosyası APK'ya dahil edilmez
@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'APP_NAME', defaultValue: 'Haber Merkezi')
  static const String appName = _Env.appName;

  @EnviedField(varName: 'APP_VERSION', defaultValue: '1.0.0')
  static const String appVersion = _Env.appVersion;

  @EnviedField(varName: 'DEBUG_MODE', defaultValue: 'false')
  static const String debugMode = _Env.debugMode;

  @EnviedField(varName: 'RSS_CACHE_DURATION_MINUTES', defaultValue: '15')
  static const String rssCacheDurationMinutes = _Env.rssCacheDurationMinutes;

  @EnviedField(varName: 'RSS_REQUEST_TIMEOUT_SECONDS', defaultValue: '10')
  static const String rssRequestTimeoutSeconds = _Env.rssRequestTimeoutSeconds;

  @EnviedField(varName: 'ANALYTICS_ENABLED', defaultValue: 'true')
  static const String analyticsEnabled = _Env.analyticsEnabled;

  @EnviedField(varName: 'FEATURE_GAMIFICATION', defaultValue: 'true')
  static const String featureGamification = _Env.featureGamification;

  @EnviedField(varName: 'FEATURE_DARK_MODE', defaultValue: 'true')
  static const String featureDarkMode = _Env.featureDarkMode;

  @EnviedField(varName: 'FEATURE_NOTIFICATIONS', defaultValue: 'true')
  static const String featureNotifications = _Env.featureNotifications;

  @EnviedField(varName: 'FEATURE_OFFLINE_MODE', defaultValue: 'true')
  static const String featureOfflineMode = _Env.featureOfflineMode;

  @EnviedField(varName: 'NEWS_API_KEY', defaultValue: '')
  static const String newsApiKey = _Env.newsApiKey;

  @EnviedField(varName: 'WEATHER_API_KEY', defaultValue: '')
  static const String weatherApiKey = _Env.weatherApiKey;

  @EnviedField(varName: 'FIREBASE_API_KEY', defaultValue: '')
  static const String firebaseApiKey = _Env.firebaseApiKey;

  @EnviedField(varName: 'FIREBASE_PROJECT_ID', defaultValue: '')
  static const String firebaseProjectId = _Env.firebaseProjectId;
}