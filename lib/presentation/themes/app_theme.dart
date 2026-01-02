import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';

/// Renk temaları enum
enum ColorTheme {
  defaultTheme,
  oceanBlue,
  springRed,
  purple,
  amber,
  dynamic,
}

/// Haber Merkezi uygulaması için tema tanımları
class AppTheme {
  AppTheme._();

  static const Color sageGreen = Color(0xFF87A96B);
  static const Color sageGreenLight = Color(0xFF9CAF88);
  static const Color sageGreenDark = Color(0xFF6B8A4F);
  static const Color sageGreenAccent = Color(0xFFA8C088);
  
  static const Color matBlack = Color(0xFF0D0D0D);
  static const Color matBlackSurface = Color(0xFF1A1A1A);
  static const Color matBlackSurfaceVariant = Color(0xFF2A2A2A);
  
  static const Color lightSurface = Color(0xFFFFFEF9);
  static const Color lightBackground = Color(0xFFFAF9F4);
  static const Color lightSurfaceVariant = Color(0xFFF5F4EF);
  
  static const Color primaryColor = sageGreen;
  static const Color accentColor = sageGreenAccent;
  static const Color primaryBlue = sageGreen;
  static const Color primaryBlueDark = sageGreenDark;
  static const Color secondaryBlue = sageGreenLight;
  static const Color accentBlue = sageGreenAccent;
  
  static const Color darkSurface = matBlackSurface;
  static const Color darkBackground = matBlack;
  static const Color lightOnSurface = Color(0xFF000000);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF4CAF50);
  
  static const Color oceanBlue = Color(0xFF2196F3);
  static const Color oceanBlueLight = Color(0xFF64B5F6);
  static const Color oceanBlueDark = Color(0xFF1976D2);
  static const Color oceanBlueAccent = Color(0xFF42A5F5);
  
  static const Color springRed = Color(0xFFC85A5A);
  static const Color springRedLight = Color(0xFFE88A8A);
  static const Color springRedDark = Color(0xFFA04545);
  static const Color springRedAccent = Color(0xFFD67A7A);
  
  static const Color purple = Color(0xFF9C27B0);
  static const Color purpleLight = Color(0xFFBA68C8);
  static const Color purpleDark = Color(0xFF7B1FA2);
  static const Color purpleAccent = Color(0xFFAB47BC);
  
  static const Color amber = Color(0xFFFF9800);
  static const Color amberLight = Color(0xFFFFB74D);
  static const Color amberDark = Color(0xFFF57C00);
  static const Color amberAccent = Color(0xFFFFA726);
  
  static const Color defaultPrimary = sageGreen;
  static const Color defaultPrimaryLight = sageGreenLight;
  static const Color defaultPrimaryDark = sageGreenDark;
  static const Color defaultPrimaryAccent = sageGreenAccent;

  static ThemeData get lightTheme => getLightTheme();
  
  static ThemeData getLightTheme([
    double fontScale = 1.0, 
    ColorTheme colorTheme = ColorTheme.defaultTheme,
    ColorScheme? dynamicColorScheme,
  ]) {
    final pColor = getPrimaryColor(colorTheme);
    final pLight = getPrimaryLightColor(colorTheme);
    final pDark = getPrimaryDarkColor(colorTheme);
    
    final ColorScheme cs;
    if (colorTheme == ColorTheme.dynamic && dynamicColorScheme != null) {
      cs = dynamicColorScheme.harmonized();
    } else {
      cs = ColorScheme.fromSeed(
        seedColor: pColor,
        brightness: Brightness.light,
        surface: lightSurface,
        error: errorRed,
        primary: pColor,
        secondary: pLight,
      );
    }
    
    final epc = colorTheme == ColorTheme.dynamic && dynamicColorScheme != null ? cs.primary : pColor;
    final epd = colorTheme == ColorTheme.dynamic && dynamicColorScheme != null ? cs.primaryContainer : pDark;
    final epl = colorTheme == ColorTheme.dynamic && dynamicColorScheme != null ? cs.secondary : pLight;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: epc.withOpacity(0.15),
        foregroundColor: epd,
        titleTextStyle: TextStyle(
          color: epd,
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.w700,
          fontFamily: GoogleFonts.merriweather().fontFamily,
        ),
        iconTheme: IconThemeData(color: epd),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: epc.withOpacity(0.3), width: 1.5),
        ),
        color: cs.surface,
        surfaceTintColor: epc.withOpacity(0.05),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: epc.withOpacity(0.1),
        selectedItemColor: epd,
        unselectedItemColor: cs.onSurface.withOpacity(0.5),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        backgroundColor: cs.surface,
        indicatorColor: epc.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: epd);
          }
          return TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: cs.onSurface.withOpacity(0.6));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: epd, size: 24);
          }
          return IconThemeData(color: cs.onSurface.withOpacity(0.6), size: 24);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerTheme: DividerThemeData(color: cs.outline.withOpacity(0.2), thickness: 1, space: 1),
      tabBarTheme: TabBarThemeData(
        labelColor: epd,
        unselectedLabelColor: cs.onSurface.withOpacity(0.5),
        indicatorColor: epc,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        dividerColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedColor: epc.withOpacity(0.2),
        checkmarkColor: epd,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: epc,
        foregroundColor: cs.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(color: cs.onInverseSurface),
        actionTextColor: epl,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: epc.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: TextStyle(color: cs.onSurface, fontSize: 24 * fontScale, fontWeight: FontWeight.w600),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: epc.withOpacity(0.05),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        dragHandleColor: cs.onSurfaceVariant.withOpacity(0.4),
        dragHandleSize: const Size(32, 4),
        showDragHandle: true,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return epc;
          return cs.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return epc.withOpacity(0.5);
          return cs.surfaceContainerHighest;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: epc,
        inactiveTrackColor: epc.withOpacity(0.3),
        thumbColor: epc,
        overlayColor: epc.withOpacity(0.12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: epc,
        linearTrackColor: epc.withOpacity(0.2),
        circularTrackColor: epc.withOpacity(0.2),
      ),
      textTheme: _buildTextTheme(cs, fontScale),
    );
  }

  static ThemeData get darkTheme => getDarkTheme();
  
  static ThemeData getDarkTheme([
    double fontScale = 1.0, 
    ColorTheme colorTheme = ColorTheme.defaultTheme,
    ColorScheme? dynamicColorScheme,
  ]) {
    final pColor = getPrimaryColor(colorTheme);
    final pLight = getPrimaryLightColor(colorTheme);
    final pDark = getPrimaryDarkColor(colorTheme);
    
    final ColorScheme cs;
    if (colorTheme == ColorTheme.dynamic && dynamicColorScheme != null) {
      cs = dynamicColorScheme.harmonized();
    } else {
      cs = ColorScheme.fromSeed(
        seedColor: pColor,
        brightness: Brightness.dark,
        surface: matBlackSurface,
        onSurface: const Color(0xFFE8E8E8), // Açık gri metin rengi
        surfaceContainerHighest: matBlackSurfaceVariant,
        error: errorRed,
        primary: pColor,
        secondary: pLight,
      );
    }
    
    final epc = colorTheme == ColorTheme.dynamic && dynamicColorScheme != null ? cs.primary : pColor;
    final epd = colorTheme == ColorTheme.dynamic && dynamicColorScheme != null ? cs.primaryContainer : pDark;
    final epl = colorTheme == ColorTheme.dynamic && dynamicColorScheme != null ? cs.secondary : pLight;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: epc.withOpacity(0.2),
        foregroundColor: epl,
        titleTextStyle: TextStyle(
          color: epl,
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.w700,
          fontFamily: GoogleFonts.merriweather().fontFamily,
        ),
        iconTheme: IconThemeData(color: epl),
      ),
      cardTheme: CardThemeData(
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: epc.withOpacity(0.4), width: 1.5),
        ),
        color: const Color(0xFF252525), // Daha açık koyu gri - kartlar için
        surfaceTintColor: epc.withOpacity(0.08),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: epc.withOpacity(0.15),
        selectedItemColor: epl,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        backgroundColor: cs.surface,
        indicatorColor: epc.withOpacity(0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: epl);
          }
          return TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.6));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: epl, size: 24);
          }
          return IconThemeData(color: Colors.white.withOpacity(0.6), size: 24);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 3,
          backgroundColor: epc,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: epl,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerTheme: DividerThemeData(color: cs.outline.withOpacity(0.2), thickness: 1, space: 1),
      tabBarTheme: TabBarThemeData(
        labelColor: epl,
        unselectedLabelColor: Colors.white.withOpacity(0.5),
        indicatorColor: epc,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        dividerColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedColor: epc.withOpacity(0.3),
        checkmarkColor: epl,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: epc,
        foregroundColor: cs.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(color: cs.onInverseSurface),
        actionTextColor: epl,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: epc.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: TextStyle(color: cs.onSurface, fontSize: 24 * fontScale, fontWeight: FontWeight.w600),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: epc.withOpacity(0.08),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        dragHandleColor: cs.onSurfaceVariant.withOpacity(0.4),
        dragHandleSize: const Size(32, 4),
        showDragHandle: true,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return epc;
          return cs.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return epc.withOpacity(0.5);
          return cs.surfaceContainerHighest;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: epc,
        inactiveTrackColor: epc.withOpacity(0.3),
        thumbColor: epc,
        overlayColor: epc.withOpacity(0.12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: epc,
        linearTrackColor: epc.withOpacity(0.2),
        circularTrackColor: epc.withOpacity(0.2),
      ),
      textTheme: _buildTextTheme(cs, fontScale),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme cs, [double fontScale = 1.0]) {
    final mw = GoogleFonts.merriweather();
    return TextTheme(
      displayLarge: mw.copyWith(fontSize: 32 * fontScale, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.5, height: 1.2),
      headlineLarge: mw.copyWith(fontSize: 22 * fontScale, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.2, height: 1.3),
      headlineMedium: mw.copyWith(fontSize: 18 * fontScale, fontWeight: FontWeight.w600, color: cs.onSurface, letterSpacing: -0.1, height: 1.3),
      headlineSmall: mw.copyWith(fontSize: 16 * fontScale, fontWeight: FontWeight.w600, color: cs.onSurface, height: 1.4),
      bodyLarge: mw.copyWith(fontSize: 16 * fontScale, fontWeight: FontWeight.w400, color: cs.onSurface, height: 1.6, letterSpacing: 0.2),
      bodyMedium: mw.copyWith(fontSize: 14 * fontScale, fontWeight: FontWeight.w400, color: cs.onSurface.withOpacity(0.85), height: 1.5, letterSpacing: 0.15),
      bodySmall: mw.copyWith(fontSize: 12 * fontScale, fontWeight: FontWeight.w400, color: cs.onSurface.withOpacity(0.7), height: 1.4, letterSpacing: 0.2),
      labelLarge: mw.copyWith(fontSize: 14 * fontScale, fontWeight: FontWeight.w600, color: cs.onSurface, letterSpacing: 0.3),
      labelMedium: mw.copyWith(fontSize: 12 * fontScale, fontWeight: FontWeight.w500, color: cs.onSurface, letterSpacing: 0.4),
      labelSmall: mw.copyWith(fontSize: 10 * fontScale, fontWeight: FontWeight.w500, color: cs.onSurface.withOpacity(0.8), letterSpacing: 0.5),
    );
  }

  static const Map<String, Color> customColors = {
    'breakingNews': Color(0xFFD32F2F),
    'politics': Color(0xFF1976D2),
    'economy': Color(0xFF4CAF50),
    'technology': Color(0xFF9C27B0),
    'sports': Color(0xFFFF9800),
    'culture': Color(0xFF795548),
  };

  static Color getPrimaryColor(ColorTheme theme) {
    switch (theme) {
      case ColorTheme.oceanBlue: return oceanBlue;
      case ColorTheme.springRed: return springRed;
      case ColorTheme.purple: return purple;
      case ColorTheme.amber: return amber;
      case ColorTheme.dynamic: return defaultPrimary;
      case ColorTheme.defaultTheme: return defaultPrimary;
    }
  }
  
  static Color getPrimaryLightColor(ColorTheme theme) {
    switch (theme) {
      case ColorTheme.oceanBlue: return oceanBlueLight;
      case ColorTheme.springRed: return springRedLight;
      case ColorTheme.purple: return purpleLight;
      case ColorTheme.amber: return amberLight;
      case ColorTheme.dynamic: return defaultPrimaryLight;
      case ColorTheme.defaultTheme: return defaultPrimaryLight;
    }
  }
  
  static Color getPrimaryDarkColor(ColorTheme theme) {
    switch (theme) {
      case ColorTheme.oceanBlue: return oceanBlueDark;
      case ColorTheme.springRed: return springRedDark;
      case ColorTheme.purple: return purpleDark;
      case ColorTheme.amber: return amberDark;
      case ColorTheme.dynamic: return defaultPrimaryDark;
      case ColorTheme.defaultTheme: return defaultPrimaryDark;
    }
  }
  
  static Color getAccentColor(ColorTheme theme) {
    switch (theme) {
      case ColorTheme.oceanBlue: return oceanBlueAccent;
      case ColorTheme.springRed: return springRedAccent;
      case ColorTheme.purple: return purpleAccent;
      case ColorTheme.amber: return amberAccent;
      case ColorTheme.dynamic: return defaultPrimaryAccent;
      case ColorTheme.defaultTheme: return defaultPrimaryAccent;
    }
  }
  
  static String getThemeName(ColorTheme theme) {
    switch (theme) {
      case ColorTheme.oceanBlue: return 'Okyanus Mavisi';
      case ColorTheme.springRed: return 'Bahar Kırmızısı';
      case ColorTheme.purple: return 'Mor';
      case ColorTheme.amber: return 'Turuncu';
      case ColorTheme.dynamic: return 'Dinamik (Sistem)';
      case ColorTheme.defaultTheme: return 'Adaçayı Yeşili';
    }
  }
  
  static String getThemeDescription(ColorTheme theme) {
    switch (theme) {
      case ColorTheme.oceanBlue: return 'Sakin ve profesyonel mavi tonlar';
      case ColorTheme.springRed: return 'Sıcak bahar yaprağı kırmızısı';
      case ColorTheme.purple: return 'Zarif ve modern mor tonlar';
      case ColorTheme.amber: return 'Enerjik turuncu tonlar';
      case ColorTheme.dynamic: return 'Duvar kağıdından otomatik renk (Android 12+)';
      case ColorTheme.defaultTheme: return 'Doğal adaçayı yeşili';
    }
  }
  
  static Color getThemeColor(ColorTheme theme) => getPrimaryColor(theme);

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'genel': return customColors['breakingNews'] ?? errorRed;
      case 'turkiye': return sageGreenDark;
      case 'ekonomi': return sageGreen;
      case 'teknoloji': return customColors['technology'] ?? Colors.purple;
      case 'spor': return customColors['sports'] ?? warningOrange;
      case 'dunya': return const Color(0xFF607D8B);
      case 'saglik': return const Color(0xFFE91E63);
      case 'kultur': return const Color(0xFF795548);
      case 'magazin': return const Color(0xFFFF5722);
      case 'bilim': return const Color(0xFF00BCD4);
      case 'egitim': return const Color(0xFF3F51B5);
      case 'otomobil': return const Color(0xFFFFC107);
      default: return customColors['culture'] ?? Colors.brown;
    }
  }
}