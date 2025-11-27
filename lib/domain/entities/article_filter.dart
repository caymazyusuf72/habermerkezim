/// Haber filtreleme kriterleri
class ArticleFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> selectedSources;
  final List<String> selectedCategories;
  final bool? isRead; // null = hepsi, true = sadece okunmuş, false = sadece okunmamış

  const ArticleFilter({
    this.startDate,
    this.endDate,
    this.selectedSources = const [],
    this.selectedCategories = const [],
    this.isRead,
  });

  /// Filtre aktif mi kontrol et
  bool get isActive {
    return startDate != null ||
        endDate != null ||
        selectedSources.isNotEmpty ||
        selectedCategories.isNotEmpty ||
        isRead != null;
  }

  /// Filtreyi temizle
  ArticleFilter clear() {
    return const ArticleFilter();
  }

  /// Kopyalama metodu
  ArticleFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? selectedSources,
    List<String>? selectedCategories,
    bool? isRead,
  }) {
    return ArticleFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedSources: selectedSources ?? this.selectedSources,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Tarih aralığı seçenekleri
  static ArticleFilter today() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return ArticleFilter(
      startDate: startOfDay,
      endDate: now,
    );
  }

  static ArticleFilter thisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return ArticleFilter(
      startDate: startOfDay,
      endDate: now,
    );
  }

  static ArticleFilter thisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return ArticleFilter(
      startDate: startOfMonth,
      endDate: now,
    );
  }
}

