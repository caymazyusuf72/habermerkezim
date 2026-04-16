import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Deep link türleri
enum DeepLinkType {
  article,
  category,
  search,
  collection,
  unknown,
}

/// Deep link veri modeli
class DeepLinkData {
  final DeepLinkType type;
  final String? articleId;
  final String? categoryName;
  final String? searchQuery;
  final String? collectionId;
  final String rawUri;

  const DeepLinkData({
    required this.type,
    this.articleId,
    this.categoryName,
    this.searchQuery,
    this.collectionId,
    required this.rawUri,
  });

  @override
  String toString() {
    return 'DeepLinkData{type: $type, articleId: $articleId, categoryName: $categoryName, searchQuery: $searchQuery, rawUri: $rawUri}';
  }
}

/// Deep Linking Servisi
/// App scheme ve web URL handling desteği
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  // App scheme
  static const String appScheme = 'habermerkezi';
  // Web domain
  static const String webDomain = 'habermerkezi.app';

  // Deep link stream controller
  final _deepLinkController = StreamController<DeepLinkData>.broadcast();

  /// Deep link event stream
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;

  /// Son deep link
  DeepLinkData? _lastDeepLink;
  DeepLinkData? get lastDeepLink => _lastDeepLink;

  /// Servisi başlat
  Future<void> initialize() async {
    debugPrint('✅ DeepLinkService initialized');
    // Platform-specific deep link dinleyicileri burada başlatılır
    // (uni_links veya app_links paketi ile)
  }

  // ─── URI Parsing ──────────────────────────────────────────────────────────

  /// URI'yi parse et ve DeepLinkData oluştur
  DeepLinkData? parseUri(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      return _parseUriInternal(uri);
    } catch (e) {
      debugPrint('❌ Deep link parse hatası: $e');
      return null;
    }
  }

  /// URI'yi internal olarak parse et
  DeepLinkData? _parseUriInternal(Uri uri) {
    // App scheme: habermerkezi://article/{articleId}
    if (uri.scheme == appScheme) {
      return _parseAppSchemeUri(uri);
    }

    // Web URL: https://habermerkezi.app/article/{id}
    if (uri.host == webDomain || uri.host == 'www.$webDomain') {
      return _parseWebUri(uri);
    }

    return DeepLinkData(
      type: DeepLinkType.unknown,
      rawUri: uri.toString(),
    );
  }

  /// App scheme URI parse
  DeepLinkData? _parseAppSchemeUri(Uri uri) {
    final host = uri.host;
    final pathSegments = uri.pathSegments;

    switch (host) {
      case 'article':
        // habermerkezi://article/{articleId}
        final articleId = pathSegments.isNotEmpty ? pathSegments[0] : null;
        return DeepLinkData(
          type: DeepLinkType.article,
          articleId: articleId,
          rawUri: uri.toString(),
        );

      case 'category':
        // habermerkezi://category/{categoryName}
        final categoryName = pathSegments.isNotEmpty
            ? Uri.decodeComponent(pathSegments[0])
            : null;
        return DeepLinkData(
          type: DeepLinkType.category,
          categoryName: categoryName,
          rawUri: uri.toString(),
        );

      case 'search':
        // habermerkezi://search?q={query}
        final query = uri.queryParameters['q'];
        return DeepLinkData(
          type: DeepLinkType.search,
          searchQuery: query,
          rawUri: uri.toString(),
        );

      case 'collection':
        // habermerkezi://collection/{collectionId}
        final collectionId = pathSegments.isNotEmpty ? pathSegments[0] : null;
        return DeepLinkData(
          type: DeepLinkType.collection,
          collectionId: collectionId,
          rawUri: uri.toString(),
        );

      default:
        return DeepLinkData(
          type: DeepLinkType.unknown,
          rawUri: uri.toString(),
        );
    }
  }

  /// Web URL parse
  DeepLinkData? _parseWebUri(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      return DeepLinkData(
        type: DeepLinkType.unknown,
        rawUri: uri.toString(),
      );
    }

    switch (pathSegments[0]) {
      case 'article':
        // https://habermerkezi.app/article/{id}
        final articleId = pathSegments.length > 1 ? pathSegments[1] : null;
        return DeepLinkData(
          type: DeepLinkType.article,
          articleId: articleId,
          rawUri: uri.toString(),
        );

      case 'category':
        // https://habermerkezi.app/category/{name}
        final categoryName = pathSegments.length > 1
            ? Uri.decodeComponent(pathSegments[1])
            : null;
        return DeepLinkData(
          type: DeepLinkType.category,
          categoryName: categoryName,
          rawUri: uri.toString(),
        );

      case 'search':
        // https://habermerkezi.app/search?q={query}
        final query = uri.queryParameters['q'];
        return DeepLinkData(
          type: DeepLinkType.search,
          searchQuery: query,
          rawUri: uri.toString(),
        );

      default:
        return DeepLinkData(
          type: DeepLinkType.unknown,
          rawUri: uri.toString(),
        );
    }
  }

  // ─── Link Oluşturma ──────────────────────────────────────────────────────

  /// Haber detay deep link oluştur
  String createArticleLink(String articleId) {
    return '$appScheme://article/$articleId';
  }

  /// Haber detay web URL oluştur
  String createArticleWebUrl(String articleId) {
    return 'https://$webDomain/article/$articleId';
  }

  /// Kategori deep link oluştur
  String createCategoryLink(String categoryName) {
    return '$appScheme://category/${Uri.encodeComponent(categoryName)}';
  }

  /// Arama deep link oluştur
  String createSearchLink(String query) {
    return '$appScheme://search?q=${Uri.encodeComponent(query)}';
  }

  /// Koleksiyon deep link oluştur
  String createCollectionLink(String collectionId) {
    return '$appScheme://collection/$collectionId';
  }

  // ─── Link Handler ─────────────────────────────────────────────────────────

  /// Deep link'i handle et (router'a yönlendirme için)
  void handleDeepLink(String uriString) {
    final data = parseUri(uriString);
    if (data != null) {
      _lastDeepLink = data;
      _deepLinkController.add(data);
      debugPrint('📱 Deep link handled: $data');
    }
  }

  /// Bekleyen deep link'i tüket (bir kere okunup temizlenir)
  DeepLinkData? consumeLastDeepLink() {
    final data = _lastDeepLink;
    _lastDeepLink = null;
    return data;
  }

  /// Dispose
  void dispose() {
    _deepLinkController.close();
  }
}

// ─── Riverpod Provider'ları ─────────────────────────────────────────────────

/// DeepLinkService provider
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService();
});

/// Deep link stream provider
final deepLinkStreamProvider = StreamProvider<DeepLinkData>((ref) {
  final service = ref.watch(deepLinkServiceProvider);
  return service.deepLinkStream;
});