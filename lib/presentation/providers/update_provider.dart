import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/update_service.dart';

/// UpdateService provider
final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

/// Güncelleme kontrolü sonucu state
class UpdateCheckState {
  final bool isLoading;
  final UpdateCheckResult? result;
  final String? error;

  UpdateCheckState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  UpdateCheckState copyWith({
    bool? isLoading,
    UpdateCheckResult? result,
    String? error,
  }) {
    return UpdateCheckState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}

/// Güncelleme kontrolü state provider
final updateCheckProvider = StateNotifierProvider<UpdateCheckNotifier, UpdateCheckState>((ref) {
  return UpdateCheckNotifier(ref.read(updateServiceProvider));
});

/// Güncelleme kontrolü notifier
class UpdateCheckNotifier extends StateNotifier<UpdateCheckState> {
  final UpdateService _updateService;

  UpdateCheckNotifier(this._updateService) : super(UpdateCheckState());

  /// Güncelleme kontrolü yap
  Future<void> checkForUpdates() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // UpdateService'i initialize et
      await _updateService.initialize();

      // Güncelleme kontrolü yap
      final result = await _updateService.checkForUpdates();

      state = state.copyWith(
        isLoading: false,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// State'i sıfırla
  void reset() {
    state = UpdateCheckState();
  }
}

/// Future provider ile güncelleme kontrolü (otomatik)
final checkForUpdatesProvider = FutureProvider<UpdateCheckResult?>((ref) async {
  final updateService = ref.read(updateServiceProvider);
  
  try {
    await updateService.initialize();
    final result = await updateService.checkForUpdates();
    
    // Güncelleme yoksa null döndür
    if (result.type == UpdateType.none) {
      return null;
    }
    
    return result;
  } catch (e) {
    print('⚠️ Güncelleme kontrolü hatası: $e');
    return null;
  }
});

