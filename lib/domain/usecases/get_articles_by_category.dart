import '../entities/article.dart';
import '../repositories/news_repository.dart';
import 'usecase.dart';

/// Kategoriye göre haberleri getiren use case
class GetArticlesByCategory
    implements UseCaseWithParams<List<Article>, String> {
  final NewsRepository repository;

  const GetArticlesByCategory(this.repository);

  @override
  Future<List<Article>> call(String category) async {
    return await repository.getArticlesByCategory(category);
  }
}

/// Kategoriye göre haberleri stream olarak dinleyen use case
class WatchArticlesByCategory
    implements StreamUseCaseWithParams<List<Article>, String> {
  final NewsRepository repository;

  const WatchArticlesByCategory(this.repository);

  @override
  Stream<List<Article>> call(String category) {
    return repository.watchArticlesByCategory(category);
  }
}
