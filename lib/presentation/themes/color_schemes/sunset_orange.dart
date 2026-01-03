import 'package:flutter/material.dart';

/// Sunset Orange tema renkleri
class SunsetOrangeTheme {
  SunsetOrangeTheme._();

  // Ana renkler
  static const Color primary = Color(0xFFE65100);
  static const Color primaryLight = Color(0xFFFF833A);
  static const Color primaryDark = Color(0xFFAC1900);
  static const Color accent = Color(0xFFFF6D00);

  // Yüzey renkleri - Light
  static const Color lightSurface = Color(0xFFFFFAF5);
  static const Color lightBackground = Color(0xFFFFF3E0);
  static const Color lightSurfaceVariant = Color(0xFFFFE0B2);

  // Yüzey renkleri - Dark
  static const Color darkSurface = Color(0xFF1A0D00);
  static const Color darkBackground = Color(0xFF120800);
  static const Color darkSurfaceVariant = Color(0xFF2E1A00);

  // Metin renkleri
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryLight = Colors.black;
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
  static String get name => 'Gün Batımı';

  /// Tema açıklaması
  static String get description => 'Sıcak ve enerjik gün batımı turuncu tonları';

  /// Tema önizleme rengi
  static Color get previewColor => primary;
}