import '../../repositories/settings_repository.dart';
import '../usecase.dart';

/// Tüm ayarları getiren use case
class GetSettingsUseCase implements UseCase<Map<String, dynamic>> {
  final SettingsRepository repository;

  const GetSettingsUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call() async {
    return await repository.getSettings();
  }
}
