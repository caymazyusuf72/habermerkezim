import '../../../core/services/hive_service.dart';

/// Okuma listesi verilerini yerel olarak saklayan data source
/// Hive database kullanır
abstract class ReadingListLocalDataSource {
  Future<void> addToReadingList(String articleId);
  Future<void> removeFromReadingList(String articleId);
  Future<List<String>> getReadingListIds();
  Future<bool> isInReadingList(String articleId);
  Future<void> clearReadingList();
}

class ReadingListLocalDataSourceImpl implements ReadingListLocalDataSource {
  @override
  Future<void> addToReadingList(String articleId) async {
    try {
      final box = HiveService.readingListBox;
      await box.put(articleId, articleId);
    } catch (e) {
      throw Exception('Okuma listesine eklenirken hata: $e');
    }
  }

  @override
  Future<void> removeFromReadingList(String articleId) async {
    try {
      final box = HiveService.readingListBox;
      await box.delete(articleId);
    } catch (e) {
      throw Exception('Okuma listesinden çıkarılırken hata: $e');
    }
  }

  @override
  Future<List<String>> getReadingListIds() async {
    try {
      final box = HiveService.readingListBox;
      return box.values.toList();
    } catch (e) {
      throw Exception('Okuma listesi yüklenirken hata: $e');
    }
  }

  @override
  Future<bool> isInReadingList(String articleId) async {
    try {
      final box = HiveService.readingListBox;
      return box.containsKey(articleId);
    } catch (e) {
      throw Exception('Okuma listesi kontrol edilirken hata: $e');
    }
  }

  @override
  Future<void> clearReadingList() async {
    try {
      final box = HiveService.readingListBox;
      await box.clear();
    } catch (e) {
      throw Exception('Okuma listesi temizlenirken hata: $e');
    }
  }
}

