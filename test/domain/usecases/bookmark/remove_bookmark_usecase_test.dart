import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:haber_merkezi/domain/usecases/bookmark/remove_bookmark_usecase.dart';

import '../../../helpers/mock_services.dart';

void main() {
  late RemoveBookmarkUseCase useCase;
  late MockBookmarkRepository mockRepository;

  setUp(() {
    mockRepository = MockBookmarkRepository();
    useCase = RemoveBookmarkUseCase(mockRepository);
  });

  group('RemoveBookmarkUseCase', () {
    test('başarılı bookmark silme', () async {
      // Arrange
      when(() => mockRepository.removeBookmark('article-123'))
          .thenAnswer((_) async {});

      // Act
      await useCase.call('article-123');

      // Assert
      verify(() => mockRepository.removeBookmark('article-123')).called(1);
    });

    test('repository hata fırlatırsa exception fırlatmalı', () async {
      // Arrange
      when(() => mockRepository.removeBookmark(any()))
          .thenThrow(Exception('Silme hatası'));

      // Act & Assert
      expect(() => useCase.call('article-123'), throwsException);
    });
  });
}