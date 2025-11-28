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
  
  // Birden fazla haber için key'ler (son 3 haber)
  static const String _title2Key = 'title2';
  static const String _title3Key = 'title3';
  static const String _link2Key = 'link2';
  static const String _link3Key = 'link3';
  static const String _imageUrl2Key = 'imageUrl2';
  static const String _imageUrl3Key = 'imageUrl3';

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

      // Son 3 haberi al
      final topArticles = articles.take(3).toList();

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
      
      // İkinci haber
      if (topArticles.length > 1) {
        final secondArticle = topArticles[1];
        widgetData[_title2Key] = secondArticle.title;
        widgetData[_link2Key] = secondArticle.link;
        if (secondArticle.imageUrl != null) {
          widgetData[_imageUrl2Key] = secondArticle.imageUrl!;
        }
      }
      
      // Üçüncü haber
      if (topArticles.length > 2) {
        final thirdArticle = topArticles[2];
        widgetData[_title3Key] = thirdArticle.title;
        widgetData[_link3Key] = thirdArticle.link;
        if (thirdArticle.imageUrl != null) {
          widgetData[_imageUrl3Key] = thirdArticle.imageUrl!;
        }
      }

      // Toplam haber sayısı
      widgetData[_countKey] = articles.length.toString();

      // Widget'ı güncelle - Tüm verileri kaydet
      await HomeWidget.saveWidgetData<String>(_titleKey, widgetData[_titleKey] ?? '');
      await HomeWidget.saveWidgetData<String>(_descriptionKey, widgetData[_descriptionKey] ?? '');
      await HomeWidget.saveWidgetData<String>(_linkKey, widgetData[_linkKey] ?? '');
      if (widgetData.containsKey(_imageUrlKey)) {
        await HomeWidget.saveWidgetData<String>(_imageUrlKey, widgetData[_imageUrlKey]!);
      }
      
      // İkinci haber
      await HomeWidget.saveWidgetData<String>(_title2Key, widgetData[_title2Key] ?? '');
      await HomeWidget.saveWidgetData<String>(_link2Key, widgetData[_link2Key] ?? '');
      if (widgetData.containsKey(_imageUrl2Key)) {
        await HomeWidget.saveWidgetData<String>(_imageUrl2Key, widgetData[_imageUrl2Key]!);
      }
      
      // Üçüncü haber
      await HomeWidget.saveWidgetData<String>(_title3Key, widgetData[_title3Key] ?? '');
      await HomeWidget.saveWidgetData<String>(_link3Key, widgetData[_link3Key] ?? '');
      if (widgetData.containsKey(_imageUrl3Key)) {
        await HomeWidget.saveWidgetData<String>(_imageUrl3Key, widgetData[_imageUrl3Key]!);
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
      await HomeWidget.saveWidgetData<String>(_title2Key, '');
      await HomeWidget.saveWidgetData<String>(_link2Key, '');
      await HomeWidget.saveWidgetData<String>(_imageUrl2Key, '');
      await HomeWidget.saveWidgetData<String>(_title3Key, '');
      await HomeWidget.saveWidgetData<String>(_link3Key, '');
      await HomeWidget.saveWidgetData<String>(_imageUrl3Key, '');
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

