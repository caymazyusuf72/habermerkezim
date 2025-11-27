import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../../core/services/widget_service.dart';
import '../../core/services/breaking_news_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/hive_service.dart';
import 'providers.dart';

/// News State - haber listesinin durumunu tutar
class NewsState {
  final List<Article> articles;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  const NewsState({
    this.articles = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 1,
  });

  NewsState copyWith({
    List<Article>? articles,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  bool get isEmpty => articles.isEmpty && !isLoading;
  bool get isError => errorMessage != null;
  bool get hasError => errorMessage != null;
  bool get hasData => articles.isNotEmpty;
  bool get hasArticles => articles.isNotEmpty;
  
  // Compatibility property
  Exception? get error => errorMessage != null ? Exception(errorMessage!) : null;
}

/// News StateNotifier - haber işlemlerini yönetir
class NewsNotifier extends StateNotifier<NewsState> {
  final NewsRepository _repository;

  NewsNotifier(this._repository) : super(const NewsState());

  /// Tüm haberleri yükler
  Future<void> loadAllArticles({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    } else if (!state.isEmpty) {
      return; // Already loaded
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final articles = await _repository.getAllArticles();
      state = state.copyWith(
        articles: articles,
        isLoading: false,
        errorMessage: null,
      );
      
      // Widget'ı güncelle
      WidgetService.updateWidget(articles);
      
      // Breaking news kontrolü ve bildirim gönderimi
      _checkAndNotifyBreakingNews(articles);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Kategori bazında haberleri yükler
  Future<void> loadArticlesByCategory(String category, {bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final articles = await _repository.getArticlesByCategory(category);
      state = state.copyWith(
        articles: articles,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Haberleri yenile (pull-to-refresh için)
  Future<void> refreshArticles([String? category]) async {
    if (category != null) {
      await loadArticlesByCategory(category, refresh: true);
    } else {
      await loadAllArticles(refresh: true);
    }
  }

  /// Kategori değiştirir ve o kategorinin haberlerini yükler
  Future<void> changeCategory(String category) async {
    await loadArticlesByCategory(category);
  }

  /// Makaleyi okundu olarak işaretle
  Future<void> markAsRead(String articleId) async {
    try {
      await _repository.markAsRead(articleId);
      
      // Update local state
      final updatedArticles = state.articles.map((article) {
        if (article.id == articleId) {
          return article.copyWith(isRead: true);
        }
        return article;
      }).toList();
      
      state = state.copyWith(articles: updatedArticles);
    } catch (e) {
      // Silently handle error for UX
      print('Failed to mark as read: $e');
    }
  }

  /// Favori durumunu değiştir
  Future<void> toggleFavorite(String articleId) async {
    try {
      await _repository.toggleFavorite(articleId);
      
      // Update local state
      final updatedArticles = state.articles.map((article) {
        if (article.id == articleId) {
          return article.copyWith(isFavorite: !article.isFavorite);
        }
        return article;
      }).toList();
      
      state = state.copyWith(articles: updatedArticles);
    } catch (e) {
      // Silently handle error for UX
      print('Failed to toggle favorite: $e');
    }
  }

  /// Hata durumunu temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Cache'i temizle
  Future<void> clearCache() async {
    try {
      await _repository.clearCache();
      state = const NewsState();
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }

  /// Breaking news kontrolü ve bildirim gönderimi
  Future<void> _checkAndNotifyBreakingNews(List<Article> articles) async {
    try {
      final breakingNewsService = BreakingNewsService();
      final notificationService = NotificationService();
      
      // Son 10 dakika içindeki haberleri kontrol et
      final now = DateTime.now();
      final recentArticles = articles.where((article) {
        final diff = now.difference(article.publishedDate);
        return diff.inMinutes <= 10;
      }).toList();
      
      // Breaking news'leri filtrele
      final breakingNews = breakingNewsService.filterBreakingNews(recentArticles);
      
      if (breakingNews.isNotEmpty) {
        // En yüksek öncelikli breaking news'i al
        breakingNews.sort((a, b) {
          final priorityA = breakingNewsService.calculatePriority(a);
          final priorityB = breakingNewsService.calculatePriority(b);
          return priorityB.compareTo(priorityA);
        });
        
        final topBreakingNews = breakingNews.first;
        
        // Bildirim sıklığı kontrolü
        if (await _canSendNotification()) {
          await notificationService.showBreakingNewsNotification(
            title: topBreakingNews.title,
            summary: topBreakingNews.description,
            articleId: topBreakingNews.id,
          );
          
          // Son bildirim zamanını kaydet
          await _saveLastNotificationTime();
        }
      }
    } catch (e) {
      print('⚠️ Breaking news kontrolü hatası: $e');
    }
  }
  
  /// Bildirim gönderilebilir mi kontrol et (saatte max 3 bildirim)
  Future<bool> _canSendNotification() async {
    try {
      final box = HiveService.notificationFrequencyBox;
      final lastNotificationTimes = box.get('lastNotificationTimes', defaultValue: <int>[]) as List<dynamic>?;
      
      if (lastNotificationTimes == null || lastNotificationTimes.isEmpty) {
        return true;
      }
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneHourAgo = now - (60 * 60 * 1000);
      
      // Son 1 saat içindeki bildirimleri filtrele
      final recentNotifications = lastNotificationTimes
          .where((time) => (time as int) > oneHourAgo)
          .toList();
      
      // Saatte max 3 bildirim
      return recentNotifications.length < 3;
    } catch (e) {
      print('⚠️ Bildirim sıklığı kontrolü hatası: $e');
      return true; // Hata durumunda bildirim gönder
    }
  }
  
  /// Son bildirim zamanını kaydet
  Future<void> _saveLastNotificationTime() async {
    try {
      final box = HiveService.notificationFrequencyBox;
      final lastNotificationTimes = box.get('lastNotificationTimes', defaultValue: <int>[]) as List<dynamic>?;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final updatedTimes = List<int>.from(lastNotificationTimes ?? []);
      updatedTimes.add(now);
      
      // Son 24 saat içindeki bildirimleri tut
      final oneDayAgo = now - (24 * 60 * 60 * 1000);
      final filteredTimes = updatedTimes.where((time) => time > oneDayAgo).toList();
      
      await box.put('lastNotificationTimes', filteredTimes);
    } catch (e) {
      print('⚠️ Bildirim zamanı kaydetme hatası: $e');
    }
  }

  /// State'i sıfırla
  void reset() {
    state = const NewsState();
  }
}

/// News provider - StateNotifierProvider
final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  final repository = ref.read(newsRepositoryProvider);
  return NewsNotifier(repository);
});

/// Favorite articles provider
final favoriteArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final repository = ref.read(newsRepositoryProvider);
  return await repository.getFavoriteArticles();
});

/// Is connected provider
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(newsRepositoryProvider);
  return await repository.isConnected();
});