import 'package:flutter/material.dart';

/// Rose Pink tema renkleri
class RosePinkTheme {
  RosePinkTheme._();

  // Ana renkler
  static const Color primary = Color(0xFFE91E63);
  static const Color primaryLight = Color(0xFFFF6090);
  static const Color primaryDark = Color(0xFFB0003A);
  static const Color accent = Color(0xFFF06292);

  // Yüzey renkleri - Light
  static const Color lightSurface = Color(0xFFFFF5F8);
  static const Color lightBackground = Color(0xFFFCE4EC);
  static const Color lightSurfaceVariant = Color(0xFFF8BBD9);

  // Yüzey renkleri - Dark
  static const Color darkSurface = Color(0xFF1A0D12);
  static const Color darkBackground = Color(0xFF12080C);
  static const Color darkSurfaceVariant = Color(0xFF2E1A22);

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
  static String get name => 'Gül Pembesi';

  /// Tema açıklaması
  static String get description => 'Zarif ve romantik gül pembesi tonları';

  /// Tema önizleme rengi
  static Color get previewColor => primary;
}