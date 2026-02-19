import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gelişmiş tipografi sistemi
/// Responsive font sizes ve text hierarchy
class EnhancedTextStyles {
  // Base font family
  static String get fontFamily => GoogleFonts.inter().fontFamily!;
  static String get headingFontFamily => GoogleFonts.poppins().fontFamily!;
  
  // Font sizes - Material Design 3 Type Scale
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;

  // Responsive font size helper
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1200) {
      // Desktop
      return baseSize * 1.1;
    } else if (width >= 600) {
      // Tablet
      return baseSize * 1.05;
    } else {
      // Mobile
      return baseSize;
    }
  }

  // Text styles with responsive sizing
  static TextStyle displayLargeStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getResponsiveFontSize(context, displayLarge),
      fontWeight: FontWeight.w700,
      height: 1.12,
      letterSpacing: -0.25,
      color: color,
    );
  }

  static TextStyle displayMediumStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getResponsiveFontSize(context, displayMedium),
      fontWeight: FontWeight.w700,
      height: 1.16,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle displaySmallStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getResponsiveFontSize(context, displaySmall),
      fontWeight: FontWeight.w600,
      height: 1.22,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle headlineLargeStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getResponsiveFontSize(context, headlineLarge),
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle headlineMediumStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getResponsiveFontSize(context, headlineMedium),
      fontWeight: FontWeight.w600,
      height: 1.29,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle headlineSmallStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: getResponsiveFontSize(context, headlineSmall),
      fontWeight: FontWeight.w600,
      height: 1.33,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle titleLargeStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getResponsiveFontSize(context, titleLarge),
      fontWeight: FontWeight.w600,
      height: 1.27,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle titleMediumStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getResponsiveFontSize(context, titleMedium),
      fontWeight: FontWeight.w600,
      height: 1.5,
      letterSpacing: 0.15,
      color: color,
    );
  }

  static TextStyle titleSmallStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getResponsiveFontSize(context, titleSmall),
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.1,
      color: color,
    );
  }

  static TextStyle bodyLargeStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getResponsiveFontSize(context, bodyLarge),
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.5,
      color: color,
    );
  }

  static TextStyle bodyMediumStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getResponsiveFontSize(context, bodyMedium),
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.25,
      color: color,
    );
  }

  static TextStyle bodySmallStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getResponsiveFontSize(context, bodySmall),
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4,
      color: color,
    );
  }

  static TextStyle labelLargeStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getResponsiveFontSize(context, labelLarge),
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: 0.1,
      color: color,
    );
  }

  static TextStyle labelMediumStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getResponsiveFontSize(context, labelMedium),
      fontWeight: FontWeight.w500,
      height: 1.33,
      letterSpacing: 0.5,
      color: color,
    );
  }

  static TextStyle labelSmallStyle(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: getResponsiveFontSize(context, labelSmall),
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: 0.5,
      color: color,
    );
  }

  // Create TextTheme for app
  static TextTheme createTextTheme(BuildContext context, {required Brightness brightness}) {
    final color = brightness == Brightness.dark ? Colors.white : Colors.black;
    
    return TextTheme(
      displayLarge: displayLargeStyle(context, color: color),
      displayMedium: displayMediumStyle(context, color: color),
      displaySmall: displaySmallStyle(context, color: color),
      headlineLarge: headlineLargeStyle(context, color: color),
      headlineMedium: headlineMediumStyle(context, color: color),
      headlineSmall: headlineSmallStyle(context, color: color),
      titleLarge: titleLargeStyle(context, color: color),
      titleMedium: titleMediumStyle(context, color: color),
      titleSmall: titleSmallStyle(context, color: color),
      bodyLarge: bodyLargeStyle(context, color: color),
      bodyMedium: bodyMediumStyle(context, color: color),
      bodySmall: bodySmallStyle(context, color: color),
      labelLarge: labelLargeStyle(context, color: color),
      labelMedium: labelMediumStyle(context, color: color),
      labelSmall: labelSmallStyle(context, color: color),
    );
  }
}

/// Text style extension for easy usage
extension TextStyleExtension on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  
  TextStyle withOpacity(double opacity) => copyWith(
    color: color?.withValues(alpha: opacity),
  );
  
  TextStyle withColor(Color color) => copyWith(color: color);
  
  TextStyle withSize(double size) => copyWith(fontSize: size);
}
