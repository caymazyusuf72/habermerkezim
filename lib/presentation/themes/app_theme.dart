import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Haber Merkezi uygulaması için tema tanımları
/// Adaçayı yeşili ve mat siyah renk paleti ile profesyonel haber okuma deneyimi
class AppTheme {
  AppTheme._();

  // Renk paleti - Adaçayı yeşili (Sage Green)
  static const Color sageGreen = Color(0xFF87A96B); // Primary
  static const Color sageGreenLight = Color(0xFF9CAF88); // Light variant
  static const Color sageGreenDark = Color(0xFF6B8A4F); // Dark variant
  static const Color sageGreenAccent = Color(0xFFA8C088); // Accent
  
  // Mat siyah renkler
  static const Color matBlack = Color(0xFF0D0D0D); // Dark background
  static const Color matBlackSurface = Color(0xFF1A1A1A); // Dark surface
  static const Color matBlackSurfaceVariant = Color(0xFF2A2A2A); // Dark surface variant
  
  // Light mode renkler
  static const Color lightSurface = Color(0xFFFFFEF9); // Bej-beyaz
  static const Color lightBackground = Color(0xFFFAF9F4); // Açık bej
  static const Color lightSurfaceVariant = Color(0xFFF5F4EF); // Variant
  
  // Alias for compatibility
  static const Color primaryColor = sageGreen;
  static const Color accentColor = sageGreenAccent;
  
  // Legacy support (geriye dönük uyumluluk için)
  static const Color primaryBlue = sageGreen;
  static const Color primaryBlueDark = sageGreenDark;
  static const Color secondaryBlue = sageGreenLight;
  static const Color accentBlue = sageGreenAccent;
  
  // Dark mode surface colors
  static const Color darkSurface = matBlackSurface;
  static const Color darkBackground = matBlack;
  
  // On surface colors
  static const Color lightOnSurface = Color(0xFF000000);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  
  // Error colors
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF4CAF50);

  /// Light Theme - Açık tema
  static ThemeData get lightTheme => getLightTheme();
  
  /// Light Theme with font scale - Açık tema font ölçeği ile
  static ThemeData getLightTheme([double fontScale = 1.0]) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: sageGreen,
      brightness: Brightness.light,
      surface: lightSurface,
      error: errorRed,
      primary: sageGreen,
      secondary: sageGreenLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // App Bar Theme - Merriweather font ile
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.merriweather().fontFamily,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Daha köşeli, gazete gibi
        ),
        color: colorScheme.surface,
      ),

      // Bottom Navigation Bar Theme - Adaçayı yeşili
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: sageGreen,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        elevation: 8,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Typography
      textTheme: _buildTextTheme(colorScheme, fontScale),
    );
  }

  /// Dark Theme - Karanlık tema
  static ThemeData get darkTheme => getDarkTheme();
  
  /// Dark Theme with font scale - Karanlık tema font ölçeği ile
  static ThemeData getDarkTheme([double fontScale = 1.0]) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: sageGreen,
      brightness: Brightness.dark,
      surface: matBlackSurface,
      error: errorRed,
      primary: sageGreen,
      secondary: sageGreenLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // App Bar Theme - Merriweather font ile, mat siyah arka plan
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: matBlackSurface,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.merriweather().fontFamily,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Daha köşeli, gazete gibi
        ),
        color: matBlackSurfaceVariant,
      ),

      // Bottom Navigation Bar Theme - Adaçayı yeşili, mat siyah arka plan
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: matBlackSurface,
        selectedItemColor: sageGreen,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        elevation: 8,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Typography
      textTheme: _buildTextTheme(colorScheme, fontScale),
    );
  }

  /// Typography sistemi - Merriweather serif font ile gazete okuma deneyimi
  static TextTheme _buildTextTheme(ColorScheme colorScheme, [double fontScale = 1.0]) {
    final merriweather = GoogleFonts.merriweather();
    
    return TextTheme(
      // Ana başlıklar - uygulama başlığı
      displayLarge: merriweather.copyWith(
        fontSize: 32 * fontScale,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      
      // Haber başlıkları - makale başlıkları
      headlineLarge: merriweather.copyWith(
        fontSize: 22 * fontScale,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.2,
        height: 1.3,
      ),
      
      // Kategori başlıkları
      headlineMedium: merriweather.copyWith(
        fontSize: 18 * fontScale,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: -0.1,
        height: 1.3,
      ),
      
      // Alt başlıklar
      headlineSmall: merriweather.copyWith(
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      
      // Ana metin - makale içeriği
      bodyLarge: merriweather.copyWith(
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.6, // Gazete okuma için daha geniş satır aralığı
        letterSpacing: 0.2,
      ),
      
      // Orta metin - makale özeti
      bodyMedium: merriweather.copyWith(
        fontSize: 14 * fontScale,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface.withOpacity(0.85),
        height: 1.5,
        letterSpacing: 0.15,
      ),
      
      // Küçük metin - tarih, kaynak bilgisi
      bodySmall: merriweather.copyWith(
        fontSize: 12 * fontScale,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface.withOpacity(0.7),
        height: 1.4,
        letterSpacing: 0.2,
      ),
      
      // Label metinleri - buton, tab isimleri
      labelLarge: merriweather.copyWith(
        fontSize: 14 * fontScale,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: 0.3,
      ),
      
      // Küçük label'lar
      labelMedium: merriweather.copyWith(
        fontSize: 12 * fontScale,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        letterSpacing: 0.4,
      ),
      
      // En küçük label'lar
      labelSmall: merriweather.copyWith(
        fontSize: 10 * fontScale,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface.withOpacity(0.8),
        letterSpacing: 0.5,
      ),
    );
  }

  /// Custom colors for specific use cases
  static const Map<String, Color> customColors = {
    'breakingNews': Color(0xFFD32F2F),
    'politics': Color(0xFF1976D2),
    'economy': Color(0xFF4CAF50),
    'technology': Color(0xFF9C27B0),
    'sports': Color(0xFFFF9800),
    'culture': Color(0xFF795548),
  };

  /// Get category color
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'genel':
        return customColors['breakingNews'] ?? errorRed;
      case 'turkiye':
        return sageGreenDark;
      case 'ekonomi':
        return sageGreen;
      case 'teknoloji':
        return customColors['technology'] ?? Colors.purple;
      case 'spor':
        return customColors['sports'] ?? warningOrange;
      case 'dunya':
        return const Color(0xFF607D8B); // Blue Grey
      case 'saglik':
        return const Color(0xFFE91E63); // Pink
      case 'kultur':
        return const Color(0xFF795548); // Brown
      case 'magazin':
        return const Color(0xFFFF5722); // Deep Orange
      case 'bilim':
        return const Color(0xFF00BCD4); // Cyan
      case 'egitim':
        return const Color(0xFF3F51B5); // Indigo
      case 'otomobil':
        return const Color(0xFFFFC107); // Amber
      default:
        return customColors['culture'] ?? Colors.brown;
    }
  }
}