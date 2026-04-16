import '../entities/article.dart';
import '../entities/category.dart';

/// CategoryRepository - Domain layer interface
/// Kategori işlemlerini yönetir
/// Clean Architecture'da business logic katmanının data katmanına bağımlılığı
abstract class CategoryRepository {
  /// Tüm kategorileri getir
  Future<List<Category>> getCategories();

  /// Aktif kategorileri getir
  Future<List<Category>> getActiveCategories();

  /// Belirli bir kategoriyi ID ile getir
  Future<Category?> getCategoryById(String categoryId);

  /// Kategoriye göre haberleri getir
  Future<List<Article>> getCategoryNews(String categoryId, {int page = 1, int limit = 20});

  /// Kategori sıralamasını güncelle
  Future<void> updateCategoryOrder(List<String> categoryIds);

  /// Kategoriyi aktif/pasif yap
  Future<void> toggleCategoryActive(String categoryId, bool isActive);

  /// Kategori makale sayılarını güncelle
  Future<Map<String, int>> getCategoryArticleCounts();
}