import '../entities/article.dart';
import '../repositories/news_repository.dart';
import 'usecase.dart';

/// Tüm haberleri getiren use case
class GetAllArticles implements UseCase<List<Article>> {
  final NewsRepository repository;

  const GetAllArticles(this.repository);

  @override
  Future<List<Article>> call() async {
    return await repository.getAllArticles();
  }
}

/// Tüm haberleri stream olarak dinleyen use case
class WatchAllArticles implements StreamUseCase<List<Article>> {
  final NewsRepository repository;

  const WatchAllArticles(this.repository);

  @override
  Stream<List<Article>> call() {
    return repository.watchAllArticles();
  }
}