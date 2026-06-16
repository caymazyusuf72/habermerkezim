import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:haber_merkezi/domain/usecases/bookmark/check_bookmark_usecase.dart';

import '../../../helpers/mock_services.dart';

void main() {
  late CheckBookmarkUseCase useCase;
  late MockBookmarkRepository mockRepository;

  setUp(() {
    mockRepository = MockBookmarkRepository();
    useCase = CheckBookmarkUseCase(mockRepository);
  });

  group('CheckBookmarkUseCase', () {
    test('bookmark varsa true döndürmeli', () async {
      // Arrange
      when(
        () => mockRepository.isBookmarked('article-123'),
      ).thenAnswer((_) async => true);

      // Act
      final result = await useCase.call('article-123');

      // Assert
      expect(result, true);
      verify(() => mockRepository.isBookmarked('article-123')).called(1);
    });

    test('bookmark yoksa false döndürmeli', () async {
      // Arrange
      when(
        () => mockRepository.isBookmarked('article-456'),
      ).thenAnswer((_) async => false);

      // Act
      final result = await useCase.call('article-456');

      // Assert
      expect(result, false);
    });

    test('repository hata fırlatırsa exception fırlatmalı', () async {
      // Arrange
      when(
        () => mockRepository.isBookmarked(any()),
      ).thenThrow(Exception('Kontrol hatası'));

      // Act & Assert
      expect(() => useCase.call('article-123'), throwsException);
    });
  });
}
