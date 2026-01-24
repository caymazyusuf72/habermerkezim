import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/hive_service.dart';

/// Okuma modu arka plan renkleri
enum ReadingBackgroundColor {
  white,      // Beyaz
  beige,      // Bej/Krem
  sepia,      // Sepia
  black,      // Siyah
  nightMode,  // Gece Modu
}

/// Satır aralığı seçenekleri
enum LineSpacing {
  compact,     // 1.2x - Dar
  normal,      // 1.5x - Normal
  comfortable, // 1.8x - Rahat
  wide,        // 2.2x - Geniş
}

/// Okuma modu ayarları modeli
class ReadingModeSettings {
  final double fontSize;
  final ReadingBackgroundColor backgroundColor;
  final LineSpacing lineSpacing;
  final bool nightModeEnabled;
  
  const ReadingModeSettings({
    this.fontSize = 1.0,
    this.backgroundColor = ReadingBackgroundColor.white,
    this.lineSpacing = LineSpacing.normal,
    this.nightModeEnabled = false,
  });
  
  /// Arka plan rengi değeri
  Color get backgroundColorValue {
    if (nightModeEnabled) return const Color(0xFF1A1A1A);
    
    switch (backgroundColor) {
      case ReadingBackgroundColor.white:
        return Colors.white;
      case ReadingBackgroundColor.beige:
        return const Color(0xFFF5F5DC); // Bej
      case ReadingBackgroundColor.sepia:
        return const Color(0xFFF4ECD8); // Sepia
      case ReadingBackgroundColor.black:
        return const Color(0xFF000000);
      case ReadingBackgroundColor.nightMode:
        return const Color(0xFF1A1A1A);
    }
  }
  
  /// Metin rengi değeri
  Color get textColorValue {
    if (nightModeEnabled) return const Color(0xFFE0E0E0);
    
    if (backgroundColor == ReadingBackgroundColor.black ||
        backgroundColor == ReadingBackgroundColor.nightMode) {
      return Colors.white;
    }
    return Colors.black87;
  }
  
  /// Satır aralığı değeri
  double get lineSpacingValue {
    switch (lineSpacing) {
      case LineSpacing.compact:
        return 1.2;
      case LineSpacing.normal:
        return 1.5;
      case LineSpacing.comfortable:
        return 1.8;
      case LineSpacing.wide:
        return 2.2;
    }
  }
  
  /// Arka plan rengi adı
  String get backgroundColorName {
    if (nightModeEnabled) return 'Gece Modu';
    
    switch (backgroundColor) {
      case ReadingBackgroundColor.white:
        return 'Beyaz';
      case ReadingBackgroundColor.beige:
        return 'Bej';
      case ReadingBackgroundColor.sepia:
        return 'Sepia';
      case ReadingBackgroundColor.black:
        return 'Siyah';
      case ReadingBackgroundColor.nightMode:
        return 'Gece';
    }
  }
  
  /// Satır aralığı adı
  String get lineSpacingName {
    switch (lineSpacing) {
      case LineSpacing.compact:
        return 'Dar';
      case LineSpacing.normal:
        return 'Normal';
      case LineSpacing.comfortable:
        return 'Rahat';
      case LineSpacing.wide:
        return 'Geniş';
    }
  }
  
  ReadingModeSettings copyWith({
    double? fontSize,
    ReadingBackgroundColor? backgroundColor,
    LineSpacing? lineSpacing,
    bool? nightModeEnabled,
  }) {
    return ReadingModeSettings(
      fontSize: fontSize ?? this.fontSize,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      nightModeEnabled: nightModeEnabled ?? this.nightModeEnabled,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'fontSize': fontSize,
      'backgroundColor': backgroundColor.index,
      'lineSpacing': lineSpacing.index,
      'nightModeEnabled': nightModeEnabled,
    };
  }
  
  factory ReadingModeSettings.fromMap(Map<String, dynamic> map) {
    return ReadingModeSettings(
      fontSize: map['fontSize']?.toDouble() ?? 1.0,
      backgroundColor: ReadingBackgroundColor.values[map['backgroundColor'] ?? 0],
      lineSpacing: LineSpacing.values[map['lineSpacing'] ?? 1],
      nightModeEnabled: map['nightModeEnabled'] ?? false,
    );
  }
}

/// Okuma modu provider
class ReadingModeNotifier extends StateNotifier<ReadingModeSettings> {
  static const String _settingsKey = 'reading_mode_settings';
  
  ReadingModeNotifier() : super(const ReadingModeSettings()) {
    _loadSettings();
  }
  
  /// Ayarları yükle
  Future<void> _loadSettings() async {
    try {
      final settingsBox = HiveService.settingsBox;
      final savedMap = settingsBox.get(_settingsKey);
      
      if (savedMap != null && savedMap is Map) {
        state = ReadingModeSettings.fromMap(Map<String, dynamic>.from(savedMap));
        debugPrint('📖 Reading mode settings loaded: ${state.backgroundColorName}, ${state.fontSize}x');
      }
    } catch (e) {
      debugPrint('❌ Reading mode load error: $e');
    }
  }
  
  /// Ayarları kaydet
  Future<void> _saveSettings() async {
    try {
      final settingsBox = HiveService.settingsBox;
      await settingsBox.put(_settingsKey, state.toMap());
      debugPrint('📖 Reading mode settings saved');
    } catch (e) {
      debugPrint('❌ Reading mode save error: $e');
    }
  }
  
  /// Font boyutu ayarla (0.8 - 1.6 arası)
  void setFontSize(double size) {
    if (size < 0.8 || size > 1.6) return;
    state = state.copyWith(fontSize: size);
    _saveSettings();
  }
  
  /// Arka plan rengi ayarla
  void setBackgroundColor(ReadingBackgroundColor color) {
    state = state.copyWith(backgroundColor: color);
    _saveSettings();
  }
  
  /// Satır aralığı ayarla
  void setLineSpacing(LineSpacing spacing) {
    state = state.copyWith(lineSpacing: spacing);
    _saveSettings();
  }
  
  /// Gece modu toggle
  void toggleNightMode(bool enabled) {
    state = state.copyWith(nightModeEnabled: enabled);
    _saveSettings();
  }
  
  /// Varsayılana sıfırla
  void resetToDefaults() {
    state = const ReadingModeSettings();
    _saveSettings();
  }
  
  /// Font boyutunu artır
  void increaseFontSize() {
    final newSize = (state.fontSize + 0.1).clamp(0.8, 1.6);
    setFontSize(newSize);
  }
  
  /// Font boyutunu azalt
  void decreaseFontSize() {
    final newSize = (state.fontSize - 0.1).clamp(0.8, 1.6);
    setFontSize(newSize);
  }
}

/// Reading mode provider instance
final readingModeProvider = StateNotifierProvider<ReadingModeNotifier, ReadingModeSettings>((ref) {
  return ReadingModeNotifier();
});