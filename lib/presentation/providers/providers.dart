import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/news_local_data_source.dart';
import '../../core/utils/app_logger.dart';
import '../../data/datasources/local/user_profile_local_data_source.dart';
import '../../data/datasources/remote/rss_remote_data_source.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
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
export 'user_profile_provider.dart';
export 'update_provider.dart';
export 'onboarding_provider.dart';
export 'personalized_news_provider.dart';

/// Dependency Injection - Tüm provider'ları burada tanımlıyoruz
/// Clean Architecture'da dependency direction'ını sağlıyoruz

// Data Sources
final rssRemoteDataSourceProvider = Provider<RssRemoteDataSource>((ref) {
  return RssRemoteDataSourceImpl();
});

final newsLocalDataSourceProvider = Provider<NewsLocalDataSource>((ref) {
  return NewsLocalDataSourceImpl();
});

final userProfileLocalDataSourceProvider = Provider<UserProfileLocalDataSource>(
  (ref) {
    return UserProfileLocalDataSourceImpl();
  },
);

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
  AppLogger.info('App initialization basliyor...');

  // Minimum splash süresi (0.3 saniye) - çok hızlı açılış
  await Future.delayed(const Duration(milliseconds: 300));

  AppLogger.success('App initialization tamamlandi');

  // Initialization tamamlandıktan SONRA haberleri yükle
  // Future.microtask ile Riverpod build cycle dışına çıkıyoruz
  Future.microtask(() async {
    try {
      AppLogger.performance('Cache\'den hızlı yükleme...');
      await ref.read(newsProvider.notifier).loadAllArticles(refresh: false);
      AppLogger.success('Cache\'den haberler yüklendi');
    } catch (e) {
      AppLogger.warning('Cache yükleme hatası: $e');
    }

    // Arka planda güncelle (refresh: true) - timeout ile
    try {
      AppLogger.info('Arka planda güncelleme başlatılıyor...');
      await ref
          .read(newsProvider.notifier)
          .loadAllArticles(refresh: true)
          .timeout(const Duration(seconds: 15));
      AppLogger.success('Arka plan güncelleme tamamlandı');
    } catch (e) {
      if (e.toString().contains('timeout') ||
          e.toString().contains('Timeout')) {
        AppLogger.warning('Arka plan güncelleme timeout (15 saniye)');
      } else {
        AppLogger.warning('Arka plan güncelleme hatası: $e');
      }
    }
  });
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

// ============================================================================
// SELECTOR PROVIDERS - Performans için granüler state erişimi
// ============================================================================

/// Sadece loading durumunu izler - gereksiz rebuild'leri önler
final newsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(newsProvider.select((state) => state.isLoading));
});

/// Sadece loadingMore durumunu izler
final newsLoadingMoreProvider = Provider<bool>((ref) {
  return ref.watch(newsProvider.select((state) => state.isLoadingMore));
});

/// Sadece hata durumunu izler
final newsErrorProvider = Provider<String?>((ref) {
  return ref.watch(newsProvider.select((state) => state.errorMessage));
});

/// Sadece hasMore durumunu izler
final newsHasMoreProvider = Provider<bool>((ref) {
  return ref.watch(newsProvider.select((state) => state.hasMore));
});

/// Sadece makale sayısını izler
final newsArticleCountProvider = Provider<int>((ref) {
  return ref.watch(newsProvider.select((state) => state.articles.length));
});

/// Kategoriye göre filtrelenmiş makaleleri döndürür
final categoryArticlesProvider = Provider.family<List<Article>, String>((
  ref,
  category,
) {
  final articles = ref.watch(newsProvider.select((state) => state.articles));

  if (category == 'genel') {
    return articles;
  }

  return articles.where((article) => article.category == category).toList();
});

/// Belirli bir makaleyi ID'ye göre döndürür
final articleByIdProvider = Provider.family<Article?, String>((ref, articleId) {
  final articles = ref.watch(newsProvider.select((state) => state.articles));

  try {
    return articles.firstWhere((article) => article.id == articleId);
  } catch (e) {
    return null;
  }
});

/// Okunmamış makale sayısını döndürür
final unreadArticleCountProvider = Provider<int>((ref) {
  return ref.watch(
    newsProvider.select(
      (state) => state.articles.where((article) => !article.isRead).length,
    ),
  );
});

/// Favori makale sayısını döndürür
final favoriteArticleCountProvider = Provider<int>((ref) {
  return ref.watch(
    newsProvider.select(
      (state) => state.articles.where((article) => article.isFavorite).length,
    ),
  );
});

/// Son güncelleme zamanını döndürür (en son makalenin tarihi)
final lastUpdateTimeProvider = Provider<DateTime?>((ref) {
  final articles = ref.watch(newsProvider.select((state) => state.articles));

  if (articles.isEmpty) return null;

  return articles
      .map((a) => a.publishedDate)
      .reduce((a, b) => a.isAfter(b) ? a : b);
});

/// Kategorilere göre makale sayılarını döndürür
final categoryCountsProvider = Provider<Map<String, int>>((ref) {
  final articles = ref.watch(newsProvider.select((state) => state.articles));

  final counts = <String, int>{};
  for (final article in articles) {
    counts[article.category] = (counts[article.category] ?? 0) + 1;
  }

  return counts;
});

/// Kaynaklara göre makale sayılarını döndürür
final sourceCountsProvider = Provider<Map<String, int>>((ref) {
  final articles = ref.watch(newsProvider.select((state) => state.articles));

  final counts = <String, int>{};
  for (final article in articles) {
    counts[article.sourceName] = (counts[article.sourceName] ?? 0) + 1;
  }

  return counts;
});

/// Bugünkü makale sayısını döndürür
final todayArticleCountProvider = Provider<int>((ref) {
  final articles = ref.watch(newsProvider.select((state) => state.articles));
  final today = DateTime.now();

  return articles.where((article) {
    final articleDate = article.publishedDate;
    return articleDate.year == today.year &&
        articleDate.month == today.month &&
        articleDate.day == today.day;
  }).length;
});

/// Pagination bilgilerini döndürür
final paginationInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(newsProvider);

  return {
    'currentPage': state.currentPage,
    'hasMore': state.hasMore,
    'totalLoaded': state.articles.length,
    'totalAvailable': state.allArticles.length,
  };
});
