import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _dailyNewsChannelId = 'daily_news';
  static const String _readingGoalChannelId = 'reading_goal';

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestProvisionalPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _initialized = true;
    if (kDebugMode) {
      debugPrint('📱 NotificationService initialized successfully');
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('📱 Notification tapped: ${response.payload}');
    }
    // TODO: Handle navigation based on payload
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // Daily news channel
    const dailyNewsChannel = AndroidNotificationChannel(
      _dailyNewsChannelId,
      'Günlük Haber Hatırlatmaları',
      description: 'Günlük haber okuma hatırlatma bildirimleri',
      importance: Importance.defaultImportance,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    // Reading goal channel
    const readingGoalChannel = AndroidNotificationChannel(
      _readingGoalChannelId,
      'Okuma Hedefi Bildirimleri',
      description: 'Günlük okuma hedefi takip bildirimleri',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(dailyNewsChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(readingGoalChannel);
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      return await androidPlugin?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final settings = await iosPlugin?.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    return true;
  }

  /// Schedule daily news reminder
  Future<void> scheduleDailyNewsReminder({
    required int hour,
    required int minute,
    required bool enabled,
  }) async {
    const int notificationId = 1;

    // Cancel existing notification
    await _notifications.cancel(notificationId);

    if (!enabled) return;

    final scheduledTime = _nextInstanceOfTime(hour, minute);

    await _notifications.zonedSchedule(
      notificationId,
      'Haber Zamanı! 📰',
      'Günün haberlerini kaçırma! Yeni haberler seni bekliyor.',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyNewsChannelId,
          'Günlük Haber Hatırlatmaları',
          channelDescription: 'Günlük haber okuma hatırlatma bildirimleri',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/launcher_icon',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        ),
        iOS: DarwinNotificationDetails(sound: 'default'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'daily_news_reminder',
      matchDateTimeComponents: DateTimeComponents.time,
    );

    if (kDebugMode) {
      debugPrint(
        '📱 Daily news reminder scheduled for ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      );
    }
  }

  /// Schedule reading goal notification
  Future<void> scheduleReadingGoalReminder({
    required int hour,
    required int minute,
    required int dailyGoal,
    required int currentProgress,
    required bool enabled,
  }) async {
    const int notificationId = 2;

    // Cancel existing notification
    await _notifications.cancel(notificationId);

    if (!enabled || currentProgress >= dailyGoal) return;

    final scheduledTime = _nextInstanceOfTime(hour, minute);
    final remaining = dailyGoal - currentProgress;

    await _notifications.zonedSchedule(
      notificationId,
      'Okuma Hedefin Seni Bekliyor! 🎯',
      'Bugünkü hedefine ulaşmak için $remaining haber daha oku!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _readingGoalChannelId,
          'Okuma Hedefi Bildirimleri',
          channelDescription: 'Günlük okuma hedefi takip bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        ),
        iOS: DarwinNotificationDetails(sound: 'default'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'reading_goal_reminder',
      matchDateTimeComponents: DateTimeComponents.time,
    );

    if (kDebugMode) {
      debugPrint(
        '📱 Reading goal reminder scheduled for ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      );
    }
  }

  /// Show instant reading goal achievement notification
  Future<void> showReadingGoalAchievedNotification() async {
    const int notificationId = 3;

    await _notifications.show(
      notificationId,
      'Tebrikler! Hedefin Tamamlandı! 🎉',
      'Bugünkü okuma hedefine ulaştın! Harika bir performans sergilediğin.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _readingGoalChannelId,
          'Okuma Hedefi Bildirimleri',
          channelDescription: 'Günlük okuma hedefi takip bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        ),
        iOS: DarwinNotificationDetails(sound: 'default'),
      ),
      payload: 'goal_achieved',
    );

    if (kDebugMode) {
      debugPrint('📱 Reading goal achievement notification shown');
    }
  }

  /// Show instant breaking news notification
  Future<void> showBreakingNewsNotification({
    required String title,
    required String summary,
    String? articleId,
  }) async {
    const int notificationId = 4;

    await _notifications.show(
      notificationId,
      'Son Dakika! 🚨',
      title.length > 100 ? '${title.substring(0, 97)}...' : title,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyNewsChannelId,
          'Günlük Haber Hatırlatmaları',
          channelDescription: 'Günlük haber okuma hatırlatma bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        ),
        iOS: DarwinNotificationDetails(sound: 'default'),
      ),
      payload: 'breaking_news:${articleId ?? ''}',
    );

    if (kDebugMode) {
      debugPrint('📱 Breaking news notification shown: $title');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    if (kDebugMode) {
      debugPrint('📱 All notifications cancelled');
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    if (kDebugMode) {
      debugPrint('📱 Notification $id cancelled');
    }
  }

  /// Get next instance of specified time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Test notification (for debugging)
  Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      'Test Bildirimi 🧪',
      'Bu bir test bildirimidir. Bildirimler düzgün çalışıyor!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyNewsChannelId,
          'Günlük Haber Hatırlatmaları',
          channelDescription: 'Test bildirimi',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(sound: 'default'),
      ),
      payload: 'test_notification',
    );
  }

  // ========== AKILLI BİLDİRİM SİSTEMİ METODLARI ==========

  /// Sessiz saatlerde mi kontrolü
  bool isInQuietHours({
    required bool quietHoursEnabled,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) {
    if (!quietHoursEnabled) return false;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    // Gece yarısı geçişi kontrolü (örn: 22:00-08:00)
    if (startMinutes > endMinutes) {
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }

    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  }

  /// Günlük limit kontrolü
  bool canSendNotification({
    required bool dailyLimitEnabled,
    required int maxDailyNotifications,
    required int todayNotificationCount,
    required DateTime lastResetDate,
  }) {
    if (!dailyLimitEnabled) return true;

    final today = DateTime.now();
    final isSameDay =
        lastResetDate.day == today.day &&
        lastResetDate.month == today.month &&
        lastResetDate.year == today.year;

    // Yeni gün, izin ver
    if (!isSameDay) return true;

    // Aynı gün, limit kontrolü
    return todayNotificationCount < maxDailyNotifications;
  }

  /// Kategori ve öncelik bazlı akıllı bildirim gönderimi
  Future<bool> sendSmartNotification({
    required String category,
    required String title,
    required String body,
    String priority = 'normal', // 'normal', 'high', 'critical'
    String? articleId,
    Map<String, bool>? categoryNotifications,
    bool? quietHoursEnabled,
    int? quietHoursStartHour,
    int? quietHoursStartMinute,
    int? quietHoursEndHour,
    int? quietHoursEndMinute,
    bool? dailyLimitEnabled,
    int? maxDailyNotifications,
    int? todayNotificationCount,
    DateTime? lastResetDate,
    bool? highPrioritySound,
    bool? highPriorityVibration,
  }) async {
    try {
      // 1. Kategori kontrolü
      if (categoryNotifications != null &&
          !(categoryNotifications[category] ?? true)) {
        if (kDebugMode) {
          debugPrint('📱 Kategori bildirim kapalı: $category');
        }
        return false;
      }

      // 2. Sessiz saatler kontrolü
      if (quietHoursEnabled == true &&
          quietHoursStartHour != null &&
          quietHoursStartMinute != null &&
          quietHoursEndHour != null &&
          quietHoursEndMinute != null) {
        if (isInQuietHours(
          quietHoursEnabled: true,
          startHour: quietHoursStartHour,
          startMinute: quietHoursStartMinute,
          endHour: quietHoursEndHour,
          endMinute: quietHoursEndMinute,
        )) {
          if (kDebugMode) {
            debugPrint('📱 Sessiz saatlerde, bildirim ertelendi');
          }
          return false;
        }
      }

      // 3. Günlük limit kontrolü
      if (dailyLimitEnabled == true &&
          maxDailyNotifications != null &&
          todayNotificationCount != null &&
          lastResetDate != null) {
        if (!canSendNotification(
          dailyLimitEnabled: true,
          maxDailyNotifications: maxDailyNotifications,
          todayNotificationCount: todayNotificationCount,
          lastResetDate: lastResetDate,
        )) {
          if (kDebugMode) {
            debugPrint(
              '📱 Günlük limit aşıldı: $todayNotificationCount/$maxDailyNotifications',
            );
          }
          return false;
        }
      }

      // 4. Öncelik seviyesine göre bildirim ayarları
      Importance importance;
      Priority androidPriority;
      String? sound;
      bool enableVibration;

      switch (priority) {
        case 'critical':
          importance = Importance.max;
          androidPriority = Priority.max;
          sound = 'default';
          enableVibration = highPriorityVibration ?? true;
          break;
        case 'high':
          importance = Importance.high;
          androidPriority = Priority.high;
          sound = highPrioritySound == true ? 'default' : null;
          enableVibration = highPriorityVibration ?? true;
          break;
        default: // normal
          importance = Importance.defaultImportance;
          androidPriority = Priority.defaultPriority;
          sound = 'default';
          enableVibration = false;
      }

      // 5. Bildirimi gönder
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _notifications.show(
        notificationId,
        title,
        body.length > 100 ? '${body.substring(0, 97)}...' : body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _dailyNewsChannelId,
            'Günlük Haber Hatırlatmaları',
            channelDescription: 'Kategori bazlı haber bildirimleri',
            importance: importance,
            priority: androidPriority,
            icon: '@mipmap/launcher_icon',
            largeIcon: const DrawableResourceAndroidBitmap(
              '@mipmap/launcher_icon',
            ),
            sound: sound != null
                ? RawResourceAndroidNotificationSound(sound)
                : null,
            enableVibration: enableVibration,
          ),
          iOS: DarwinNotificationDetails(sound: sound),
        ),
        payload: 'category:$category${articleId != null ? ':$articleId' : ''}',
      );

      if (kDebugMode) {
        debugPrint('📱 Smart notification sent: $category - $priority');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Smart notification error: $e');
      }
      return false;
    }
  }
}
