import 'package:flutter/material.dart';

/// Haber Merkezi uygulaması için tema tanımları
/// Material Design 3 kullanarak mavi-beyaz temalı tasarım
class AppTheme {
  AppTheme._();

  // Renk paleti - Haber Merkezi mavi teması
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryBlueDark = Color(0xFF0D47A1);
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color accentBlue = Color(0xFF42A5F5);
  
  // Alias for compatibility
  static const Color primaryColor = primaryBlue;
  static const Color accentColor = accentBlue;
  
  // Surface colors
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF1E1E1E);
  
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
      seedColor: primaryBlue,
      brightness: Brightness.light,
      surface: lightSurface,
      error: errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: colorScheme.surface,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
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
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      surface: darkSurface,
      error: errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: colorScheme.surface,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
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

  /// Typography sistemi - haber uygulamasına özel font stilleri
  static TextTheme _buildTextTheme(ColorScheme colorScheme, [double fontScale = 1.0]) {
    return TextTheme(
      // Ana başlıklar - uygulama başlığı
      displayLarge: TextStyle(
        fontSize: 32 * fontScale,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      
      // Haber başlıkları - makale başlıkları
      headlineLarge: TextStyle(
        fontSize: 22 * fontScale,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.2,
        height: 1.2,
      ),
      
      // Kategori başlıkları
      headlineMedium: TextStyle(
        fontSize: 18 * fontScale,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: -0.1,
      ),
      
      // Alt başlıklar
      headlineSmall: TextStyle(
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      
      // Ana metin - makale içeriği
      bodyLarge: TextStyle(
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.5,
        letterSpacing: 0.1,
      ),
      
      // Orta metin - makale özeti
      bodyMedium: TextStyle(
        fontSize: 14 * fontScale,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface.withOpacity(0.8),
        height: 1.4,
        letterSpacing: 0.1,
      ),
      
      // Küçük metin - tarih, kaynak bilgisi
      bodySmall: TextStyle(
        fontSize: 12 * fontScale,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface.withOpacity(0.6),
        height: 1.3,
        letterSpacing: 0.2,
      ),
      
      // Label metinleri - buton, tab isimleri
      labelLarge: TextStyle(
        fontSize: 14 * fontScale,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: 0.3,
      ),
      
      // Küçük label'lar
      labelMedium: TextStyle(
        fontSize: 12 * fontScale,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        letterSpacing: 0.4,
      ),
      
      // En küçük label'lar
      labelSmall: TextStyle(
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
        return customColors['politics'] ?? primaryBlue;
      case 'ekonomi':
        return customColors['economy'] ?? successGreen;
      case 'teknoloji':
        return customColors['technology'] ?? Colors.purple;
      case 'spor':
        return customColors['sports'] ?? warningOrange;
      default:
        return customColors['culture'] ?? Colors.brown;
    }
  }
}