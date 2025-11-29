import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/news_local_data_source.dart';
import '../../data/datasources/remote/rss_remote_data_source.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/repositories/news_repository.dart';
import 'news_provider.dart';

// Export specific providers only
export 'news_provider.dart';
export 'theme_provider.dart';
export 'search_provider.dart';
export 'favorites_provider.dart';
export 'notification_provider.dart';
export 'notification_banner_provider.dart';
export 'category_order_provider.dart';
export 'reading_list_provider.dart';
export 'article_filter_provider.dart';

/// Dependency Injection - Tüm provider'ları burada tanımlıyoruz
/// Clean Architecture'da dependency direction'ını sağlıyoruz

// Data Sources
final rssRemoteDataSourceProvider = Provider<RssRemoteDataSource>((ref) {
  return RssRemoteDataSourceImpl();
});

final newsLocalDataSourceProvider = Provider<NewsLocalDataSource>((ref) {
  return NewsLocalDataSourceImpl();
});


// Repository
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    remoteDataSource: ref.read(rssRemoteDataSourceProvider),
    localDataSource: ref.read(newsLocalDataSourceProvider),
    connectivity: Connectivity(),
  );
});

/// Uygulama başlangıcında çağrılacak initialization provider
final appInitializationProvider = FutureProvider<void>((ref) async {
  print('App initialization basliyor...');
  
  // Minimum splash süresi (2 saniye) - kullanıcı deneyimi için
  final minSplashDuration = Future.delayed(const Duration(seconds: 2));
  
  try {
    // RSS feedleri yukle - timeout ile (10 saniye)
    print('RSS feedleri yukleniyor...');
    final loadArticlesFuture = ref.read(newsProvider.notifier).loadAllArticles(refresh: true);
    
    // Timeout ekle - 10 saniye içinde yüklenmezse devam et
    try {
      await loadArticlesFuture.timeout(
        const Duration(seconds: 10),
      );
      print('✅ RSS feedleri basariyla yuklendi');
    } on TimeoutException {
      print('⚠️ RSS yukleme timeout oldu (10 saniye), cache\'den devam ediliyor');
    } catch (e) {
      print('⚠️ RSS yukleme hatasi (network veya diger): $e');
    }
    
    // Minimum splash süresini bekle (eğer henüz geçmediyse)
    await minSplashDuration;
    
    print('RSS feedleri basariyla yuklendi');
    
  } catch (e) {
    print('RSS yukleme hatasi: $e');
    // Hata durumunda minimum splash süresini bekle
    await minSplashDuration;
    // Hata durumunda bos geciyoruz, kullanici manuel refresh yapabilir
  }
  
  print('App initialization tamamlandi');
});

/// App lifecycle provider - uygulama yaşam döngüsünü izler
final appLifecycleProvider = StateProvider<bool>((ref) => true);

/// Debug mode provider - development sırasında debug bilgileri göstermek için
final debugModeProvider = Provider<bool>((ref) {
  // Release mode'da false, debug mode'da true
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
});

/// Performance monitoring provider
final performanceProvider = StateProvider<Map<String, dynamic>>((ref) => {});