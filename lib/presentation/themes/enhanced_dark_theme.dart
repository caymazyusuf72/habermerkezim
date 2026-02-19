import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gelişmiş Dark Mode tema
/// True Black (OLED) desteği ve smooth transitions
class EnhancedDarkTheme {
  // True Black mode için renkler
  static const Color truBlackBackground = Color(0xFF000000);
  static const Color trueBlackSurface = Color(0xFF0A0A0A);
  static const Color trueBlackSurfaceVariant = Color(0xFF121212);
  
  // Standard dark mode renkleri
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

  /// True Black (OLED) tema oluştur
  static ThemeData createTrueBlackTheme({
    required ColorScheme colorScheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme.copyWith(
        surface: truBlackBackground,
        surfaceContainerHighest: trueBlackSurfaceVariant,
        surfaceContainer: trueBlackSurface,
      ),
      scaffoldBackgroundColor: truBlackBackground,
      cardTheme: CardThemeData(
        color: trueBlackSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: truBlackBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: trueBlackSurface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.white.withValues(alpha: 0.6),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: trueBlackSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: trueBlackSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.1),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }

  /// Standard dark tema oluştur
  static ThemeData createStandardDarkTheme({
    required ColorScheme colorScheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme.copyWith(
        surface: darkBackground,
        surfaceContainerHighest: darkSurfaceVariant,
        surfaceContainer: darkSurface,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.white.withValues(alpha: 0.6),
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.12),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }

  /// Accent color customization için color schemes
  static ColorScheme blueAccentDark = const ColorScheme.dark(
    primary: Color(0xFF64B5F6),
    primaryContainer: Color(0xFF1976D2),
    secondary: Color(0xFF81C784),
    secondaryContainer: Color(0xFF388E3C),
    tertiary: Color(0xFFFFB74D),
    error: Color(0xFFEF5350),
    surface: darkBackground,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
  );

  static ColorScheme purpleAccentDark = const ColorScheme.dark(
    primary: Color(0xFFBA68C8),
    primaryContainer: Color(0xFF7B1FA2),
    secondary: Color(0xFF9575CD),
    secondaryContainer: Color(0xFF512DA8),
    tertiary: Color(0xFFFFB74D),
    error: Color(0xFFEF5350),
    surface: darkBackground,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
  );

  static ColorScheme greenAccentDark = const ColorScheme.dark(
    primary: Color(0xFF81C784),
    primaryContainer: Color(0xFF388E3C),
    secondary: Color(0xFF64B5F6),
    secondaryContainer: Color(0xFF1976D2),
    tertiary: Color(0xFFFFB74D),
    error: Color(0xFFEF5350),
    surface: darkBackground,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
  );

  static ColorScheme orangeAccentDark = const ColorScheme.dark(
    primary: Color(0xFFFFB74D),
    primaryContainer: Color(0xFFF57C00),
    secondary: Color(0xFFEF5350),
    secondaryContainer: Color(0xFFC62828),
    tertiary: Color(0xFF64B5F6),
    error: Color(0xFFEF5350),
    surface: darkBackground,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
  );
}

/// Dark mode türleri
enum DarkModeType {
  standard,
  trueBlack,
}

/// Accent color türleri
enum AccentColorType {
  blue,
  purple,
  green,
  orange,
}

/// Dark mode ayarları için model
class DarkModeSettings {
  final DarkModeType type;
  final AccentColorType accentColor;
  final bool smoothTransitions;

  const DarkModeSettings({
    this.type = DarkModeType.standard,
    this.accentColor = AccentColorType.blue,
    this.smoothTransitions = true,
  });

  DarkModeSettings copyWith({
    DarkModeType? type,
    AccentColorType? accentColor,
    bool? smoothTransitions,
  }) {
    return DarkModeSettings(
      type: type ?? this.type,
      accentColor: accentColor ?? this.accentColor,
      smoothTransitions: smoothTransitions ?? this.smoothTransitions,
    );
  }

  ColorScheme getColorScheme() {
    switch (accentColor) {
      case AccentColorType.blue:
        return EnhancedDarkTheme.blueAccentDark;
      case AccentColorType.purple:
        return EnhancedDarkTheme.purpleAccentDark;
      case AccentColorType.green:
        return EnhancedDarkTheme.greenAccentDark;
      case AccentColorType.orange:
        return EnhancedDarkTheme.orangeAccentDark;
    }
  }

  ThemeData getTheme() {
    final colorScheme = getColorScheme();
    
    switch (type) {
      case DarkModeType.standard:
        return EnhancedDarkTheme.createStandardDarkTheme(
          colorScheme: colorScheme,
        );
      case DarkModeType.trueBlack:
        return EnhancedDarkTheme.createTrueBlackTheme(
          colorScheme: colorScheme,
        );
    }
  }
}

/// Smooth theme transition widget
class SmoothThemeTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const SmoothThemeTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}
