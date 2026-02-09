import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

import 'core/services/hive_service.dart';
import 'core/services/rss_sources_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_service.dart';
import 'core/services/custom_categories_service.dart';
import 'core/services/rss_health_check_service.dart';
import 'core/services/image_cache_service.dart';
import 'core/services/article_popularity_service.dart';
import 'core/services/gamification_service.dart';
import 'core/services/env_config_service.dart';
import 'presentation/app.dart';

/// Haber Merkezi uygulamasının giriş noktası
/// Hive database'i initialize eder ve Riverpod ile app'i başlatır
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // System UI overlay'i ayarla
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
    ),
  );
  
  try {
    // Firebase'i initialize et (sadece bir kez)
    debugPrint('🔄 Firebase initialize ediliyor...');
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase başarıyla initialize edildi');
    } else {
      debugPrint('ℹ️ Firebase zaten initialize edilmiş');
    }
    
    // Firebase Crashlytics'i başlat
    debugPrint('🔄 Firebase Crashlytics initialize ediliyor...');
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Async hataları yakala
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    debugPrint('✅ Firebase Crashlytics başarıyla initialize edildi');
    
    // Memory cache boyutunu optimize et (RAM tasarrufu için)
    debugPrint('🔄 Memory cache optimize ediliyor...');
    PaintingBinding.instance.imageCache.maximumSize = 50; // Varsayılan 1000'den 50'ye düşürüldü
    PaintingBinding.instance.imageCache.maximumSizeBytes = 25 * 1024 * 1024; // 25 MB (varsayılan 100 MB)
    debugPrint('✅ Memory cache optimize edildi');
    
    // Environment Config servisini initialize et
    debugPrint('🔄 Environment Config service initialize ediliyor...');
    await EnvConfigService().init();
    debugPrint('✅ Environment Config service başarıyla initialize edildi');
    
    // Hive database'i initialize et
    debugPrint('🔄 Hive database initialize ediliyor...');
    await HiveService.initialize();
    debugPrint('✅ Hive başarıyla initialize edildi');
    
    // Image Cache servisini initialize et
    debugPrint('🔄 Image Cache service initialize ediliyor...');
    await ImageCacheService().init();
    debugPrint('✅ Image Cache service başarıyla initialize edildi');
    
    // RSS Sources servisini initialize et
    debugPrint('🔄 RSS Sources service initialize ediliyor...');
    await RssSourcesService.init();
    debugPrint('✅ RSS Sources service başarıyla initialize edildi');
    
    // Custom Categories servisini initialize et
    debugPrint('🔄 Custom Categories service initialize ediliyor...');
    await CustomCategoriesService.init();
    debugPrint('✅ Custom Categories service başarıyla initialize edildi');
    
    // Analytics servisini initialize et
    debugPrint('🔄 Analytics service initialize ediliyor...');
    await AnalyticsService.init();
    debugPrint('✅ Analytics service başarıyla initialize edildi');
    
    // Article Popularity servisini initialize et
    debugPrint('🔄 Article Popularity service initialize ediliyor...');
    await ArticlePopularityService.init();
    debugPrint('✅ Article Popularity service başarıyla initialize edildi');
    
    // Gamification servisini initialize et
    debugPrint('🔄 Gamification service initialize ediliyor...');
    await GamificationService.instance.init();
    debugPrint('✅ Gamification service başarıyla initialize edildi');
    
    // Notification servisini initialize et
    debugPrint('🔄 Notification service initialize ediliyor...');
    await NotificationService().initialize();
    debugPrint('✅ Notification service başarıyla initialize edildi');
    
    // Widget servisini initialize et
    debugPrint('🔄 Widget service initialize ediliyor...');
    await WidgetService.initialize();
    debugPrint('✅ Widget service başarıyla initialize edildi');
    
    // RSS Health Check servisini başlat (6 saatte bir kontrol)
    debugPrint('🔄 RSS Health Check service başlatılıyor...');
    RssHealthCheckService().startPeriodicHealthCheck(
      interval: const Duration(hours: 6),
    );
    debugPrint('✅ RSS Health Check service başarıyla başlatıldı');
    
    // Uygulamayı başlat
    runApp(
      const ProviderScope(
        child: HaberMerkeziApp(),
      ),
    );
    
  } catch (e) {
    debugPrint('❌ Uygulama başlatma hatası: $e');
    
    // Hata durumunda basit hata ekranıyla uygulamayı başlat
    runApp(
      MaterialApp(
        title: 'Haber Merkezi - Hata',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Uygulama başlatılamadı',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Uygulamayı yeniden başlat
                    SystemNavigator.pop();
                  },
                  child: const Text('Yeniden Başlat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
