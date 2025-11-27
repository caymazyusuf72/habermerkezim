import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import 'providers.dart';

/// Arama durumunu yönetir
class SearchState {
  final List<Article> searchResults;
  final String searchQuery;
  final bool isSearching;
  final List<String> searchHistory;
  final String? error;

  const SearchState({
    this.searchResults = const [],
    this.searchQuery = '',
    this.isSearching = false,
    this.searchHistory = const [],
    this.error,
  });

  SearchState copyWith({
    List<Article>? searchResults,
    String? searchQuery,
    bool? isSearching,
    List<String>? searchHistory,
    String? error,
  }) {
    return SearchState(
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      searchHistory: searchHistory ?? this.searchHistory,
      error: error ?? this.error,
    );
  }

  bool get hasResults => searchResults.isNotEmpty;
  bool get hasError => error != null;
}

/// Arama provider'ı - makale arama işlevselliği
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._ref) : super(const SearchState()) {
    _loadSearchHistory();
  }

  final Ref _ref;

  /// Arama geçmişini yükle
  void _loadSearchHistory() async {
    try {
      final localDataSource = _ref.read(newsLocalDataSourceProvider);
      final history = await localDataSource.getSearchHistory();
      state = state.copyWith(searchHistory: history);
    } catch (e) {
      // Sessiz hata, arama geçmişi kritik değil
    }
  }

  /// Makale ara
  Future<void> searchArticles(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(
      isSearching: true,
      searchQuery: query,
      error: null,
    );

    try {
      // Tüm makaleleri al
      final repository = _ref.read(newsRepositoryProvider);
      final allArticles = await repository.getAllArticles();
      
      // Arama query'sine göre filtrele
      final filteredArticles = _filterArticles(allArticles, query);
      
      state = state.copyWith(
        searchResults: filteredArticles,
        isSearching: false,
      );

      // Arama geçmişine ekle
      _addToSearchHistory(query);
    } catch (e) {
      state = state.copyWith(
        error: 'Arama sırasında bir hata oluştu: ${e.toString()}',
        isSearching: false,
      );
    }
  }

  /// Makaleleri filtrele
  List<Article> _filterArticles(List<Article> articles, String query) {
    final lowercaseQuery = query.toLowerCase();
    
    return articles.where((article) {
      return article.title.toLowerCase().contains(lowercaseQuery) ||
             article.description.toLowerCase().contains(lowercaseQuery) ||
             article.sourceName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Arama geçmişine ekle
  Future<void> _addToSearchHistory(String query) async {
    try {
      final localDataSource = _ref.read(newsLocalDataSourceProvider);
      await localDataSource.addToSearchHistory(query);
      
      // State'i güncelle
      final updatedHistory = List<String>.from(state.searchHistory);
      if (!updatedHistory.contains(query)) {
        updatedHistory.insert(0, query);
        // Son 20 arama kaydını tut
        if (updatedHistory.length > 20) {
          updatedHistory.removeLast();
        }
        state = state.copyWith(searchHistory: updatedHistory);
      }
    } catch (e) {
      // Sessiz hata, arama geçmişi kritik değil
    }
  }

  /// Arama geçmişini temizle
  Future<void> clearSearchHistory() async {
    try {
      final localDataSource = _ref.read(newsLocalDataSourceProvider);
      await localDataSource.clearSearchHistory();
      state = state.copyWith(searchHistory: []);
    } catch (e) {
      // Sessiz hata
    }
  }

  /// Arama geçmişinden sil
  Future<void> removeFromSearchHistory(String query) async {
    try {
      final localDataSource = _ref.read(newsLocalDataSourceProvider);
      await localDataSource.removeFromSearchHistory(query);
      
      final updatedHistory = List<String>.from(state.searchHistory);
      updatedHistory.remove(query);
      state = state.copyWith(searchHistory: updatedHistory);
    } catch (e) {
      // Sessiz hata
    }
  }

  /// Arama sonuçlarını temizle
  void clearSearch() {
    state = state.copyWith(
      searchResults: [],
      searchQuery: '',
      isSearching: false,
      error: null,
    );
  }
}

/// Search provider'ı
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});