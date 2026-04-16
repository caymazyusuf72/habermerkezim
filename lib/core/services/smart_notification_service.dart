import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hive_service.dart';
import 'notification_service.dart';

/// Bildirim öncelik seviyeleri
enum NotificationPriority {
  low,
  normal,
  high,
  critical, // Son dakika
}

/// Bildirim istatistik modeli
class NotificationStats {
  final int totalSent;
  final int totalViewed;
  final int totalClicked;
  final Map<String, int> categoryStats;
  final DateTime lastResetDate;

  const NotificationStats({
    this.totalSent = 0,
    this.totalViewed = 0,
    this.totalClicked = 0,
    this.categoryStats = const {},
    required this.lastResetDate,
  });

  double get clickRate => totalSent > 0 ? (totalClicked / totalSent) * 100 : 0;
  double get viewRate => totalSent > 0 ? (totalViewed / totalSent) * 100 : 0;

  Map<String, dynamic> toJson() => {
    'totalSent': totalSent,
    'totalViewed': totalViewed,
    'totalClicked': totalClicked,
    'categoryStats': categoryStats,
    'lastResetDate': lastResetDate.toIso8601String(),
  };

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      totalSent: json['totalSent'] ?? 0,
      totalViewed: json['totalViewed'] ?? 0,
      totalClicked: json['totalClicked'] ?? 0,
      categoryStats: Map<String, int>.from(json['categoryStats'] ?? {}),
      lastResetDate: json['lastResetDate'] != null
          ? DateTime.parse(json['lastResetDate'])
          : DateTime.now(),
    );
  }
}

/// Sessiz saatler ayarı
class QuietHoursSettings {
  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const QuietHoursSettings({
    this.enabled = true,
    this.startHour = 22,
    this.startMinute = 0,
    this.endHour = 8,
    this.endMinute = 0,
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'startHour': startHour,
    'startMinute': startMinute,
    'endHour': endHour,
    'endMinute': endMinute,
  };

  factory QuietHoursSettings.fromJson(Map<String, dynamic> json) {
    return QuietHoursSettings(
      enabled: json['enabled'] ?? true,
      startHour: json['startHour'] ?? 22,
      startMinute: json['startMinute'] ?? 0,
      endHour: json['endHour'] ?? 8,
      endMinute: json['endMinute'] ?? 0,
    );
  }

  QuietHoursSettings copyWith({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return QuietHoursSettings(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }
}

/// Günlük özet ayarı
class DailySummarySettings {
  final bool enabled;
  final int hour;
  final int minute;

  const DailySummarySettings({
    this.enabled = false,
    this.hour = 9,
    this.minute = 0,
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'hour': hour,
    'minute': minute,
  };

  factory DailySummarySettings.fromJson(Map<String, dynamic> json) {
    return DailySummarySettings(
      enabled: json['enabled'] ?? false,
      hour: json['hour'] ?? 9,
      minute: json['minute'] ?? 0,
    );
  }

  DailySummarySettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return DailySummarySettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}

/// Akıllı Bildirim Servisi
/// Topic-based, scheduled, gruplama, sessiz saatler ve öncelik sistemi
class SmartNotificationService {
  static final SmartNotificationService _instance = SmartNotificationService._internal();
  factory SmartNotificationService() => _instance;
  SmartNotificationService._internal();

  final NotificationService _notificationService = NotificationService();

  // Hive keys
  static const String _topicSubscriptionsKey = 'notification_topic_subscriptions';
  static const String _quietHoursKey = 'notification_quiet_hours';
  static const String _dailySummaryKey = 'notification_daily_summary';
  static const String _notificationStatsKey = 'notification_stats';
  static const String _pendingNotificationsKey = 'notification_pending_group';
  static const String _dailyNotificationCountKey = 'notification_daily_count';
  static const String _lastCountResetKey = 'notification_last_count_reset';

  // ─── Topic-Based Bildirimler ──────────────────────────────────────────────

  /// Kategori aboneliklerini al
  Map<String, bool> getTopicSubscriptions() {
    try {
      final box = HiveService.settingsBox;
      final data = box.get(_topicSubscriptionsKey);
      if (data is Map) {
        return Map<String, bool>.from(data);
      }
      // Default: tüm kategoriler açık
      return {};
    } catch (e) {
      debugPrint('❌ Topic subscriptions alınamadı: $e');
      return {};
    }
  }

  /// Kategori aboneliğini güncelle
  Future<void> setTopicSubscription(String category, bool subscribed) async {
    try {
      final box = HiveService.settingsBox;
      final subs = getTopicSubscriptions();
      subs[category] = subscribed;
      await box.put(_topicSubscriptionsKey, subs);
      debugPrint('📱 Topic subscription güncellendi: $category = $subscribed');
    } catch (e) {
      debugPrint('❌ Topic subscription güncellenemedi: $e');
    }
  }

  /// Kategoriye abone mi kontrol et
  bool isSubscribedToTopic(String category) {
    final subs = getTopicSubscriptions();
    return subs[category] ?? true; // Default: abone
  }

  // ─── Scheduled Bildirimler ────────────────────────────────────────────────

  /// Günlük özet ayarlarını al
  DailySummarySettings getDailySummarySettings() {
    try {
      final box = HiveService.settingsBox;
      final data = box.get(_dailySummaryKey);
      if (data is Map) {
        return DailySummarySettings.fromJson(Map<String, dynamic>.from(data));
      }
      return const DailySummarySettings();
    } catch (e) {
      return const DailySummarySettings();
    }
  }

  /// Günlük özet ayarlarını kaydet
  Future<void> setDailySummarySettings(DailySummarySettings settings) async {
    try {
      final box = HiveService.settingsBox;
      await box.put(_dailySummaryKey, settings.toJson());

      // Bildirim zamanlayıcısını güncelle
      await _notificationService.scheduleDailyNewsReminder(
        hour: settings.hour,
        minute: settings.minute,
        enabled: settings.enabled,
      );

      debugPrint('📱 Günlük özet ayarları güncellendi: ${settings.hour}:${settings.minute}');
    } catch (e) {
      debugPrint('❌ Günlük özet ayarları güncellenemedi: $e');
    }
  }

  // ─── Bildirim Gruplama ────────────────────────────────────────────────────

  /// Bekleyen bildirimleri grupla ve gönder
  Future<void> addToNotificationGroup({
    required String source,
    required String title,
    required String body,
    String? articleId,
  }) async {
    try {
      final box = HiveService.settingsBox;
      final pending = _getPendingNotifications();

      pending.add({
        'source': source,
        'title': title,
        'body': body,
        'articleId': articleId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await box.put(_pendingNotificationsKey, jsonEncode(pending));

      // Aynı kaynaktan 3+ bildirim birikirse gruplayarak gönder
      final sourceNotifications = pending.where((n) => n['source'] == source).toList();
      if (sourceNotifications.length >= 3) {
        await _sendGroupedNotification(source, sourceNotifications);
        // Gönderilen bildirimleri temizle
        pending.removeWhere((n) => n['source'] == source);
        await box.put(_pendingNotificationsKey, jsonEncode(pending));
      }
    } catch (e) {
      debugPrint('❌ Bildirim gruplama hatası: $e');
    }
  }

  /// Gruplanmış bildirim gönder
  Future<void> _sendGroupedNotification(
    String source,
    List<Map<String, dynamic>> notifications,
  ) async {
    final count = notifications.length;
    await _notificationService.sendSmartNotification(
      category: source,
      title: '$source - $count yeni haber',
      body: notifications.take(3).map((n) => n['title']).join(', '),
      priority: 'normal',
    );

    // İstatistikleri güncelle
    await _incrementSentCount(count);
  }

  List<Map<String, dynamic>> _getPendingNotifications() {
    try {
      final box = HiveService.settingsBox;
      final data = box.get(_pendingNotificationsKey);
      if (data is String && data.isNotEmpty) {
        final decoded = jsonDecode(data) as List;
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ─── Sessiz Saatler ──────────────────────────────────────────────────────

  /// Sessiz saatler ayarlarını al
  QuietHoursSettings getQuietHoursSettings() {
    try {
      final box = HiveService.settingsBox;
      final data = box.get(_quietHoursKey);
      if (data is Map) {
        return QuietHoursSettings.fromJson(Map<String, dynamic>.from(data));
      }
      return const QuietHoursSettings();
    } catch (e) {
      return const QuietHoursSettings();
    }
  }

  /// Sessiz saatler ayarlarını kaydet
  Future<void> setQuietHoursSettings(QuietHoursSettings settings) async {
    try {
      final box = HiveService.settingsBox;
      await box.put(_quietHoursKey, settings.toJson());
      debugPrint('📱 Sessiz saatler güncellendi: ${settings.startHour}:${settings.startMinute} - ${settings.endHour}:${settings.endMinute}');
    } catch (e) {
      debugPrint('❌ Sessiz saatler güncellenemedi: $e');
    }
  }

  /// Şu anda sessiz saatlerde mi?
  bool isInQuietHours() {
    final settings = getQuietHoursSettings();
    return _notificationService.isInQuietHours(
      quietHoursEnabled: settings.enabled,
      startHour: settings.startHour,
      startMinute: settings.startMinute,
      endHour: settings.endHour,
      endMinute: settings.endMinute,
    );
  }

  // ─── Öncelik Sistemi ─────────────────────────────────────────────────────

  /// Akıllı bildirim gönder (tüm kontrolleri uygular)
  Future<bool> sendNotification({
    required String category,
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.normal,
    String? articleId,
  }) async {
    // 1. Topic kontrolü (critical hariç)
    if (priority != NotificationPriority.critical) {
      if (!isSubscribedToTopic(category)) {
        debugPrint('📱 Kategori abonelik kapalı: $category');
        return false;
      }
    }

    // 2. Sessiz saatler kontrolü (critical hariç)
    if (priority != NotificationPriority.critical && isInQuietHours()) {
      debugPrint('📱 Sessiz saatlerde bildirim ertelendi');
      // Pending'e ekle
      await addToNotificationGroup(
        source: category,
        title: title,
        body: body,
        articleId: articleId,
      );
      return false;
    }

    // 3. Günlük limit kontrolü
    if (priority == NotificationPriority.low || priority == NotificationPriority.normal) {
      final dailyCount = _getDailyNotificationCount();
      if (dailyCount >= 20) { // Günlük max 20 bildirim
        debugPrint('📱 Günlük bildirim limiti aşıldı: $dailyCount');
        return false;
      }
    }

    // 4. Önceliğe göre bildirim ayarları
    String priorityStr;
    switch (priority) {
      case NotificationPriority.critical:
        priorityStr = 'critical';
        break;
      case NotificationPriority.high:
        priorityStr = 'high';
        break;
      case NotificationPriority.low:
        priorityStr = 'normal';
        break;
      case NotificationPriority.normal:
        priorityStr = 'normal';
        break;
    }

    // 5. Gönder
    final result = await _notificationService.sendSmartNotification(
      category: category,
      title: title,
      body: body,
      priority: priorityStr,
      articleId: articleId,
    );

    if (result) {
      await _incrementSentCount(1);
      _incrementDailyCount();
    }

    return result;
  }

  // ─── Bildirim İstatistikleri ──────────────────────────────────────────────

  /// İstatistikleri al
  NotificationStats getStats() {
    try {
      final box = HiveService.settingsBox;
      final data = box.get(_notificationStatsKey);
      if (data is Map) {
        return NotificationStats.fromJson(Map<String, dynamic>.from(data));
      }
      return NotificationStats(lastResetDate: DateTime.now());
    } catch (e) {
      return NotificationStats(lastResetDate: DateTime.now());
    }
  }

  /// Gönderim sayacını artır
  Future<void> _incrementSentCount(int count) async {
    try {
      final stats = getStats();
      final newStats = NotificationStats(
        totalSent: stats.totalSent + count,
        totalViewed: stats.totalViewed,
        totalClicked: stats.totalClicked,
        categoryStats: stats.categoryStats,
        lastResetDate: stats.lastResetDate,
      );
      await HiveService.settingsBox.put(_notificationStatsKey, newStats.toJson());
    } catch (e) {
      debugPrint('❌ Bildirim istatistiği güncellenemedi: $e');
    }
  }

  /// Görüntülenme kaydet
  Future<void> recordView() async {
    try {
      final stats = getStats();
      final newStats = NotificationStats(
        totalSent: stats.totalSent,
        totalViewed: stats.totalViewed + 1,
        totalClicked: stats.totalClicked,
        categoryStats: stats.categoryStats,
        lastResetDate: stats.lastResetDate,
      );
      await HiveService.settingsBox.put(_notificationStatsKey, newStats.toJson());
    } catch (e) {
      debugPrint('❌ Görüntülenme kaydedilemedi: $e');
    }
  }

  /// Tıklanma kaydet
  Future<void> recordClick() async {
    try {
      final stats = getStats();
      final newStats = NotificationStats(
        totalSent: stats.totalSent,
        totalViewed: stats.totalViewed,
        totalClicked: stats.totalClicked + 1,
        categoryStats: stats.categoryStats,
        lastResetDate: stats.lastResetDate,
      );
      await HiveService.settingsBox.put(_notificationStatsKey, newStats.toJson());
    } catch (e) {
      debugPrint('❌ Tıklanma kaydedilemedi: $e');
    }
  }

  /// İstatistikleri sıfırla
  Future<void> resetStats() async {
    try {
      final newStats = NotificationStats(lastResetDate: DateTime.now());
      await HiveService.settingsBox.put(_notificationStatsKey, newStats.toJson());
    } catch (e) {
      debugPrint('❌ İstatistikler sıfırlanamadı: $e');
    }
  }

  // ─── Günlük Sayaç ────────────────────────────────────────────────────────

  int _getDailyNotificationCount() {
    try {
      final box = HiveService.settingsBox;
      final lastReset = box.get(_lastCountResetKey);
      final today = DateTime.now();

      // Gün değişmişse sıfırla
      if (lastReset != null) {
        final lastResetDate = DateTime.parse(lastReset.toString());
        if (lastResetDate.day != today.day ||
            lastResetDate.month != today.month ||
            lastResetDate.year != today.year) {
          box.put(_dailyNotificationCountKey, 0);
          box.put(_lastCountResetKey, today.toIso8601String());
          return 0;
        }
      } else {
        box.put(_lastCountResetKey, today.toIso8601String());
      }

      return box.get(_dailyNotificationCountKey, defaultValue: 0) as int;
    } catch (e) {
      return 0;
    }
  }

  void _incrementDailyCount() {
    try {
      final box = HiveService.settingsBox;
      final count = _getDailyNotificationCount();
      box.put(_dailyNotificationCountKey, count + 1);
    } catch (e) {
      debugPrint('❌ Günlük sayaç güncellenemedi: $e');
    }
  }
}

// ─── Riverpod Provider'ları ─────────────────────────────────────────────────

/// SmartNotificationService provider
final smartNotificationServiceProvider = Provider<SmartNotificationService>((ref) {
  return SmartNotificationService();
});

/// Bildirim istatistikleri provider
final notificationStatsProvider = Provider<NotificationStats>((ref) {
  final service = ref.watch(smartNotificationServiceProvider);
  return service.getStats();
});

/// Topic abonelikleri provider
final topicSubscriptionsProvider = Provider<Map<String, bool>>((ref) {
  final service = ref.watch(smartNotificationServiceProvider);
  return service.getTopicSubscriptions();
});

/// Sessiz saatler ayarları provider
final quietHoursProvider = Provider<QuietHoursSettings>((ref) {
  final service = ref.watch(smartNotificationServiceProvider);
  return service.getQuietHoursSettings();
});

/// Günlük özet ayarları provider
final dailySummaryProvider = Provider<DailySummarySettings>((ref) {
  final service = ref.watch(smartNotificationServiceProvider);
  return service.getDailySummarySettings();
});