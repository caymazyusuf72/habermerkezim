import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      debugPrint('⚠️ Widget initialize hatası: $e');
    }
  }

  /// Widget'ı son haberlerle güncelle
  static Future<void> updateWidget(List<Article> articles) async {
    try {
      debugPrint('🔄 Widget güncelleniyor: ${articles.length} haber');
      
      if (articles.isEmpty) {
        debugPrint('⚠️ Widget: Haber listesi boş, widget temizleniyor');
        await _clearWidget();
        return;
      }

      // Son 10 haberi al (kaydırma için)
      final topArticles = articles.take(10).toList();
      debugPrint('📰 Widget: ${topArticles.length} haber kaydediliyor');

      // SharedPreferences instance (FlutterSharedPreferences)
      final prefs = await SharedPreferences.getInstance();

      // İlk haber (varsayılan gösterilecek)
      if (topArticles.isNotEmpty) {
        final firstArticle = topArticles[0];
        debugPrint('📝 Widget: İlk haber - ${firstArticle.title.substring(0, firstArticle.title.length > 50 ? 50 : firstArticle.title.length)}...');
        
        // HomeWidget üzerinden veri kaydet
        await HomeWidget.saveWidgetData<String>(_titleKey, firstArticle.title);
        await HomeWidget.saveWidgetData<String>(_descriptionKey, firstArticle.description);
        await HomeWidget.saveWidgetData<String>(_linkKey, firstArticle.link);
        if (firstArticle.imageUrl != null) {
          await HomeWidget.saveWidgetData<String>(_imageUrlKey, firstArticle.imageUrl!);
        }

      // SharedPreferences üzerinden aynı veriyi kaydet (flutter. prefix ile)
      await prefs.setString('flutter.$_titleKey', firstArticle.title);
      await prefs.setString('flutter.$_descriptionKey', firstArticle.description);
      await prefs.setString('flutter.$_linkKey', firstArticle.link);
      if (firstArticle.imageUrl != null) {
        await prefs.setString('flutter.$_imageUrlKey', firstArticle.imageUrl!);
      }
      // Ayrıca direkt key'leri de kaydet (home_widget uyumluluğu için)
      await prefs.setString(_titleKey, firstArticle.title);
      await prefs.setString(_descriptionKey, firstArticle.description);
      await prefs.setString(_linkKey, firstArticle.link);
      if (firstArticle.imageUrl != null) {
        await prefs.setString(_imageUrlKey, firstArticle.imageUrl!);
      }
      debugPrint('✅ Widget: İlk haber kaydedildi');
      }

      // Toplam haber sayısı ve mevcut index
      await HomeWidget.saveWidgetData<String>(_countKey, topArticles.length.toString());
      await HomeWidget.saveWidgetData<String>(_currentIndexKey, '0'); // İlk haber gösteriliyor

      // Count ve currentIndex'i hem flutter. prefix ile hem de direkt kaydet
      await prefs.setString('flutter.$_countKey', topArticles.length.toString());
      await prefs.setString('flutter.$_currentIndexKey', '0');
      await prefs.setString(_countKey, topArticles.length.toString());
      await prefs.setString(_currentIndexKey, '0');
      
      // Tüm haberleri string olarak kaydet (kaydırma için)
      final articlesJsonString = topArticles.map((article) => 
        '${article.title}|${article.description}|${article.link}|${article.imageUrl ?? ''}'
      ).join('|||');
      
      await HomeWidget.saveWidgetData<String>(_articlesKey, articlesJsonString);
      await prefs.setString('flutter.$_articlesKey', articlesJsonString);
      await prefs.setString(_articlesKey, articlesJsonString);
      debugPrint('✅ Widget: Tüm haberler kaydedildi (${articlesJsonString.length} karakter)');
      
      // Debug: Kaydedilen verileri kontrol et
      final savedTitle = await HomeWidget.getWidgetData<String>(_titleKey, defaultValue: '');
      final savedArticles = await HomeWidget.getWidgetData<String>(_articlesKey, defaultValue: '');
      debugPrint('🔍 Debug - Kaydedilen title: ${savedTitle?.substring(0, savedTitle.length > 30 ? 30 : savedTitle.length)}');
      debugPrint('🔍 Debug - Kaydedilen articles length: ${savedArticles?.length ?? 0}');

      // Widget'ları yeniden yükle (banner + liste)
      try {
        await HomeWidget.updateWidget(
          name: _widgetName,
          androidName: 'NewsWidgetProvider',
        );
        await HomeWidget.updateWidget(
          androidName: 'NewsListWidgetProvider',
        );
      } catch (e) {
        debugPrint('⚠️ Widget updateWidget hatası: $e');
      }

      debugPrint('✅ Widget güncellendi: ${topArticles.length} haber');
    } catch (e, stackTrace) {
      debugPrint('⚠️ Widget güncelleme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Widget'ı temizle
  static Future<void> _clearWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await HomeWidget.saveWidgetData<String>(_titleKey, '');
      await HomeWidget.saveWidgetData<String>(_descriptionKey, '');
      await HomeWidget.saveWidgetData<String>(_linkKey, '');
      await HomeWidget.saveWidgetData<String>(_imageUrlKey, '');
      await HomeWidget.saveWidgetData<String>(_countKey, '0');
      await HomeWidget.saveWidgetData<String>(_currentIndexKey, '0');
      await HomeWidget.saveWidgetData<String>(_articlesKey, '');

      // Hem flutter. prefix ile hem de direkt key'leri temizle
      await prefs.setString('flutter.$_titleKey', '');
      await prefs.setString('flutter.$_descriptionKey', '');
      await prefs.setString('flutter.$_linkKey', '');
      await prefs.setString('flutter.$_imageUrlKey', '');
      await prefs.setString('flutter.$_countKey', '0');
      await prefs.setString('flutter.$_currentIndexKey', '0');
      await prefs.setString('flutter.$_articlesKey', '');
      await prefs.setString(_titleKey, '');
      await prefs.setString(_descriptionKey, '');
      await prefs.setString(_linkKey, '');
      await prefs.setString(_imageUrlKey, '');
      await prefs.setString(_countKey, '0');
      await prefs.setString(_currentIndexKey, '0');
      await prefs.setString(_articlesKey, '');
      
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: 'NewsWidgetProvider',
      );
    } catch (e) {
      debugPrint('⚠️ Widget temizleme hatası: $e');
    }
  }
}

