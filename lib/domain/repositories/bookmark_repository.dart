import '../entities/article.dart';

/// BookmarkRepository - Domain layer interface
/// Yer imi (bookmark) işlemlerini yönetir
/// Clean Architecture'da business logic katmanının data katmanına bağımlılığı
abstract class BookmarkRepository {
  /// Yer imlerine makale ekle
  Future<void> addBookmark(String articleId);

  /// Yer imlerinden makale çıkar
  Future<void> removeBookmark(String articleId);

  /// Tüm yer imli makaleleri getir
  Future<List<Article>> getBookmarks();

  /// Makale yer imlerinde mi kontrol et
  Future<bool> isBookmarked(String articleId);

  /// Tüm yer imlerini temizle
  Future<void> clearBookmarks();

  /// Yer imi sayısını getir
  Future<int> getBookmarkCount();
}