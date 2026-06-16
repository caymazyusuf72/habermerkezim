import 'package:flutter/material.dart';

/// İlgi alanı hashtag'ini temsil eden domain entity
/// Kullanıcıların seçebileceği hashtag'leri tanımlar
class InterestTag {
  final String id;
  final String name; // Örn: "Teknoloji", "Spor"
  final String displayName; // Örn: "#Teknoloji"
  final IconData icon; // Material icon
  final String? category; // Opsiyonel kategori eşleştirmesi (örn: "teknoloji")
  final List<String> keywords; // Eşleştirme için anahtar kelimeler
  final String color; // Hex color code (opsiyonel)

  const InterestTag({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    this.category,
    this.keywords = const [],
    this.color = '#1976D2',
  });

  /// Equality karşılaştırması - id bazlı
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterestTag &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Debug için string representation
  @override
  String toString() {
    return 'InterestTag{id: $id, name: $name, displayName: $displayName}';
  }

  /// Kopyalama methodu
  InterestTag copyWith({
    String? id,
    String? name,
    String? displayName,
    IconData? icon,
    String? category,
    List<String>? keywords,
    String? color,
  }) {
    return InterestTag(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      keywords: keywords ?? this.keywords,
      color: color ?? this.color,
    );
  }
}
