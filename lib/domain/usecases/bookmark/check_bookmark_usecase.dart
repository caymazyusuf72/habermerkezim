import '../../repositories/bookmark_repository.dart';
import '../usecase.dart';

/// Makale yer imlerinde mi kontrol eden use case
class CheckBookmarkUseCase implements UseCaseWithParams<bool, String> {
  final BookmarkRepository repository;

  const CheckBookmarkUseCase(this.repository);

  @override
  Future<bool> call(String articleId) async {
    return await repository.isBookmarked(articleId);
  }
}