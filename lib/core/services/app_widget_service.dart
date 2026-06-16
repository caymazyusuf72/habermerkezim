import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/article.dart';

/// Widget türleri
enum WidgetType {
  /// Banner widget - marquee ile kayan tek haber
  banner,
  /// Small (2x1) - Tek haber başlığı, gradient arka plan
  small,
  /// Medium (4x2) - 3 haber listesi, resimler
  medium,
  /// Large (4x4) - Büyük ana haber kartı + alt haberler
  large,
  /// Headlines (4x1) - ViewFlipper ile kayan başlıklar
  headlines,
  /// Haber listesi (mevcut eski widget)
  newsList,
}

/// Android Home Screen App Widget servisi
/// Tüm widget türleri için veri güncelleme, deep link ve periyodik güncelleme yönetimi
class AppWidgetService {
  // Widget Android sınıf adları
  static const String _bannerWidgetName = 'NewsWidgetProvider';
  static const String _newsListWidgetName = 'NewsListWidgetProvider';
  static const String _smallWidgetName = 'NewsWidgetSmall';
  static const String _mediumWidgetName = 'NewsWidgetMedium';
  static const String _largeWidgetName = 'NewsWidgetLarge';
  static const String _headlinesWidgetName = 'NewsWidgetHeadlines';

  // SharedPreferences key'leri
  static const String _titleKey = 'title';
  static const String _descriptionKey = 'description';
  static const String _linkKey = 'link';
  static const String _imageUrlKey = 'imageUrl';
  static const String _countKey = 'count';
  static const String _currentIndexKey = 'currentIndex';
  static const String _articlesKey = 'articles';
  static const String _sourcesKey = 'sources';
  static const String _timesKey = 'times';
  static const String _isBreakingKey = 'isBreaking';

  /// Widget'ı initialize et
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId('group.com.habermerkezi.widget');
      debugPrint('✅ AppWidgetService initialized');
    } catch (e) {
      debugPrint('⚠️ AppWidgetService initialize hatası: $e');
    }
  }

  /// Tüm widget'ları son haberlerle güncelle
  static Future<void> updateAllWidgets(List<Article> articles) async {
    try {
      debugPrint('🔄 Tüm widget\'lar güncelleniyor: ${articles.length} haber');

      if (articles.isEmpty) {
        debugPrint('⚠️ Haber listesi boş, widget\'lar temizleniyor');
        await _clearAllWidgetData();
        return;
      }

      // Son 10 haberi al
      final topArticles = articles.take(10).toList();

      // Verileri kaydet
      await _saveArticleData(topArticles);

      // Tüm widget'ları güncelle
      await _updateWidget(_bannerWidgetName);
      await _updateWidget(_newsListWidgetName);
      await _updateWidget(_smallWidgetName);
      await _updateWidget(_mediumWidgetName);
      await _updateWidget(_largeWidgetName);
      await _updateWidget(_headlinesWidgetName);

      debugPrint('✅ Tüm widget\'lar güncellendi: ${topArticles.length} haber');
    } catch (e, stackTrace) {
      debugPrint('⚠️ Widget güncelleme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Belirli widget türlerini güncelle
  static Future<void> updateWidgets(List<Article> articles, List<WidgetType> types) async {
    try {
      if (articles.isEmpty) return;

      final topArticles = articles.take(10).toList();
      await _saveArticleData(topArticles);

      for (final type in types) {
        switch (type) {
          case WidgetType.banner:
            await _updateWidget(_bannerWidgetName);
            break;
          case WidgetType.small:
            await _updateWidget(_smallWidgetName);
            break;
          case WidgetType.medium:
            await _updateWidget(_mediumWidgetName);
            break;
          case WidgetType.large:
            await _updateWidget(_largeWidgetName);
            break;
          case WidgetType.headlines:
            await _updateWidget(_headlinesWidgetName);
            break;
          case WidgetType.newsList:
            await _updateWidget(_newsListWidgetName);
            break;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Widget güncelleme hatası: $e');
    }
  }

  /// Son dakika haberi flag'ini ayarla
  static Future<void> setBreakingNews(bool isBreaking) async {
    try {
      await HomeWidget.saveWidgetData<String>(_isBreakingKey, isBreaking.toString());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('flutter.$_isBreakingKey', isBreaking.toString());
      await prefs.setString(_isBreakingKey, isBreaking.toString());

      // Large widget'ı güncelle (breaking badge göstermesi için)
      await _updateWidget(_largeWidgetName);
    } catch (e) {
      debugPrint('⚠️ Breaking news flag hatası: $e');
    }
  }

  /// Makale verilerini SharedPreferences'a kaydet
  static Future<void> _saveArticleData(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();

    // İlk haber (banner widget için geriye uyumluluk)
    if (articles.isNotEmpty) {
      final first = articles[0];
      await _saveToAll(prefs, _titleKey, first.title);
      await _saveToAll(prefs, _descriptionKey, first.description);
      await _saveToAll(prefs, _linkKey, first.link);
      if (first.imageUrl != null) {
        await _saveToAll(prefs, _imageUrlKey, first.imageUrl!);
      }
    }

    // Toplam haber sayısı ve index
    await _saveToAll(prefs, _countKey, articles.length.toString());
    await _saveToAll(prefs, _currentIndexKey, '0');

    // Tüm haberler — pipe-separated format
    final articlesString = articles.map((a) =>
      '${a.title}|${a.description}|${a.link}|${a.imageUrl ?? ""}'
    ).join('|||');
    await _saveToAll(prefs, _articlesKey, articlesString);

    // Kaynak adları
    final sourcesString = articles.map((a) => a.sourceName).join('|||');
    await _saveToAll(prefs, _sourcesKey, sourcesString);

    // Zaman bilgileri
    final timeFormatter = DateFormat('HH:mm', 'tr');
    final timesString = articles.map((a) {
      final now = DateTime.now();
      final diff = now.difference(a.publishedDate);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} dk önce';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} sa önce';
      } else if (diff.inDays == 1) {
        return 'Dün ${timeFormatter.format(a.publishedDate)}';
      } else {
        return DateFormat('dd MMM', 'tr').format(a.publishedDate);
      }
    }).join('|||');
    await _saveToAll(prefs, _timesKey, timesString);

    debugPrint('✅ Widget verileri kaydedildi: ${articles.length} haber');
  }

  /// Veriyi hem HomeWidget hem de SharedPreferences'a kaydet
  static Future<void> _saveToAll(SharedPreferences prefs, String key, String value) async {
    await HomeWidget.saveWidgetData<String>(key, value);
    await prefs.setString('flutter.$key', value);
    await prefs.setString(key, value);
  }

  /// Belirli bir Android widget'ını güncelle
  static Future<void> _updateWidget(String androidName) async {
    try {
      await HomeWidget.updateWidget(
        androidName: androidName,
      );
    } catch (e) {
      debugPrint('⚠️ Widget güncelleme hatası ($androidName): $e');
    }
  }

  /// Tüm widget verilerini temizle
  static Future<void> _clearAllWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = [_titleKey, _descriptionKey, _linkKey, _imageUrlKey,
                    _countKey, _currentIndexKey, _articlesKey, _sourcesKey,
                    _timesKey, _isBreakingKey];

      for (final key in keys) {
        await HomeWidget.saveWidgetData<String>(key, '');
        await prefs.setString('flutter.$key', '');
        await prefs.setString(key, '');
      }

      // Tüm widget'ları güncelle
      await _updateWidget(_bannerWidgetName);
      await _updateWidget(_newsListWidgetName);
      await _updateWidget(_smallWidgetName);
      await _updateWidget(_mediumWidgetName);
      await _updateWidget(_largeWidgetName);
      await _updateWidget(_headlinesWidgetName);

      debugPrint('✅ Tüm widget verileri temizlendi');
    } catch (e) {
      debugPrint('⚠️ Widget temizleme hatası: $e');
    }
  }
}

/// Riverpod provider — AppWidgetService instance
final appWidgetServiceProvider = Provider<AppWidgetService>((ref) {
  return AppWidgetService();
});