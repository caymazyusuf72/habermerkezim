import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/news_local_data_source.dart';
import '../../data/datasources/local/user_profile_local_data_source.dart';
import '../../data/datasources/remote/rss_remote_data_source.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import 'news_provider.dart';
import 'user_profile_provider.dart';

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
export 'user_profile_provider.dart';

/// Dependency Injection - Tüm provider'ları burada tanımlıyoruz
/// Clean Architecture'da dependency direction'ını sağlıyoruz

// Data Sources
final rssRemoteDataSourceProvider = Provider<RssRemoteDataSource>((ref) {
  return RssRemoteDataSourceImpl();
});

final newsLocalDataSourceProvider = Provider<NewsLocalDataSource>((ref) {
  return NewsLocalDataSourceImpl();
});

final userProfileLocalDataSourceProvider = Provider<UserProfileLocalDataSource>((ref) {
  return UserProfileLocalDataSourceImpl();
});

// Repository
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    remoteDataSource: ref.read(rssRemoteDataSourceProvider),
    localDataSource: ref.read(newsLocalDataSourceProvider),
    connectivity: Connectivity(),
  );
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(
    localDataSource: ref.read(userProfileLocalDataSourceProvider),
  );
});

/// Uygulama başlangıcında çağrılacak initialization provider
/// Cache'den hızlı göster, arka planda güncelle
final appInitializationProvider = FutureProvider<void>((ref) async {
  print('🔄 App initialization basliyor...');
  
  // Minimum splash süresi (0.8 saniye) - daha hızlı açılış
  final minSplashDuration = Future.delayed(const Duration(milliseconds: 800));
  
  try {
    // ÖNCE: Cache'den hızlıca yükle (refresh: false)
    print('⚡ Cache\'den hızlı yükleme...');
    try {
      await ref.read(newsProvider.notifier).loadAllArticles(refresh: false);
      print('✅ Cache\'den haberler yüklendi');
    } catch (e) {
      print('⚠️ Cache yükleme hatası: $e');
    }
    
    // Minimum splash süresini bekle
    await minSplashDuration;
    
    // SONRA: Arka planda güncelle (refresh: true) - timeout ile
    print('🔄 Arka planda güncelleme başlatılıyor...');
    Future.microtask(() async {
      try {
        await ref.read(newsProvider.notifier)
            .loadAllArticles(refresh: true)
            .timeout(const Duration(seconds: 15));
        print('✅ Arka plan güncelleme tamamlandı');
      } catch (e) {
        if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
          print('⚠️ Arka plan güncelleme timeout (15 saniye)');
        } else {
          print('⚠️ Arka plan güncelleme hatası: $e');
        }
      }
    });
    
  } catch (e) {
    print('⚠️ App initialization hatasi: $e');
    // Hata durumunda minimum splash süresini bekle
    await minSplashDuration;
  }
  
  print('✅ App initialization tamamlandi');
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