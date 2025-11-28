import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/hive_service.dart';
import '../themes/app_theme.dart';

/// Theme state - dark/light mode, color theme ve font scale durumunu yönetir
class ThemeState {
  final ThemeMode themeMode;
  final bool isDarkMode;
  final double fontScale;
  final AppTheme.ColorTheme colorTheme;
  
  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.isDarkMode = false,
    this.fontScale = 1.0,
    this.colorTheme = AppTheme.ColorTheme.defaultTheme,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isDarkMode,
    double? fontScale,
    AppTheme.ColorTheme? colorTheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontScale: fontScale ?? this.fontScale,
      colorTheme: colorTheme ?? this.colorTheme,
    );
  }

  @override
  String toString() {
    return 'ThemeState{themeMode: $themeMode, isDarkMode: $isDarkMode, fontScale: $fontScale, colorTheme: $colorTheme}';
  }
}

/// Theme StateNotifier - tema state'ini yöneten sınıf
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'theme_mode';
  static const String _fontScaleKey = 'font_scale';
  static const String _colorThemeKey = 'color_theme';
  
  ThemeNotifier() : super(const ThemeState()) {
    _loadThemeFromStorage();
  }

  /// Local storage'dan tema ayarını yükler
  Future<void> _loadThemeFromStorage() async {
    try {
      final savedTheme = HiveService.settingsBox.get(_themeKey, defaultValue: 'light') as String;
      final savedFontScale = HiveService.settingsBox.get(_fontScaleKey, defaultValue: 1.0) as double;
      final savedColorTheme = HiveService.settingsBox.get(_colorThemeKey, defaultValue: 'default') as String;
      
      final themeMode = _stringToThemeMode(savedTheme);
      final colorTheme = _stringToColorTheme(savedColorTheme);
      
      // System mode için sistem temasını kontrol et
      bool isDarkMode = false;
      if (themeMode == ThemeMode.system) {
        isDarkMode = _getSystemBrightness() == Brightness.dark;
      } else {
        isDarkMode = themeMode == ThemeMode.dark;
      }
      
      state = state.copyWith(
        themeMode: themeMode,
        isDarkMode: isDarkMode,
        fontScale: savedFontScale,
        colorTheme: colorTheme,
      );
    } catch (e) {
      // Storage error durumunda default kullan
      print('Theme yükleme hatası: $e');
    }
  }

  /// Sistem parlaklık modunu alır
  Brightness _getSystemBrightness() {
    try {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    } catch (e) {
      return Brightness.light; // Default
    }
  }

  /// Light mode'a geçer
  Future<void> setLightMode() async {
    await _updateTheme(ThemeMode.light, false);
  }

  /// Dark mode'a geçer
  Future<void> setDarkMode() async {
    await _updateTheme(ThemeMode.dark, true);
  }

  /// Renk temasını ayarlar
  Future<void> setColorTheme(AppTheme.ColorTheme colorTheme) async {
    state = state.copyWith(colorTheme: colorTheme);
    
    try {
      await HiveService.settingsBox.put(_colorThemeKey, _colorThemeToString(colorTheme));
    } catch (e) {
      print('Color theme kaydetme hatası: $e');
    }
  }
  
  /// ColorTheme'u string'e çevirir
  String _colorThemeToString(AppTheme.ColorTheme colorTheme) {
    switch (colorTheme) {
      case AppTheme.ColorTheme.defaultTheme:
        return 'default';
      case AppTheme.ColorTheme.oceanBlue:
        return 'oceanBlue';
      case AppTheme.ColorTheme.springRed:
        return 'springRed';
      case AppTheme.ColorTheme.purple:
        return 'purple';
      case AppTheme.ColorTheme.amber:
        return 'amber';
    }
  }
  
  /// String'i ColorTheme'a çevirir
  AppTheme.ColorTheme _stringToColorTheme(String themeString) {
    switch (themeString) {
      case 'oceanBlue':
        return AppTheme.ColorTheme.oceanBlue;
      case 'springRed':
        return AppTheme.ColorTheme.springRed;
      case 'purple':
        return AppTheme.ColorTheme.purple;
      case 'amber':
        return AppTheme.ColorTheme.amber;
      case 'default':
      default:
        return AppTheme.ColorTheme.defaultTheme;
    }
  }

  /// Theme'i toggle eder (light <-> dark)
  Future<void> toggleTheme() async {
    if (state.themeMode == ThemeMode.dark) {
      await setLightMode();
    } else if (state.themeMode == ThemeMode.light) {
      await setDarkMode();
    } else {
      // System mode'daysa dark'a geç
      await setDarkMode();
    }
  }

  /// Font boyutunu ayarlar
  Future<void> setFontScale(double scale) async {
    // Font scale değerini 0.8 - 1.6 arasında sınırla
    final clampedScale = scale.clamp(0.8, 1.6);
    
    state = state.copyWith(fontScale: clampedScale);
    
    try {
      await HiveService.settingsBox.put(_fontScaleKey, clampedScale);
    } catch (e) {
      print('Font scale kaydetme hatası: $e');
    }
  }

  /// Font boyutunu küçük yapar (0.8x)
  Future<void> setSmallFont() async {
    await setFontScale(0.8);
  }

  /// Font boyutunu normal yapar (1.0x)
  Future<void> setNormalFont() async {
    await setFontScale(1.0);
  }

  /// Font boyutunu büyük yapar (1.2x)
  Future<void> setLargeFont() async {
    await setFontScale(1.2);
  }

  /// Font boyutunu çok büyük yapar (1.4x)
  Future<void> setExtraLargeFont() async {
    await setFontScale(1.4);
  }

  /// Theme'i günceller ve storage'a kaydeder
  Future<void> _updateTheme(ThemeMode themeMode, bool isDarkMode) async {
    state = state.copyWith(
      themeMode: themeMode,
      isDarkMode: isDarkMode,
    );

    try {
      await HiveService.settingsBox.put(_themeKey, _themeModeToString(themeMode));
    } catch (e) {
      print('Theme kaydetme hatası: $e');
    }
  }

  /// ThemeMode'u string'e çevirir
  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// String'i ThemeMode'a çevirir
  ThemeMode _stringToThemeMode(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light; // Default light mode
    }
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// Current theme mode provider
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.themeMode;
});

/// Is dark mode provider - sistem temasını da kontrol eder
final isDarkModeProvider = Provider<bool>((ref) {
  final themeState = ref.watch(themeProvider);
  
  // System mode ise sistem temasını kontrol et
  if (themeState.themeMode == ThemeMode.system) {
    try {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    } catch (e) {
      return false; // Default to light
    }
  }
  
  return themeState.isDarkMode;
});

/// Font scale provider
final fontScaleProvider = Provider<double>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.fontScale;
});

/// Color theme provider
final colorThemeProvider = Provider<AppTheme.ColorTheme>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.colorTheme;
});