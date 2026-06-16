import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import 'providers.dart';

/// Favoriler durumunu yönetir
class FavoritesState {
  final List<Article> favoriteArticles;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favoriteArticles = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<Article>? favoriteArticles,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favoriteArticles: favoriteArticles ?? this.favoriteArticles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get hasFavorites => favoriteArticles.isNotEmpty;
  bool get hasError => error != null;
  int get favoritesCount => favoriteArticles.length;

  // Export/Import için ek getter
  List<Article> get articles => favoriteArticles;

  /// Makale favori mi kontrol et
  bool isFavorite(String articleId) {
    return favoriteArticles.any((article) => article.id == articleId);
  }
}

/// Favoriler provider'ı - favori makaleleri yönetir
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier(this._ref) : super(const FavoritesState()) {
    loadFavorites();
  }

  final Ref _ref;

  /// Tüm favori makaleleri yükle
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = _ref.read(newsRepositoryProvider);
      final favorites = await repository.getFavoriteArticles();

      state = state.copyWith(favoriteArticles: favorites, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Favoriler yüklenirken hata oluştu: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Makaleyi favorilere ekle
  Future<void> addToFavorites(Article article) async {
    // Zaten favori mi kontrol et
    if (state.isFavorite(article.id)) {
      return;
    }

    try {
      final repository = _ref.read(newsRepositoryProvider);
      await repository.toggleFavorite(article.id);

      // State'i güncelle
      final updatedFavorites = List<Article>.from(state.favoriteArticles);
      updatedFavorites.insert(0, article); // En başa ekle

      state = state.copyWith(favoriteArticles: updatedFavorites, error: null);
    } catch (e) {
      state = state.copyWith(
        error: 'Favorilere eklenirken hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Makaleyi favorilerden çıkar
  Future<void> removeFromFavorites(String articleId) async {
    try {
      final repository = _ref.read(newsRepositoryProvider);
      await repository.toggleFavorite(articleId);

      // State'i güncelle
      final updatedFavorites = state.favoriteArticles
          .where((article) => article.id != articleId)
          .toList();

      state = state.copyWith(favoriteArticles: updatedFavorites, error: null);
    } catch (e) {
      state = state.copyWith(
        error: 'Favorilerden çıkarılırken hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Favori durumunu değiştir (toggle)
  Future<void> toggleFavorite(Article article) async {
    if (state.isFavorite(article.id)) {
      await removeFromFavorites(article.id);
    } else {
      await addToFavorites(article);
    }
  }

  /// Tüm favorileri temizle
  Future<void> clearAllFavorites() async {
    try {
      final repository = _ref.read(newsRepositoryProvider);

      // Tüm favori makaleleri tek tek kaldır
      for (final article in state.favoriteArticles) {
        await repository.toggleFavorite(article.id);
      }

      state = state.copyWith(favoriteArticles: [], error: null);
    } catch (e) {
      state = state.copyWith(
        error: 'Favoriler temizlenirken hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Favori makaleyi ID ile bul
  Article? getFavoriteById(String articleId) {
    try {
      return state.favoriteArticles.firstWhere(
        (article) => article.id == articleId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Favorileri tarihe göre sırala (en yeni en üstte)
  void sortFavoritesByDate() {
    final sortedFavorites = List<Article>.from(state.favoriteArticles);
    sortedFavorites.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));

    state = state.copyWith(favoriteArticles: sortedFavorites);
  }

  /// Favorileri başlığa göre sırala
  void sortFavoritesByTitle() {
    final sortedFavorites = List<Article>.from(state.favoriteArticles);
    sortedFavorites.sort((a, b) => a.title.compareTo(b.title));

    state = state.copyWith(favoriteArticles: sortedFavorites);
  }

  /// Favorileri kaynağa göre sırala
  void sortFavoritesBySource() {
    final sortedFavorites = List<Article>.from(state.favoriteArticles);
    sortedFavorites.sort((a, b) => a.sourceName.compareTo(b.sourceName));

    state = state.copyWith(favoriteArticles: sortedFavorites);
  }
}

/// Favorites provider'ı
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
      return FavoritesNotifier(ref);
    });

/// Tek bir makalenin favori durumunu kontrol eden provider
final isFavoriteProvider = Provider.family<bool, String>((ref, articleId) {
  final favoritesState = ref.watch(favoritesProvider);
  return favoritesState.isFavorite(articleId);
});

/// Favori sayısını dönen provider
final favoritesCountProvider = Provider<int>((ref) {
  final favoritesState = ref.watch(favoritesProvider);
  return favoritesState.favoritesCount;
});
