import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:haber_merkezi/domain/usecases/category/get_categories_usecase.dart';

import '../../../helpers/mock_services.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetCategoriesUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = GetCategoriesUseCase(mockRepository);
  });

  group('GetCategoriesUseCase', () {
    test('kategori listesi döndürmeli', () async {
      // Arrange
      final categories = createTestCategoryList(5);
      when(() => mockRepository.getCategories())
          .thenAnswer((_) async => categories);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, hasLength(5));
      expect(result, categories);
      verify(() => mockRepository.getCategories()).called(1);
    });

    test('boş liste döndürmeli - kategori yoksa', () async {
      // Arrange
      when(() => mockRepository.getCategories())
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isEmpty);
    });

    test('repository hata fırlatırsa exception fırlatmalı', () async {
      // Arrange
      when(() => mockRepository.getCategories())
          .thenThrow(Exception('Kategori yükleme hatası'));

      // Act & Assert
      expect(() => useCase.call(), throwsException);
    });
  });
}