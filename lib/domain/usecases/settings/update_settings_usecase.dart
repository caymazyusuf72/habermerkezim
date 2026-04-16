import '../../repositories/settings_repository.dart';
import '../usecase.dart';

/// Ayar güncelleme parametreleri
class UpdateSettingsParams {
  final String key;
  final dynamic value;

  const UpdateSettingsParams({required this.key, required this.value});
}

/// Ayarları güncelleme use case'i
class UpdateSettingsUseCase implements VoidUseCaseWithParams<UpdateSettingsParams> {
  final SettingsRepository repository;

  const UpdateSettingsUseCase(this.repository);

  @override
  Future<void> call(UpdateSettingsParams params) async {
    return await repository.updateSetting(params.key, params.value);
  }
}