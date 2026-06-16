/// Okuma istatistikleri entity
class ReadingAnalytics {
  final String id;
  final DateTime date;
  final int articlesRead;
  final int timeSpentMinutes;
  final int favoriteCount;
  final int searchCount;
  final int shareCount;
  final Map<String, int> categoriesRead;
  final Map<String, int> sourcesRead;

  const ReadingAnalytics({
    required this.id,
    required this.date,
    this.articlesRead = 0,
    this.timeSpentMinutes = 0,
    this.favoriteCount = 0,
    this.searchCount = 0,
    this.shareCount = 0,
    this.categoriesRead = const {},
    this.sourcesRead = const {},
  });

  /// Bugünün analytics'i için ID oluştur
  static String getTodayId() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Boş analytics
  static ReadingAnalytics empty() {
    return ReadingAnalytics(id: getTodayId(), date: DateTime.now());
  }

  /// Bu hafta için ID oluştur
  static String getWeekId(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return 'week-${startOfWeek.year}-${startOfWeek.month}-${startOfWeek.day}';
  }

  /// Bu ay için ID oluştur
  static String getMonthId(DateTime date) {
    return 'month-${date.year}-${date.month}';
  }

  /// Toplam aktivite puanı
  int get totalActivity {
    return articlesRead * 3 + favoriteCount * 2 + searchCount + shareCount;
  }

  /// En çok okunan kategori
  String get topCategory {
    if (categoriesRead.isEmpty) return 'Henüz veri yok';

    var maxEntry = categoriesRead.entries.first;
    for (final entry in categoriesRead.entries) {
      if (entry.value > maxEntry.value) {
        maxEntry = entry;
      }
    }
    return maxEntry.key;
  }

  /// En çok okunan kaynak
  String get topSource {
    if (sourcesRead.isEmpty) return 'Henüz veri yok';

    var maxEntry = sourcesRead.entries.first;
    for (final entry in sourcesRead.entries) {
      if (entry.value > maxEntry.value) {
        maxEntry = entry;
      }
    }
    return maxEntry.key;
  }

  /// Ortalama okuma süresi (dakika/makale)
  double get averageReadingTimePerArticle {
    if (articlesRead == 0) return 0;
    return timeSpentMinutes / articlesRead;
  }

  /// Kopya oluştur
  ReadingAnalytics copyWith({
    String? id,
    DateTime? date,
    int? articlesRead,
    int? timeSpentMinutes,
    int? favoriteCount,
    int? searchCount,
    int? shareCount,
    Map<String, int>? categoriesRead,
    Map<String, int>? sourcesRead,
  }) {
    return ReadingAnalytics(
      id: id ?? this.id,
      date: date ?? this.date,
      articlesRead: articlesRead ?? this.articlesRead,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      searchCount: searchCount ?? this.searchCount,
      shareCount: shareCount ?? this.shareCount,
      categoriesRead: categoriesRead ?? this.categoriesRead,
      sourcesRead: sourcesRead ?? this.sourcesRead,
    );
  }

  /// Makale okundu olayını ekle
  ReadingAnalytics incrementArticleRead(
    String category,
    String source, {
    int timeSpent = 0,
  }) {
    final newCategoriesRead = Map<String, int>.from(categoriesRead);
    newCategoriesRead[category] = (newCategoriesRead[category] ?? 0) + 1;

    final newSourcesRead = Map<String, int>.from(sourcesRead);
    newSourcesRead[source] = (newSourcesRead[source] ?? 0) + 1;

    return copyWith(
      articlesRead: articlesRead + 1,
      timeSpentMinutes: timeSpentMinutes + timeSpent,
      categoriesRead: newCategoriesRead,
      sourcesRead: newSourcesRead,
    );
  }

  /// Favori eklendi olayını ekle
  ReadingAnalytics incrementFavorite() {
    return copyWith(favoriteCount: favoriteCount + 1);
  }

  /// Arama yapıldı olayını ekle
  ReadingAnalytics incrementSearch() {
    return copyWith(searchCount: searchCount + 1);
  }

  /// Paylaşım yapıldı olayını ekle
  ReadingAnalytics incrementShare() {
    return copyWith(shareCount: shareCount + 1);
  }

  /// Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'articlesRead': articlesRead,
      'timeSpentMinutes': timeSpentMinutes,
      'favoriteCount': favoriteCount,
      'searchCount': searchCount,
      'shareCount': shareCount,
      'categoriesRead': categoriesRead,
      'sourcesRead': sourcesRead,
    };
  }

  /// Map'den oluştur
  factory ReadingAnalytics.fromMap(Map<String, dynamic> map) {
    return ReadingAnalytics(
      id: map['id'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      articlesRead: map['articlesRead'] ?? 0,
      timeSpentMinutes: map['timeSpentMinutes'] ?? 0,
      favoriteCount: map['favoriteCount'] ?? 0,
      searchCount: map['searchCount'] ?? 0,
      shareCount: map['shareCount'] ?? 0,
      categoriesRead: Map<String, int>.from(map['categoriesRead'] ?? {}),
      sourcesRead: Map<String, int>.from(map['sourcesRead'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'ReadingAnalytics(id: $id, date: $date, articlesRead: $articlesRead, totalActivity: $totalActivity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingAnalytics && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Analytics özet bilgileri
class AnalyticsSummary {
  final int totalArticlesRead;
  final int totalTimeSpent;
  final int totalFavorites;
  final int totalSearches;
  final int totalShares;
  final Map<String, int> categoriesBreakdown;
  final Map<String, int> sourcesBreakdown;
  final List<ReadingAnalytics> dailyData;
  final int streakDays;

  const AnalyticsSummary({
    required this.totalArticlesRead,
    required this.totalTimeSpent,
    required this.totalFavorites,
    required this.totalSearches,
    required this.totalShares,
    required this.categoriesBreakdown,
    required this.sourcesBreakdown,
    required this.dailyData,
    required this.streakDays,
  });

  /// Boş özet
  static const AnalyticsSummary empty = AnalyticsSummary(
    totalArticlesRead: 0,
    totalTimeSpent: 0,
    totalFavorites: 0,
    totalSearches: 0,
    totalShares: 0,
    categoriesBreakdown: {},
    sourcesBreakdown: {},
    dailyData: [],
    streakDays: 0,
  );

  /// Toplam aktivite puanı
  int get totalActivityScore {
    return totalArticlesRead * 3 +
        totalFavorites * 2 +
        totalSearches +
        totalShares;
  }

  /// Günlük ortalama makale okuma
  double get averageDailyReading {
    if (dailyData.isEmpty) return 0;
    return totalArticlesRead / dailyData.length;
  }

  /// En aktif gün
  ReadingAnalytics? get mostActiveDay {
    if (dailyData.isEmpty) return null;

    ReadingAnalytics mostActive = dailyData.first;
    for (final day in dailyData) {
      if (day.totalActivity > mostActive.totalActivity) {
        mostActive = day;
      }
    }
    return mostActive;
  }

  /// En çok okunan kategori
  String get topCategory {
    if (categoriesBreakdown.isEmpty) return 'Henüz veri yok';

    var maxEntry = categoriesBreakdown.entries.first;
    for (final entry in categoriesBreakdown.entries) {
      if (entry.value > maxEntry.value) {
        maxEntry = entry;
      }
    }
    return maxEntry.key;
  }

  /// Okuma tutarlılığı (0-100 arası)
  double get readingConsistency {
    if (dailyData.length < 2) return 0;

    final daysWithReading = dailyData
        .where((day) => day.articlesRead > 0)
        .length;
    return (daysWithReading / dailyData.length) * 100;
  }
}

/// Analytics tarih aralıkları
enum AnalyticsTimeRange {
  today,
  week,
  month,
  threeMonths,
  year,
  all;

  String get displayName {
    switch (this) {
      case AnalyticsTimeRange.today:
        return 'Bugün';
      case AnalyticsTimeRange.week:
        return 'Bu Hafta';
      case AnalyticsTimeRange.month:
        return 'Bu Ay';
      case AnalyticsTimeRange.threeMonths:
        return 'Son 3 Ay';
      case AnalyticsTimeRange.year:
        return 'Bu Yıl';
      case AnalyticsTimeRange.all:
        return 'Tümü';
    }
  }

  /// Başlangıç tarihini al
  DateTime getStartDate() {
    final now = DateTime.now();
    switch (this) {
      case AnalyticsTimeRange.today:
        return DateTime(now.year, now.month, now.day);
      case AnalyticsTimeRange.week:
        return now.subtract(Duration(days: now.weekday - 1));
      case AnalyticsTimeRange.month:
        return DateTime(now.year, now.month, 1);
      case AnalyticsTimeRange.threeMonths:
        return DateTime(now.year, now.month - 2, 1);
      case AnalyticsTimeRange.year:
        return DateTime(now.year, 1, 1);
      case AnalyticsTimeRange.all:
        return DateTime(2024, 1, 1); // Uygulama başlangıç tarihi
    }
  }
}
