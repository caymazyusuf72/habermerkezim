import 'package:flutter/material.dart';

/// Midnight Blue tema renkleri
class MidnightBlueTheme {
  MidnightBlueTheme._();

  // Ana renkler
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF534BAE);
  static const Color primaryDark = Color(0xFF000051);
  static const Color accent = Color(0xFF3949AB);

  // Yüzey renkleri - Light
  static const Color lightSurface = Color(0xFFF8F9FF);
  static const Color lightBackground = Color(0xFFF0F2FF);
  static const Color lightSurfaceVariant = Color(0xFFE8EAFF);

  // Yüzey renkleri - Dark
  static const Color darkSurface = Color(0xFF0D1033);
  static const Color darkBackground = Color(0xFF080A1A);
  static const Color darkSurfaceVariant = Color(0xFF1A1D4A);

  // Metin renkleri
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryLight = Colors.white;
  static const Color onPrimaryDark = Colors.white;

  /// Light tema ColorScheme
  static ColorScheme get lightColorScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: primaryLight,
        surface: lightSurface,
        error: const Color(0xFFB00020),
      );

  /// Dark tema ColorScheme
  static ColorScheme get darkColorScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primaryLight,
        secondary: accent,
        surface: darkSurface,
        error: const Color(0xFFCF6679),
      );

  /// Tema adı
  static String get name => 'Gece Mavisi';

  /// Tema açıklaması
  static String get description => 'Derin ve sakin gece mavisi tonları';

  /// Tema önizleme rengi
  static Color get previewColor => primary;
}