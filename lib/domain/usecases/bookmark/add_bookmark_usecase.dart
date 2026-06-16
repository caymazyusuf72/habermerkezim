import '../../repositories/bookmark_repository.dart';
import '../usecase.dart';

/// Yer imlerine makale ekleme use case'i
class AddBookmarkUseCase implements VoidUseCaseWithParams<String> {
  final BookmarkRepository repository;

  const AddBookmarkUseCase(this.repository);

  @override
  Future<void> call(String articleId) async {
    return await repository.addBookmark(articleId);
  }
}