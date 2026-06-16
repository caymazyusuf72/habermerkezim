import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:haber_merkezi/domain/usecases/settings/get_theme_usecase.dart';

import '../../../helpers/mock_services.dart';

void main() {
  late GetThemeUseCase useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = GetThemeUseCase(mockRepository);
  });

  group('GetThemeUseCase', () {
    test('light tema bilgisi döndürmeli', () async {
      // Arrange
      when(
        () => mockRepository.getThemeMode(),
      ).thenAnswer((_) async => 'light');

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, 'light');
      verify(() => mockRepository.getThemeMode()).called(1);
    });

    test('dark tema bilgisi döndürmeli', () async {
      // Arrange
      when(() => mockRepository.getThemeMode()).thenAnswer((_) async => 'dark');

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, 'dark');
    });

    test('system tema bilgisi döndürmeli', () async {
      // Arrange
      when(
        () => mockRepository.getThemeMode(),
      ).thenAnswer((_) async => 'system');

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, 'system');
    });

    test('repository hata fırlatırsa exception fırlatmalı', () async {
      // Arrange
      when(
        () => mockRepository.getThemeMode(),
      ).thenThrow(Exception('Tema okuma hatası'));

      // Act & Assert
      expect(() => useCase.call(), throwsException);
    });
  });
}
