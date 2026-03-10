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
    // === ADIM 1: Firebase (diğer servisler için gerekli) ===
    debugPrint('🔄 Firebase initialize ediliyor...');
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase başarıyla initialize edildi');
    } else {
      debugPrint('ℹ️ Firebase zaten initialize edilmiş');
    }
    
    // === ADIM 2: Senkron ayarlar (Crashlytics + Memory Cache) ===
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    debugPrint('✅ Firebase Crashlytics callback\'leri ayarlandı');
    
    PaintingBinding.instance.imageCache.maximumSize = 50;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 25 * 1024 * 1024;
    debugPrint('✅ Memory cache optimize edildi');
    
    // === ADIM 3: Bağımsız servisleri paralel başlat ===
    // Hive, EnvConfig, ImageCache, Notification, Widget birbirinden bağımsız
    debugPrint('🔄 Bağımsız servisler paralel başlatılıyor...');
    await Future.wait([
      HiveService.initialize(),
      EnvConfigService().init(),
      ImageCacheService().init(),
      NotificationService().initialize(),
      WidgetService.initialize(),
    ]);
    debugPrint('✅ Bağımsız servisler başarıyla initialize edildi');
    
    // === ADIM 4: Hive'a bağımlı servisleri paralel başlat ===
    // Hive artık hazır, Hive box kullanan servisleri paralel başlat
    debugPrint('🔄 Hive-bağımlı servisler paralel başlatılıyor...');
    await Future.wait([
      RssSourcesService.init(),
      CustomCategoriesService.init(),
      AnalyticsService.init(),
      ArticlePopularityService.init(),
      GamificationService.instance.init(),
    ]);
    debugPrint('✅ Hive-bağımlı servisler başarıyla initialize edildi');
    
    // === ADIM 5: Periyodik görevleri başlat ===
    RssHealthCheckService().startPeriodicHealthCheck(
      interval: const Duration(hours: 6),
    );
    debugPrint('✅ RSS Health Check service başlatıldı');
    
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
