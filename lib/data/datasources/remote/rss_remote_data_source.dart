import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/exceptions.dart';
import '../../models/article_model.dart';

/// RSS feed'lerini çeken remote data source
/// HTTP client ile RSS XML'lerini alır ve ArticleModel'lere parse eder
abstract class RssRemoteDataSource {
  Future<List<ArticleModel>> getArticlesByCategory(String category);
  Future<List<ArticleModel>> getAllArticles();
  Future<List<ArticleModel>> refreshArticles(String category);
}

class RssRemoteDataSourceImpl implements RssRemoteDataSource {
  final Dio _dio;
  
  RssRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? _createDio();
  
  /// Dio client oluşturur
  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: ApiEndpoints.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: ApiEndpoints.receiveTimeoutMs),
      sendTimeout: const Duration(milliseconds: ApiEndpoints.sendTimeoutMs),
      headers: {
        'User-Agent': 'Haber Merkezi RSS Reader v1.0',
        'Accept': 'application/rss+xml, application/xml, text/xml',
      },
    ));
    
    // Request/Response interceptor (debugging için)
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (object) => print('[RSS HTTP] $object'),
    ));
    
    return dio;
  }

  @override
  Future<List<ArticleModel>> getArticlesByCategory(String category) async {
    try {
      print('🌐 RSS Request: $category');
      
      // Kategoriye ait tüm RSS feed'lerini bul (örn: teknoloji, teknoloji_webtekno, teknoloji_shiftdelete)
      final categoryFeeds = ApiEndpoints.rssFeedUrls.entries
          .where((entry) => entry.key == category || entry.key.startsWith('${category}_'))
          .toList();
      
      if (categoryFeeds.isEmpty) {
        print('❌ Kategori bulunamadı: $category');
        throw RssParseException('Kategori bulunamadı: $category');
      }
      
      final List<ArticleModel> allArticles = [];
      
      // Kategoriye ait tüm feed'leri paralel olarak çek
      for (final feedEntry in categoryFeeds) {
        try {
          final feedUrl = feedEntry.value;
          final feedKey = feedEntry.key;
          
          print('📡 URL [$feedKey]: $feedUrl');
          final response = await _dio.get(feedUrl);
          print('📊 Response [$feedKey]: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            final xmlString = response.data as String;
            print('📝 Parsing XML [$feedKey]...');
            final articles = await _parseRssXml(xmlString, category);
            allArticles.addAll(articles);
            print('✅ $feedKey: ${articles.length} makale');
          } else {
            print('⚠️ HTTP Error [$feedKey]: ${response.statusCode}');
          }
        } catch (e) {
          // Bir feed başarısız olursa diğerlerine devam et
          print('⚠️ Feed hatası [${feedEntry.key}]: $e');
        }
      }
      
      if (allArticles.isEmpty) {
        throw RssParseException('$category kategorisinden hiç haber alınamadı');
      }
      
      // Duplicate'leri kaldır
      final uniqueArticles = _removeDuplicates(allArticles);
      
      // Resim olanları üste, tarihe göre sırala
      uniqueArticles.sort((a, b) {
        final aHasImage = a.imageUrl != null && a.imageUrl!.isNotEmpty;
        final bHasImage = b.imageUrl != null && b.imageUrl!.isNotEmpty;
        
        if (aHasImage && !bHasImage) return -1;
        if (!aHasImage && bHasImage) return 1;
        
        // Aynı durumda tarihe göre sırala
        return b.publishedDate.compareTo(a.publishedDate);
      });
      
      print('✅ $category: Toplam ${uniqueArticles.length} makale (${allArticles.length} feed\'den)');
      return uniqueArticles;
      
    } on DioException catch (e) {
      print('💥 DioException [$category]: ${e.type} - ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('💥 Parse Error [$category]: $e');
      throw ServerException('RSS feed parse hatası: ${e.toString()}');
    }
  }
  
  /// Duplicate makaleleri kaldır (aynı link'e sahip)
  List<ArticleModel> _removeDuplicates(List<ArticleModel> articles) {
    final seenLinks = <String>{};
    final uniqueArticles = <ArticleModel>[];
    
    for (final article in articles) {
      if (!seenLinks.contains(article.link)) {
        seenLinks.add(article.link);
        uniqueArticles.add(article);
      }
    }
    
    return uniqueArticles;
  }
  
  /// Ana kategorileri döndürür (alt feed'leri değil)
  List<String> _getMainCategories() {
    final categories = <String>{};
    
    for (final key in ApiEndpoints.rssFeedUrls.keys) {
      // Alt feed'ler "_" ile ayrılmış (örn: teknoloji_webtekno)
      // Ana kategori alt çizgi içermez veya sadece kategori adıdır
      if (!key.contains('_') || key.split('_').length == 1) {
        categories.add(key);
      } else {
        // Alt feed'lerden ana kategoriyi çıkar (teknoloji_webtekno -> teknoloji)
        final mainCategory = key.split('_').first;
        categories.add(mainCategory);
      }
    }
    
    return categories.toList()..sort();
  }

  @override
  Future<List<ArticleModel>> getAllArticles() async {
    final List<ArticleModel> allArticles = [];
    
    // Sadece ana kategorileri al (alt feed'leri değil)
    final mainCategories = _getMainCategories();
    
    for (final category in mainCategories) {
      try {
        final articles = await getArticlesByCategory(category);
        allArticles.addAll(articles);
      } catch (e) {
        // Tek kategori başarısız olursa devam et
        print('[$category] RSS feed hatası: $e');
      }
    }
    
    if (allArticles.isEmpty) {
      throw const RssParseException('Hiç haber alınamadı');
    }
    
    // Duplicate'leri kaldır
    final uniqueArticles = _removeDuplicates(allArticles);
    
    // Resim olanları üste, tarihe göre sırala
    uniqueArticles.sort((a, b) {
      final aHasImage = a.imageUrl != null && a.imageUrl!.isNotEmpty;
      final bHasImage = b.imageUrl != null && b.imageUrl!.isNotEmpty;
      
      if (aHasImage && !bHasImage) return -1;
      if (!aHasImage && bHasImage) return 1;
      
      // Aynı durumda tarihe göre sırala
      return b.publishedDate.compareTo(a.publishedDate);
    });
    
    print('✅ Tüm kategoriler: Toplam ${uniqueArticles.length} makale');
    return uniqueArticles;
  }

  @override
  Future<List<ArticleModel>> refreshArticles(String category) async {
    // Cache'i bypass etmek için timestamp ekle
    final feedUrl = ApiEndpoints.rssFeedUrls[category];
    if (feedUrl == null) {
      throw RssParseException('Kategori bulunamadı: $category');
    }
    
    final refreshUrl = '$feedUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      final response = await _dio.get(refreshUrl);
      
      if (response.statusCode != 200) {
        throw ServerException(
          'RSS feed yenilenemedi: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      
      final xmlString = response.data as String;
      final articles = await _parseRssXml(xmlString, category);
      
      return articles;
      
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// RSS XML'ini parse eder ve ArticleModel listesi döner
  Future<List<ArticleModel>> _parseRssXml(String xmlString, String category) async {
    try {
      final document = XmlDocument.parse(xmlString);
      final sourceName = ApiEndpoints.feedNames[category] ?? category;
      
      // RSS 2.0 format kontrolü
      if (document.findAllElements('rss').isNotEmpty) {
        return _parseRss2Format(document, category, sourceName);
      }
      
      // Atom format kontrolü
      if (document.findAllElements('feed').isNotEmpty) {
        return _parseAtomFormat(document, category, sourceName);
      }
      
      throw InvalidRssFeedException(ApiEndpoints.rssFeedUrls[category] ?? '');
      
    } catch (e) {
      if (e is RssParseException) rethrow;
      throw RssParseException('XML parse hatası: ${e.toString()}');
    }
  }

  /// RSS 2.0 formatını parse eder
  List<ArticleModel> _parseRss2Format(XmlDocument document, String category, String sourceName) {
    final items = document.findAllElements('item');
    final List<ArticleModel> articles = [];
    
    for (final item in items) {
      try {
        final articleData = <String, dynamic>{};
        
        // Temel alanları çıkar
        articleData['title'] = _getElementText(item, 'title');
        articleData['link'] = _getElementText(item, 'link');
        articleData['description'] = _getElementText(item, 'description');
        articleData['pubDate'] = _getElementText(item, 'pubDate');
        
        // İçerik alanları (farklı taglar olabilir)
        articleData['content'] = _getElementText(item, 'content:encoded') ??
                                 _getElementText(item, 'content') ??
                                 articleData['description'];
        
        // Media content (görsel)
        articleData['mediaContent'] = _getMediaContent(item);
        
        // Enclosure (alternatif görsel)
        articleData['enclosure'] = _getEnclosureUrl(item);
        
        final article = ArticleModel.fromRssItem(
          rssItem: articleData,
          category: category,
          sourceName: sourceName,
        );
        
        articles.add(article);
        
      } catch (e) {
        print('RSS item parse hatası: $e');
        // Tek item başarısız olursa devam et
        continue;
      }
    }
    
    if (articles.isEmpty) {
      throw EmptyRssFeedException(ApiEndpoints.rssFeedUrls[category] ?? '');
    }
    
    return articles;
  }

  /// Atom formatını parse eder
  List<ArticleModel> _parseAtomFormat(XmlDocument document, String category, String sourceName) {
    final entries = document.findAllElements('entry');
    final List<ArticleModel> articles = [];
    
    for (final entry in entries) {
      try {
        final articleData = <String, dynamic>{};
        
        // Atom alanlarını RSS formatına dönüştür
        articleData['title'] = _getElementText(entry, 'title');
        
        // Link elementi attribute'dan alınır
        final linkElement = entry.findElements('link').firstOrNull;
        articleData['link'] = linkElement?.getAttribute('href') ?? '';
        
        // Summary veya content
        articleData['description'] = _getElementText(entry, 'summary') ??
                                   _getElementText(entry, 'content');
        
        // Updated date
        articleData['pubDate'] = _getElementText(entry, 'updated') ??
                               _getElementText(entry, 'published');
        
        articleData['content'] = articleData['description'];
        
        // Atom formatında görsel çekme
        articleData['mediaContent'] = _getMediaContent(entry);
        
        final article = ArticleModel.fromRssItem(
          rssItem: articleData,
          category: category,
          sourceName: sourceName,
        );
        
        articles.add(article);
        
      } catch (e) {
        print('Atom entry parse hatası: $e');
        continue;
      }
    }
    
    if (articles.isEmpty) {
      throw EmptyRssFeedException(ApiEndpoints.rssFeedUrls[category] ?? '');
    }
    
    return articles;
  }

  /// XML element'inin text değerini döner
  String? _getElementText(XmlElement parent, String tagName) {
    final element = parent.findElements(tagName).firstOrNull;
    return element?.innerText.trim();
  }

  /// Media content URL'ini çıkarır
  String? _getMediaContent(XmlElement item) {
    // media:content elementi (Media RSS namespace)
    var mediaElement = item.findElements('media:content').firstOrNull;
    if (mediaElement != null) {
      final url = mediaElement.getAttribute('url');
      if (url != null && url.isNotEmpty) return url;
    }
    
    // content elementi (Atom format)
    mediaElement = item.findElements('content').firstOrNull;
    if (mediaElement != null) {
      final url = mediaElement.getAttribute('url');
      if (url != null && url.isNotEmpty) return url;
    }
    
    // media:thumbnail elementi
    final thumbnailElement = item.findElements('media:thumbnail').firstOrNull;
    if (thumbnailElement != null) {
      final url = thumbnailElement.getAttribute('url');
      if (url != null && url.isNotEmpty) return url;
    }
    
    // media:group içindeki media:content
    final mediaGroup = item.findElements('media:group').firstOrNull;
    if (mediaGroup != null) {
      final groupContent = mediaGroup.findElements('media:content').firstOrNull;
      if (groupContent != null) {
        final url = groupContent.getAttribute('url');
        if (url != null && url.isNotEmpty) return url;
      }
    }
    
    return null;
  }

  /// Enclosure URL'ini çıkarır  
  String? _getEnclosureUrl(XmlElement item) {
    final enclosureElement = item.findElements('enclosure').firstOrNull;
    
    if (enclosureElement != null) {
      final type = enclosureElement.getAttribute('type') ?? '';
      if (type.startsWith('image/')) {
        return enclosureElement.getAttribute('url');
      }
    }
    
    return null;
  }

  /// DioError'ı uygun exception'a çevirir
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
        
      case DioExceptionType.connectionError:
        return const NoInternetException();
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return const BadRequestException();
          case 401:
            return const UnauthorizedException();
          case 404:
            return const NotFoundException('RSS feed bulunamadı');
          case 500:
            return const InternalServerException();
          default:
            return ServerException(
              'HTTP Hatası: $statusCode',
              statusCode: statusCode,
            );
        }
        
      case DioExceptionType.cancel:
        return const NetworkException('İstek iptal edildi');
        
      case DioExceptionType.unknown:
        return NetworkException('Bilinmeyen network hatası: ${error.message}');
        
      default:
        return NetworkException('Network hatası: ${error.message}');
    }
  }
}