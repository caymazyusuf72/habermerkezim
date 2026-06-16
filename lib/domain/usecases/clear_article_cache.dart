import '../repositories/news_repository.dart';
import 'usecase.dart';

/// Makale cache'ini temizleyen use case
class ClearArticleCache implements VoidUseCase {
  final NewsRepository repository;

  const ClearArticleCache(this.repository);

  @override
  Future<void> call() async {
    await repository.clearCache();
  }
}
