import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/reading_list_repository.dart';
import '../../data/datasources/local/reading_list_local_data_source.dart';
import '../../data/repositories/reading_list_repository_impl.dart';
import 'providers.dart';

/// Okuma listesi durumunu yönetir
class ReadingListState {
  final List<Article> readingListArticles;
  final bool isLoading;
  final String? error;

  const ReadingListState({
    this.readingListArticles = const [],
    this.isLoading = false,
    this.error,
  });

  ReadingListState copyWith({
    List<Article>? readingListArticles,
    bool? isLoading,
    String? error,
  }) {
    return ReadingListState(
      readingListArticles: readingListArticles ?? this.readingListArticles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasArticles => readingListArticles.isNotEmpty;
  bool get hasError => error != null;
  int get readingListCount => readingListArticles.length;

  // Export/Import için ek getter
  List<Article> get articles => readingListArticles;

  /// Makale okuma listesinde mi kontrol et
  bool isInReadingList(String articleId) {
    return readingListArticles.any((article) => article.id == articleId);
  }
}

/// Okuma listesi provider'ı - okuma listesi makalelerini yönetir
class ReadingListNotifier extends StateNotifier<ReadingListState> {
  ReadingListNotifier(this._ref) : super(const ReadingListState()) {
    loadReadingList();
  }

  final Ref _ref;

  ReadingListRepository get _repository {
    final localDataSource = ReadingListLocalDataSourceImpl();
    final newsLocalDataSource = _ref.read(newsLocalDataSourceProvider);
    return ReadingListRepositoryImpl(
      localDataSource: localDataSource,
      newsLocalDataSource: newsLocalDataSource,
    );
  }

  /// Tüm okuma listesi makalelerini yükle
  Future<void> loadReadingList() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final articles = await _repository.getReadingListArticles();

      state = state.copyWith(readingListArticles: articles, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Okuma listesi yüklenirken hata oluştu: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Makaleyi okuma listesine ekle
  Future<void> addToReadingList(Article article) async {
    // Zaten okuma listesinde mi kontrol et
    if (state.isInReadingList(article.id)) {
      return;
    }

    try {
      await _repository.addToReadingList(article.id);

      // State'i güncelle
      final updatedList = List<Article>.from(state.readingListArticles);
      updatedList.insert(0, article); // En başa ekle

      state = state.copyWith(readingListArticles: updatedList, error: null);
    } catch (e) {
      state = state.copyWith(
        error: 'Okuma listesine eklenirken hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Makaleyi okuma listesinden çıkar
  Future<void> removeFromReadingList(String articleId) async {
    try {
      await _repository.removeFromReadingList(articleId);

      // State'i güncelle
      final updatedList = state.readingListArticles
          .where((article) => article.id != articleId)
          .toList();

      state = state.copyWith(readingListArticles: updatedList, error: null);
    } catch (e) {
      state = state.copyWith(
        error: 'Okuma listesinden çıkarılırken hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Okuma listesi durumunu değiştir (toggle)
  Future<void> toggleReadingList(Article article) async {
    if (state.isInReadingList(article.id)) {
      await removeFromReadingList(article.id);
    } else {
      await addToReadingList(article);
    }
  }

  /// Tüm okuma listesini temizle
  Future<void> clearReadingList() async {
    try {
      await _repository.clearReadingList();

      state = state.copyWith(readingListArticles: [], error: null);
    } catch (e) {
      state = state.copyWith(
        error: 'Okuma listesi temizlenirken hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Okuma listesindeki makaleyi ID ile bul
  Article? getArticleById(String articleId) {
    try {
      return state.readingListArticles.firstWhere(
        (article) => article.id == articleId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Okuma listesini tarihe göre sırala (en yeni en üstte)
  void sortByDate() {
    final sortedList = List<Article>.from(state.readingListArticles);
    sortedList.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));

    state = state.copyWith(readingListArticles: sortedList);
  }

  /// Okuma listesini başlığa göre sırala
  void sortByTitle() {
    final sortedList = List<Article>.from(state.readingListArticles);
    sortedList.sort((a, b) => a.title.compareTo(b.title));

    state = state.copyWith(readingListArticles: sortedList);
  }

  /// Okuma listesini kaynağa göre sırala
  void sortBySource() {
    final sortedList = List<Article>.from(state.readingListArticles);
    sortedList.sort((a, b) => a.sourceName.compareTo(b.sourceName));

    state = state.copyWith(readingListArticles: sortedList);
  }
}

/// Reading list provider'ı
final readingListProvider =
    StateNotifierProvider<ReadingListNotifier, ReadingListState>((ref) {
      return ReadingListNotifier(ref);
    });

/// Tek bir makalenin okuma listesinde olup olmadığını kontrol eden provider
final isInReadingListProvider = Provider.family<bool, String>((ref, articleId) {
  final readingListState = ref.watch(readingListProvider);
  return readingListState.isInReadingList(articleId);
});

/// Okuma listesi sayısını dönen provider
final readingListCountProvider = Provider<int>((ref) {
  final readingListState = ref.watch(readingListProvider);
  return readingListState.readingListCount;
});
