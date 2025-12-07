import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/hive_service.dart';
import 'core/services/rss_sources_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_service.dart';
import 'core/services/custom_categories_service.dart';
import 'core/services/rss_health_check_service.dart';
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
    // Hive database'i initialize et
    print('🔄 Hive database initialize ediliyor...');
    await HiveService.initialize();
    print('✅ Hive başarıyla initialize edildi');
    
    // RSS Sources servisini initialize et
    print('🔄 RSS Sources service initialize ediliyor...');
    await RssSourcesService.init();
    print('✅ RSS Sources service başarıyla initialize edildi');
    
    // Custom Categories servisini initialize et
    print('🔄 Custom Categories service initialize ediliyor...');
    await CustomCategoriesService.init();
    print('✅ Custom Categories service başarıyla initialize edildi');
    
    // Analytics servisini initialize et
    print('🔄 Analytics service initialize ediliyor...');
    await AnalyticsService.init();
    print('✅ Analytics service başarıyla initialize edildi');
    
    // Notification servisini initialize et
    print('🔄 Notification service initialize ediliyor...');
    await NotificationService().initialize();
    print('✅ Notification service başarıyla initialize edildi');
    
    // Widget servisini initialize et
    print('🔄 Widget service initialize ediliyor...');
    await WidgetService.initialize();
    print('✅ Widget service başarıyla initialize edildi');
    
    // RSS Health Check servisini başlat (6 saatte bir kontrol)
    print('🔄 RSS Health Check service başlatılıyor...');
    RssHealthCheckService().startPeriodicHealthCheck(
      interval: const Duration(hours: 6),
    );
    print('✅ RSS Health Check service başarıyla başlatıldı');
    
    // Uygulamayı başlat
    runApp(
      const ProviderScope(
        child: HaberMerkeziApp(),
      ),
    );
    
  } catch (e) {
    print('❌ Uygulama başlatma hatası: $e');
    
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
