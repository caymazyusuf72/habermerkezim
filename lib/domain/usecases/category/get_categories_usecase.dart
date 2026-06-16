import '../../entities/category.dart';
import '../../repositories/category_repository.dart';
import '../usecase.dart';

/// Tüm kategorileri getiren use case
class GetCategoriesUseCase implements UseCase<List<Category>> {
  final CategoryRepository repository;

  const GetCategoriesUseCase(this.repository);

  @override
  Future<List<Category>> call() async {
    return await repository.getCategories();
  }
}