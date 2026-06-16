import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'APP_NAME', defaultValue: 'Haber Merkezi')
  static final String appName = _Env.appName;

  @EnviedField(varName: 'APP_VERSION', defaultValue: '1.0.0')
  static final String appVersion = _Env.appVersion;

  @EnviedField(varName: 'DEBUG_MODE', defaultValue: 'false')
  static final String debugMode = _Env.debugMode;

  @EnviedField(varName: 'RSS_CACHE_DURATION_MINUTES', defaultValue: '15')
  static final String rssCacheDurationMinutes = _Env.rssCacheDurationMinutes;

  @EnviedField(varName: 'RSS_REQUEST_TIMEOUT_SECONDS', defaultValue: '10')
  static final String rssRequestTimeoutSeconds = _Env.rssRequestTimeoutSeconds;

  @EnviedField(varName: 'ANALYTICS_ENABLED', defaultValue: 'true')
  static final String analyticsEnabled = _Env.analyticsEnabled;

  @EnviedField(varName: 'FEATURE_GAMIFICATION', defaultValue: 'true')
  static final String featureGamification = _Env.featureGamification;

  @EnviedField(varName: 'FEATURE_DARK_MODE', defaultValue: 'true')
  static final String featureDarkMode = _Env.featureDarkMode;

  @EnviedField(varName: 'FEATURE_NOTIFICATIONS', defaultValue: 'true')
  static final String featureNotifications = _Env.featureNotifications;

  @EnviedField(varName: 'FEATURE_OFFLINE_MODE', defaultValue: 'true')
  static final String featureOfflineMode = _Env.featureOfflineMode;

  @EnviedField(varName: 'NEWS_API_KEY', defaultValue: '')
  static final String newsApiKey = _Env.newsApiKey;

  @EnviedField(varName: 'WEATHER_API_KEY', defaultValue: '')
  static final String weatherApiKey = _Env.weatherApiKey;

  @EnviedField(varName: 'FIREBASE_API_KEY', defaultValue: '')
  static final String firebaseApiKey = _Env.firebaseApiKey;

  @EnviedField(varName: 'FIREBASE_PROJECT_ID', defaultValue: '')
  static final String firebaseProjectId = _Env.firebaseProjectId;
}
