import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/article_model.dart';

/// Hive database servis sınıfı
/// Uygulama başlangıcında Hive'ı initialize eder ve box'ları açar
class HiveService {
  static const String _articlesBoxName = 'articles';
  static const String _favoritesBoxName = 'favorites';
  static const String _readArticlesBoxName = 'read_articles';
  static const String _settingsBoxName = 'settings';
  static const String _categoryOrderBoxName = 'category_order';
  static const String _readingListBoxName = 'reading_list';
  static const String _notificationFrequencyBoxName = 'notification_frequency';
  static const String _categoryNotificationsBoxName = 'category_notifications';

  static bool _initialized = false;

  /// Hive'ı initialize eder
  /// main.dart'dan çağrılmalı
  static Future<void> initialize() async {
    if (_initialized) {
      print('⚠️ Hive zaten initialize edilmiş');
      return;
    }

    try {
      print('🔧 Hive initialization başlıyor...');
      // Hive Flutter'ı initialize et
      await Hive.initFlutter();
      print('✅ Hive.initFlutter() tamamlandı');

      // Type adapter'ları register et
      print("📝 Type adapter'lar register ediliyor...");
      _registerAdapters();
      print("✅ Type adapter'lar register edildi");

      // Temel box'ları aç
      print("📦 Box'lar açılıyor...");
      await _openBoxes();
      print("✅ Box'lar açıldı");

      _initialized = true;
      print('✅ Hive başarıyla initialize edildi');

    } catch (e) {
      print('❌ Hive initialization hatası: $e');
      print('🔍 Hata detayı: ${e.toString()}');
      rethrow;
    }
  }

  /// Type adapter'ları register eder
  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ArticleModelAdapter());
    }
  }

  /// Temel box'ları açar
  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<ArticleModel>(_articlesBoxName),
      Hive.openBox<String>(_favoritesBoxName),
      Hive.openBox<String>(_readArticlesBoxName),
      Hive.openBox<dynamic>(_settingsBoxName),
      Hive.openBox<dynamic>(_categoryOrderBoxName),
      Hive.openBox<String>(_readingListBoxName),
      Hive.openBox<dynamic>(_notificationFrequencyBoxName),
      Hive.openBox<dynamic>(_categoryNotificationsBoxName),
    ]);
  }

  /// Articles box'ını döner
  static Box<ArticleModel> get articlesBox {
    _ensureInitialized();
    return Hive.box<ArticleModel>(_articlesBoxName);
  }

  /// Favorites box'ını döner
  static Box<String> get favoritesBox {
    _ensureInitialized();
    return Hive.box<String>(_favoritesBoxName);
  }

  /// Read articles box'ını döner
  static Box<String> get readArticlesBox {
    _ensureInitialized();
    return Hive.box<String>(_readArticlesBoxName);
  }

  /// Settings box'ını döner
  static Box<dynamic> get settingsBox {
    _ensureInitialized();
    return Hive.box<dynamic>(_settingsBoxName);
  }

  /// Category order box'ını döner
  static Box<dynamic> get categoryOrderBox {
    _ensureInitialized();
    return Hive.box<dynamic>(_categoryOrderBoxName);
  }

  /// Reading list box'ını döner
  static Box<String> get readingListBox {
    _ensureInitialized();
    return Hive.box<String>(_readingListBoxName);
  }

  /// Notification frequency box'ını döner
  static Box<dynamic> get notificationFrequencyBox {
    _ensureInitialized();
    return Hive.box<dynamic>(_notificationFrequencyBoxName);
  }

  /// Category notifications box'ını döner
  static Box<dynamic> get categoryNotificationsBox {
    _ensureInitialized();
    return Hive.box<dynamic>(_categoryNotificationsBoxName);
  }

  /// Box açmak için metod (static method)
  static Future<Box<dynamic>> getBox(String boxName) async {
    _ensureInitialized();
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<dynamic>(boxName);
    }
    return Hive.box<dynamic>(boxName);
  }


  /// Box'ları kapatır ve Hive'ı temizler
  static Future<void> dispose() async {
    if (!_initialized) return;

    try {
      await Hive.close();
      _initialized = false;
      print('✅ Hive başarıyla kapatıldı');
    } catch (e) {
      print('❌ Hive kapatma hatası: $e');
    }
  }

  /// Tüm verileri temizler (factory reset)
  static Future<void> clearAllData() async {
    _ensureInitialized();

    try {
      await Future.wait([
        articlesBox.clear(),
        favoritesBox.clear(),
        readArticlesBox.clear(),
        settingsBox.clear(),
      ]);

      print('✅ Tüm Hive verileri temizlendi');
    } catch (e) {
      print('❌ Hive veri temizleme hatası: $e');
      rethrow;
    }
  }

  /// Database istatistiklerini döner
  static Map<String, dynamic> getStats() {
    if (!_initialized) {
      return {'initialized': false};
    }

    try {
      return {
        'initialized': true,
        'articlesCount': articlesBox.length,
        'favoritesCount': favoritesBox.length,
        'readArticlesCount': readArticlesBox.length,
        'settingsCount': settingsBox.length,
        'totalSize': _calculateTotalSize(),
      };
    } catch (e) {
      return {
        'initialized': true,
        'error': e.toString(),
      };
    }
  }

  /// Database boyutunu hesaplar (yaklaşık)
  static int _calculateTotalSize() {
    int totalSize = 0;
    
    try {
      // Articles box size
      for (final article in articlesBox.values) {
        totalSize += article.title.length;
        totalSize += article.description.length;
        totalSize += (article.content?.length ?? 0);
        totalSize += article.link.length;
        totalSize += (article.imageUrl?.length ?? 0);
      }
      
      // Favorites box size
      totalSize += favoritesBox.values.fold(0, (sum, id) => sum + id.length);
      
      // Read articles box size
      totalSize += readArticlesBox.values.fold(0, (sum, id) => sum + id.length);
      
    } catch (e) {
      // Size calculation error, return 0
      return 0;
    }
    
    return totalSize;
  }

  /// Initialize kontrolü
  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('HiveService initialize edilmemiş! main.dart\'da HiveService.initialize() çağırın.');
    }
  }

  /// Debug için box içeriklerini yazdırır
  static void printDebugInfo() {
    if (!_initialized) {
      print('❌ Hive initialize edilmemiş');
      return;
    }

    print('=== HIVE DEBUG INFO ===');
    print('Articles: ${articlesBox.length}');
    print('Favorites: ${favoritesBox.length}');
    print('Read Articles: ${readArticlesBox.length}');
    print('Settings: ${settingsBox.length}');
    
    // Son 5 makaleyi göster
    if (articlesBox.isNotEmpty) {
      print('\n📰 Son Makaleler:');
      final articles = articlesBox.values.take(5).toList();
      for (final article in articles) {
        print('  - ${article.title} (${article.category})');
      }
    }
    
    print('======================');
  }
}