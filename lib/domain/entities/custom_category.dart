/// Kullanıcı tanımlı kategori entity
class CustomCategory {
  final String id;
  final String name;
  final String? description;
  final List<String> rssFeedUrls;
  final String? iconName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CustomCategory({
    required this.id,
    required this.name,
    this.description,
    required this.rssFeedUrls,
    this.iconName,
    required this.createdAt,
    this.updatedAt,
  });

  /// CustomCategory kopyalama methodu
  CustomCategory copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? rssFeedUrls,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rssFeedUrls: rssFeedUrls ?? this.rssFeedUrls,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Equality karşılaştırması
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Debug için string representation
  @override
  String toString() {
    return 'CustomCategory{id: $id, name: $name, feeds: ${rssFeedUrls.length}}';
  }

  /// JSON'a çevirir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rssFeedUrls': rssFeedUrls,
      'iconName': iconName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// JSON'dan oluşturur
  factory CustomCategory.fromJson(Map<String, dynamic> json) {
    return CustomCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      rssFeedUrls: json['rssFeedUrls'] != null
          ? List<String>.from(json['rssFeedUrls'])
          : [],
      iconName: json['iconName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

