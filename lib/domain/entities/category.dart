/// Haber kategorisini temsil eden domain entity sınıfı
/// Clean Architecture'da business logic katmanında yer alır
class Category {
  final String id;
  final String name;
  final String displayName;
  final String iconName;
  final String color;
  final bool isActive;
  final int articleCount;

  const Category({
    required this.id,
    required this.name,
    required this.displayName,
    required this.iconName,
    required this.color,
    this.isActive = true,
    this.articleCount = 0,
  });

  /// Category kopyalama methodu - immutable pattern
  Category copyWith({
    String? id,
    String? name,
    String? displayName,
    String? iconName,
    String? color,
    bool? isActive,
    int? articleCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      articleCount: articleCount ?? this.articleCount,
    );
  }

  /// Equality karşılaştırması - id bazlı
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Debug için string representation
  @override
  String toString() {
    return 'Category{id: $id, name: $name, displayName: $displayName, articleCount: $articleCount}';
  }

  /// Varsayılan kategoriler listesi
  static List<Category> get defaultCategories => [
    const Category(
      id: 'genel',
      name: 'genel',
      displayName: 'Son Dakika',
      iconName: 'breaking_news',
      color: '#F44336', // Kırmızı
    ),
    const Category(
      id: 'turkiye',
      name: 'turkiye',
      displayName: 'Türkiye',
      iconName: 'flag',
      color: '#2196F3', // Mavi
    ),
    const Category(
      id: 'ekonomi',
      name: 'ekonomi',
      displayName: 'Ekonomi',
      iconName: 'trending_up',
      color: '#4CAF50', // Yeşil
    ),
    const Category(
      id: 'teknoloji',
      name: 'teknoloji',
      displayName: 'Teknoloji',
      iconName: 'computer',
      color: '#9C27B0', // Mor
    ),
    const Category(
      id: 'spor',
      name: 'spor',
      displayName: 'Spor',
      iconName: 'sports_soccer',
      color: '#FF9800', // Turuncu
    ),
    const Category(
      id: 'dunya',
      name: 'dunya',
      displayName: 'Dünya',
      iconName: 'public',
      color: '#607D8B', // Blue Grey
    ),
    const Category(
      id: 'saglik',
      name: 'saglik',
      displayName: 'Sağlık',
      iconName: 'health_and_safety',
      color: '#E91E63', // Pink
    ),
    const Category(
      id: 'kultur',
      name: 'kultur',
      displayName: 'Kültür-Sanat',
      iconName: 'palette',
      color: '#795548', // Brown
    ),
    const Category(
      id: 'magazin',
      name: 'magazin',
      displayName: 'Magazin',
      iconName: 'celebration',
      color: '#FF5722', // Deep Orange
    ),
    const Category(
      id: 'bilim',
      name: 'bilim',
      displayName: 'Bilim',
      iconName: 'science',
      color: '#00BCD4', // Cyan
    ),
    const Category(
      id: 'egitim',
      name: 'egitim',
      displayName: 'Eğitim',
      iconName: 'school',
      color: '#3F51B5', // Indigo
    ),
    const Category(
      id: 'otomobil',
      name: 'otomobil',
      displayName: 'Otomobil',
      iconName: 'directions_car',
      color: '#FFC107', // Amber
    ),
  ];
}
