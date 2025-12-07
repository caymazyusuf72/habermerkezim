import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Görsel önbellek ve optimizasyon servisi
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  static const int _maxCacheSize = 200 * 1024 * 1024; // 200 MB
  static const int _maxCacheObjects = 200;
  
  late final CacheManager _cacheManager;

  /// Servisi başlat
  Future<void> init() async {
    _cacheManager = CacheManager(
      Config(
        'image_cache',
        maxNrOfCacheObjects: _maxCacheObjects,
        repo: JsonCacheInfoRepository(databaseName: 'image_cache.db'),
        fileService: HttpFileService(),
      ),
    );
  }

  /// Görsel URL'ini optimize eder (CDN veya resize parametreleri ekler)
  static String? optimizeImageUrl(String? imageUrl, {int? width, int? height}) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    // Bazı CDN'ler için resize parametreleri ekle
    // Örnek: Cloudinary, Imgix, etc.
    if (imageUrl.contains('cloudinary.com')) {
      final uri = Uri.parse(imageUrl);
      final params = Map<String, String>.from(uri.queryParameters);
      if (width != null) params['w'] = width.toString();
      if (height != null) params['h'] = height.toString();
      params['q'] = 'auto'; // Kalite optimizasyonu
      params['f'] = 'auto'; // Format optimizasyonu
      return uri.replace(queryParameters: params).toString();
    }
    
    // Imgix için
    if (imageUrl.contains('imgix.net')) {
      final uri = Uri.parse(imageUrl);
      final params = Map<String, String>.from(uri.queryParameters);
      if (width != null) params['w'] = width.toString();
      if (height != null) params['h'] = height.toString();
      params['auto'] = 'format,compress';
      return uri.replace(queryParameters: params).toString();
    }
    
    // Genel olarak URL'yi döndür (optimizasyon yoksa)
    return imageUrl;
  }

  /// Görseli önbelleğe al
  Future<dynamic> cacheImage(String imageUrl) async {
    try {
      final file = await _cacheManager.getSingleFile(imageUrl);
      return file;
    } catch (e) {
      print('💥 Görsel önbellekleme hatası: $e');
      return null;
    }
  }

  /// Önbellekten görseli getir
  Future<dynamic> getCachedImage(String imageUrl) async {
    try {
      final file = await _cacheManager.getSingleFile(imageUrl);
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Önbelleği temizle
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
    } catch (e) {
      print('💥 Önbellek temizleme hatası: $e');
    }
  }

  /// Önbellek boyutunu al
  Future<int> getCacheSize() async {
    try {
      // Cache manager'dan cache size bilgisi alınabilir
      // Şimdilik placeholder
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Eski önbellekleri temizle (belirli bir süreden eski)
  Future<void> clearOldCache({Duration maxAge = const Duration(days: 7)}) async {
    try {
      // Cache manager'ın kendi temizleme mekanizması var
      // Manuel temizleme için ekstra kod gerekebilir
    } catch (e) {
      print('💥 Eski önbellek temizleme hatası: $e');
    }
  }
}

