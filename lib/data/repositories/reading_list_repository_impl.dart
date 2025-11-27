import '../../domain/entities/article.dart';
import '../../domain/repositories/reading_list_repository.dart';
import '../datasources/local/reading_list_local_data_source.dart';
import '../datasources/local/news_local_data_source.dart';

/// ReadingListRepository interface'inin implementasyonu
class ReadingListRepositoryImpl implements ReadingListRepository {
  final ReadingListLocalDataSource localDataSource;
  final NewsLocalDataSource newsLocalDataSource;

  ReadingListRepositoryImpl({
    required this.localDataSource,
    required this.newsLocalDataSource,
  });

  @override
  Future<void> addToReadingList(String articleId) async {
    await localDataSource.addToReadingList(articleId);
  }

  @override
  Future<void> removeFromReadingList(String articleId) async {
    await localDataSource.removeFromReadingList(articleId);
  }

  @override
  Future<List<Article>> getReadingListArticles() async {
    try {
      final readingListIds = await localDataSource.getReadingListIds();
      if (readingListIds.isEmpty) {
        return [];
      }

      // Cache'den makaleleri al
      final allCachedArticles = await newsLocalDataSource.getCachedArticles();
      
      // Okuma listesindeki ID'lere göre filtrele
      final readingListArticles = allCachedArticles
          .where((article) => readingListIds.contains(article.id))
          .toList();

      // ID sırasına göre sırala (en son eklenen en üstte)
      readingListArticles.sort((a, b) {
        final aIndex = readingListIds.indexOf(a.id);
        final bIndex = readingListIds.indexOf(b.id);
        return bIndex.compareTo(aIndex); // Ters sıralama (yeni eklenen üstte)
      });

      return readingListArticles.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Okuma listesi makaleleri yüklenirken hata: $e');
    }
  }

  @override
  Future<bool> isInReadingList(String articleId) async {
    return await localDataSource.isInReadingList(articleId);
  }

  @override
  Future<void> clearReadingList() async {
    await localDataSource.clearReadingList();
  }
}

