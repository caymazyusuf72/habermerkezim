import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/local/news_local_data_source.dart';
import '../datasources/remote/rss_remote_data_source.dart';

import 'package:flutter/foundation.dart';
/// NewsRepository interface'inin implementasyonu
/// Remote ve local data source'ları koordine eder
/// Network durumuna göre online/offline logic'i yönetir
class NewsRepositoryImpl implements NewsRepository {
  final RssRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  final Connectivity connectivity;

  /// Stream controller for reactive updates
  final StreamController<List<Article>> _articlesStreamController =
      StreamController<List<Article>>.broadcast();

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  /// Dispose stream controller
  void dispose() {
    _articlesStreamController.close();
  }

  @override
  Future<List<Article>> getArticlesByCategory(String category) async {
    try {
      debugPrint('🔄 getArticlesByCategory başladı: $category (Cache-First)');
      
      // 1. ÖNCE CACHE'DEN AL (Hızlı başlangıç)
      try {
        final cachedArticles = await localDataSource.getCachedArticlesByCategory(category);
        if (cachedArticles.isNotEmpty) {
          debugPrint('✅ Cache\'den $category kategorisi için ${cachedArticles.length} haber alındı (HIZLI YÜKLEME)');
          final entities = cachedArticles.map((model) => model.toEntity()).toList();
          final sortedEntities = _sortArticlesByImage(entities);
          
          // 2. ARKA PLANDA YENİLE (non-blocking)
          final connectivityResult = await connectivity.checkConnectivity();
          final hasConnection = !connectivityResult.contains(ConnectivityResult.none) &&
                                 connectivityResult.isNotEmpty;
          
          if (hasConnection) {
            debugPrint('🔄 [$category] Arka planda yenileme başlatılıyor...');
            _refreshCategoryInBackground(category);
          }
          
          return sortedEntities;
        }
      } catch (cacheError) {
        debugPrint('⚠️ Cache okuma hatası: $cacheError');
      }
      
      // 3. CACHE YOKSA NETWORK'TEN ÇEK
      debugPrint('📡 [$category] Cache boş, network\'ten çekiliyor...');
      final connectivityResult = await connectivity.checkConnectivity();
      final hasConnection = !connectivityResult.contains(ConnectivityResult.none) &&
                             connectivityResult.isNotEmpty;
      debugPrint('🌐 Network durumu: $hasConnection');

      if (hasConnection) {
        try {
          debugPrint('🔄 Remote\'dan $category kategorisi için haberler çekiliyor...');
          final articles = await remoteDataSource.getArticlesByCategory(category);
          debugPrint('✅ Remote\'dan ${articles.length} makale alındı');
          
          if (articles.isEmpty) {
            debugPrint('⚠️ Remote\'dan haber gelmedi, demo data döndürülüyor');
            return _createDemoArticlesByCategory(category);
          }
          
          // Cache articles locally
          debugPrint('💾 $category kategorisi cache\'e kaydediliyor...');
          await localDataSource.cacheArticles(articles);
          
          // Convert ArticleModel to Article and sort by image
          final entities = articles.map((model) => model.toEntity()).toList();
          debugPrint('✅ $category kategorisi için ${entities.length} haber alındı');
          return _sortArticlesByImage(entities);
        } catch (e) {
          debugPrint('⚠️ Remote request hatası: $e, demo data döndürülüyor');
          return _createDemoArticlesByCategory(category);
        }
      } else {
        // Offline - demo data
        debugPrint('📱 Offline mod - demo data döndürülüyor');
        return _createDemoArticlesByCategory(category);
      }
    } catch (e) {
      debugPrint('💥 getArticlesByCategory HATA: $e');
      return _createDemoArticlesByCategory(category);
    }
  }
  
  /// Kategori için arka planda yenileme (non-blocking)
  void _refreshCategoryInBackground(String category) async {
    try {
      debugPrint('🔄 [Background] $category kategorisini yeniliyorum...');
      final articles = await remoteDataSource.getArticlesByCategory(category);
      await localDataSource.cacheArticles(articles);
      debugPrint('✅ [Background] $category: ${articles.length} makale cache\'e kaydedildi');
      
      // ✅ Stream'e yeni verileri gönder (UI güncellemesi için)
      final entities = articles.map((model) => model.toEntity()).toList();
      final sortedEntities = _sortArticlesByImage(entities);
      if (!_articlesStreamController.isClosed) {
        _articlesStreamController.add(sortedEntities);
        debugPrint('📡 [Stream] $category kategorisi için ${sortedEntities.length} makale stream\'e gönderildi');
      }
    } catch (e) {
      debugPrint('⚠️ [Background] $category yenileme hatası (sessizce başarısız): $e');
    }
  }

  @override
  Future<List<Article>> getAllArticles() async {
    try {
      debugPrint('🔄 getAllArticles başladı (Cache-First stratejisi)');
      
      // 1. ÖNCE CACHE'DEN AL (Hızlı başlangıç)
      try {
        final cachedArticles = await localDataSource.getCachedArticles();
        if (cachedArticles.isNotEmpty) {
          debugPrint('✅ Cache\'den ${cachedArticles.length} makale alındı (HIZLI YÜKLEME)');
          final entities = cachedArticles.map((model) => model.toEntity()).toList();
          final sortedEntities = _sortArticlesByImage(entities);
          
          // 2. ARKA PLANDA YENİLE (non-blocking)
          final connectivityResult = await connectivity.checkConnectivity();
          final hasConnection = !connectivityResult.contains(ConnectivityResult.none) &&
                                 connectivityResult.isNotEmpty;
          
          if (hasConnection) {
            debugPrint('🔄 Arka planda yenileme başlatılıyor...');
            _refreshInBackground();
          }
          
          return sortedEntities;
        }
      } catch (cacheError) {
        debugPrint('⚠️ Cache okuma hatası: $cacheError');
      }
      
      // 3. CACHE YOKSA NETWORK'TEN ÇEK
      debugPrint('📡 Cache boş, network\'ten çekiliyor...');
      final connectivityResult = await connectivity.checkConnectivity();
      final hasConnection = !connectivityResult.contains(ConnectivityResult.none) &&
                             connectivityResult.isNotEmpty;
      debugPrint('🌐 Network durumu: $hasConnection ($connectivityResult)');

      if (hasConnection) {
        try {
          debugPrint('⬇️ Remote data source\'dan veri çekiliyor...');
          final articles = await remoteDataSource.getAllArticles();
          debugPrint('✅ Remote\'dan ${articles.length} makale alındı');
          
          // Cache articles locally
          debugPrint('💾 Makaleler cache\'e kaydediliyor...');
          await localDataSource.cacheArticles(articles);
          debugPrint('✅ Cache\'e kaydetme başarılı');
          
          // Convert ArticleModel to Article and sort by image
          final entities = articles.map((model) => model.toEntity()).toList();
          final sortedEntities = _sortArticlesByImage(entities);
          debugPrint('✅ getAllArticles tamamlandı: ${sortedEntities.length} makale');
          return sortedEntities;
        } catch (e) {
          debugPrint('❌ Remote request hatası: $e');
          debugPrint('❌ Cache de boş, demo data döndürülüyor');
          return _createDemoArticles();
        }
      } else {
        debugPrint('📱 Offline mod - demo data döndürülüyor');
        return _createDemoArticles();
      }
    } catch (e) {
      debugPrint('💥 getAllArticles HATA: $e');
      throw Exception('Failed to get all articles: $e');
    }
  }
  
  /// Arka planda yenileme (non-blocking) - Kategori kategori yükler
  void _refreshInBackground() async {
    try {
      debugPrint('🔄 [Background] Haberleri kategori kategori yeniliyorum...');
      
      // Kategorileri sırayla yükle (paralel değil, sıralı)
      final categories = ['genel', 'turkiye', 'dunya', 'ekonomi', 'teknoloji',
                         'spor', 'saglik', 'kultur', 'egitim', 'magazin', 'otomobil', 'bilim'];
      
      final allArticles = <ArticleModel>[];
      
      for (final category in categories) {
        try {
          debugPrint('📥 [Background] $category kategorisi yükleniyor...');
          final categoryArticles = await remoteDataSource.getArticlesByCategory(category);
          allArticles.addAll(categoryArticles);
          
          // Her kategori sonrası kısa bekleme (UI'ı rahatlatmak için)
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Ara güncelleme - şimdiye kadar yüklenen makaleleri göster
          if (allArticles.isNotEmpty && !_articlesStreamController.isClosed) {
            final entities = allArticles.map((model) => model.toEntity()).toList();
            final sortedEntities = _sortArticlesByImage(entities);
            _articlesStreamController.add(sortedEntities);
            debugPrint('📡 [Stream] ${sortedEntities.length} makale stream\'e gönderildi (${category} dahil)');
          }
        } catch (e) {
          debugPrint('⚠️ [Background] $category kategorisi yüklenemedi: $e');
        }
      }
      
      // Tüm makaleleri cache'e kaydet
      if (allArticles.isNotEmpty) {
        await localDataSource.cacheArticles(allArticles);
        debugPrint('✅ [Background] ${allArticles.length} makale cache\'e kaydedildi');
      }
    } catch (e) {
      debugPrint('⚠️ [Background] Yenileme hatası (sessizce başarısız): $e');
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
      return !connectivityResult.contains(ConnectivityResult.none) &&
             connectivityResult.isNotEmpty;
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

  /// Kategori bazlı demo makaleler
  List<Article> _createDemoArticlesByCategory(String category) {
    final now = DateTime.now();
    final categoryNames = {
      'magazin': 'Magazin',
      'bilim': 'Bilim',
      'egitim': 'Eğitim',
      'otomobil': 'Otomobil',
    };
    
    final categoryName = categoryNames[category] ?? category;
    
    return [
      Article(
        id: 'demo_${category}_1',
        title: '$categoryName kategorisi yükleniyor...',
        description: 'İnternet bağlantınız kurulduğunda $categoryName kategorisindeki güncel haberler yüklenecek.',
        content: 'Bu demo içeriktir. İnternet bağlantınızı kontrol edin ve sayfayı yenileyin.',
        link: '',
        imageUrl: null,
        publishedDate: now.subtract(const Duration(minutes: 5)),
        category: category,
        sourceName: 'Haber Merkezi',
        isRead: false,
        isFavorite: false,
      ),
      Article(
        id: 'demo_${category}_2',
        title: 'Yenile Butonunu Kullanın',
        description: 'Sayfayı aşağı çekerek yenileme yapabilir veya ayarlardan cache\'i temizleyebilirsiniz.',
        content: 'Pull-to-refresh özelliği ile haberleri manuel olarak güncelleyebilirsiniz.',
        link: '',
        imageUrl: null,
        publishedDate: now.subtract(const Duration(minutes: 10)),
        category: category,
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

  @override
  Stream<List<Article>> watchArticlesByCategory(String category) {
    return _articlesStreamController.stream
        .map((articles) => articles.where((a) =>
            category == 'genel' || a.category == category).toList());
  }

  @override
  Stream<List<Article>> watchAllArticles() {
    return _articlesStreamController.stream;
  }
}