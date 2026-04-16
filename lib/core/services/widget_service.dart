import 'package:flutter/foundation.dart';
import '../../domain/entities/article.dart';
import 'app_widget_service.dart';

/// Android widget servisi - widget verilerini günceller
/// Geriye uyumluluk için korunmuştur.
/// Yeni kod [AppWidgetService] kullanmalıdır.
class WidgetService {
  /// Widget'ı initialize et
  static Future<void> initialize() async {
    await AppWidgetService.initialize();
  }

  /// Widget'ı son haberlerle güncelle
  static Future<void> updateWidget(List<Article> articles) async {
    debugPrint('🔄 WidgetService.updateWidget -> AppWidgetService.updateAllWidgets');
    await AppWidgetService.updateAllWidgets(articles);
  }
}
