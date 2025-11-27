import '../entities/article.dart';

/// ReadingListRepository - Domain layer interface
/// Okuma listesi işlemlerini yönetir
abstract class ReadingListRepository {
  /// Okuma listesine makale ekle
  Future<void> addToReadingList(String articleId);

  /// Okuma listesinden makale çıkar
  Future<void> removeFromReadingList(String articleId);

  /// Okuma listesindeki tüm makaleleri getir
  Future<List<Article>> getReadingListArticles();

  /// Makale okuma listesinde mi kontrol et
  Future<bool> isInReadingList(String articleId);

  /// Okuma listesini temizle
  Future<void> clearReadingList();
}

