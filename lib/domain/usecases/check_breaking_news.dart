import 'package:flutter/foundation.dart';

import '../entities/article.dart';
import '../../core/services/breaking_news_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/hive_service.dart';

/// Breaking news kontrolü ve bildirim gönderimi use case
/// Provider'daki _checkAndNotifyBreakingNews, _canSendNotification ve
/// _saveLastNotificationTime iş mantığını barındırır
class CheckBreakingNews {
  final BreakingNewsService _breakingNewsService;
  final NotificationService _notificationService;

  CheckBreakingNews({
    BreakingNewsService? breakingNewsService,
    NotificationService? notificationService,
  })  : _breakingNewsService = breakingNewsService ?? BreakingNewsService(),
        _notificationService = notificationService ?? NotificationService();

  /// Makaleler arasında breaking news kontrol et ve bildirim gönder
  Future<void> call(List<Article> articles) async {
    try {
      // Son 10 dakika içindeki haberleri kontrol et
      final now = DateTime.now();
      final recentArticles = articles.where((article) {
        final diff = now.difference(article.publishedDate);
        return diff.inMinutes <= 10;
      }).toList();

      // Breaking news'leri filtrele
      final breakingNews = _breakingNewsService.filterBreakingNews(recentArticles);

      if (breakingNews.isEmpty) return;

      // En yüksek öncelikli breaking news'i al
      breakingNews.sort((a, b) {
        final priorityA = _breakingNewsService.calculatePriority(a);
        final priorityB = _breakingNewsService.calculatePriority(b);
        return priorityB.compareTo(priorityA);
      });

      final topBreakingNews = breakingNews.first;

      // Bildirim sıklığı kontrolü
      if (await _canSendNotification()) {
        await _notificationService.showBreakingNewsNotification(
          title: topBreakingNews.title,
          summary: topBreakingNews.description,
          articleId: topBreakingNews.id,
        );

        // Son bildirim zamanını kaydet
        await _saveLastNotificationTime();
      }
    } catch (e) {
      debugPrint('⚠️ Breaking news kontrolü hatası: $e');
    }
  }

  /// Bildirim gönderilebilir mi kontrol et (saatte max 3 bildirim)
  Future<bool> _canSendNotification() async {
    try {
      final box = HiveService.notificationFrequencyBox;
      final lastNotificationTimes =
          box.get('lastNotificationTimes', defaultValue: <int>[]) as List<dynamic>?;

      if (lastNotificationTimes == null || lastNotificationTimes.isEmpty) {
        return true;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final oneHourAgo = now - (60 * 60 * 1000);

      // Son 1 saat içindeki bildirimleri filtrele
      final recentNotifications =
          lastNotificationTimes.where((time) => (time as int) > oneHourAgo).toList();

      // Saatte max 3 bildirim
      return recentNotifications.length < 3;
    } catch (e) {
      debugPrint('⚠️ Bildirim sıklığı kontrolü hatası: $e');
      return true; // Hata durumunda bildirim gönder
    }
  }

  /// Son bildirim zamanını kaydet
  Future<void> _saveLastNotificationTime() async {
    try {
      final box = HiveService.notificationFrequencyBox;
      final lastNotificationTimes =
          box.get('lastNotificationTimes', defaultValue: <int>[]) as List<dynamic>?;

      final now = DateTime.now().millisecondsSinceEpoch;
      final updatedTimes = List<int>.from(lastNotificationTimes ?? []);
      updatedTimes.add(now);

      // Son 24 saat içindeki bildirimleri tut
      final oneDayAgo = now - (24 * 60 * 60 * 1000);
      final filteredTimes = updatedTimes.where((time) => time > oneDayAgo).toList();

      await box.put('lastNotificationTimes', filteredTimes);
    } catch (e) {
      debugPrint('⚠️ Bildirim zamanı kaydetme hatası: $e');
    }
  }
}