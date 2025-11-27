import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/category.dart';
import '../../core/services/hive_service.dart';

/// Kategori sıralaması state
class CategoryOrderState {
  final List<String> categoryIds;
  final bool isLoading;

  const CategoryOrderState({
    required this.categoryIds,
    this.isLoading = false,
  });

  CategoryOrderState copyWith({
    List<String>? categoryIds,
    bool? isLoading,
  }) {
    return CategoryOrderState(
      categoryIds: categoryIds ?? this.categoryIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static CategoryOrderState get initial => CategoryOrderState(
    categoryIds: Category.defaultCategories.map((c) => c.id).toList(),
  );
}

/// Kategori sıralaması notifier
class CategoryOrderNotifier extends StateNotifier<CategoryOrderState> {
  CategoryOrderNotifier() : super(CategoryOrderState.initial) {
    _loadCategoryOrder();
  }

  /// Kategori sıralamasını yükle
  Future<void> _loadCategoryOrder() async {
    try {
      final box = HiveService.categoryOrderBox;
      final savedOrder = box.get('categoryOrder', defaultValue: <String>[]);
      
      if (savedOrder != null && savedOrder.isNotEmpty) {
        // Kaydedilmiş sıralama var, kullan
        final defaultIds = Category.defaultCategories.map((c) => c.id).toList();
        final savedOrderList = (savedOrder as List).map((e) => e.toString()).toList();
        final validIds = savedOrderList.where((id) => defaultIds.contains(id)).toList();
        
        // Eksik kategorileri ekle
        final missingIds = defaultIds.where((id) => !validIds.contains(id)).toList();
        final orderedIds = <String>[...validIds, ...missingIds];
        
        state = state.copyWith(categoryIds: orderedIds);
      } else {
        // Varsayılan sıralamayı kullan
        state = CategoryOrderState.initial;
      }
    } catch (e) {
      print('⚠️ Kategori sıralaması yüklenirken hata: $e');
      state = CategoryOrderState.initial;
    }
  }

  /// Kategori sıralamasını kaydet
  Future<void> _saveCategoryOrder() async {
    try {
      final box = HiveService.categoryOrderBox;
      await box.put('categoryOrder', state.categoryIds);
    } catch (e) {
      print('⚠️ Kategori sıralaması kaydedilirken hata: $e');
    }
  }

  /// Kategori sırasını değiştir
  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    
    final newOrder = List<String>.from(state.categoryIds);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    
    state = state.copyWith(categoryIds: newOrder);
    await _saveCategoryOrder();
  }

  /// Kategorileri sıralı döndür
  List<Category> getOrderedCategories() {
    final allCategories = Category.defaultCategories;
    final orderedCategories = <Category>[];
    
    // Sıralamaya göre ekle
    for (final id in state.categoryIds) {
      final category = allCategories.firstWhere(
        (c) => c.id == id,
        orElse: () => allCategories.first,
      );
      if (!orderedCategories.contains(category)) {
        orderedCategories.add(category);
      }
    }
    
    // Eksik kategorileri ekle
    for (final category in allCategories) {
      if (!orderedCategories.contains(category)) {
        orderedCategories.add(category);
      }
    }
    
    return orderedCategories;
  }
}

/// Kategori sıralaması provider
final categoryOrderProvider = StateNotifierProvider<CategoryOrderNotifier, CategoryOrderState>((ref) {
  return CategoryOrderNotifier();
});

/// Sıralı kategoriler provider
final orderedCategoriesProvider = Provider<List<Category>>((ref) {
  final orderNotifier = ref.watch(categoryOrderProvider.notifier);
  return orderNotifier.getOrderedCategories();
});

