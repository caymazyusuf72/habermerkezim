import '../repositories/news_repository.dart';
import 'usecase.dart';

/// Makale favori durumunu değiştiren use case
class ToggleArticleFavorite implements VoidUseCaseWithParams<String> {
  final NewsRepository repository;

  const ToggleArticleFavorite(this.repository);

  @override
  Future<void> call(String articleId) async {
    await repository.toggleFavorite(articleId);
  }
}
