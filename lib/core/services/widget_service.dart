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
  static const String _currentIndexKey = 'currentIndex'; // Hangi haber gösteriliyor (0, 1, 2...)
  
  // Birden fazla haber için key'ler (kaydırma için son 10 haber)
  static const String _articlesKey = 'articles'; // JSON array olarak tüm haberler

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
      print('🔄 Widget güncelleniyor: ${articles.length} haber');
      
      if (articles.isEmpty) {
        print('⚠️ Widget: Haber listesi boş, widget temizleniyor');
        await _clearWidget();
        return;
      }

      // Son 10 haberi al (kaydırma için)
      final topArticles = articles.take(10).toList();
      print('📰 Widget: ${topArticles.length} haber kaydediliyor');

      // İlk haber (varsayılan gösterilecek)
      if (topArticles.isNotEmpty) {
        final firstArticle = topArticles[0];
        print('📝 Widget: İlk haber - ${firstArticle.title.substring(0, firstArticle.title.length > 50 ? 50 : firstArticle.title.length)}...');
        
        await HomeWidget.saveWidgetData<String>(_titleKey, firstArticle.title);
        await HomeWidget.saveWidgetData<String>(_descriptionKey, firstArticle.description);
        await HomeWidget.saveWidgetData<String>(_linkKey, firstArticle.link);
        if (firstArticle.imageUrl != null) {
          await HomeWidget.saveWidgetData<String>(_imageUrlKey, firstArticle.imageUrl!);
        }
        print('✅ Widget: İlk haber kaydedildi');
      }

      // Toplam haber sayısı ve mevcut index
      await HomeWidget.saveWidgetData<String>(_countKey, topArticles.length.toString());
      await HomeWidget.saveWidgetData<String>(_currentIndexKey, '0'); // İlk haber gösteriliyor
      
      // Tüm haberleri string olarak kaydet (kaydırma için)
      final articlesJsonString = topArticles.map((article) => 
        '${article.title}|${article.description}|${article.link}|${article.imageUrl ?? ''}'
      ).join('|||');
      
      await HomeWidget.saveWidgetData<String>(_articlesKey, articlesJsonString);
      print('✅ Widget: Tüm haberler kaydedildi (${articlesJsonString.length} karakter)');

      // Widget'ı yeniden yükle
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: 'NewsWidgetProvider',
      );

      print('✅ Widget güncellendi: ${topArticles.length} haber');
    } catch (e, stackTrace) {
      print('⚠️ Widget güncelleme hatası: $e');
      print('Stack trace: $stackTrace');
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
      await HomeWidget.saveWidgetData<String>(_currentIndexKey, '0');
      await HomeWidget.saveWidgetData<String>(_articlesKey, '');
      
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: 'NewsWidgetProvider',
      );
    } catch (e) {
      print('⚠️ Widget temizleme hatası: $e');
    }
  }
}

