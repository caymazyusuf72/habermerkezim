import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/local/news_local_data_source.dart';
import '../datasources/remote/rss_remote_data_source.dart';

/// NewsRepository interface'inin implementasyonu
/// Remote ve local data source'ları koordine eder
/// Network durumuna göre online/offline logic'i yönetir
class NewsRepositoryImpl implements NewsRepository {
  final RssRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  final Connectivity connectivity;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<List<Article>> getArticlesByCategory(String category) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;

      if (hasConnection) {
        try {
          final articles = await remoteDataSource.getArticlesByCategory(category);
          
          // Cache articles locally
          await localDataSource.cacheArticles(articles);
          // Convert ArticleModel to Article and sort by image
          final entities = articles.map((model) => model.toEntity()).toList();
          return _sortArticlesByImage(entities);
        } catch (e) {
          // Fall back to cached data if network fails
          final cachedArticles = await localDataSource.getCachedArticlesByCategory(category);
          final entities = cachedArticles.map((model) => model.toEntity()).toList();
          return _sortArticlesByImage(entities);
        }
      } else {
        // Offline - get from cache
        final cachedArticles = await localDataSource.getCachedArticlesByCategory(category);
        final entities = cachedArticles.map((model) => model.toEntity()).toList();
        return _sortArticlesByImage(entities);
      }
    } catch (e) {
      throw Exception('Failed to get articles: $e');
    }
  }

  @override
  Future<List<Article>> getAllArticles() async {
    try {
      print('🔄 getAllArticles başladı');
      final connectivityResult = await connectivity.checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;
      print('🌐 Network durumu: $hasConnection ($connectivityResult)');

      if (hasConnection) {
        try {
          print('⬇️ Remote data source\'dan veri çekiliyor...');
          final articles = await remoteDataSource.getAllArticles();
          print('✅ Remote\'dan ${articles.length} makale alındı');
          
          // Cache articles locally
          print('💾 Makaleler cache\'e kaydediliyor...');
          await localDataSource.cacheArticles(articles);
          print('✅ Cache\'e kaydetme başarılı');
          
          // Convert ArticleModel to Article and sort by image
          final entities = articles.map((model) => model.toEntity()).toList();
          final sortedEntities = _sortArticlesByImage(entities);
          print('✅ getAllArticles tamamlandı: ${sortedEntities.length} makale');
          return sortedEntities;
        } catch (e) {
          print('❌ Remote request hatası: $e');
          print('🔄 Cache\'den veri deneniyor...');
          // Fall back to cached data if network fails
          try {
            final cachedArticles = await localDataSource.getCachedArticles();
            print('✅ Cache\'den ${cachedArticles.length} makale alındı');
            final entities = cachedArticles.map((model) => model.toEntity()).toList();
            return _sortArticlesByImage(entities);
          } catch (cacheError) {
            print('❌ Cache de boş, demo data döndürülüyor');
            // Cache de boş ise demo data döndür
            return _createDemoArticles();
          }
        }
      } else {
        print('📱 Offline mod - cache\'den veri alınıyor');
        // Offline - get from cache
        try {
          final cachedArticles = await localDataSource.getCachedArticles();
          print('✅ Cache\'den ${cachedArticles.length} makale alındı');
          final entities = cachedArticles.map((model) => model.toEntity()).toList();
          return _sortArticlesByImage(entities);
        } catch (cacheError) {
          print('❌ Offline ve cache boş, demo data döndürülüyor');
          // Cache boş ise demo data döndür
          return _createDemoArticles();
        }
      }
    } catch (e) {
      print('💥 getAllArticles HATA: $e');
      throw Exception('Failed to get all articles: $e');
    }
  }

  @override
  Future<Article?> getArticleById(String id) async {
    try {
      final articles = await localDataSource.getCachedArticles();
      final model = articles.firstWhere((article) => article.id == id, orElse: () => throw Exception('Article not found'));
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get article by id: $e');
    }
  }

  @override
  Future<void> markAsRead(String articleId) async {
    try {
      await localDataSource.markArticleAsRead(articleId);
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String articleId) async {
    try {
      await localDataSource.toggleArticleFavorite(articleId);
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<List<Article>> getFavoriteArticles() async {
    try {
      final favoriteModels = await localDataSource.getFavoriteArticles();
      return favoriteModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get favorite articles: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await localDataSource.clearCache();
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// Demo makaleler - cache boş olduğunda göstermek için
  List<Article> _createDemoArticles() {
    final now = DateTime.now();
    
    return [
      Article(
        id: 'demo_1',
        title: 'Haber Merkezi\'ne Hoş Geldiniz',
        description: 'Uygulamanız başarıyla çalışıyor. İnternet bağlantınız kurulduğunda güncel haberler yüklenecek.',
        content: 'Bu demo içeriktir. İnternet bağlantınızı kontrol edin ve uygulamayı yenileyin.',
        link: '',
        imageUrl: null,
        publishedDate: now.subtract(const Duration(minutes: 5)),
        category: 'genel',
        sourceName: 'Haber Merkezi',
        isRead: false,
        isFavorite: false,
      ),
      Article(
        id: 'demo_2',
        title: 'Bağlantı Ayarlarını Kontrol Edin',
        description: 'WiFi veya mobil internet bağlantınızın aktif olduğundan emin olun.',
        content: 'Uygulama internete bağlandığında otomatik olarak güncel haberleri çekecektir.',
        link: '',
        imageUrl: null,
        publishedDate: now.subtract(const Duration(minutes: 10)),
        category: 'teknoloji',
        sourceName: 'Haber Merkezi',
        isRead: false,
        isFavorite: false,
      ),
      Article(
        id: 'demo_3',
        title: 'Yenile Butonunu Kullanın',
        description: 'Sayfayı aşağı çekerek yenileme yapabilir veya ayarlardan cache\'i temizleyebilirsiniz.',
        content: 'Pull-to-refresh özelliği ile haberleri manuel olarak güncelleyebilirsiniz.',
        link: '',
        imageUrl: null,
        publishedDate: now.subtract(const Duration(minutes: 15)),
        category: 'genel',
        sourceName: 'Haber Merkezi',
        isRead: false,
        isFavorite: false,
      ),
    ];
  }
  
  /// Haberleri resim durumuna göre sıralar (resim olanlar üstte, olmayanlar altta)
  /// Aynı zamanda tarihe göre de sıralar (yeniden eskiye)
  List<Article> _sortArticlesByImage(List<Article> articles) {
    final sorted = List<Article>.from(articles);
    
    sorted.sort((a, b) {
      // Önce resim durumuna göre sırala (resim olanlar üstte)
      final aHasImage = a.imageUrl != null && a.imageUrl!.isNotEmpty;
      final bHasImage = b.imageUrl != null && b.imageUrl!.isNotEmpty;
      
      if (aHasImage && !bHasImage) {
        return -1; // a üstte
      } else if (!aHasImage && bHasImage) {
        return 1; // b üstte
      }
      
      // İkisi de aynı durumda (ikisi de resimli veya ikisi de resimsiz)
      // Tarihe göre sırala (yeniden eskiye)
      return b.publishedDate.compareTo(a.publishedDate);
    });
    
    return sorted;
  }
}