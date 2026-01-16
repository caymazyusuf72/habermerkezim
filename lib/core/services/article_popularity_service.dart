import 'package:hive_flutter/hive_flutter.dart';

/// Makale popülerlik verisi
class ArticlePopularity {
  final String articleId;
  final String title;
  final String? imageUrl;
  final String sourceName;
  final String category;
  final int viewCount;
  final int shareCount;
  final int favoriteCount;
  final DateTime lastViewed;
  final DateTime firstViewed;

  const ArticlePopularity({
    required this.articleId,
    required this.title,
    this.imageUrl,
    required this.sourceName,
    required this.category,
    this.viewCount = 0,
    this.shareCount = 0,
    this.favoriteCount = 0,
    required this.lastViewed,
    required this.firstViewed,
  });

  /// Popülerlik puanı hesapla
  /// Görüntülenme: 1 puan, Paylaşım: 3 puan, Favori: 2 puan
  /// Zaman faktörü: Son 24 saat içindeki görüntülemeler 2x puan
  double get popularityScore {
    final now = DateTime.now();
    final hoursSinceLastView = now.difference(lastViewed).inHours;
    
    // Temel puan
    double baseScore = viewCount * 1.0 + shareCount * 3.0 + favoriteCount * 2.0;
    
    // Zaman faktörü (son 24 saat içinde görüntülendiyse bonus)
    if (hoursSinceLastView < 24) {
      baseScore *= 1.5;
    } else if (hoursSinceLastView < 48) {
      baseScore *= 1.2;
    } else if (hoursSinceLastView > 168) {
      // 1 haftadan eski ise azalt
      baseScore *= 0.7;
    }
    
    return baseScore;
  }

  /// Trend puanı (son 24 saatteki aktivite)
  bool get isTrending {
    final hoursSinceLastView = DateTime.now().difference(lastViewed).inHours;
    return hoursSinceLastView < 24 && viewCount >= 3;
  }

  ArticlePopularity copyWith({
    String? articleId,
    String? title,
    String? imageUrl,
    String? sourceName,
    String? category,
    int? viewCount,
    int? shareCount,
    int? favoriteCount,
    DateTime? lastViewed,
    DateTime? firstViewed,
  }) {
    return ArticlePopularity(
      articleId: articleId ?? this.articleId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      sourceName: sourceName ?? this.sourceName,
      category: category ?? this.category,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      lastViewed: lastViewed ?? this.lastViewed,
      firstViewed: firstViewed ?? this.firstViewed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'articleId': articleId,
      'title': title,
      'imageUrl': imageUrl,
      'sourceName': sourceName,
      'category': category,
      'viewCount': viewCount,
      'shareCount': shareCount,
      'favoriteCount': favoriteCount,
      'lastViewed': lastViewed.millisecondsSinceEpoch,
      'firstViewed': firstViewed.millisecondsSinceEpoch,
    };
  }

  factory ArticlePopularity.fromMap(Map<String, dynamic> map) {
    return ArticlePopularity(
      articleId: map['articleId'] ?? '',
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'],
      sourceName: map['sourceName'] ?? '',
      category: map['category'] ?? '',
      viewCount: map['viewCount'] ?? 0,
      shareCount: map['shareCount'] ?? 0,
      favoriteCount: map['favoriteCount'] ?? 0,
      lastViewed: DateTime.fromMillisecondsSinceEpoch(map['lastViewed'] ?? 0),
      firstViewed: DateTime.fromMillisecondsSinceEpoch(map['firstViewed'] ?? 0),
    );
  }
}

/// Makale popülerlik servisi
class ArticlePopularityService {
  static const String _boxName = 'article_popularity';
  static Box<Map>? _box;

  /// Servisi başlat
  static Future<void> init() async {
    try {
      if (_box == null || !_box!.isOpen) {
        _box = await Hive.openBox<Map>(_boxName);
      }
    } catch (e) {
      debugPrint('ArticlePopularityService başlatma hatası: $e');
      rethrow;
    }
  }

  /// Makale görüntüleme kaydet
  static Future<bool> recordView({
    required String articleId,
    required String title,
    String? imageUrl,
    required String sourceName,
    required String category,
  }) async {
    try {
      final existing = _box!.get(articleId);
      final now = DateTime.now();

      if (existing != null) {
        final popularity = ArticlePopularity.fromMap(Map<String, dynamic>.from(existing));
        final updated = popularity.copyWith(
          viewCount: popularity.viewCount + 1,
          lastViewed: now,
          title: title,
          imageUrl: imageUrl,
          sourceName: sourceName,
          category: category,
        );
        await _box!.put(articleId, updated.toMap());
      } else {
        final newPopularity = ArticlePopularity(
          articleId: articleId,
          title: title,
          imageUrl: imageUrl,
          sourceName: sourceName,
          category: category,
          viewCount: 1,
          lastViewed: now,
          firstViewed: now,
        );
        await _box!.put(articleId, newPopularity.toMap());
      }
      return true;
    } catch (e) {
      debugPrint('Görüntüleme kaydetme hatası: $e');
      return false;
    }
  }

  /// Makale paylaşım kaydet
  static Future<bool> recordShare(String articleId) async {
    try {
      final existing = _box!.get(articleId);
      if (existing != null) {
        final popularity = ArticlePopularity.fromMap(Map<String, dynamic>.from(existing));
        final updated = popularity.copyWith(
          shareCount: popularity.shareCount + 1,
          lastViewed: DateTime.now(),
        );
        await _box!.put(articleId, updated.toMap());
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Paylaşım kaydetme hatası: $e');
      return false;
    }
  }

  /// Makale favori kaydet
  static Future<bool> recordFavorite(String articleId) async {
    try {
      final existing = _box!.get(articleId);
      if (existing != null) {
        final popularity = ArticlePopularity.fromMap(Map<String, dynamic>.from(existing));
        final updated = popularity.copyWith(
          favoriteCount: popularity.favoriteCount + 1,
          lastViewed: DateTime.now(),
        );
        await _box!.put(articleId, updated.toMap());
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Favori kaydetme hatası: $e');
      return false;
    }
  }

  /// Makale popülerlik bilgisini al
  static ArticlePopularity? getPopularity(String articleId) {
    try {
      final map = _box!.get(articleId);
      if (map != null) {
        return ArticlePopularity.fromMap(Map<String, dynamic>.from(map));
      }
      return null;
    } catch (e) {
      debugPrint('Popülerlik alma hatası: $e');
      return null;
    }
  }

  /// En popüler makaleleri al
  static List<ArticlePopularity> getPopularArticles({
    int limit = 20,
    String? category,
    Duration? timeRange,
  }) {
    try {
      final allPopularity = <ArticlePopularity>[];
      final now = DateTime.now();

      for (final map in _box!.values) {
        final popularity = ArticlePopularity.fromMap(Map<String, dynamic>.from(map));
        
        // Kategori filtresi
        if (category != null && popularity.category != category) {
          continue;
        }
        
        // Zaman aralığı filtresi
        if (timeRange != null) {
          final cutoffDate = now.subtract(timeRange);
          if (popularity.lastViewed.isBefore(cutoffDate)) {
            continue;
          }
        }
        
        allPopularity.add(popularity);
      }

      // Popülerlik puanına göre sırala
      allPopularity.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));

      return allPopularity.take(limit).toList();
    } catch (e) {
      debugPrint('Popüler makaleler alma hatası: $e');
      return [];
    }
  }

  /// Trend olan makaleleri al (son 24 saat)
  static List<ArticlePopularity> getTrendingArticles({int limit = 10}) {
    try {
      final allPopularity = <ArticlePopularity>[];
      final cutoffDate = DateTime.now().subtract(const Duration(hours: 24));

      for (final map in _box!.values) {
        final popularity = ArticlePopularity.fromMap(Map<String, dynamic>.from(map));
        
        // Son 24 saat içinde görüntülenen ve en az 2 görüntülenme
        if (popularity.lastViewed.isAfter(cutoffDate) && popularity.viewCount >= 2) {
          allPopularity.add(popularity);
        }
      }

      // Popülerlik puanına göre sırala
      allPopularity.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));

      return allPopularity.take(limit).toList();
    } catch (e) {
      debugPrint('Trend makaleler alma hatası: $e');
      return [];
    }
  }

  /// Kategoriye göre popüler makaleleri al
  static List<ArticlePopularity> getPopularByCategory(String category, {int limit = 10}) {
    return getPopularArticles(limit: limit, category: category);
  }

  /// Son 7 günün popüler makaleleri
  static List<ArticlePopularity> getWeeklyPopular({int limit = 20}) {
    return getPopularArticles(
      limit: limit,
      timeRange: const Duration(days: 7),
    );
  }

  /// Son 30 günün popüler makaleleri
  static List<ArticlePopularity> getMonthlyPopular({int limit = 20}) {
    return getPopularArticles(
      limit: limit,
      timeRange: const Duration(days: 30),
    );
  }

  /// Toplam görüntülenme sayısı
  static int getTotalViews() {
    try {
      int total = 0;
      for (final map in _box!.values) {
        total += (map['viewCount'] as int?) ?? 0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Toplam takip edilen makale sayısı
  static int getTotalTrackedArticles() {
    try {
      return _box!.length;
    } catch (e) {
      return 0;
    }
  }

  /// Eski verileri temizle (30 günden eski)
  static Future<int> cleanupOldData({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final keysToDelete = <String>[];

      for (final entry in _box!.toMap().entries) {
        final popularity = ArticlePopularity.fromMap(Map<String, dynamic>.from(entry.value));
        if (popularity.lastViewed.isBefore(cutoffDate)) {
          keysToDelete.add(entry.key.toString());
        }
      }

      for (final key in keysToDelete) {
        await _box!.delete(key);
      }

      return keysToDelete.length;
    } catch (e) {
      debugPrint('Eski veri temizleme hatası: $e');
      return 0;
    }
  }

  /// Tüm verileri temizle
  static Future<bool> clearAll() async {
    try {
      await _box!.clear();
      return true;
    } catch (e) {
      debugPrint('Veri temizleme hatası: $e');
      return false;
    }
  }

  /// Servisi kapat
  static Future<void> dispose() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}