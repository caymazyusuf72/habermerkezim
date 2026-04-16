import 'package:flutter/material.dart';

/// Tutarlı text style'ları
/// Her biri light/dark theme desteği ile
class AppTextStyles {
  AppTextStyles._();

  // === Headline Styles ===
  static TextStyle headlineLarge(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineLarge ?? const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineMedium ?? const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 1.3,
    );
  }

  static TextStyle headlineSmall(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineSmall ?? const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );
  }

  // === Title Styles ===
  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge ?? const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium ?? const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    );
  }

  static TextStyle titleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall ?? const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );
  }

  // === Body Styles ===
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge ?? const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.6,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ?? const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall ?? const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.4,
    );
  }

  // === Caption & Label Styles ===
  static TextStyle caption(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall?.copyWith(
      fontSize: 11,
      letterSpacing: 0.4,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    ) ?? const TextStyle(fontSize: 11);
  }

  static TextStyle labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge ?? const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );
  }

  static TextStyle labelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium ?? const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    );
  }

  static TextStyle labelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall ?? const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    );
  }

  // === Özel Stiller ===

  /// Haber başlığı stili
  static TextStyle articleTitle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.3,
    ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  }

  /// Haber açıklama stili
  static TextStyle articleDescription(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium?.copyWith(
      height: 1.5,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
    ) ?? const TextStyle(fontSize: 14);
  }

  /// Kategori badge stili
  static TextStyle categoryBadge(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ) ?? const TextStyle(fontSize: 10, fontWeight: FontWeight.w700);
  }

  /// Zaman stili (3 dk önce gibi)
  static TextStyle timestamp(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      fontSize: 11,
    ) ?? const TextStyle(fontSize: 11);
  }

  /// Kaynak adı stili
  static TextStyle sourceName(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.primary,
    ) ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
  }

  /// Buton text stili
  static TextStyle button(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ) ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  }

  /// Sayaç stili (gamification)
  static TextStyle counter(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.primary,
    ) ?? const TextStyle(fontSize: 32, fontWeight: FontWeight.w800);
  }
}