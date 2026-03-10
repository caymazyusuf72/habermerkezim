import '../entities/article.dart';
import '../repositories/news_repository.dart';
import 'usecase.dart';

/// Favori makaleleri getiren use case
class GetFavoriteArticles implements UseCase<List<Article>> {
  final NewsRepository repository;

  const GetFavoriteArticles(this.repository);

  @override
  Future<List<Article>> call() async {
    return await repository.getFavoriteArticles();
  }
}