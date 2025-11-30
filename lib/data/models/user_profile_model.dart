import 'package:hive/hive.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

/// UserProfile entity'sinin data layer implementasyonu
/// Hive database desteği ile
@HiveType(typeId: 1)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? avatarUrl;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final UserStatsModel stats;

  @HiveField(6)
  final UserPreferencesModel preferences;

  UserProfileModel({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
    required this.createdAt,
    required this.stats,
    required this.preferences,
  });

  /// Domain entity'den model oluşturur
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      avatarUrl: profile.avatarUrl,
      createdAt: profile.createdAt,
      stats: UserStatsModel.fromEntity(profile.stats),
      preferences: UserPreferencesModel.fromEntity(profile.preferences),
    );
  }

  /// Model'den domain entity oluşturur
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      stats: stats.toEntity(),
      preferences: preferences.toEntity(),
    );
  }

  /// JSON'dan model oluşturur
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      stats: json['stats'] != null
          ? UserStatsModel.fromJson(json['stats'])
          : UserStatsModel.empty,
      preferences: json['preferences'] != null
          ? UserPreferencesModel.fromJson(json['preferences'])
          : UserPreferencesModel.defaultPreferences,
    );
  }

  /// Model'i JSON'a çevirir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'stats': stats.toJson(),
      'preferences': preferences.toJson(),
    };
  }
}

/// UserStats model
@HiveType(typeId: 2)
class UserStatsModel extends HiveObject {
  @HiveField(0)
  final int totalArticlesRead;

  @HiveField(1)
  final int totalFavorites;

  @HiveField(2)
  final int totalReadingList;

  @HiveField(3)
  final int streakDays;

  @HiveField(4)
  final Map<String, int> categoryReadCount;

  @HiveField(5)
  final DateTime? lastReadDate;

  UserStatsModel({
    this.totalArticlesRead = 0,
    this.totalFavorites = 0,
    this.totalReadingList = 0,
    this.streakDays = 0,
    this.categoryReadCount = const {},
    this.lastReadDate,
  });

  /// Domain entity'den model oluşturur
  factory UserStatsModel.fromEntity(UserStats stats) {
    return UserStatsModel(
      totalArticlesRead: stats.totalArticlesRead,
      totalFavorites: stats.totalFavorites,
      totalReadingList: stats.totalReadingList,
      streakDays: stats.streakDays,
      categoryReadCount: Map<String, int>.from(stats.categoryReadCount),
      lastReadDate: stats.lastReadDate,
    );
  }

  /// Model'den domain entity oluşturur
  UserStats toEntity() {
    return UserStats(
      totalArticlesRead: totalArticlesRead,
      totalFavorites: totalFavorites,
      totalReadingList: totalReadingList,
      streakDays: streakDays,
      categoryReadCount: Map<String, int>.from(categoryReadCount),
      lastReadDate: lastReadDate,
    );
  }

  /// Boş istatistikler
  static const UserStatsModel empty = UserStatsModel();

  /// JSON'dan model oluşturur
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalArticlesRead: json['totalArticlesRead'] ?? 0,
      totalFavorites: json['totalFavorites'] ?? 0,
      totalReadingList: json['totalReadingList'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      categoryReadCount: json['categoryReadCount'] != null
          ? Map<String, int>.from(json['categoryReadCount'])
          : {},
      lastReadDate: json['lastReadDate'] != null
          ? DateTime.parse(json['lastReadDate'])
          : null,
    );
  }

  /// Model'i JSON'a çevirir
  Map<String, dynamic> toJson() {
    return {
      'totalArticlesRead': totalArticlesRead,
      'totalFavorites': totalFavorites,
      'totalReadingList': totalReadingList,
      'streakDays': streakDays,
      'categoryReadCount': categoryReadCount,
      'lastReadDate': lastReadDate?.toIso8601String(),
    };
  }
}

/// UserPreferences model
@HiveType(typeId: 3)
class UserPreferencesModel extends HiveObject {
  @HiveField(0)
  final List<String> favoriteCategories;

  @HiveField(1)
  final List<String> blockedSources;

  @HiveField(2)
  final bool enableNotifications;

  @HiveField(3)
  final String preferredLanguage;

  UserPreferencesModel({
    this.favoriteCategories = const [],
    this.blockedSources = const [],
    this.enableNotifications = true,
    this.preferredLanguage = 'tr',
  });

  /// Domain entity'den model oluşturur
  factory UserPreferencesModel.fromEntity(UserPreferences preferences) {
    return UserPreferencesModel(
      favoriteCategories: List<String>.from(preferences.favoriteCategories),
      blockedSources: List<String>.from(preferences.blockedSources),
      enableNotifications: preferences.enableNotifications,
      preferredLanguage: preferences.preferredLanguage,
    );
  }

  /// Model'den domain entity oluşturur
  UserPreferences toEntity() {
    return UserPreferences(
      favoriteCategories: List<String>.from(favoriteCategories),
      blockedSources: List<String>.from(blockedSources),
      enableNotifications: enableNotifications,
      preferredLanguage: preferredLanguage,
    );
  }

  /// Varsayılan tercihler
  static const UserPreferencesModel defaultPreferences = UserPreferencesModel();

  /// JSON'dan model oluşturur
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      favoriteCategories: json['favoriteCategories'] != null
          ? List<String>.from(json['favoriteCategories'])
          : [],
      blockedSources: json['blockedSources'] != null
          ? List<String>.from(json['blockedSources'])
          : [],
      enableNotifications: json['enableNotifications'] ?? true,
      preferredLanguage: json['preferredLanguage'] ?? 'tr',
    );
  }

  /// Model'i JSON'a çevirir
  Map<String, dynamic> toJson() {
    return {
      'favoriteCategories': favoriteCategories,
      'blockedSources': blockedSources,
      'enableNotifications': enableNotifications,
      'preferredLanguage': preferredLanguage,
    };
  }
}

