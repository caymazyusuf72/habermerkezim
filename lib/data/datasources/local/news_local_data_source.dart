import 'package:hive/hive.dart';
import '../../../core/error/exceptions.dart';
import '../../models/article_model.dart';

/// Haber verilerini yerel olarak saklayan data source
/// Hive database kullanır, offline mode desteği sağlar
abstract class NewsLocalDataSource {
  Future<void> cacheArticles(List<ArticleModel> articles);
  Future<List<ArticleModel>> getCachedArticles();
  Future<List<ArticleModel>> getCachedArticlesByCategory(String category);
  Future<void> markArticleAsRead(String articleId);
  Future<void> toggleArticleFavorite(String articleId);
  Future<List<ArticleModel>> getFavoriteArticles();
  Future<void> clearCache();
  Future<void> clearOldCache();
  
  // Favoriler için ek methodlar
  Future<void> addToFavorites(ArticleModel article);
  Future<void> removeFromFavorites(String articleId);
  Future<void> clearAllFavorites();
  
  // Arama geçmişi methodları
  Future<List<String>> getSearchHistory();
  Future<void> addToSearchHistory(String query);
  Future<void> removeFromSearchHistory(String query);
  Future<void> clearSearchHistory();
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  static const String _articlesBoxName = 'articles';
  static const String _favoritesBoxName = 'favorites';
  static const String _readArticlesBoxName = 'read_articles';
  static const String _searchHistoryBoxName = 'search_history';
  
  Box<ArticleModel>? _articlesBox;
  Box<String>? _favoritesBox;
  Box<String>? _readArticlesBox;
  Box<String>? _searchHistoryBox;

  /// Hive box'larını açar
  Future<void> _ensureBoxesOpen() async {
    _articlesBox ??= await Hive.openBox<ArticleModel>(_articlesBoxName);
    _favoritesBox ??= await Hive.openBox<String>(_favoritesBoxName);
    _readArticlesBox ??= await Hive.openBox<String>(_readArticlesBoxName);
    _searchHistoryBox ??= await Hive.openBox<String>(_searchHistoryBoxName);
  }

  @override
  Future<void> cacheArticles(List<ArticleModel> articles) async {
    try {
      print('💾 Cache\'e ${articles.length} makale kaydediliyor...');
      await _ensureBoxesOpen();
      
      final articlesBox = _articlesBox!;
      final readArticlesBox = _readArticlesBox!;
      final favoritesBox = _favoritesBox!;
      
      print('📊 Mevcut cache durumu: ${articlesBox.length} makale');
      
      // Mevcut read ve favorite durumlarını koru
      final Map<String, bool> readStatus = {};
      final Map<String, bool> favoriteStatus = {};
      
      for (final article in articles) {
        readStatus[article.id] = readArticlesBox.containsKey(article.id);
        favoriteStatus[article.id] = favoritesBox.containsKey(article.id);
      }
      
      print('🔄 Makale durumları kontrol edildi');
      
      // Yeni makaleleri kaydet
      for (final article in articles) {
        final updatedArticle = ArticleModel(
          id: article.id,
          title: article.title,
          description: article.description,
          content: article.content,
          link: article.link,
          imageUrl: article.imageUrl,
          publishedDate: article.publishedDate,
          category: article.category,
          sourceName: article.sourceName,
          isRead: readStatus[article.id] ?? false,
          isFavorite: favoriteStatus[article.id] ?? false,
        );
        
        await articlesBox.put(article.id, updatedArticle);
      }
      
      print('✅ Cache\'e ${articles.length} makale kaydedildi (Toplam: ${articlesBox.length})');
      
    } catch (e) {
      print('💥 Cache kaydetme hatası: $e');
      throw DatabaseException('Makaleler cache\'e kaydedilemedi: ${e.toString()}');
    }
  }

  @override
  Future<List<ArticleModel>> getCachedArticles() async {
    try {
      print('💾 Cache\'den makale okunuyor...');
      await _ensureBoxesOpen();
      
      final articlesBox = _articlesBox!;
      print('📊 Cache durumu: ${articlesBox.length} makale');
      
      if (articlesBox.isEmpty) {
        print('❌ Cache boş - hiç makale yok!');
        throw const DataNotFoundException('Cache\'de makale bulunamadı');
      }
      
      final articles = articlesBox.values.toList();
      print('📋 Cache\'den ${articles.length} makale alındı');
      
      // Tarihe göre sırala (yeniden eskiye)
      articles.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
      
      print('✅ Cache makaleleri başarıyla sıralandı');
      return articles;
      
    } catch (e) {
      print('💥 Cache okuma hatası: $e');
      if (e is DataNotFoundException) rethrow;
      throw DatabaseException('Cache\'den veri okunamadı: ${e.toString()}');
    }
  }

  @override
  Future<List<ArticleModel>> getCachedArticlesByCategory(String category) async {
    try {
      await _ensureBoxesOpen();
      
      final articlesBox = _articlesBox!;
      if (articlesBox.isEmpty) {
        throw const DataNotFoundException('Cache\'de makale bulunamadı');
      }
      
      final articles = articlesBox.values
          .where((article) => article.category == category)
          .toList();
      
      if (articles.isEmpty) {
        throw DataNotFoundException('$category kategorisinde cache\'de makale bulunamadı');
      }
      
      // Tarihe göre sırala (yeniden eskiye)
      articles.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
      
      return articles;
      
    } catch (e) {
      if (e is DataNotFoundException) rethrow;
      throw DatabaseException('Kategori verileri okunamadı: ${e.toString()}');
    }
  }

  @override
  Future<void> markArticleAsRead(String articleId) async {
    try {
      await _ensureBoxesOpen();
      
      final articlesBox = _articlesBox!;
      final readArticlesBox = _readArticlesBox!;
      
      // Read listesine ekle
      await readArticlesBox.put(articleId, articleId);
      
      // Article modelini güncelle
      final article = articlesBox.get(articleId);
      if (article != null) {
        final updatedArticle = ArticleModel(
          id: article.id,
          title: article.title,
          description: article.description,
          content: article.content,
          link: article.link,
          imageUrl: article.imageUrl,
          publishedDate: article.publishedDate,
          category: article.category,
          sourceName: article.sourceName,
          isRead: true,
          isFavorite: article.isFavorite,
        );
        
        await articlesBox.put(articleId, updatedArticle);
      }
      
    } catch (e) {
      throw DatabaseException('Makale okundu olarak işaretlenemedi: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleArticleFavorite(String articleId) async {
    try {
      await _ensureBoxesOpen();
      
      final articlesBox = _articlesBox!;
      final favoritesBox = _favoritesBox!;
      
      final article = articlesBox.get(articleId);
      if (article == null) {
        throw const DataNotFoundException('Makale bulunamadı');
      }
      
      final isFavorite = favoritesBox.containsKey(articleId);
      
      // Favorite durumunu toggle et
      if (isFavorite) {
        await favoritesBox.delete(articleId);
      } else {
        await favoritesBox.put(articleId, articleId);
      }
      
      // Article modelini güncelle
      final updatedArticle = ArticleModel(
        id: article.id,
        title: article.title,
        description: article.description,
        content: article.content,
        link: article.link,
        imageUrl: article.imageUrl,
        publishedDate: article.publishedDate,
        category: article.category,
        sourceName: article.sourceName,
        isRead: article.isRead,
        isFavorite: !isFavorite,
      );
      
      await articlesBox.put(articleId, updatedArticle);
      
    } catch (e) {
      if (e is DataNotFoundException) rethrow;
      throw DatabaseException('Makale favorilere eklenemedi/çıkarılamadı: ${e.toString()}');
    }
  }

  @override
  Future<List<ArticleModel>> getFavoriteArticles() async {
    try {
      await _ensureBoxesOpen();
      
      final articlesBox = _articlesBox!;
      final favoritesBox = _favoritesBox!;
      
      if (favoritesBox.isEmpty) {
        return [];
      }
      
      final favoriteArticles = <ArticleModel>[];
      
      for (final articleId in favoritesBox.keys) {
        final article = articlesBox.get(articleId);
        if (article != null) {
          favoriteArticles.add(article);
        }
      }
      
      // Tarihe göre sırala (yeniden eskiye)
      favoriteArticles.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
      
      return favoriteArticles;
      
    } catch (e) {
      throw DatabaseException('Favori makaleler okunamadı: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _ensureBoxesOpen();
      
      await _articlesBox!.clear();
      await _favoritesBox!.clear();
      await _readArticlesBox!.clear();
      
      print('Tüm cache temizlendi');
      
    } catch (e) {
      throw DatabaseException('Cache temizlenemedi: ${e.toString()}');
    }
  }

  @override
  Future<void> clearOldCache() async {
    try {
      await _ensureBoxesOpen();
      
      final articlesBox = _articlesBox!;
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
      
      // 7 günden eski makaleleri sil
      final keysToDelete = <String>[];
      
      for (final entry in articlesBox.toMap().entries) {
        if (entry.value.publishedDate.isBefore(cutoffDate)) {
          keysToDelete.add(entry.key);
        }
      }
      
      for (final key in keysToDelete) {
        await articlesBox.delete(key);
      }
      
      print('${keysToDelete.length} eski makale cache\'den temizlendi');
      
    } catch (e) {
      throw DatabaseException('Eski cache temizlenemedi: ${e.toString()}');
    }
  }

  /// Cache istatistiklerini döner (debug amaçlı)
  Future<Map<String, int>> getCacheStats() async {
    try {
      await _ensureBoxesOpen();
      
      return {
        'totalArticles': _articlesBox!.length,
        'favoriteArticles': _favoritesBox!.length,
        'readArticles': _readArticlesBox!.length,
      };
      
    } catch (e) {
      return {
        'totalArticles': 0,
        'favoriteArticles': 0,
        'readArticles': 0,
      };
    }
  }

  /// Favorilere makale ekle
  @override
  Future<void> addToFavorites(ArticleModel article) async {
    try {
      await _ensureBoxesOpen();
      
      final articlesBox = _articlesBox!;
      final favoritesBox = _favoritesBox!;
      
      // Favorites box'a ekle
      await favoritesBox.put(article.id, article.id);
      
      // Article modelini güncelle
      final updatedArticle = ArticleModel(
        id: article.id,
        title: article.title,
        description: article.description,
        content: article.content,
        link: article.link,
        imageUrl: article.imageUrl,
        publishedDate: article.publishedDate,
        category: article.category,
        sourceName: article.sourceName,
        isRead: article.isRead,
        isFavorite: true,
      );
      
      await articlesBox.put(article.id, updatedArticle);
      
    } catch (e) {
      throw DatabaseException('Makale favorilere eklenemedi: ${e.toString()}');
    }
  }

  /// Favorilerden makale çıkar
  @override
  Future<void> removeFromFavorites(String articleId) async {
    try {
      await _ensureBoxesOpen();
      
      final articlesBox = _articlesBox!;
      final favoritesBox = _favoritesBox!;
      
      // Favorites box'tan çıkar
      await favoritesBox.delete(articleId);
      
      // Article modelini güncelle
      final article = articlesBox.get(articleId);
      if (article != null) {
        final updatedArticle = ArticleModel(
          id: article.id,
          title: article.title,
          description: article.description,
          content: article.content,
          link: article.link,
          imageUrl: article.imageUrl,
          publishedDate: article.publishedDate,
          category: article.category,
          sourceName: article.sourceName,
          isRead: article.isRead,
          isFavorite: false,
        );
        
        await articlesBox.put(articleId, updatedArticle);
      }
      
    } catch (e) {
      throw DatabaseException('Makale favorilerden çıkarılamadı: ${e.toString()}');
    }
  }

  /// Tüm favorileri temizle
  @override
  Future<void> clearAllFavorites() async {
    try {
      await _ensureBoxesOpen();
      
      final articlesBox = _articlesBox!;
      final favoritesBox = _favoritesBox!;
      
      // Tüm makale favorite durumlarını false yap
      for (final articleId in favoritesBox.keys) {
        final article = articlesBox.get(articleId);
        if (article != null) {
          final updatedArticle = ArticleModel(
            id: article.id,
            title: article.title,
            description: article.description,
            content: article.content,
            link: article.link,
            imageUrl: article.imageUrl,
            publishedDate: article.publishedDate,
            category: article.category,
            sourceName: article.sourceName,
            isRead: article.isRead,
            isFavorite: false,
          );
          
          await articlesBox.put(articleId, updatedArticle);
        }
      }
      
      // Favorites box'ı temizle
      await favoritesBox.clear();
      
    } catch (e) {
      throw DatabaseException('Favoriler temizlenemedi: ${e.toString()}');
    }
  }

  /// Arama geçmişini getir
  @override
  Future<List<String>> getSearchHistory() async {
    try {
      await _ensureBoxesOpen();
      
      final searchHistoryBox = _searchHistoryBox!;
      
      // Arama geçmişini listele (en yeni en başta)
      final history = searchHistoryBox.values.toList();
      return history.reversed.toList();
      
    } catch (e) {
      return [];
    }
  }

  /// Arama geçmişine ekle
  @override
  Future<void> addToSearchHistory(String query) async {
    try {
      await _ensureBoxesOpen();
      
      final searchHistoryBox = _searchHistoryBox!;
      final trimmedQuery = query.trim();
      
      if (trimmedQuery.isEmpty) return;
      
      // Eğer zaten varsa önce sil
      final existingKeys = <dynamic>[];
      for (final entry in searchHistoryBox.toMap().entries) {
        if (entry.value == trimmedQuery) {
          existingKeys.add(entry.key);
        }
      }
      
      for (final key in existingKeys) {
        await searchHistoryBox.delete(key);
      }
      
      // Yeni arama terimini en başa ekle
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await searchHistoryBox.put(timestamp, trimmedQuery);
      
      // En fazla 20 arama kaydı tut
      if (searchHistoryBox.length > 20) {
        final oldestKey = searchHistoryBox.keys.first;
        await searchHistoryBox.delete(oldestKey);
      }
      
    } catch (e) {
      // Sessiz hata, arama geçmişi kritik değil
    }
  }

  /// Arama geçmişinden sil
  @override
  Future<void> removeFromSearchHistory(String query) async {
    try {
      await _ensureBoxesOpen();
      
      final searchHistoryBox = _searchHistoryBox!;
      
      // Query'ye sahip tüm kayıtları sil
      final keysToDelete = <dynamic>[];
      for (final entry in searchHistoryBox.toMap().entries) {
        if (entry.value == query) {
          keysToDelete.add(entry.key);
        }
      }
      
      for (final key in keysToDelete) {
        await searchHistoryBox.delete(key);
      }
      
    } catch (e) {
      // Sessiz hata
    }
  }

  /// Arama geçmişini temizle
  @override
  Future<void> clearSearchHistory() async {
    try {
      await _ensureBoxesOpen();
      
      await _searchHistoryBox!.clear();
      
    } catch (e) {
      // Sessiz hata
    }
  }

  /// Hive box'larını kapatır
  Future<void> closeBoxes() async {
    await _articlesBox?.close();
    await _favoritesBox?.close();
    await _readArticlesBox?.close();
    await _searchHistoryBox?.close();
    
    _articlesBox = null;
    _favoritesBox = null;
    _readArticlesBox = null;
    _searchHistoryBox = null;
  }
}