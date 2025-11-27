import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/analytics_service.dart';
import '../../domain/entities/reading_analytics.dart';

/// Analytics state
class AnalyticsState {
  final ReadingAnalytics todayAnalytics;
  final List<ReadingAnalytics> weeklyAnalytics;
  final List<ReadingAnalytics> monthlyAnalytics;
  final AnalyticsSummary weeklySummary;
  final AnalyticsSummary monthlySummary;
  final bool isLoading;
  final String? error;
  final int streakDays;

  const AnalyticsState({
    required this.todayAnalytics,
    required this.weeklyAnalytics,
    required this.monthlyAnalytics,
    required this.weeklySummary,
    required this.monthlySummary,
    this.isLoading = false,
    this.error,
    this.streakDays = 0,
  });

  AnalyticsState copyWith({
    ReadingAnalytics? todayAnalytics,
    List<ReadingAnalytics>? weeklyAnalytics,
    List<ReadingAnalytics>? monthlyAnalytics,
    AnalyticsSummary? weeklySummary,
    AnalyticsSummary? monthlySummary,
    bool? isLoading,
    String? error,
    int? streakDays,
  }) {
    return AnalyticsState(
      todayAnalytics: todayAnalytics ?? this.todayAnalytics,
      weeklyAnalytics: weeklyAnalytics ?? this.weeklyAnalytics,
      monthlyAnalytics: monthlyAnalytics ?? this.monthlyAnalytics,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  static AnalyticsState get initial => AnalyticsState(
    todayAnalytics: ReadingAnalytics.empty(),
    weeklyAnalytics: [],
    monthlyAnalytics: [],
    weeklySummary: AnalyticsSummary.empty,
    monthlySummary: AnalyticsSummary.empty,
    isLoading: false,
    streakDays: 0,
  );
}

/// Analytics notifier
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState.initial);

  /// Analytics verilerini yükle
  Future<void> loadAnalytics() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Bugünün analytics'i
      final todayAnalytics = AnalyticsService.getTodayAnalytics();

      // Son 7 günün analytics'i
      final weeklyAnalytics = AnalyticsService.getLast7DaysAnalytics();

      // Son 30 günün analytics'i
      final monthlyAnalytics = AnalyticsService.getLast30DaysAnalytics();

      // Haftalık özet
      final weeklySummary = AnalyticsService.createSummary(AnalyticsTimeRange.week);

      // Aylık özet
      final monthlySummary = AnalyticsService.createSummary(AnalyticsTimeRange.month);

      state = state.copyWith(
        todayAnalytics: todayAnalytics,
        weeklyAnalytics: weeklyAnalytics,
        monthlyAnalytics: monthlyAnalytics,
        weeklySummary: weeklySummary,
        monthlySummary: monthlySummary,
        streakDays: weeklySummary.streakDays,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Analytics yüklenirken hata: $e',
      );
    }
  }

  /// Makale okundu kaydet
  Future<void> recordArticleRead(String category, String source, {int timeSpent = 0}) async {
    try {
      final success = await AnalyticsService.recordArticleRead(category, source, timeSpent: timeSpent);
      if (success) {
        await loadAnalytics(); // Verileri güncelle
      }
    } catch (e) {
      print('Makale okuma kaydı hatası: $e');
    }
  }

  /// Favori eklendi kaydet
  Future<void> recordFavoriteAdded() async {
    try {
      final success = await AnalyticsService.recordFavoriteAdded();
      if (success) {
        await loadAnalytics(); // Verileri güncelle
      }
    } catch (e) {
      print('Favori ekleme kaydı hatası: $e');
    }
  }

  /// Arama yapıldı kaydet
  Future<void> recordSearchPerformed() async {
    try {
      final success = await AnalyticsService.recordSearchPerformed();
      if (success) {
        await loadAnalytics(); // Verileri güncelle
      }
    } catch (e) {
      print('Arama kaydı hatası: $e');
    }
  }

  /// Paylaşım yapıldı kaydet
  Future<void> recordSharePerformed() async {
    try {
      final success = await AnalyticsService.recordSharePerformed();
      if (success) {
        await loadAnalytics(); // Verileri güncelle
      }
    } catch (e) {
      print('Paylaşım kaydı hatası: $e');
    }
  }

  /// Belirli tarih aralığı için analytics al
  List<ReadingAnalytics> getAnalyticsForRange(AnalyticsTimeRange range) {
    return AnalyticsService.getAnalyticsInRange(range);
  }

  /// Özet oluştur
  AnalyticsSummary createSummaryForRange(AnalyticsTimeRange range) {
    return AnalyticsService.createSummary(range);
  }

  /// Motivasyon mesajı al
  String getMotivationMessage() {
    return AnalyticsHelper.getMotivationMessage(state.todayAnalytics, state.streakDays);
  }

  /// Günlük hedef kontrolü
  bool checkDailyGoal(int goalArticles) {
    return AnalyticsHelper.checkDailyReadingGoal(state.todayAnalytics, goalArticles);
  }

  /// Haftalık hedef kontrolü
  bool checkWeeklyGoal(int goalArticles) {
    return AnalyticsHelper.checkWeeklyReadingGoal(state.weeklyAnalytics, goalArticles);
  }

  /// Tutarlılık puanı hesapla
  double getConsistencyScore() {
    return AnalyticsHelper.calculateConsistencyScore(state.monthlyAnalytics);
  }

  /// Okuma trendi hesapla
  int getReadingTrend() {
    return AnalyticsHelper.calculateReadingTrend(state.monthlyAnalytics);
  }

  /// En verimli okuma saati
  String getMostProductiveReadingTime() {
    return AnalyticsHelper.getMostProductiveReadingTime();
  }

  /// Analytics verilerini export et
  Map<String, dynamic> exportAnalytics() {
    return AnalyticsService.exportAnalytics();
  }

  /// Analytics verilerini import et
  Future<bool> importAnalytics(Map<String, dynamic> data) async {
    try {
      final success = await AnalyticsService.importAnalytics(data);
      if (success) {
        await loadAnalytics(); // Verileri güncelle
      }
      return success;
    } catch (e) {
      print('Analytics import hatası: $e');
      return false;
    }
  }

  /// Tüm analytics'i temizle
  Future<void> clearAllAnalytics() async {
    try {
      state = state.copyWith(isLoading: true);
      await AnalyticsService.clearAllAnalytics();
      await loadAnalytics();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Analytics temizlenirken hata: $e',
      );
    }
  }

  /// Hata mesajını temizle
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Manuel güncelleme
  void refresh() {
    loadAnalytics();
  }
}

/// Analytics provider
final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});

/// Bugünkü analytics provider (sadece okuma için)
final todayAnalyticsProvider = Provider<ReadingAnalytics>((ref) {
  return ref.watch(analyticsProvider).todayAnalytics;
});

/// Haftalık özet provider (sadece okuma için)
final weeklySummaryProvider = Provider<AnalyticsSummary>((ref) {
  return ref.watch(analyticsProvider).weeklySummary;
});

/// Aylık özet provider (sadece okuma için)
final monthlySummaryProvider = Provider<AnalyticsSummary>((ref) {
  return ref.watch(analyticsProvider).monthlySummary;
});

/// Streak provider (sadece okuma için)
final streakDaysProvider = Provider<int>((ref) {
  return ref.watch(analyticsProvider).streakDays;
});

/// Motivasyon mesajı provider (sadece okuma için)
final motivationMessageProvider = Provider<String>((ref) {
  final analytics = ref.watch(analyticsProvider.notifier);
  return analytics.getMotivationMessage();
});

/// Analytics loading durumu provider
final analyticsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(analyticsProvider).isLoading;
});

/// Analytics hata mesajı provider
final analyticsErrorProvider = Provider<String?>((ref) {
  return ref.watch(analyticsProvider).error;
});

/// Günlük okuma hedefi kontrolü provider (varsayılan hedef: 3 makale)
final dailyGoalProvider = Provider.family<bool, int>((ref, goalArticles) {
  final analytics = ref.watch(analyticsProvider.notifier);
  return analytics.checkDailyGoal(goalArticles);
});

/// Haftalık okuma hedefi kontrolü provider (varsayılan hedef: 21 makale)
final weeklyGoalProvider = Provider.family<bool, int>((ref, goalArticles) {
  final analytics = ref.watch(analyticsProvider.notifier);
  return analytics.checkWeeklyGoal(goalArticles);
});

/// Tutarlılık puanı provider
final consistencyScoreProvider = Provider<double>((ref) {
  final analytics = ref.watch(analyticsProvider.notifier);
  return analytics.getConsistencyScore();
});

/// Okuma trendi provider
final readingTrendProvider = Provider<int>((ref) {
  final analytics = ref.watch(analyticsProvider.notifier);
  return analytics.getReadingTrend();
});

/// En verimli okuma saati provider
final productiveReadingTimeProvider = Provider<String>((ref) {
  final analytics = ref.watch(analyticsProvider.notifier);
  return analytics.getMostProductiveReadingTime();
});

/// Analytics quick stats provider (ana sayfa için)
final quickStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(analyticsProvider);
  
  return {
    'todayArticles': state.todayAnalytics.articlesRead,
    'weeklyArticles': state.weeklySummary.totalArticlesRead,
    'streakDays': state.streakDays,
    'consistency': ref.watch(consistencyScoreProvider),
  };
});

/// En çok okunan kategori provider
final topCategoryProvider = Provider<String?>((ref) {
  final summary = ref.watch(weeklySummaryProvider);
  
  if (summary.categoriesBreakdown.isEmpty) return null;
  
  String? topCategory;
  int maxCount = 0;
  
  for (final entry in summary.categoriesBreakdown.entries) {
    if (entry.value > maxCount) {
      maxCount = entry.value;
      topCategory = entry.key;
    }
  }
  
  return topCategory;
});

/// En çok okunan kaynak provider
final topSourceProvider = Provider<String?>((ref) {
  final summary = ref.watch(weeklySummaryProvider);
  
  if (summary.sourcesBreakdown.isEmpty) return null;
  
  String? topSource;
  int maxCount = 0;
  
  for (final entry in summary.sourcesBreakdown.entries) {
    if (entry.value > maxCount) {
      maxCount = entry.value;
      topSource = entry.key;
    }
  }
  
  return topSource;
});