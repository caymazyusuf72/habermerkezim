import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/rss_source.dart';

import 'package:flutter/foundation.dart';
/// RSS kaynakları yönetim servisi
class RssSourcesService {
  static const String _boxName = 'rss_sources';
  static Box<Map>? _box;

  /// Servisi başlat
  static Future<void> init() async {
    try {
      if (_box == null || !_box!.isOpen) {
        _box = await Hive.openBox<Map>(_boxName);
      }

      // İlk başlatmada varsayılan kaynakları ekle
      if (_box!.isEmpty) {
        await _initializeDefaultSources();
      }
    } catch (e) {
      debugPrint('RSS Sources Service başlatma hatası: $e');
      rethrow;
    }
  }

  /// Varsayılan kaynakları başlat
  static Future<void> _initializeDefaultSources() async {
    final sources = DefaultRssSources.sources;
    final now = DateTime.now();
    
    for (final source in sources) {
      final sourceWithDate = source.copyWith(
        createdAt: now,
      );
      await _box!.put(source.id, sourceWithDate.toMap());
    }
  }

  /// Tüm RSS kaynaklarını al
  static List<RssSource> getAllSources() {
    try {
      final sources = <RssSource>[];
      
      for (final map in _box!.values) {
        // Type casting için
        final convertedMap = Map<String, dynamic>.from(map);
        sources.add(RssSource.fromMap(convertedMap));
      }
      
      // ID'ye göre sırala
      sources.sort((a, b) => a.id.compareTo(b.id));
      return sources;
    } catch (e) {
      debugPrint('RSS Sources alma hatası: $e');
      return [];
    }
  }

  /// Aktif RSS kaynaklarını al
  static List<RssSource> getActiveSources() {
    return getAllSources().where((source) => source.isEnabled).toList();
  }

  /// Kategoriye göre RSS kaynaklarını al
  static List<RssSource> getSourcesByCategory(String category) {
    return getAllSources()
        .where((source) => source.category == category)
        .toList();
  }

  /// Aktif kategoriye göre RSS kaynaklarını al
  static List<RssSource> getActiveSourcesByCategory(String category) {
    return getActiveSources()
        .where((source) => source.category == category)
        .toList();
  }

  /// RSS kaynağını ID'ye göre al
  static RssSource? getSourceById(String id) {
    try {
      final map = _box!.get(id);
      if (map != null) {
        final convertedMap = Map<String, dynamic>.from(map);
        return RssSource.fromMap(convertedMap);
      }
      return null;
    } catch (e) {
      debugPrint('RSS Source alma hatası: $e');
      return null;
    }
  }

  /// Yeni RSS kaynağı ekle
  static Future<bool> addSource(RssSource source) async {
    try {
      // ID'nin benzersiz olup olmadığını kontrol et
      if (_box!.containsKey(source.id)) {
        return false; // ID zaten mevcut
      }

      await _box!.put(source.id, source.toMap());
      return true;
    } catch (e) {
      debugPrint('RSS Source ekleme hatası: $e');
      return false;
    }
  }

  /// RSS kaynağını güncelle
  static Future<bool> updateSource(RssSource source) async {
    try {
      await _box!.put(source.id, source.toMap());
      return true;
    } catch (e) {
      debugPrint('RSS Source güncelleme hatası: $e');
      return false;
    }
  }

  /// RSS kaynağını sil
  static Future<bool> deleteSource(String id) async {
    try {
      await _box!.delete(id);
      return true;
    } catch (e) {
      debugPrint('RSS Source silme hatası: $e');
      return false;
    }
  }

  /// RSS kaynağını aktif/pasif yap
  static Future<bool> toggleSourceStatus(String id) async {
    try {
      final source = getSourceById(id);
      if (source != null) {
        final updatedSource = source.copyWith(isEnabled: !source.isEnabled);
        return await updateSource(updatedSource);
      }
      return false;
    } catch (e) {
      debugPrint('RSS Source durum değiştirme hatası: $e');
      return false;
    }
  }

  /// RSS kaynağının son güncelleme tarihini güncelle
  static Future<bool> updateLastFetchedTime(String id, {int? articleCount}) async {
    try {
      final source = getSourceById(id);
      if (source != null) {
        final updatedSource = source.copyWith(
          lastFetchedAt: DateTime.now(),
          articleCount: articleCount ?? source.articleCount,
        );
        return await updateSource(updatedSource);
      }
      return false;
    } catch (e) {
      debugPrint('RSS Source son güncelleme tarihi güncelleme hatası: $e');
      return false;
    }
  }

  /// Tüm RSS kaynaklarını temizle (resetle)
  static Future<bool> clearAllSources() async {
    try {
      await _box!.clear();
      return true;
    } catch (e) {
      debugPrint('RSS Sources temizleme hatası: $e');
      return false;
    }
  }

  /// Varsayılan kaynakları geri yükle
  static Future<bool> resetToDefaults() async {
    try {
      await clearAllSources();
      await _initializeDefaultSources();
      return true;
    } catch (e) {
      debugPrint('RSS Sources varsayılanlara sıfırlama hatası: $e');
      return false;
    }
  }

  /// RSS kaynağının URL'sinin geçerli olup olmadığını kontrol et
  static bool isValidRssUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Benzersiz ID oluştur
  static String generateUniqueId(String name) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanName = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    
    return '${cleanName}_$timestamp';
  }

  /// RSS kaynağı sayısını al
  static int getSourceCount() {
    return _box?.length ?? 0;
  }

  /// Aktif RSS kaynağı sayısını al
  static int getActiveSourceCount() {
    return getActiveSources().length;
  }

  /// Kategorilerin listesini al
  static List<String> getAllCategories() {
    final categories = <String>{};
    for (final source in getAllSources()) {
      categories.add(source.category);
    }
    
    // Varsayılan kategorileri de ekle
    categories.addAll(DefaultRssSources.categories);
    
    final sortedCategories = categories.toList()..sort();
    return sortedCategories;
  }

  /// Kategoriye göre kaynak sayısını al
  static Map<String, int> getSourceCountByCategory() {
    final counts = <String, int>{};
    
    for (final source in getAllSources()) {
      counts[source.category] = (counts[source.category] ?? 0) + 1;
    }
    
    return counts;
  }

  /// Aktif kategoriye göre kaynak sayısını al
  static Map<String, int> getActiveSourceCountByCategory() {
    final counts = <String, int>{};
    
    for (final source in getActiveSources()) {
      counts[source.category] = (counts[source.category] ?? 0) + 1;
    }
    
    return counts;
  }

  /// RSS kaynağını kopyala (başka bir ID ile)
  static Future<RssSource?> duplicateSource(String sourceId) async {
    try {
      final source = getSourceById(sourceId);
      if (source != null) {
        final duplicatedSource = source.copyWith(
          id: generateUniqueId('${source.name}_copy'),
          name: '${source.name} (Kopya)',
          createdAt: DateTime.now(),
          lastFetchedAt: null,
          articleCount: null,
        );
        
        final success = await addSource(duplicatedSource);
        return success ? duplicatedSource : null;
      }
      return null;
    } catch (e) {
      debugPrint('RSS Source kopyalama hatası: $e');
      return null;
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

/// RSS Kaynakları için yardımcı sınıf
class RssSourcesHelper {
  RssSourcesHelper._();

  /// RSS URL'sinden başlık tahmin et
  static String predictTitleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final domain = uri.host.replaceAll('www.', '');
      final parts = domain.split('.');
      
      if (parts.isNotEmpty) {
        return parts.first.replaceFirst(parts.first[0], parts.first[0].toUpperCase());
      }
      
      return 'RSS Kaynağı';
    } catch (e) {
      return 'RSS Kaynağı';
    }
  }

  /// URL'den kategori tahmin et
  static String predictCategoryFromUrl(String url) {
    final lowerUrl = url.toLowerCase();
    
    if (lowerUrl.contains('teknoloji') || lowerUrl.contains('tech')) {
      return 'teknoloji';
    } else if (lowerUrl.contains('spor') || lowerUrl.contains('sport')) {
      return 'spor';
    } else if (lowerUrl.contains('ekonomi') || lowerUrl.contains('finans')) {
      return 'ekonomi';
    } else if (lowerUrl.contains('saglik') || lowerUrl.contains('health')) {
      return 'sağlık';
    } else if (lowerUrl.contains('kultur') || lowerUrl.contains('sanat')) {
      return 'kültür';
    } else if (lowerUrl.contains('egitim') || lowerUrl.contains('edu')) {
      return 'eğitim';
    }
    
    return 'genel';
  }

  /// RSS kaynağını doğrula
  static Map<String, String?> validateRssSource({
    required String name,
    required String url,
    required String category,
  }) {
    final errors = <String, String?>{};

    // Name validation
    if (name.trim().isEmpty) {
      errors['name'] = 'Kaynak adı boş olamaz';
    } else if (name.trim().length < 2) {
      errors['name'] = 'Kaynak adı en az 2 karakter olmalı';
    } else if (name.trim().length > 50) {
      errors['name'] = 'Kaynak adı en fazla 50 karakter olmalı';
    }

    // URL validation
    if (url.trim().isEmpty) {
      errors['url'] = 'RSS URL boş olamaz';
    } else if (!RssSourcesService.isValidRssUrl(url.trim())) {
      errors['url'] = 'Geçersiz URL formatı';
    }

    // Category validation
    if (category.trim().isEmpty) {
      errors['category'] = 'Kategori seçilmelidir';
    }

    return errors;
  }
}