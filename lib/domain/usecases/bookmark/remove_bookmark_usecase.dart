import '../../repositories/bookmark_repository.dart';
import '../usecase.dart';

/// Yer imlerinden makale çıkarma use case'i
class RemoveBookmarkUseCase implements VoidUseCaseWithParams<String> {
  final BookmarkRepository repository;

  const RemoveBookmarkUseCase(this.repository);

  @override
  Future<void> call(String articleId) async {
    return await repository.removeBookmark(articleId);
  }
}