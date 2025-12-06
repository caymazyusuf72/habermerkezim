/// Kullanıcı profilini temsil eden domain entity sınıfı
/// Clean Architecture'da business logic katmanında yer alır
class UserProfile {
  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final DateTime createdAt;
  final UserStats stats;
  final UserPreferences preferences;

  const UserProfile({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
    required this.createdAt,
    required this.stats,
    required this.preferences,
  });

  /// UserProfile kopyalama methodu - immutable pattern
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    UserStats? stats,
    UserPreferences? preferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      stats: stats ?? this.stats,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Equality karşılaştırması - id bazlı
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Debug için string representation
  @override
  String toString() {
    return 'UserProfile{id: $id, name: $name, email: $email}';
  }

  /// Varsayılan profil oluşturur
  static UserProfile get defaultProfile => UserProfile(
        id: 'default_user',
        createdAt: DateTime.now(),
        stats: UserStats.empty,
        preferences: UserPreferences.defaultPreferences,
      );
}

/// Kullanıcı istatistiklerini temsil eden sınıf
class UserStats {
  final int totalArticlesRead;
  final int totalFavorites;
  final int totalReadingList;
  final int streakDays;
  final Map<String, int> categoryReadCount;
  final DateTime? lastReadDate;

  const UserStats({
    this.totalArticlesRead = 0,
    this.totalFavorites = 0,
    this.totalReadingList = 0,
    this.streakDays = 0,
    this.categoryReadCount = const {},
    this.lastReadDate,
  });

  /// UserStats kopyalama methodu
  UserStats copyWith({
    int? totalArticlesRead,
    int? totalFavorites,
    int? totalReadingList,
    int? streakDays,
    Map<String, int>? categoryReadCount,
    DateTime? lastReadDate,
  }) {
    return UserStats(
      totalArticlesRead: totalArticlesRead ?? this.totalArticlesRead,
      totalFavorites: totalFavorites ?? this.totalFavorites,
      totalReadingList: totalReadingList ?? this.totalReadingList,
      streakDays: streakDays ?? this.streakDays,
      categoryReadCount: categoryReadCount ?? this.categoryReadCount,
      lastReadDate: lastReadDate ?? this.lastReadDate,
    );
  }

  /// Boş istatistikler
  static const UserStats empty = UserStats();

  /// En çok okunan kategori
  String? get topCategory {
    if (categoryReadCount.isEmpty) return null;
    return categoryReadCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Toplam okuma süresi (dakika) - yaklaşık hesaplama
  int get totalReadingTimeMinutes {
    // Ortalama makale okuma süresi: 3 dakika
    return totalArticlesRead * 3;
  }
}

/// Kullanıcı tercihlerini temsil eden sınıf
class UserPreferences {
  final List<String> favoriteCategories;
  final List<String> blockedSources;
  final bool enableNotifications;
  final String preferredLanguage;
  final List<String> interestTags; // Seçilen hashtag ID'leri

  const UserPreferences({
    this.favoriteCategories = const [],
    this.blockedSources = const [],
    this.enableNotifications = true,
    this.preferredLanguage = 'tr',
    this.interestTags = const [],
  });

  /// UserPreferences kopyalama methodu
  UserPreferences copyWith({
    List<String>? favoriteCategories,
    List<String>? blockedSources,
    bool? enableNotifications,
    String? preferredLanguage,
    List<String>? interestTags,
  }) {
    return UserPreferences(
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      blockedSources: blockedSources ?? this.blockedSources,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      interestTags: interestTags ?? this.interestTags,
    );
  }

  /// Varsayılan tercihler
  static const UserPreferences defaultPreferences = UserPreferences();

  /// Kategori favori mi kontrol et
  bool isCategoryFavorite(String category) {
    return favoriteCategories.contains(category);
  }

  /// Kaynak engellenmiş mi kontrol et
  bool isSourceBlocked(String source) {
    return blockedSources.contains(source);
  }
}

