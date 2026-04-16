import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:haber_merkezi/domain/usecases/bookmark/get_bookmarks_usecase.dart';

import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetBookmarksUseCase useCase;
  late MockBookmarkRepository mockRepository;

  setUp(() {
    mockRepository = MockBookmarkRepository();
    useCase = GetBookmarksUseCase(mockRepository);
  });

  group('GetBookmarksUseCase', () {
    test('boş liste döndürmeli - bookmark yoksa', () async {
      // Arrange
      when(() => mockRepository.getBookmarks())
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getBookmarks()).called(1);
    });

    test('dolu liste döndürmeli - bookmark varsa', () async {
      // Arrange
      final articles = createTestArticleList(3);
      when(() => mockRepository.getBookmarks())
          .thenAnswer((_) async => articles);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, hasLength(3));
      expect(result, articles);
      verify(() => mockRepository.getBookmarks()).called(1);
    });

    test('repository hata fırlatırsa exception fırlatmalı', () async {
      // Arrange
      when(() => mockRepository.getBookmarks())
          .thenThrow(Exception('Veritabanı hatası'));

      // Act & Assert
      expect(() => useCase.call(), throwsException);
    });
  });
}