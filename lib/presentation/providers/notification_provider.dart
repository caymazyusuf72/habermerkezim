import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/hive_service.dart';
import 'analytics_provider.dart';

/// Notification settings model
class NotificationSettings {
  final bool dailyNewsEnabled;
  final int dailyNewsHour;
  final int dailyNewsMinute;
  final bool readingGoalEnabled;
  final int readingGoalHour;
  final int readingGoalMinute;
  final int dailyReadingGoal;
  final bool breakingNewsEnabled;
  final Map<String, bool>
  categoryNotifications; // Kategori ID -> bildirim açık/kapalı

  // YENİ ALANLAR - Sessiz Saatler
  final bool quietHoursEnabled;
  final int quietHoursStartHour;
  final int quietHoursStartMinute;
  final int quietHoursEndHour;
  final int quietHoursEndMinute;

  // YENİ ALANLAR - Bildirim Limiti
  final bool dailyLimitEnabled;
  final int maxDailyNotifications;
  final DateTime lastResetDate;
  final int todayNotificationCount;

  // YENİ ALANLAR - Öncelik Ayarları
  final bool highPrioritySound;
  final bool highPriorityVibration;

  NotificationSettings({
    this.dailyNewsEnabled = true,
    this.dailyNewsHour = 9,
    this.dailyNewsMinute = 0,
    this.readingGoalEnabled = true,
    this.readingGoalHour = 20,
    this.readingGoalMinute = 0,
    this.dailyReadingGoal = 10,
    this.breakingNewsEnabled = false,
    this.categoryNotifications = const {},
    // Sessiz Saatler - Varsayılan: 22:00-08:00
    this.quietHoursEnabled = false,
    this.quietHoursStartHour = 22,
    this.quietHoursStartMinute = 0,
    this.quietHoursEndHour = 8,
    this.quietHoursEndMinute = 0,
    // Bildirim Limiti - Varsayılan: 10 bildirim/gün
    this.dailyLimitEnabled = false,
    this.maxDailyNotifications = 10,
    DateTime? lastResetDate,
    this.todayNotificationCount = 0,
    // Öncelik Ayarları
    this.highPrioritySound = true,
    this.highPriorityVibration = true,
  }) : lastResetDate = lastResetDate ?? DateTime.now();

  NotificationSettings copyWith({
    bool? dailyNewsEnabled,
    int? dailyNewsHour,
    int? dailyNewsMinute,
    bool? readingGoalEnabled,
    int? readingGoalHour,
    int? readingGoalMinute,
    int? dailyReadingGoal,
    bool? breakingNewsEnabled,
    Map<String, bool>? categoryNotifications,
    bool? quietHoursEnabled,
    int? quietHoursStartHour,
    int? quietHoursStartMinute,
    int? quietHoursEndHour,
    int? quietHoursEndMinute,
    bool? dailyLimitEnabled,
    int? maxDailyNotifications,
    DateTime? lastResetDate,
    int? todayNotificationCount,
    bool? highPrioritySound,
    bool? highPriorityVibration,
  }) {
    return NotificationSettings(
      dailyNewsEnabled: dailyNewsEnabled ?? this.dailyNewsEnabled,
      dailyNewsHour: dailyNewsHour ?? this.dailyNewsHour,
      dailyNewsMinute: dailyNewsMinute ?? this.dailyNewsMinute,
      readingGoalEnabled: readingGoalEnabled ?? this.readingGoalEnabled,
      readingGoalHour: readingGoalHour ?? this.readingGoalHour,
      readingGoalMinute: readingGoalMinute ?? this.readingGoalMinute,
      dailyReadingGoal: dailyReadingGoal ?? this.dailyReadingGoal,
      breakingNewsEnabled: breakingNewsEnabled ?? this.breakingNewsEnabled,
      categoryNotifications:
          categoryNotifications ?? this.categoryNotifications,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStartHour: quietHoursStartHour ?? this.quietHoursStartHour,
      quietHoursStartMinute:
          quietHoursStartMinute ?? this.quietHoursStartMinute,
      quietHoursEndHour: quietHoursEndHour ?? this.quietHoursEndHour,
      quietHoursEndMinute: quietHoursEndMinute ?? this.quietHoursEndMinute,
      dailyLimitEnabled: dailyLimitEnabled ?? this.dailyLimitEnabled,
      maxDailyNotifications:
          maxDailyNotifications ?? this.maxDailyNotifications,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      todayNotificationCount:
          todayNotificationCount ?? this.todayNotificationCount,
      highPrioritySound: highPrioritySound ?? this.highPrioritySound,
      highPriorityVibration:
          highPriorityVibration ?? this.highPriorityVibration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyNewsEnabled': dailyNewsEnabled,
      'dailyNewsHour': dailyNewsHour,
      'dailyNewsMinute': dailyNewsMinute,
      'readingGoalEnabled': readingGoalEnabled,
      'readingGoalHour': readingGoalHour,
      'readingGoalMinute': readingGoalMinute,
      'dailyReadingGoal': dailyReadingGoal,
      'breakingNewsEnabled': breakingNewsEnabled,
      'categoryNotifications': categoryNotifications,
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStartHour': quietHoursStartHour,
      'quietHoursStartMinute': quietHoursStartMinute,
      'quietHoursEndHour': quietHoursEndHour,
      'quietHoursEndMinute': quietHoursEndMinute,
      'dailyLimitEnabled': dailyLimitEnabled,
      'maxDailyNotifications': maxDailyNotifications,
      'lastResetDate': lastResetDate.toIso8601String(),
      'todayNotificationCount': todayNotificationCount,
      'highPrioritySound': highPrioritySound,
      'highPriorityVibration': highPriorityVibration,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      dailyNewsEnabled: map['dailyNewsEnabled'] ?? true,
      dailyNewsHour: map['dailyNewsHour'] ?? 9,
      dailyNewsMinute: map['dailyNewsMinute'] ?? 0,
      readingGoalEnabled: map['readingGoalEnabled'] ?? true,
      readingGoalHour: map['readingGoalHour'] ?? 20,
      readingGoalMinute: map['readingGoalMinute'] ?? 0,
      dailyReadingGoal: map['dailyReadingGoal'] ?? 10,
      breakingNewsEnabled: map['breakingNewsEnabled'] ?? false,
      categoryNotifications: map['categoryNotifications'] != null
          ? Map<String, bool>.from(map['categoryNotifications'])
          : const {},
      quietHoursEnabled: map['quietHoursEnabled'] ?? false,
      quietHoursStartHour: map['quietHoursStartHour'] ?? 22,
      quietHoursStartMinute: map['quietHoursStartMinute'] ?? 0,
      quietHoursEndHour: map['quietHoursEndHour'] ?? 8,
      quietHoursEndMinute: map['quietHoursEndMinute'] ?? 0,
      dailyLimitEnabled: map['dailyLimitEnabled'] ?? false,
      maxDailyNotifications: map['maxDailyNotifications'] ?? 10,
      lastResetDate: map['lastResetDate'] != null
          ? DateTime.parse(map['lastResetDate'])
          : DateTime.now(),
      todayNotificationCount: map['todayNotificationCount'] ?? 0,
      highPrioritySound: map['highPrioritySound'] ?? true,
      highPriorityVibration: map['highPriorityVibration'] ?? true,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings('
        'dailyNewsEnabled: $dailyNewsEnabled, '
        'dailyNewsHour: $dailyNewsHour, '
        'dailyNewsMinute: $dailyNewsMinute, '
        'readingGoalEnabled: $readingGoalEnabled, '
        'readingGoalHour: $readingGoalHour, '
        'readingGoalMinute: $readingGoalMinute, '
        'dailyReadingGoal: $dailyReadingGoal, '
        'breakingNewsEnabled: $breakingNewsEnabled'
        ')';
  }
}

/// Notification provider state
class NotificationState {
  final NotificationSettings settings;
  final bool permissionsGranted;
  final bool initialized;
  final bool loading;
  final String? error;

  NotificationState({
    NotificationSettings? settings,
    this.permissionsGranted = false,
    this.initialized = false,
    this.loading = false,
    this.error,
  }) : settings = settings ?? NotificationSettings();

  NotificationState copyWith({
    NotificationSettings? settings,
    bool? permissionsGranted,
    bool? initialized,
    bool? loading,
    String? error,
  }) {
    return NotificationState(
      settings: settings ?? this.settings,
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      initialized: initialized ?? this.initialized,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// Notification provider
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;
  final Ref _ref;

  static const String _settingsKey = 'notification_settings';

  NotificationNotifier(this._notificationService, this._ref)
    : super(NotificationState()) {
    _initialize();
  }

  /// Initialize notification provider
  Future<void> _initialize() async {
    try {
      state = state.copyWith(loading: true, error: null);

      // Initialize notification service
      await _notificationService.initialize();

      // Check permissions
      final permissions = await _notificationService.areNotificationsEnabled();

      // Load saved settings
      final savedSettings = await _loadSettings();

      // Update schedules if permissions granted
      if (permissions) {
        await _updateNotificationSchedules(savedSettings);
      }

      state = state.copyWith(
        settings: savedSettings,
        permissionsGranted: permissions,
        initialized: true,
        loading: false,
      );

      if (kDebugMode) {
        debugPrint('📱 NotificationProvider initialized: $savedSettings');
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Bildirim servisi başlatılamadı: $e',
      );
      if (kDebugMode) {
        debugPrint('❌ NotificationProvider initialization error: $e');
      }
    }
  }

  /// Load settings from storage
  Future<NotificationSettings> _loadSettings() async {
    try {
      final settingsBox = HiveService.settingsBox;
      final savedMap = settingsBox.get(_settingsKey);

      if (savedMap != null && savedMap is Map) {
        return NotificationSettings.fromMap(
          Map<String, dynamic>.from(savedMap),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading notification settings: $e');
      }
    }
    return NotificationSettings();
  }

  /// Save settings to storage
  Future<void> _saveSettings(NotificationSettings settings) async {
    try {
      final settingsBox = HiveService.settingsBox;
      await settingsBox.put(_settingsKey, settings.toMap());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving notification settings: $e');
      }
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      state = state.copyWith(loading: true);

      final granted = await _notificationService.requestPermissions();

      state = state.copyWith(permissionsGranted: granted, loading: false);

      if (granted) {
        await _updateNotificationSchedules(state.settings);
      }

      return granted;
    } catch (e) {
      state = state.copyWith(loading: false, error: 'İzin alınamadı: $e');
      return false;
    }
  }

  /// Update daily news settings
  Future<void> updateDailyNewsSettings({
    bool? enabled,
    int? hour,
    int? minute,
  }) async {
    try {
      final newSettings = state.settings.copyWith(
        dailyNewsEnabled: enabled,
        dailyNewsHour: hour,
        dailyNewsMinute: minute,
      );

      await _saveSettings(newSettings);

      if (state.permissionsGranted) {
        await _notificationService.scheduleDailyNewsReminder(
          hour: newSettings.dailyNewsHour,
          minute: newSettings.dailyNewsMinute,
          enabled: newSettings.dailyNewsEnabled,
        );
      }

      state = state.copyWith(settings: newSettings);

      if (kDebugMode) {
        debugPrint('📱 Daily news settings updated: $newSettings');
      }
    } catch (e) {
      state = state.copyWith(error: 'Günlük haber ayarları güncellenemedi: $e');
    }
  }

  /// Update reading goal settings
  Future<void> updateReadingGoalSettings({
    bool? enabled,
    int? hour,
    int? minute,
    int? dailyGoal,
  }) async {
    try {
      final newSettings = state.settings.copyWith(
        readingGoalEnabled: enabled,
        readingGoalHour: hour,
        readingGoalMinute: minute,
        dailyReadingGoal: dailyGoal,
      );

      await _saveSettings(newSettings);

      if (state.permissionsGranted) {
        // Get current progress from analytics
        final currentProgress = _getCurrentReadingProgress();
        await _notificationService.scheduleReadingGoalReminder(
          hour: newSettings.readingGoalHour,
          minute: newSettings.readingGoalMinute,
          dailyGoal: newSettings.dailyReadingGoal,
          currentProgress: currentProgress,
          enabled: newSettings.readingGoalEnabled,
        );
      }

      state = state.copyWith(settings: newSettings);

      if (kDebugMode) {
        debugPrint('📱 Reading goal settings updated: $newSettings');
      }
    } catch (e) {
      state = state.copyWith(error: 'Okuma hedefi ayarları güncellenemedi: $e');
    }
  }

  /// Update breaking news setting
  Future<void> updateBreakingNewsEnabled(bool enabled) async {
    try {
      final newSettings = state.settings.copyWith(breakingNewsEnabled: enabled);

      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);

      if (kDebugMode) {
        debugPrint('📱 Breaking news settings updated: enabled=$enabled');
      }
    } catch (e) {
      state = state.copyWith(error: 'Son dakika ayarları güncellenemedi: $e');
    }
  }

  /// Update notification schedules
  Future<void> _updateNotificationSchedules(
    NotificationSettings settings,
  ) async {
    // Schedule daily news reminder
    await _notificationService.scheduleDailyNewsReminder(
      hour: settings.dailyNewsHour,
      minute: settings.dailyNewsMinute,
      enabled: settings.dailyNewsEnabled,
    );

    // Schedule reading goal reminder
    final currentProgress = _getCurrentReadingProgress();
    await _notificationService.scheduleReadingGoalReminder(
      hour: settings.readingGoalHour,
      minute: settings.readingGoalMinute,
      dailyGoal: settings.dailyReadingGoal,
      currentProgress: currentProgress,
      enabled: settings.readingGoalEnabled,
    );
  }

  /// Analytics'ten mevcut okuma ilerlemesini alır
  int _getCurrentReadingProgress() {
    try {
      final todayAnalytics = _ref.read(todayAnalyticsProvider);
      return todayAnalytics.articlesRead;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Analytics progress alma hatası: $e');
      }
      return 0; // Default to 0 if analytics not available
    }
  }

  /// Show reading goal achieved notification
  Future<void> showGoalAchievedNotification() async {
    if (state.permissionsGranted && state.settings.readingGoalEnabled) {
      await _notificationService.showReadingGoalAchievedNotification();
    }
  }

  /// Show breaking news notification
  Future<void> showBreakingNewsNotification({
    required String title,
    required String summary,
    String? articleId,
  }) async {
    if (state.permissionsGranted && state.settings.breakingNewsEnabled) {
      await _notificationService.showBreakingNewsNotification(
        title: title,
        summary: summary,
        articleId: articleId,
      );
    }
  }

  /// Show test notification
  Future<void> showTestNotification() async {
    if (state.permissionsGranted) {
      await _notificationService.showTestNotification();
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // ========== YENİ METODLAR - AKILLI BİLDİRİM SİSTEMİ ==========

  /// Sessiz saatler toggle
  Future<void> toggleQuietHours(bool enabled) async {
    try {
      final newSettings = state.settings.copyWith(quietHoursEnabled: enabled);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);

      if (kDebugMode) {
        debugPrint('📱 Quiet hours ${enabled ? "enabled" : "disabled"}');
      }
    } catch (e) {
      state = state.copyWith(error: 'Sessiz saatler ayarı güncellenemedi: $e');
    }
  }

  /// Sessiz saatler zamanlarını ayarla
  Future<void> setQuietHours({
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) async {
    try {
      final newSettings = state.settings.copyWith(
        quietHoursStartHour: startHour,
        quietHoursStartMinute: startMinute,
        quietHoursEndHour: endHour,
        quietHoursEndMinute: endMinute,
      );
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);

      if (kDebugMode) {
        debugPrint(
          '📱 Quiet hours set: $startHour:$startMinute - $endHour:$endMinute',
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Sessiz saatler zamanı ayarlanamadı: $e');
    }
  }

  /// Günlük limit toggle
  Future<void> toggleDailyLimit(bool enabled) async {
    try {
      final newSettings = state.settings.copyWith(dailyLimitEnabled: enabled);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);

      if (kDebugMode) {
        debugPrint('📱 Daily limit ${enabled ? "enabled" : "disabled"}');
      }
    } catch (e) {
      state = state.copyWith(error: 'Günlük limit ayarı güncellenemedi: $e');
    }
  }

  /// Maksimum bildirim sayısı
  Future<void> setMaxDailyNotifications(int max) async {
    try {
      final newSettings = state.settings.copyWith(maxDailyNotifications: max);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);

      if (kDebugMode) {
        debugPrint('📱 Max daily notifications set to: $max');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Maksimum bildirim sayısı ayarlanamadı: $e',
      );
    }
  }

  /// Kategori bildirim toggle
  Future<void> toggleCategoryNotification(String category, bool enabled) async {
    try {
      final newCategories = Map<String, bool>.from(
        state.settings.categoryNotifications,
      );
      newCategories[category] = enabled;

      final newSettings = state.settings.copyWith(
        categoryNotifications: newCategories,
      );
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);

      if (kDebugMode) {
        debugPrint(
          '📱 Category "$category" notifications ${enabled ? "enabled" : "disabled"}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Kategori bildirim ayarı güncellenemedi: $e',
      );
    }
  }

  /// Bildirim sayacını artır (internal kullanım için)
  Future<void> incrementNotificationCount() async {
    try {
      final today = DateTime.now();
      final isSameDay =
          state.settings.lastResetDate.day == today.day &&
          state.settings.lastResetDate.month == today.month &&
          state.settings.lastResetDate.year == today.year;

      final newSettings = state.settings.copyWith(
        todayNotificationCount: isSameDay
            ? state.settings.todayNotificationCount + 1
            : 1,
        lastResetDate: today,
      );

      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);

      if (kDebugMode) {
        debugPrint(
          '📱 Notification count: ${newSettings.todayNotificationCount}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error incrementing notification count: $e');
      }
    }
  }

  /// Öncelik ses ayarı
  Future<void> toggleHighPrioritySound(bool enabled) async {
    try {
      final newSettings = state.settings.copyWith(highPrioritySound: enabled);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
    } catch (e) {
      state = state.copyWith(error: 'Öncelik ses ayarı güncellenemedi: $e');
    }
  }

  /// Öncelik titreşim ayarı
  Future<void> toggleHighPriorityVibration(bool enabled) async {
    try {
      final newSettings = state.settings.copyWith(
        highPriorityVibration: enabled,
      );
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
    } catch (e) {
      state = state.copyWith(
        error: 'Öncelik titreşim ayarı güncellenemedi: $e',
      );
    }
  }
}

/// Notification provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      final notificationService = NotificationService();
      return NotificationNotifier(notificationService, ref);
    });

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
