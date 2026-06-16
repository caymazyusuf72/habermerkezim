import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/article_popularity_service.dart';
import '../../domain/entities/article.dart';

/// Popüler makaleler state
class PopularArticlesState {
  final List<ArticlePopularity> popularArticles;
  final List<ArticlePopularity> trendingArticles;
  final List<ArticlePopularity> weeklyPopular;
  final bool isLoading;
  final String? error;
  final PopularTimeRange selectedTimeRange;

  const PopularArticlesState({
    this.popularArticles = const [],
    this.trendingArticles = const [],
    this.weeklyPopular = const [],
    this.isLoading = false,
    this.error,
    this.selectedTimeRange = PopularTimeRange.all,
  });

  PopularArticlesState copyWith({
    List<ArticlePopularity>? popularArticles,
    List<ArticlePopularity>? trendingArticles,
    List<ArticlePopularity>? weeklyPopular,
    bool? isLoading,
    String? error,
    PopularTimeRange? selectedTimeRange,
  }) {
    return PopularArticlesState(
      popularArticles: popularArticles ?? this.popularArticles,
      trendingArticles: trendingArticles ?? this.trendingArticles,
      weeklyPopular: weeklyPopular ?? this.weeklyPopular,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
    );
  }
}

/// Popüler zaman aralığı
enum PopularTimeRange {
  today,
  week,
  month,
  all;

  String get displayName {
    switch (this) {
      case PopularTimeRange.today:
        return 'Bugün';
      case PopularTimeRange.week:
        return 'Bu Hafta';
      case PopularTimeRange.month:
        return 'Bu Ay';
      case PopularTimeRange.all:
        return 'Tüm Zamanlar';
    }
  }

  Duration? get duration {
    switch (this) {
      case PopularTimeRange.today:
        return const Duration(hours: 24);
      case PopularTimeRange.week:
        return const Duration(days: 7);
      case PopularTimeRange.month:
        return const Duration(days: 30);
      case PopularTimeRange.all:
        return null;
    }
  }
}

/// Popüler makaleler notifier
class PopularArticlesNotifier extends StateNotifier<PopularArticlesState> {
  PopularArticlesNotifier() : super(const PopularArticlesState());

  /// Popüler makaleleri yükle
  Future<void> loadPopularArticles() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Tüm popüler makaleler
      final popular = ArticlePopularityService.getPopularArticles(
        limit: 50,
        timeRange: state.selectedTimeRange.duration,
      );

      // Trend olan makaleler (son 24 saat)
      final trending = ArticlePopularityService.getTrendingArticles(limit: 10);

      // Haftalık popüler
      final weekly = ArticlePopularityService.getWeeklyPopular(limit: 20);

      state = state.copyWith(
        popularArticles: popular,
        trendingArticles: trending,
        weeklyPopular: weekly,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Popüler makaleler yüklenirken hata: $e',
      );
    }
  }

  /// Zaman aralığını değiştir
  void setTimeRange(PopularTimeRange range) {
    state = state.copyWith(selectedTimeRange: range);
    loadPopularArticles();
  }

  /// Makale görüntüleme kaydet
  Future<void> recordArticleView(Article article) async {
    await ArticlePopularityService.recordView(
      articleId: article.id,
      title: article.title,
      imageUrl: article.imageUrl,
      sourceName: article.sourceName,
      category: article.category,
    );
    // Listeyi güncelle
    await loadPopularArticles();
  }

  /// Makale paylaşım kaydet
  Future<void> recordArticleShare(String articleId) async {
    await ArticlePopularityService.recordShare(articleId);
    await loadPopularArticles();
  }

  /// Makale favori kaydet
  Future<void> recordArticleFavorite(String articleId) async {
    await ArticlePopularityService.recordFavorite(articleId);
    await loadPopularArticles();
  }

  /// Kategoriye göre popüler makaleleri al
  List<ArticlePopularity> getPopularByCategory(String category) {
    return ArticlePopularityService.getPopularByCategory(category, limit: 10);
  }

  /// Verileri yenile
  Future<void> refresh() async {
    await loadPopularArticles();
  }

  /// Eski verileri temizle
  Future<int> cleanupOldData() async {
    final deletedCount = await ArticlePopularityService.cleanupOldData();
    await loadPopularArticles();
    return deletedCount;
  }
}

/// Popüler makaleler provider
final popularArticlesProvider = StateNotifierProvider<PopularArticlesNotifier, PopularArticlesState>((ref) {
  return PopularArticlesNotifier();
});

/// Trend makaleler provider (sadece okuma için)
final trendingArticlesProvider = Provider<List<ArticlePopularity>>((ref) {
  return ref.watch(popularArticlesProvider).trendingArticles;
});

/// Haftalık popüler makaleler provider (sadece okuma için)
final weeklyPopularProvider = Provider<List<ArticlePopularity>>((ref) {
  return ref.watch(popularArticlesProvider).weeklyPopular;
});

/// Popüler makaleler loading durumu
final popularArticlesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(popularArticlesProvider).isLoading;
});

/// Seçili zaman aralığı provider
final selectedTimeRangeProvider = Provider<PopularTimeRange>((ref) {
  return ref.watch(popularArticlesProvider).selectedTimeRange;
});

/// Kategoriye göre popüler makaleler provider
final popularByCategoryProvider = Provider.family<List<ArticlePopularity>, String>((ref, category) {
  final notifier = ref.watch(popularArticlesProvider.notifier);
  return notifier.getPopularByCategory(category);
});

/// Toplam görüntülenme sayısı provider
final totalViewsProvider = Provider<int>((ref) {
  ref.watch(popularArticlesProvider); // Değişiklikleri dinle
  return ArticlePopularityService.getTotalViews();
});

/// Toplam takip edilen makale sayısı provider
final totalTrackedArticlesProvider = Provider<int>((ref) {
  ref.watch(popularArticlesProvider); // Değişiklikleri dinle
  return ArticlePopularityService.getTotalTrackedArticles();
});

/// Popüler makaleyi Article'a dönüştür (eğer hala mevcut ise)
extension PopularityToArticle on ArticlePopularity {
  /// Mevcut makaleler listesinden Article bul
  Article? findArticle(List<Article> articles) {
    try {
      return articles.firstWhere((a) => a.id == articleId);
    } catch (e) {
      return null;
    }
  }
}