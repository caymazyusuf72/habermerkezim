/// Rozet entity'si - Gamification sistemi için
class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeCategory category;
  final BadgeTier tier;
  final int requiredValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress; // 0.0 - 1.0 arası

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.tier,
    required this.requiredValue,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
  });

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    BadgeCategory? category,
    BadgeTier? tier,
    int? requiredValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? progress,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      requiredValue: requiredValue ?? this.requiredValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category.name,
      'tier': tier.name,
      'requiredValue': requiredValue,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: BadgeCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => BadgeCategory.reading,
      ),
      tier: BadgeTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => BadgeTier.bronze,
      ),
      requiredValue: json['requiredValue'] as int,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Badge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Rozet kategorileri
enum BadgeCategory {
  reading('Okuma', '📖'),
  streak('Seri', '🔥'),
  favorites('Favoriler', '❤️'),
  sharing('Paylaşım', '📤'),
  exploration('Keşif', '🧭'),
  achievement('Başarı', '🏆'),
  special('Özel', '⭐');

  final String displayName;
  final String emoji;

  const BadgeCategory(this.displayName, this.emoji);
}

/// Rozet seviyeleri
enum BadgeTier {
  bronze('Bronz', 1, 0xFFCD7F32),
  silver('Gümüş', 2, 0xFFC0C0C0),
  gold('Altın', 3, 0xFFFFD700),
  platinum('Platin', 4, 0xFFE5E4E2),
  diamond('Elmas', 5, 0xFFB9F2FF);

  final String displayName;
  final int level;
  final int color;

  const BadgeTier(this.displayName, this.level, this.color);
}

/// Kullanıcı seviyesi
class UserLevel {
  final int level;
  final String title;
  final int currentXP;
  final int requiredXP;
  final int totalXP;

  const UserLevel({
    required this.level,
    required this.title,
    required this.currentXP,
    required this.requiredXP,
    required this.totalXP,
  });

  double get progress => requiredXP > 0 ? currentXP / requiredXP : 0.0;
  double get progressToNextLevel => progress;
  int get xpForNextLevel => requiredXP - currentXP;

  factory UserLevel.initial() {
    return const UserLevel(
      level: 1,
      title: 'Yeni Okuyucu',
      currentXP: 0,
      requiredXP: 100,
      totalXP: 0,
    );
  }

  UserLevel copyWith({
    int? level,
    String? title,
    int? currentXP,
    int? requiredXP,
    int? totalXP,
  }) {
    return UserLevel(
      level: level ?? this.level,
      title: title ?? this.title,
      currentXP: currentXP ?? this.currentXP,
      requiredXP: requiredXP ?? this.requiredXP,
      totalXP: totalXP ?? this.totalXP,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'currentXP': currentXP,
      'requiredXP': requiredXP,
      'totalXP': totalXP,
    };
  }

  factory UserLevel.fromJson(Map<String, dynamic> json) {
    return UserLevel(
      level: json['level'] as int? ?? 1,
      title: json['title'] as String? ?? 'Yeni Okuyucu',
      currentXP: json['currentXP'] as int? ?? 0,
      requiredXP: json['requiredXP'] as int? ?? 100,
      totalXP: json['totalXP'] as int? ?? 0,
    );
  }

  /// Seviye numarasından UserLevel oluştur
  factory UserLevel.fromLevel(int level) {
    final titles = [
      'Yeni Okuyucu',
      'Meraklı Okuyucu',
      'Düzenli Okuyucu',
      'Aktif Okuyucu',
      'Tutkulu Okuyucu',
      'Deneyimli Okuyucu',
      'Uzman Okuyucu',
      'Usta Okuyucu',
      'Elit Okuyucu',
      'Efsane Okuyucu',
      'Haber Avcısı',
      'Bilgi Uzmanı',
      'Medya Analisti',
      'Enformasyon Ustası',
      'Haber Dehası',
      'Bilgi Kaynağı',
      'Medya Guru',
      'Haber Efsanesi',
      'Omniscient Reader',
      'Haber Tanrısı',
    ];

    final clampedLevel = level.clamp(1, 20);
    final title = titles[clampedLevel - 1];
    final requiredXP = 100 * clampedLevel;

    return UserLevel(
      level: clampedLevel,
      title: title,
      currentXP: 0,
      requiredXP: requiredXP,
      totalXP: 0,
    );
  }
}

/// Gamification durumu
class GamificationState {
  final UserLevel userLevel;
  final List<Badge> badges;
  final int totalPoints;
  final int dailyStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;

  const GamificationState({
    required this.userLevel,
    required this.badges,
    required this.totalPoints,
    required this.dailyStreak,
    required this.longestStreak,
    this.lastActivityDate,
  });

  factory GamificationState.initial() {
    return GamificationState(
      userLevel: UserLevel.initial(),
      badges: [],
      totalPoints: 0,
      dailyStreak: 0,
      longestStreak: 0,
      lastActivityDate: null,
    );
  }

  int get unlockedBadgesCount => badges.where((b) => b.isUnlocked).length;
  int get totalBadgesCount => badges.length;

  GamificationState copyWith({
    UserLevel? userLevel,
    List<Badge>? badges,
    int? totalPoints,
    int? dailyStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
  }) {
    return GamificationState(
      userLevel: userLevel ?? this.userLevel,
      badges: badges ?? this.badges,
      totalPoints: totalPoints ?? this.totalPoints,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userLevel': userLevel.toJson(),
      'badges': badges.map((b) => b.toJson()).toList(),
      'totalPoints': totalPoints,
      'dailyStreak': dailyStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
    };
  }

  factory GamificationState.fromJson(Map<String, dynamic> json) {
    return GamificationState(
      userLevel: json['userLevel'] != null
          ? UserLevel.fromJson(json['userLevel'] as Map<String, dynamic>)
          : UserLevel.initial(),
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map((b) => Badge.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      totalPoints: json['totalPoints'] as int? ?? 0,
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
    );
  }
}
