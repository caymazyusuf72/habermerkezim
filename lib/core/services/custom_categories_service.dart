import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/custom_category.dart';

import 'package:flutter/foundation.dart';

/// Özel kategoriler servisi
class CustomCategoriesService {
  static const String _boxName = 'custom_categories';
  static Box<Map>? _box;

  /// Servisi başlat
  static Future<void> init() async {
    try {
      if (_box == null || !_box!.isOpen) {
        _box = await Hive.openBox<Map>(_boxName);
      }
    } catch (e) {
      debugPrint('Custom Categories Service başlatma hatası: $e');
      rethrow;
    }
  }

  /// Tüm özel kategorileri getir
  static List<CustomCategory> getAllCategories() {
    try {
      if (_box == null) return [];

      final categories = <CustomCategory>[];
      for (final key in _box!.keys) {
        final map = _box!.get(key);
        if (map != null) {
          final convertedMap = Map<String, dynamic>.from(map);
          categories.add(CustomCategory.fromJson(convertedMap));
        }
      }

      // Oluşturulma tarihine göre sırala
      categories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return categories;
    } catch (e) {
      debugPrint('Özel kategoriler getirme hatası: $e');
      return [];
    }
  }

  /// Kategoriyi kaydet
  static Future<bool> saveCategory(CustomCategory category) async {
    try {
      await _box!.put(category.id, category.toJson());
      return true;
    } catch (e) {
      debugPrint('Kategori kaydetme hatası: $e');
      return false;
    }
  }

  /// Kategoriyi güncelle
  static Future<bool> updateCategory(CustomCategory category) async {
    try {
      final updated = category.copyWith(updatedAt: DateTime.now());
      await _box!.put(category.id, updated.toJson());
      return true;
    } catch (e) {
      debugPrint('Kategori güncelleme hatası: $e');
      return false;
    }
  }

  /// Kategoriyi sil
  static Future<bool> deleteCategory(String categoryId) async {
    try {
      await _box!.delete(categoryId);
      return true;
    } catch (e) {
      debugPrint('Kategori silme hatası: $e');
      return false;
    }
  }

  /// ID'ye göre kategori getir
  static CustomCategory? getCategoryById(String categoryId) {
    try {
      final map = _box!.get(categoryId);
      if (map != null) {
        final convertedMap = Map<String, dynamic>.from(map);
        return CustomCategory.fromJson(convertedMap);
      }
      return null;
    } catch (e) {
      debugPrint('Kategori getirme hatası: $e');
      return null;
    }
  }

  /// Kategori var mı kontrol et
  static bool categoryExists(String categoryId) {
    return _box!.containsKey(categoryId);
  }
}
