import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/onboarding_service.dart';
import '../../domain/repositories/interest_tags_repository.dart';
import '../../data/repositories/interest_tags_repository_impl.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/entities/user_profile.dart';
import 'providers.dart';

/// Onboarding state - seçilen hashtag'leri tutar
class OnboardingState {
  final List<String> selectedTagIds;
  final bool isLoading;
  final String? errorMessage;

  const OnboardingState({
    this.selectedTagIds = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    List<String>? selectedTagIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      selectedTagIds: selectedTagIds ?? this.selectedTagIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  bool get canProceed => selectedTagIds.length >= 3;
  int get selectedCount => selectedTagIds.length;
}

/// Onboarding notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final InterestTagsRepository _tagsRepository;
  final UserProfileRepository _profileRepository;

  OnboardingNotifier(
    this._tagsRepository,
    this._profileRepository,
  ) : super(const OnboardingState());

  /// Hashtag seç/seçimi kaldır
  void toggleTag(String tagId) {
    final current = List<String>.from(state.selectedTagIds);
    
    if (current.contains(tagId)) {
      current.remove(tagId);
    } else {
      current.add(tagId);
    }

    state = state.copyWith(selectedTagIds: current);
  }

  /// Onboarding'i tamamla ve seçilen tag'leri kaydet
  Future<bool> completeOnboarding() async {
    if (!state.canProceed) {
      state = state.copyWith(
        errorMessage: 'Lütfen en az 3 ilgi alanı seçin',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Seçilen tag'leri repository'ye kaydet
      await _tagsRepository.saveUserInterestTags(state.selectedTagIds);

      // 2. UserProfile'a interestTags ekle
      final profile = await _profileRepository.getProfile();
      if (profile case final existingProfile?) {
        final updatedPreferences = existingProfile.preferences.copyWith(
          interestTags: state.selectedTagIds,
        );
        await _profileRepository.updatePreferences(updatedPreferences);
      } else {
        // Profil yoksa oluştur
        final defaultProfile = UserProfile.defaultProfile.copyWith(
          preferences: UserPreferences.defaultPreferences.copyWith(
            interestTags: state.selectedTagIds,
          ),
        );
        await _profileRepository.saveProfile(defaultProfile);
      }

      // 3. Onboarding'i tamamlandı olarak işaretle
      await OnboardingService.completeOnboarding();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Bir hata oluştu: ${e.toString()}',
      );
      return false;
    }
  }

  /// Hata durumunu temizle
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Onboarding provider
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(
    InterestTagsRepositoryImpl(),
    ref.read(userProfileRepositoryProvider),
  );
});

/// Onboarding tamamlanmış mı kontrol provider'ı
final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  return await OnboardingService.hasCompletedOnboarding();
});

