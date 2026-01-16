import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Desteklenen diller
enum AppLanguage {
  turkish('tr', 'Türkçe', '🇹🇷'),
  english('en', 'English', '🇬🇧');

  final String code;
  final String name;
  final String flag;

  const AppLanguage(this.code, this.name, this.flag);

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.turkish,
    );
  }
}

/// Locale state
class LocaleState {
  final Locale locale;
  final AppLanguage language;

  const LocaleState({
    required this.locale,
    required this.language,
  });

  factory LocaleState.initial() {
    return const LocaleState(
      locale: Locale('tr'),
      language: AppLanguage.turkish,
    );
  }

  LocaleState copyWith({
    Locale? locale,
    AppLanguage? language,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      language: language ?? this.language,
    );
  }
}

/// Locale notifier
class LocaleNotifier extends StateNotifier<LocaleState> {
  static const String _localeKey = 'app_locale';

  LocaleNotifier() : super(LocaleState.initial()) {
    _loadLocale();
  }

  /// Kaydedilmiş dili yükle
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_localeKey);
      
      if (savedCode != null) {
        final language = AppLanguage.fromCode(savedCode);
        state = LocaleState(
          locale: language.locale,
          language: language,
        );
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }

  /// Dili değiştir
  Future<void> setLocale(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, language.code);
      
      state = LocaleState(
        locale: language.locale,
        language: language,
      );
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Dili toggle et (TR <-> EN)
  Future<void> toggleLocale() async {
    final newLanguage = state.language == AppLanguage.turkish
        ? AppLanguage.english
        : AppLanguage.turkish;
    await setLocale(newLanguage);
  }
}

/// Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleState>((ref) {
  return LocaleNotifier();
});

/// Sadece locale'i izle
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(localeProvider).locale;
});

/// Sadece dili izle
final currentLanguageProvider = Provider<AppLanguage>((ref) {
  return ref.watch(localeProvider).language;
});