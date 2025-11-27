import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../../core/services/widget_service.dart';
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