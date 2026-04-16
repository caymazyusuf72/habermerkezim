import '../../repositories/settings_repository.dart';
import '../usecase.dart';

/// Tema modunu getiren use case
class GetThemeUseCase implements UseCase<String> {
  final SettingsRepository repository;

  const GetThemeUseCase(this.repository);

  @override
  Future<String> call() async {
    return await repository.getThemeMode();
  }
}