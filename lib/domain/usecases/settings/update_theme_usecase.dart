import '../../repositories/settings_repository.dart';
import '../usecase.dart';

/// Tema modunu güncelleme use case'i
class UpdateThemeUseCase implements VoidUseCaseWithParams<String> {
  final SettingsRepository repository;

  const UpdateThemeUseCase(this.repository);

  @override
  Future<void> call(String themeMode) async {
    return await repository.updateThemeMode(themeMode);
  }
}
