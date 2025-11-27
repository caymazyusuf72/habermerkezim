import 'package:home_widget/home_widget.dart';
import '../../domain/entities/article.dart';

/// Android widget servisi - widget verilerini günceller
class WidgetService {
  static const String _widgetName = 'NewsWidget';
  static const String _titleKey = 'title';
  static const String _descriptionKey = 'description';
  static const String _linkKey = 'link';
  static const String _imageUrlKey = 'imageUrl';
  static const String _countKey = 'count';

  /// Widget'ı initialize et
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId('group.com.habermerkezi.widget');
    } catch (e) {
      print('⚠️ Widget initialize hatası: $e');
    }
  }

  /// Widget'ı son haberlerle güncelle
  static Future<void> updateWidget(List<Article> articles) async {
    try {
      if (articles.isEmpty) {
        await _clearWidget();
        return;
      }

      // Son 5 haberi al
      final topArticles = articles.take(5).toList();

      // Widget verilerini hazırla
      final widgetData = <String, String>{};
      
      // İlk haber (ana haber)
      if (topArticles.isNotEmpty) {
        final firstArticle = topArticles[0];
        widgetData[_titleKey] = firstArticle.title;
        widgetData[_descriptionKey] = firstArticle.description;
        widgetData[_linkKey] = firstArticle.link;
        if (firstArticle.imageUrl != null) {
          widgetData[_imageUrlKey] = firstArticle.imageUrl!;
        }
      }

      // Toplam haber sayısı
      widgetData[_countKey] = articles.length.toString();

      // Widget'ı güncelle
      await HomeWidget.saveWidgetData<String>(_titleKey, widgetData[_titleKey] ?? '');
      await HomeWidget.saveWidgetData<String>(_descriptionKey, widgetData[_descriptionKey] ?? '');
      await HomeWidget.saveWidgetData<String>(_linkKey, widgetData[_linkKey] ?? '');
      if (widgetData.containsKey(_imageUrlKey)) {
        await HomeWidget.saveWidgetData<String>(_imageUrlKey, widgetData[_imageUrlKey]!);
      }
      await HomeWidget.saveWidgetData<String>(_countKey, widgetData[_countKey] ?? '0');

      // Widget'ı yeniden yükle
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: 'NewsWidgetProvider',
      );

      print('✅ Widget güncellendi: ${topArticles.length} haber');
    } catch (e) {
      print('⚠️ Widget güncelleme hatası: $e');
    }
  }

  /// Widget'ı temizle
  static Future<void> _clearWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>(_titleKey, '');
      await HomeWidget.saveWidgetData<String>(_descriptionKey, '');
      await HomeWidget.saveWidgetData<String>(_linkKey, '');
      await HomeWidget.saveWidgetData<String>(_imageUrlKey, '');
      await HomeWidget.saveWidgetData<String>(_countKey, '0');
      
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: 'NewsWidgetProvider',
      );
    } catch (e) {
      print('⚠️ Widget temizleme hatası: $e');
    }
  }
}

