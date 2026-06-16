import 'package:flutter/material.dart';

/// Tutarlı shadow tanımları
/// Material Design 3 elevation seviyeleri ile uyumlu
class AppShadows {
  AppShadows._();

  // === Elevation Seviyeleri ===

  /// Elevation 0 - Düz (shadow yok)
  static const List<BoxShadow> none = [];

  /// Elevation 1 - Minimal
  static List<BoxShadow> elevation1(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.08),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Elevation 2 - Hafif
  static List<BoxShadow> elevation2(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.06),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.04),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Elevation 3 - Orta
  static List<BoxShadow> elevation3(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.black.withValues(alpha: 0.06),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Elevation 4 - Yüksek
  static List<BoxShadow> elevation4(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.6)
            : Colors.black.withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.08),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ];
  }

  /// Elevation 5 - En yüksek
  static List<BoxShadow> elevation5(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.7)
            : Colors.black.withValues(alpha: 0.15),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.black.withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // === Özel Shadow Tipleri ===

  /// Kart shadow'u
  static List<BoxShadow> card(BuildContext context) => elevation2(context);

  /// Navigasyon bar shadow'u
  static List<BoxShadow> navigationBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, -2),
      ),
    ];
  }

  /// FAB shadow'u
  static List<BoxShadow> fab(BuildContext context) => elevation4(context);

  /// Bottom sheet shadow'u
  static List<BoxShadow> bottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.6)
            : Colors.black.withValues(alpha: 0.15),
        blurRadius: 20,
        offset: const Offset(0, -5),
      ),
    ];
  }

  /// Renkli shadow (buton vb. için)
  static List<BoxShadow> colored(
    Color color, {
    double opacity = 0.3,
    double blurRadius = 12,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blurRadius,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Soft glow efekti
  static List<BoxShadow> glow(
    Color color, {
    double opacity = 0.2,
    double blurRadius = 20,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blurRadius,
        spreadRadius: 2,
      ),
    ];
  }
}

/// BoxDecoration extension - kolay shadow ekleme
extension ShadowExtension on BoxDecoration {
  BoxDecoration withShadow(List<BoxShadow> shadows) {
    return copyWith(boxShadow: shadows);
  }
}
