import '../../entities/article.dart';
import '../../repositories/category_repository.dart';
import '../usecase.dart';

/// Kategori haberleri getirme parametreleri
class GetCategoryNewsParams {
  final String categoryId;
  final int page;
  final int limit;

  const GetCategoryNewsParams({
    required this.categoryId,
    this.page = 1,
    this.limit = 20,
  });
}

/// Kategoriye göre haberleri getiren use case
class GetCategoryNewsUseCase
    implements UseCaseWithParams<List<Article>, GetCategoryNewsParams> {
  final CategoryRepository repository;

  const GetCategoryNewsUseCase(this.repository);

  @override
  Future<List<Article>> call(GetCategoryNewsParams params) async {
    return await repository.getCategoryNews(
      params.categoryId,
      page: params.page,
      limit: params.limit,
    );
  }
}
