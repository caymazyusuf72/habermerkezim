import 'dart:async';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

import 'hive_service.dart';
import '../error/exceptions.dart';
import '../utils/retry_helper.dart';

import 'package:flutter/foundation.dart';

/// Web scraping ile tam makale içeriği çeken servis
/// HTML parse ederek ana içeriği çıkarır ve cache'ler
class ArticleContentService {
  static final ArticleContentService _instance =
      ArticleContentService._internal();
  factory ArticleContentService() => _instance;
  ArticleContentService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'tr-TR,tr;q=0.8,en-US;q=0.5,en;q=0.3',
        'Accept-Encoding': 'gzip, deflate',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
      },
    ),
  );

  /// URL'den tam makale içeriği çeker
  Future<ArticleContent?> getFullArticleContent(String url) async {
    if (url.isEmpty) return null;

    try {
      // Cache'den kontrol et - ancak yeni temizleme sistemi için cache'yi bypass et
      // Geçici olarak cache'i devre dışı bırak
      // final cachedContent = await _getCachedContent(url);
      // if (cachedContent != null) {
      //   debugPrint('📋 Cache\'den içerik alındı: ${url.substring(0, 50)}...');
      //   return cachedContent;
      // }

      debugPrint('🌐 Web scraping başlatılıyor: ${url.substring(0, 50)}...');

      // Retry ile web scraping yap
      final content = await RetryHelper.retryOrNull(
        operation: () async {
          final response = await _dio.get(url);

          if (response.statusCode != 200) {
            throw ServerException(
              'HTTP Error: ${response.statusCode}',
              statusCode: response.statusCode,
            );
          }

          final htmlString = response.data as String;
          return _extractArticleContent(htmlString, url);
        },
        maxAttempts: 3,
        initialDelay: const Duration(seconds: 1),
        maxDelay: const Duration(seconds: 5),
      );

      if (content != null) {
        // İçeriği cache'le
        await _cacheContent(url, content);
        debugPrint('✅ İçerik başarıyla çekildi ve cache\'lendi');
      }

      return content;
    } on DioException catch (e) {
      debugPrint('🚫 Web scraping DIO hatası: ${e.type} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('🚫 Web scraping hatası: $e');
      return null;
    }
  }

  /// HTML'den makale içeriğini çıkarır (Readability algoritması)
  ArticleContent _extractArticleContent(String html, String url) {
    final document = parse(html);

    // HTML'den gereksiz elementleri temizle
    _cleanHtmlDocument(document);

    // Farklı haber sitelerinin yapılarına göre içerik çıkarma
    final extractors = [
      _extractByCommonSelectors,
      _extractBySemanticTags,
      _extractByTextDensity,
      _extractByParagraphs,
    ];

    String? bestContent;
    String? title;
    String? imageUrl;
    String? publishDate;
    String? author;

    for (final extractor in extractors) {
      final result = extractor(document, url);
      if (result.content != null &&
          result.content!.length > (bestContent?.length ?? 0)) {
        bestContent = result.content;
        title = result.title ?? title;
        imageUrl = result.imageUrl ?? imageUrl;
        publishDate = result.publishDate ?? publishDate;
        author = result.author ?? author;
      }
    }

    return ArticleContent(
      url: url,
      title: title ?? 'Başlık Bulunamadı',
      content: bestContent ?? 'İçerik çıkarılamadı',
      imageUrl: imageUrl,
      publishDate: publishDate,
      author: author,
      extractedAt: DateTime.now(),
      wordCount: _countWords(bestContent ?? ''),
      readingTimeMinutes: _estimateReadingTime(bestContent ?? ''),
    );
  }

  /// Yaygın CSS seçiciler ile içerik çıkarır
  ArticleContent _extractByCommonSelectors(dom.Document document, String url) {
    // Yaygın makale içerik seçicileri
    final contentSelectors = [
      'article',
      '.article-content',
      '.article-body',
      '.content',
      '.post-content',
      '.entry-content',
      '.news-content',
      '.story-body',
      '.article-text',
      '.main-content',
      '.haber-detay',
      '.haber-metni',
      '.detay-content',
      '.article-detail',
    ];

    String? content;
    for (final selector in contentSelectors) {
      final element = document.querySelector(selector);
      if (element != null) {
        content = _cleanText(element.text);
        if (content.length > 200) break; // Yeterli uzunlukta ise kullan
      }
    }

    // Başlık çıkarma
    final h1Element = document.querySelector('h1');
    final articleTitleElement = document.querySelector('.article-title');
    final titleElement = document.querySelector('title');
    final title =
        h1Element?.text.trim() ??
        articleTitleElement?.text.trim() ??
        titleElement?.text.trim();

    // Görsel çıkarma
    final ogImage = document.querySelector('meta[property="og:image"]');
    final articleImage = document.querySelector('.article-image img');
    final articleImg = document.querySelector('article img');
    final imageUrl =
        ogImage?.attributes['content'] ??
        articleImage?.attributes['src'] ??
        articleImg?.attributes['src'];

    // Yazar çıkarma
    final authorElement = document.querySelector('.author');
    final bylineElement = document.querySelector('.byline');
    final relAuthorElement = document.querySelector('[rel="author"]');
    final author =
        authorElement?.text.trim() ??
        bylineElement?.text.trim() ??
        relAuthorElement?.text.trim();

    // Tarih çıkarma
    final timeElement = document.querySelector('time');
    final dateElement = document.querySelector('.date');
    final publishDateElement = document.querySelector('.publish-date');
    final publishDate =
        timeElement?.attributes['datetime'] ??
        dateElement?.text.trim() ??
        publishDateElement?.text.trim();

    return ArticleContent(
      url: url,
      title: title,
      content: content,
      imageUrl: imageUrl,
      author: author,
      publishDate: publishDate,
      extractedAt: DateTime.now(),
    );
  }

  /// Semantic HTML tagları ile içerik çıkarır
  ArticleContent _extractBySemanticTags(dom.Document document, String url) {
    final article = document.querySelector('article');
    if (article == null) {
      return ArticleContent(url: url, extractedAt: DateTime.now());
    }

    // Article tag içindeki paragrafları topla
    final paragraphs = article.querySelectorAll('p');
    final contentBuilder = StringBuffer();

    for (final p in paragraphs) {
      final text = _cleanText(p.text);
      if (text.length > 10) {
        // Kısa paragrafları filtrele
        contentBuilder.writeln(text);
        contentBuilder.writeln();
      }
    }

    return ArticleContent(
      url: url,
      content: contentBuilder.toString().trim(),
      extractedAt: DateTime.now(),
    );
  }

  /// Metin yoğunluğu analizi ile içerik çıkarır
  ArticleContent _extractByTextDensity(dom.Document document, String url) {
    final elements = document.querySelectorAll('div, section, article');
    dom.Element? bestElement;
    int maxScore = 0;

    for (final element in elements) {
      final text = element.text.trim();
      if (text.length < 100) continue;

      // Skor hesaplama: metin uzunluğu / etiket sayısı
      final tagCount = element.querySelectorAll('*').length;
      final score = tagCount > 0 ? (text.length / tagCount).round() : 0;

      if (score > maxScore) {
        maxScore = score;
        bestElement = element;
      }
    }

    final content = bestElement != null ? _cleanText(bestElement.text) : null;

    return ArticleContent(
      url: url,
      content: content,
      extractedAt: DateTime.now(),
    );
  }

  /// Paragraf analizi ile içerik çıkarır
  ArticleContent _extractByParagraphs(dom.Document document, String url) {
    final paragraphs = document.querySelectorAll('p');
    final contentBuilder = StringBuffer();

    int validParagraphs = 0;
    for (final p in paragraphs) {
      final text = _cleanText(p.text);

      // Kaliteli paragraf kontrolü
      if (text.length > 20 &&
          !_isNavigationText(text) &&
          !_isAdvertisementText(text)) {
        contentBuilder.writeln(text);
        contentBuilder.writeln();
        validParagraphs++;
      }

      // Çok fazla paragraf alma
      if (validParagraphs >= 50) break;
    }

    return ArticleContent(
      url: url,
      content: contentBuilder.toString().trim(),
      extractedAt: DateTime.now(),
    );
  }

  /// HTML dökümanından gereksiz elementleri temizler
  void _cleanHtmlDocument(dom.Document document) {
    // Script tag'lerini kaldır (JavaScript kodları)
    final scripts = document.querySelectorAll('script');
    for (final script in scripts) {
      script.remove();
    }

    // Style tag'lerini kaldır (CSS kodları)
    final styles = document.querySelectorAll('style');
    for (final style in styles) {
      style.remove();
    }

    // Yaygın reklam ve sosyal medya widget'larını kaldır
    final unwantedSelectors = [
      '.taboola',
      '[id*="taboola"]',
      '[class*="taboola"]',
      '.outbrain',
      '[id*="outbrain"]',
      '[class*="outbrain"]',
      '.google-ad',
      '.adsystem',
      '.advertisement',
      '.ad-container',
      '.social-widget',
      '.social-share',
      '.newsletter',
      '.popup',
      '.modal',
      '.overlay',
      '.sidebar',
      '.comments',
      '.comment-section',
      '.related-news',
      '.breaking-news-ticker',
      'iframe[src*="google"]',
      'iframe[src*="facebook"]',
      'iframe[src*="twitter"]',
      'iframe[src*="youtube"]',
      '[id*="disqus"]',
      '[class*="disqus"]',
    ];

    for (final selector in unwantedSelectors) {
      final elements = document.querySelectorAll(selector);
      for (final element in elements) {
        element.remove();
      }
    }

    // Boş veya sadece whitespace içeren elementleri kaldır
    _removeEmptyElements(document);
  }

  /// Boş elementleri temizler
  void _removeEmptyElements(dom.Document document) {
    final allElements = document.querySelectorAll('*');
    for (final element in allElements) {
      if (element.text.trim().isEmpty &&
          element.children.isEmpty &&
          element.attributes.isEmpty) {
        element.remove();
      }
    }
  }

  /// Metni temizler ve JavaScript kodlarını filtreler
  String _cleanText(String text) {
    // JavaScript keyword'lerini ve kodlarını temizle
    final jsKeywords = [
      'window.isTaboolaMobile',
      'window._taboola',
      'document.querySelector',
      'setAttribute',
      'getElementById',
      'className',
      'innerHTML',
      'addEventListener',
      'function',
      'var ',
      'let ',
      'const ',
      'taboola',
      'outbrain',
      'google-ad',
    ];

    String cleanedText = text;

    // JavaScript kodlarını çıkar
    for (final keyword in jsKeywords) {
      if (cleanedText.toLowerCase().contains(keyword.toLowerCase())) {
        // Bu satırı tamamen çıkar
        final lines = cleanedText.split('\n');
        final filteredLines = lines
            .where(
              (line) => !line.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList();
        cleanedText = filteredLines.join('\n');
      }
    }

    // JavaScript pattern'lerini temizle
    cleanedText = cleanedText
        .replaceAll(
          RegExp(r'window\.[a-zA-Z_][a-zA-Z0-9_.]*\s*=.*?;', multiLine: true),
          '',
        ) // window object assignments
        .replaceAll(
          RegExp(r'document\.[a-zA-Z_][a-zA-Z0-9_.]*\(.*?\)', multiLine: true),
          '',
        ) // document method calls
        .replaceAll(
          RegExp(
            r'[a-zA-Z_][a-zA-Z0-9_.]*\s*=\s*[a-zA-Z_][a-zA-Z0-9_.]*\s*\|\|\s*.*?;',
            multiLine: true,
          ),
          '',
        ) // variable assignments with ||
        .replaceAll(
          RegExp(r'{[^{}]*:[^{}]*}', multiLine: true),
          '',
        ) // object literals
        .replaceAll(
          RegExp(r'function\s*\([^)]*\)\s*{[^}]*}', multiLine: true),
          '',
        ) // function definitions
        .replaceAll(
          RegExp(r'\w+\.\w+\([^)]*\)', multiLine: true),
          '',
        ) // method calls
        .replaceAll(
          RegExp(r'[a-zA-Z_]\w*\s*\+\+\s*;', multiLine: true),
          '',
        ) // increment operations
        .replaceAll(
          RegExp(r'"[^"]*"', multiLine: true),
          '',
        ) // quoted strings that might be JS
        .replaceAll(
          RegExp(r"'[^']*'", multiLine: true),
          '',
        ) // single quoted strings
        .replaceAll(RegExp(r'\s+'), ' ') // Çoklu boşlukları tek boşluğa çevir
        .replaceAll(
          RegExp(r'\n\s*\n'),
          '\n\n',
        ) // Çoklu satır atlamalarını düzenle
        .trim();

    return cleanedText;
  }

  /// Navigasyon metni kontrolü
  bool _isNavigationText(String text) {
    final navKeywords = [
      'ana sayfa',
      'menü',
      'kategori',
      'daha fazla',
      'ileri',
      'geri',
      'paylaş',
    ];
    final lowerText = text.toLowerCase();
    return navKeywords.any((keyword) => lowerText.contains(keyword)) &&
        text.length < 50;
  }

  /// Reklam metni kontrolü
  bool _isAdvertisementText(String text) {
    final adKeywords = [
      'reklam',
      'ilan',
      'sponsorlu',
      'ücretsiz',
      'indirim',
      'kampanya',
    ];
    final lowerText = text.toLowerCase();
    return adKeywords.any((keyword) => lowerText.contains(keyword)) &&
        text.length < 100;
  }

  /// Kelime sayısını hesaplar
  int _countWords(String text) {
    return text.trim().split(RegExp(r'\s+')).length;
  }

  /// Okuma süresini tahmin eder (dakika)
  int _estimateReadingTime(String text) {
    final wordCount = _countWords(text);
    // Ortalama okuma hızı: 200 kelime/dakika
    return (wordCount / 200).ceil();
  }

  /// İçeriği cache'den alır (şu an kullanılmıyor)
  // ignore: unused_element
  Future<ArticleContent?> _getCachedContent(String url) async {
    try {
      final box = HiveService.settingsBox;
      final cacheKey = 'article_content_${url.hashCode}';
      final cachedData = box.get(cacheKey) as Map<String, dynamic>?;

      if (cachedData != null) {
        final extractedAt = DateTime.parse(cachedData['extractedAt'] as String);
        final now = DateTime.now();

        // 24 saat içindeyse cache'den al
        if (now.difference(extractedAt).inHours < 24) {
          return ArticleContent.fromJson(cachedData);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Cache okuma hatası: $e');
    }

    return null;
  }

  /// İçeriği cache'ler
  Future<void> _cacheContent(String url, ArticleContent content) async {
    try {
      final box = HiveService.settingsBox;
      final cacheKey = 'article_content_${url.hashCode}';

      await box.put(cacheKey, content.toJson());

      // Cache boyutunu kontrol et (en fazla 100 makale)
      await _cleanUpCache();
    } catch (e) {
      debugPrint('⚠️ Cache yazma hatası: $e');
    }
  }

  /// Cache temizliği yapar
  Future<void> _cleanUpCache() async {
    try {
      final box = HiveService.settingsBox;
      final keys = box.keys
          .where((key) => key.toString().startsWith('article_content_'))
          .toList();

      if (keys.length > 100) {
        // En eski cache'leri sil
        final cacheData = <String, DateTime>{};

        for (final key in keys) {
          final data = box.get(key) as Map<String, dynamic>?;
          if (data != null) {
            cacheData[key.toString()] = DateTime.parse(
              data['extractedAt'] as String,
            );
          }
        }

        // En eskilerden başlayarak sırala
        final sortedKeys = cacheData.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        // İlk 20'sini sil
        for (int i = 0; i < 20 && i < sortedKeys.length; i++) {
          await box.delete(sortedKeys[i].key);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Cache temizleme hatası: $e');
    }
  }

  /// Cache istatistiklerini döndürür
  Future<CacheStats> getCacheStats() async {
    try {
      final box = HiveService.settingsBox;
      final keys = box.keys
          .where((key) => key.toString().startsWith('article_content_'))
          .toList();

      int totalSize = 0;
      for (final key in keys) {
        final data = box.get(key) as Map<String, dynamic>?;
        if (data != null) {
          totalSize += (data['content'] as String? ?? '').length;
        }
      }

      return CacheStats(
        totalItems: keys.length,
        totalSizeBytes: totalSize,
        lastCleanup: DateTime.now(),
      );
    } catch (e) {
      return CacheStats(
        totalItems: 0,
        totalSizeBytes: 0,
        lastCleanup: DateTime.now(),
      );
    }
  }

  /// Tüm cache'i temizler
  Future<void> clearAllCache() async {
    try {
      final box = HiveService.settingsBox;
      final keys = box.keys
          .where((key) => key.toString().startsWith('article_content_'))
          .toList();

      for (final key in keys) {
        await box.delete(key);
      }

      debugPrint('🗑️ Tüm makale cache\'i temizlendi (${keys.length} öğe)');
    } catch (e) {
      debugPrint('⚠️ Cache temizleme hatası: $e');
    }
  }
}

/// Makale içeriği modeli
class ArticleContent {
  final String url;
  final String? title;
  final String? content;
  final String? imageUrl;
  final String? publishDate;
  final String? author;
  final DateTime extractedAt;
  final int? wordCount;
  final int? readingTimeMinutes;

  const ArticleContent({
    required this.url,
    this.title,
    this.content,
    this.imageUrl,
    this.publishDate,
    this.author,
    required this.extractedAt,
    this.wordCount,
    this.readingTimeMinutes,
  });

  bool get hasContent => content != null && content!.trim().isNotEmpty;
  bool get isSuccessful => hasContent && (content?.length ?? 0) > 100;

  Map<String, dynamic> toJson() => {
    'url': url,
    'title': title,
    'content': content,
    'imageUrl': imageUrl,
    'publishDate': publishDate,
    'author': author,
    'extractedAt': extractedAt.toIso8601String(),
    'wordCount': wordCount,
    'readingTimeMinutes': readingTimeMinutes,
  };

  factory ArticleContent.fromJson(Map<String, dynamic> json) => ArticleContent(
    url: json['url'] as String,
    title: json['title'] as String?,
    content: json['content'] as String?,
    imageUrl: json['imageUrl'] as String?,
    publishDate: json['publishDate'] as String?,
    author: json['author'] as String?,
    extractedAt: DateTime.parse(json['extractedAt'] as String),
    wordCount: json['wordCount'] as int?,
    readingTimeMinutes: json['readingTimeMinutes'] as int?,
  );
}

/// Cache istatistikleri
class CacheStats {
  final int totalItems;
  final int totalSizeBytes;
  final DateTime lastCleanup;

  const CacheStats({
    required this.totalItems,
    required this.totalSizeBytes,
    required this.lastCleanup,
  });

  double get totalSizeMB => totalSizeBytes / (1024 * 1024);
}
