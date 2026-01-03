import 'package:flutter/material.dart';

/// Monochrome tema renkleri - Siyah-beyaz minimalist tema
class MonochromeTheme {
  MonochromeTheme._();

  // Ana renkler
  static const Color primary = Color(0xFF212121);
  static const Color primaryLight = Color(0xFF484848);
  static const Color primaryDark = Color(0xFF000000);
  static const Color accent = Color(0xFF616161);

  // Yüzey renkleri - Light
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);

  // Yüzey renkleri - Dark (OLED Black)
  static const Color darkSurface = Color(0xFF000000);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurfaceVariant = Color(0xFF121212);

  // Metin renkleri
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryLight = Colors.white;
  static const Color onPrimaryDark = Colors.white;

  /// Light tema ColorScheme
  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFE0E0E0),
        onPrimaryContainer: Color(0xFF212121),
        secondary: accent,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFEEEEEE),
        onSecondaryContainer: Color(0xFF424242),
        tertiary: Color(0xFF757575),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFF5F5F5),
        onTertiaryContainer: Color(0xFF616161),
        error: Color(0xFFB00020),
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        surface: lightSurface,
        onSurface: Color(0xFF212121),
        surfaceContainerHighest: lightSurfaceVariant,
        onSurfaceVariant: Color(0xFF616161),
        outline: Color(0xFFBDBDBD),
        outlineVariant: Color(0xFFE0E0E0),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(0xFF303030),
        onInverseSurface: Colors.white,
        inversePrimary: Color(0xFFE0E0E0),
      );

  /// Dark tema ColorScheme (OLED Black)
  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFE0E0E0),
        onPrimary: Colors.black,
        primaryContainer: Color(0xFF424242),
        onPrimaryContainer: Color(0xFFE0E0E0),
        secondary: Color(0xFFBDBDBD),
        onSecondary: Colors.black,
        secondaryContainer: Color(0xFF303030),
        onSecondaryContainer: Color(0xFFE0E0E0),
        tertiary: Color(0xFF9E9E9E),
        onTertiary: Colors.black,
        tertiaryContainer: Color(0xFF424242),
        onTertiaryContainer: Color(0xFFE0E0E0),
        error: Color(0xFFCF6679),
        onError: Colors.black,
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: darkSurface,
        onSurface: Color(0xFFE0E0E0),
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: Color(0xFF9E9E9E),
        outline: Color(0xFF616161),
        outlineVariant: Color(0xFF424242),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(0xFFE0E0E0),
        onInverseSurface: Color(0xFF212121),
        inversePrimary: Color(0xFF424242),
      );

  /// Tema adı
  static String get name => 'Monokrom';

  /// Tema açıklaması
  static String get description => 'Minimalist siyah-beyaz tema (OLED uyumlu)';

  /// Tema önizleme rengi
  static Color get previewColor => primary;
}