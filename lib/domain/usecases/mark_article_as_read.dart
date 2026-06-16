import '../repositories/news_repository.dart';
import 'usecase.dart';

/// Makaleyi okundu olarak işaretleyen use case
class MarkArticleAsRead implements VoidUseCaseWithParams<String> {
  final NewsRepository repository;

  const MarkArticleAsRead(this.repository);

  @override
  Future<void> call(String articleId) async {
    await repository.markAsRead(articleId);
  }
}
