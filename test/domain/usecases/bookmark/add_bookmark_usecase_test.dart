import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:haber_merkezi/domain/usecases/bookmark/add_bookmark_usecase.dart';

import '../../../helpers/mock_services.dart';

void main() {
  late AddBookmarkUseCase useCase;
  late MockBookmarkRepository mockRepository;

  setUp(() {
    mockRepository = MockBookmarkRepository();
    useCase = AddBookmarkUseCase(mockRepository);
  });

  group('AddBookmarkUseCase', () {
    test('başarılı bookmark ekleme', () async {
      // Arrange
      when(
        () => mockRepository.addBookmark('article-123'),
      ).thenAnswer((_) async {});

      // Act
      await useCase.call('article-123');

      // Assert
      verify(() => mockRepository.addBookmark('article-123')).called(1);
    });

    test('repository hata fırlatırsa exception fırlatmalı', () async {
      // Arrange
      when(
        () => mockRepository.addBookmark(any()),
      ).thenThrow(Exception('Bookmark ekleme hatası'));

      // Act & Assert
      expect(() => useCase.call('article-123'), throwsException);
    });

    test('boş articleId ile çağrılabilmeli', () async {
      // Arrange
      when(() => mockRepository.addBookmark('')).thenAnswer((_) async {});

      // Act
      await useCase.call('');

      // Assert
      verify(() => mockRepository.addBookmark('')).called(1);
    });
  });
}
