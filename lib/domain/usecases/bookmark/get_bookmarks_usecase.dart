import '../../entities/article.dart';
import '../../repositories/bookmark_repository.dart';
import '../usecase.dart';

/// Tüm yer imli makaleleri getiren use case
class GetBookmarksUseCase implements UseCase<List<Article>> {
  final BookmarkRepository repository;

  const GetBookmarksUseCase(this.repository);

  @override
  Future<List<Article>> call() async {
    return await repository.getBookmarks();
  }
}