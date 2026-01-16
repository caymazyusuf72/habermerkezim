import 'package:flutter/material.dart';

/// Forest Green tema renkleri
class ForestGreenTheme {
  ForestGreenTheme._();

  // Ana renkler
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);
  static const Color accent = Color(0xFF43A047);

  // Yüzey renkleri - Light
  static const Color lightSurface = Color(0xFFF5FFF5);
  static const Color lightBackground = Color(0xFFEDF7ED);
  static const Color lightSurfaceVariant = Color(0xFFE0F2E0);

  // Yüzey renkleri - Dark
  static const Color darkSurface = Color(0xFF0D1A0D);
  static const Color darkBackground = Color(0xFF081208);
  static const Color darkSurfaceVariant = Color(0xFF1A2E1A);

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
  static String get name => 'Orman Yeşili';

  /// Tema açıklaması
  static String get description => 'Doğal ve huzur verici orman yeşili tonları';

  /// Tema önizleme rengi
  static Color get previewColor => primary;
}