import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/article_filter.dart';

/// Haber filtreleme state yönetimi
class ArticleFilterNotifier extends StateNotifier<ArticleFilter> {
  ArticleFilterNotifier() : super(const ArticleFilter());

  /// Filtreyi güncelle
  void updateFilter(ArticleFilter filter) {
    state = filter;
  }

  /// Tarih aralığı ayarla
  void setDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  /// Kaynak ekle/çıkar
  void toggleSource(String source) {
    final sources = List<String>.from(state.selectedSources);
    if (sources.contains(source)) {
      sources.remove(source);
    } else {
      sources.add(source);
    }
    state = state.copyWith(selectedSources: sources);
  }

  /// Kategori ekle/çıkar
  void toggleCategory(String category) {
    final categories = List<String>.from(state.selectedCategories);
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    state = state.copyWith(selectedCategories: categories);
  }

  /// Okunmuş/okunmamış filtresi ayarla
  void setIsRead(bool? isRead) {
    state = state.copyWith(isRead: isRead);
  }

  /// Arama sorgusu ayarla
  void setSearchQuery(String? query) {
    state = state.copyWith(
      searchQuery: query?.trim().isEmpty == true ? null : query?.trim(),
    );
  }

  /// Filtreyi temizle
  void clearFilter() {
    state = const ArticleFilter();
  }

  /// Hızlı filtreler
  void setTodayFilter() {
    state = ArticleFilter.today();
  }

  void setThisWeekFilter() {
    state = ArticleFilter.thisWeek();
  }

  void setThisMonthFilter() {
    state = ArticleFilter.thisMonth();
  }
}

/// Article filter provider
final articleFilterProvider =
    StateNotifierProvider<ArticleFilterNotifier, ArticleFilter>((ref) {
      return ArticleFilterNotifier();
    });
