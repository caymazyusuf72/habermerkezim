import '../entities/article.dart';

/// NewsRepository - Domain layer interface
/// Clean Architecture'da business logic'in data layer'a dependency'si
abstract class NewsRepository {
  /// Kategoriye göre haberleri getir
  Future<List<Article>> getArticlesByCategory(String category);

  /// Tüm haberleri getir
  Future<List<Article>> getAllArticles();

  /// ID'ye göre makale getir
  Future<Article?> getArticleById(String id);

  /// Makaleyi okundu olarak işaretle
  Future<void> markAsRead(String articleId);

  /// Favori durumunu değiştir
  Future<void> toggleFavorite(String articleId);

  /// Favori makaleleri getir
  Future<List<Article>> getFavoriteArticles();

  /// Cache'i temizle
  Future<void> clearCache();

  /// İnternet bağlantısı kontrol et
  Future<bool> isConnected();

  /// Kategoriye göre haberleri stream olarak dinle (reactive updates)
  Stream<List<Article>> watchArticlesByCategory(String category);

  /// Tüm haberleri stream olarak dinle (reactive updates)
  Stream<List<Article>> watchAllArticles();
}