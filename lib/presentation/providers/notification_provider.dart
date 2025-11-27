import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/hive_service.dart';

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
  final Map<String, bool> categoryNotifications; // Kategori ID -> bildirim açık/kapalı

  const NotificationSettings({
    this.dailyNewsEnabled = true,
    this.dailyNewsHour = 9,
    this.dailyNewsMinute = 0,
    this.readingGoalEnabled = true,
    this.readingGoalHour = 20,
    this.readingGoalMinute = 0,
    this.dailyReadingGoal = 10,
    this.breakingNewsEnabled = false,
    this.categoryNotifications = const {},
  });

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
      categoryNotifications: categoryNotifications ?? this.categoryNotifications,
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

  const NotificationState({
    this.settings = const NotificationSettings(),
    this.permissionsGranted = false,
    this.initialized = false,
    this.loading = false,
    this.error,
  });

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
  final HiveService _hiveService;

  static const String _settingsKey = 'notification_settings';

  NotificationNotifier(this._notificationService, this._hiveService)
      : super(const NotificationState()) {
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
        print('📱 NotificationProvider initialized: $savedSettings');
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Bildirim servisi başlatılamadı: $e',
      );
      if (kDebugMode) {
        print('❌ NotificationProvider initialization error: $e');
      }
    }
  }

  /// Load settings from storage
  Future<NotificationSettings> _loadSettings() async {
    try {
      final settingsBox = HiveService.settingsBox;
      final savedMap = settingsBox.get(_settingsKey);

      if (savedMap != null && savedMap is Map) {
        return NotificationSettings.fromMap(Map<String, dynamic>.from(savedMap));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading notification settings: $e');
      }
    }
    return const NotificationSettings();
  }

  /// Save settings to storage
  Future<void> _saveSettings(NotificationSettings settings) async {
    try {
      final settingsBox = HiveService.settingsBox;
      await settingsBox.put(_settingsKey, settings.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving notification settings: $e');
      }
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      state = state.copyWith(loading: true);

      final granted = await _notificationService.requestPermissions();
      
      state = state.copyWith(
        permissionsGranted: granted,
        loading: false,
      );

      if (granted) {
        await _updateNotificationSchedules(state.settings);
      }

      return granted;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'İzin alınamadı: $e',
      );
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
        print('📱 Daily news settings updated: $newSettings');
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
        // For reading goal, we need current progress from analytics
        // For now, assume 0 progress - this will be updated when analytics are available
        await _notificationService.scheduleReadingGoalReminder(
          hour: newSettings.readingGoalHour,
          minute: newSettings.readingGoalMinute,
          dailyGoal: newSettings.dailyReadingGoal,
          currentProgress: 0, // TODO: Get from analytics
          enabled: newSettings.readingGoalEnabled,
        );
      }

      state = state.copyWith(settings: newSettings);

      if (kDebugMode) {
        print('📱 Reading goal settings updated: $newSettings');
      }
    } catch (e) {
      state = state.copyWith(error: 'Okuma hedefi ayarları güncellenemedi: $e');
    }
  }

  /// Update breaking news setting
  Future<void> updateBreakingNewsEnabled(bool enabled) async {
    try {
      final newSettings = state.settings.copyWith(
        breakingNewsEnabled: enabled,
      );

      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);

      if (kDebugMode) {
        print('📱 Breaking news settings updated: enabled=$enabled');
      }
    } catch (e) {
      state = state.copyWith(error: 'Son dakika ayarları güncellenemedi: $e');
    }
  }

  /// Update notification schedules
  Future<void> _updateNotificationSchedules(NotificationSettings settings) async {
    // Schedule daily news reminder
    await _notificationService.scheduleDailyNewsReminder(
      hour: settings.dailyNewsHour,
      minute: settings.dailyNewsMinute,
      enabled: settings.dailyNewsEnabled,
    );

    // Schedule reading goal reminder
    await _notificationService.scheduleReadingGoalReminder(
      hour: settings.readingGoalHour,
      minute: settings.readingGoalMinute,
      dailyGoal: settings.dailyReadingGoal,
      currentProgress: 0, // TODO: Get from analytics
      enabled: settings.readingGoalEnabled,
    );
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
}

/// Notification provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notificationService = NotificationService();
  final hiveService = HiveService();
  return NotificationNotifier(notificationService, hiveService);
});

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});