import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import '../../core/services/search_service.dart';
import 'providers.dart';

/// Gelişmiş arama durumunu yönetir
class SearchState {
  final List<SearchResult> searchResults;
  final String searchQuery;
  final bool isSearching;
  final List<String> searchHistory;
  final List<String> autocompleteSuggestions;
  final List<String> popularSearches;
  final List<TrendingSearch> trendingSearches;
  final String? error;
  final bool showSuggestions;

  const SearchState({
    this.searchResults = const [],
    this.searchQuery = '',
    this.isSearching = false,
    this.searchHistory = const [],
    this.autocompleteSuggestions = const [],
    this.popularSearches = const [],
    this.trendingSearches = const [],
    this.error,
    this.showSuggestions = false,
  });

  SearchState copyWith({
    List<SearchResult>? searchResults,
    String? searchQuery,
    bool? isSearching,
    List<String>? searchHistory,
    List<String>? autocompleteSuggestions,
    List<String>? popularSearches,
    List<TrendingSearch>? trendingSearches,
    String? error,
    bool? showSuggestions,
  }) {
    return SearchState(
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      searchHistory: searchHistory ?? this.searchHistory,
      autocompleteSuggestions: autocompleteSuggestions ?? this.autocompleteSuggestions,
      popularSearches: popularSearches ?? this.popularSearches,
      trendingSearches: trendingSearches ?? this.trendingSearches,
      error: error,
      showSuggestions: showSuggestions ?? this.showSuggestions,
    );
  }

  bool get hasResults => searchResults.isNotEmpty;
  bool get hasError => error != null;
  bool get hasSuggestions => autocompleteSuggestions.isNotEmpty;
  
  /// Arama sonuçlarını Article listesi olarak döndür
  List<Article> get articles => searchResults.map((r) => r.article).toList();
  
  /// Toplam sonuç sayısı
  int get resultCount => searchResults.length;
  
  /// Yüksek kaliteli sonuç sayısı
  int get highQualityResultCount => 
      searchResults.where((r) => r.matchQuality == 'high').length;
}

/// Gelişmiş arama provider'ı
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._ref) : super(const SearchState()) {
    _searchService = SearchService();
    _loadInitialData();
  }

  final Ref _ref;
  late final SearchService _searchService;

  /// Başlangıç verilerini yükle
  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadSearchHistory(),
      _loadPopularSearches(),
      _loadTrendingSearches(),
    ]);
  }

  /// Arama geçmişini yükle
  Future<void> _loadSearchHistory() async {
    try {
      final localDataSource = _ref.read(newsLocalDataSourceProvider);
      final history = await localDataSource.getSearchHistory();
      state = state.copyWith(searchHistory: history);
    } catch (e) {
      // Sessiz hata, arama geçmişi kritik değil
    }
  }

  /// Popüler aramaları yükle
  Future<void> _loadPopularSearches() async {
    try {
      final popular = await _searchService.getPopularSearches();
      state = state.copyWith(popularSearches: popular);
    } catch (e) {
      // Sessiz hata
    }
  }

  /// Trend aramaları yükle
  Future<void> _loadTrendingSearches() async {
    try {
      final trending = await _searchService.getTrendingSearches();
      state = state.copyWith(trendingSearches: trending);
    } catch (e) {
      // Sessiz hata
    }
  }

  /// Gelişmiş makale arama
  Future<void> searchArticles(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(
      isSearching: true,
      searchQuery: query,
      error: null,
      showSuggestions: false,
    );

    try {
      // Tüm makaleleri al
      final repository = _ref.read(newsRepositoryProvider);
      final allArticles = await repository.getAllArticles();
      
      // Gelişmiş arama ile skorlama
      final searchResults = _searchService.searchArticles(allArticles, query);
      
      state = state.copyWith(
        searchResults: searchResults,
        isSearching: false,
      );

      // Arama geçmişine ekle
      await _addToSearchHistory(query);
      
      // Popüler aramaları güncelle
      await _loadPopularSearches();
    } catch (e) {
      state = state.copyWith(
        error: 'Arama sırasında bir hata oluştu: ${e.toString()}',
        isSearching: false,
      );
    }
  }

  /// Autocomplete önerileri getir
  Future<void> getAutocompleteSuggestions(String query) async {
    if (query.trim().length < 2) {
      state = state.copyWith(
        autocompleteSuggestions: [],
        showSuggestions: false,
      );
      return;
    }

    try {
      final repository = _ref.read(newsRepositoryProvider);
      final allArticles = await repository.getAllArticles();
      
      final suggestions = await _searchService.getAutocompleteSuggestions(
        query,
        allArticles,
      );
      
      state = state.copyWith(
        autocompleteSuggestions: suggestions,
        showSuggestions: suggestions.isNotEmpty,
      );
    } catch (e) {
      // Sessiz hata
    }
  }

  /// Debounced autocomplete
  void getAutocompleteSuggestionsDebounced(String query) {
    _ref.read(newsRepositoryProvider).getAllArticles().then((articles) {
      _searchService.getAutocompleteSuggestionsDebounced(
        query,
        articles,
        (suggestions) {
          if (mounted) {
            state = state.copyWith(
              autocompleteSuggestions: suggestions,
              showSuggestions: suggestions.isNotEmpty && query.isNotEmpty,
            );
          }
        },
      );
    });
  }

  /// Önerileri gizle
  void hideSuggestions() {
    state = state.copyWith(showSuggestions: false);
  }

  /// Önerileri göster
  void showSuggestions() {
    if (state.autocompleteSuggestions.isNotEmpty) {
      state = state.copyWith(showSuggestions: true);
    }
  }

  /// Arama geçmişine ekle
  Future<void> _addToSearchHistory(String query) async {
    try {
      await _searchService.addToSearchHistory(query);
      
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
      // Sessiz hata
    }
  }

  /// Arama geçmişini temizle
  Future<void> clearSearchHistory() async {
    try {
      await _searchService.clearSearchHistory();
      state = state.copyWith(searchHistory: []);
    } catch (e) {
      // Sessiz hata
    }
  }

  /// Arama geçmişinden sil
  Future<void> removeFromSearchHistory(String query) async {
    try {
      await _searchService.removeFromSearchHistory(query);
      
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
      showSuggestions: false,
      autocompleteSuggestions: [],
    );
  }

  /// Highlight edilmiş metin oluştur
  List<HighlightedText> highlightMatches(String text) {
    return _searchService.highlightMatches(text, state.searchQuery);
  }

  /// Popüler aramaları yenile
  Future<void> refreshPopularSearches() async {
    await _loadPopularSearches();
  }

  /// Trend aramaları yenile
  Future<void> refreshTrendingSearches() async {
    await _loadTrendingSearches();
  }

  @override
  void dispose() {
    _searchService.dispose();
    super.dispose();
  }
}

/// Search provider'ı
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});

/// Popüler aramalar provider'ı
final popularSearchesProvider = FutureProvider<List<String>>((ref) async {
  final searchService = SearchService();
  return searchService.getPopularSearches();
});

/// Trend aramalar provider'ı
final trendingSearchesProvider = FutureProvider<List<TrendingSearch>>((ref) async {
  final searchService = SearchService();
  return searchService.getTrendingSearches();
});