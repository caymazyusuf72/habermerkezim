import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/badge.dart';

/// Gamification servisi - Rozetler, puanlar ve seviyeler
class GamificationService {
  static const String _boxName = 'gamification';
  static const String _stateKey = 'gamification_state';
  
  static GamificationService? _instance;
  static GamificationService get instance => _instance ??= GamificationService._();
  
  GamificationService._();
  
  Box? _box;
  GamificationState _state = GamificationState.initial();
  
  GamificationState get state => _state;
  
  /// Servisi başlat
  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
      await _loadState();
      await _initializeBadges();
      debugPrint('✅ GamificationService initialized');
    } catch (e) {
      debugPrint('❌ GamificationService init error: $e');
    }
  }
  
  /// State'i yükle
  Future<void> _loadState() async {
    try {
      final stateJson = _box?.get(_stateKey);
      if (stateJson != null) {
        final Map<String, dynamic> json = jsonDecode(stateJson as String);
        _state = GamificationState.fromJson(json);
      }
    } catch (e) {
      debugPrint('⚠️ Gamification state yüklenemedi: $e');
      _state = GamificationState.initial();
    }
  }
  
  /// State'i kaydet
  Future<void> _saveState() async {
    try {
      final stateJson = jsonEncode(_state.toJson());
      await _box?.put(_stateKey, stateJson);
    } catch (e) {
      debugPrint('❌ Gamification state kaydedilemedi: $e');
    }
  }
  
  /// Rozetleri başlat
  Future<void> _initializeBadges() async {
    if (_state.badges.isEmpty) {
      _state = _state.copyWith(badges: _getAllBadges());
      await _saveState();
    } else {
      // Yeni rozetleri ekle (güncelleme durumunda)
      final existingIds = _state.badges.map((b) => b.id).toSet();
      final allBadges = _getAllBadges();
      final newBadges = allBadges.where((b) => !existingIds.contains(b.id)).toList();
      
      if (newBadges.isNotEmpty) {
        _state = _state.copyWith(badges: [..._state.badges, ...newBadges]);
        await _saveState();
      }
    }
  }
  
  /// Tüm rozetleri tanımla
  List<Badge> _getAllBadges() {
    return [
      // Okuma Rozetleri
      const Badge(
        id: 'first_read',
        name: 'İlk Adım',
        description: 'İlk haberini oku',
        icon: '📰',
        category: BadgeCategory.reading,
        tier: BadgeTier.bronze,
        requiredValue: 1,
      ),
      const Badge(
        id: 'reader_10',
        name: 'Meraklı Okuyucu',
        description: '10 haber oku',
        icon: '📚',
        category: BadgeCategory.reading,
        tier: BadgeTier.bronze,
        requiredValue: 10,
      ),
      const Badge(
        id: 'reader_50',
        name: 'Haber Kurdu',
        description: '50 haber oku',
        icon: '🐺',
        category: BadgeCategory.reading,
        tier: BadgeTier.silver,
        requiredValue: 50,
      ),
      const Badge(
        id: 'reader_100',
        name: 'Haber Uzmanı',
        description: '100 haber oku',
        icon: '🎓',
        category: BadgeCategory.reading,
        tier: BadgeTier.gold,
        requiredValue: 100,
      ),
      const Badge(
        id: 'reader_500',
        name: 'Haber Gurusu',
        description: '500 haber oku',
        icon: '🧙',
        category: BadgeCategory.reading,
        tier: BadgeTier.platinum,
        requiredValue: 500,
      ),
      const Badge(
        id: 'reader_1000',
        name: 'Haber Efsanesi',
        description: '1000 haber oku',
        icon: '👑',
        category: BadgeCategory.reading,
        tier: BadgeTier.diamond,
        requiredValue: 1000,
      ),
      
      // Seri Rozetleri
      const Badge(
        id: 'streak_3',
        name: 'Başlangıç Serisi',
        description: '3 gün üst üste haber oku',
        icon: '🔥',
        category: BadgeCategory.streak,
        tier: BadgeTier.bronze,
        requiredValue: 3,
      ),
      const Badge(
        id: 'streak_7',
        name: 'Haftalık Seri',
        description: '7 gün üst üste haber oku',
        icon: '🔥',
        category: BadgeCategory.streak,
        tier: BadgeTier.silver,
        requiredValue: 7,
      ),
      const Badge(
        id: 'streak_30',
        name: 'Aylık Seri',
        description: '30 gün üst üste haber oku',
        icon: '🔥',
        category: BadgeCategory.streak,
        tier: BadgeTier.gold,
        requiredValue: 30,
      ),
      const Badge(
        id: 'streak_100',
        name: 'Yüz Günlük Seri',
        description: '100 gün üst üste haber oku',
        icon: '💯',
        category: BadgeCategory.streak,
        tier: BadgeTier.platinum,
        requiredValue: 100,
      ),
      const Badge(
        id: 'streak_365',
        name: 'Yıllık Seri',
        description: '365 gün üst üste haber oku',
        icon: '🏆',
        category: BadgeCategory.streak,
        tier: BadgeTier.diamond,
        requiredValue: 365,
      ),
      
      // Favori Rozetleri
      const Badge(
        id: 'favorite_1',
        name: 'İlk Favori',
        description: 'İlk haberini favorilere ekle',
        icon: '❤️',
        category: BadgeCategory.favorites,
        tier: BadgeTier.bronze,
        requiredValue: 1,
      ),
      const Badge(
        id: 'favorite_10',
        name: 'Koleksiyoncu',
        description: '10 haberi favorilere ekle',
        icon: '💕',
        category: BadgeCategory.favorites,
        tier: BadgeTier.silver,
        requiredValue: 10,
      ),
      const Badge(
        id: 'favorite_50',
        name: 'Arşivci',
        description: '50 haberi favorilere ekle',
        icon: '📁',
        category: BadgeCategory.favorites,
        tier: BadgeTier.gold,
        requiredValue: 50,
      ),
      const Badge(
        id: 'favorite_100',
        name: 'Kütüphaneci',
        description: '100 haberi favorilere ekle',
        icon: '📚',
        category: BadgeCategory.favorites,
        tier: BadgeTier.platinum,
        requiredValue: 100,
      ),
      
      // Paylaşım Rozetleri
      const Badge(
        id: 'share_1',
        name: 'İlk Paylaşım',
        description: 'İlk haberini paylaş',
        icon: '📤',
        category: BadgeCategory.sharing,
        tier: BadgeTier.bronze,
        requiredValue: 1,
      ),
      const Badge(
        id: 'share_10',
        name: 'Sosyal Okuyucu',
        description: '10 haber paylaş',
        icon: '🌐',
        category: BadgeCategory.sharing,
        tier: BadgeTier.silver,
        requiredValue: 10,
      ),
      const Badge(
        id: 'share_50',
        name: 'Haber Elçisi',
        description: '50 haber paylaş',
        icon: '📢',
        category: BadgeCategory.sharing,
        tier: BadgeTier.gold,
        requiredValue: 50,
      ),
      
      // Keşif Rozetleri
      const Badge(
        id: 'category_5',
        name: 'Kaşif',
        description: '5 farklı kategoriden haber oku',
        icon: '🧭',
        category: BadgeCategory.exploration,
        tier: BadgeTier.bronze,
        requiredValue: 5,
      ),
      const Badge(
        id: 'category_all',
        name: 'Çok Yönlü',
        description: 'Tüm kategorilerden haber oku',
        icon: '🌈',
        category: BadgeCategory.exploration,
        tier: BadgeTier.gold,
        requiredValue: 10,
      ),
      const Badge(
        id: 'search_10',
        name: 'Araştırmacı',
        description: '10 farklı arama yap',
        icon: '🔍',
        category: BadgeCategory.exploration,
        tier: BadgeTier.silver,
        requiredValue: 10,
      ),
      
      // Başarı Rozetleri
      const Badge(
        id: 'level_5',
        name: 'Yükselen Yıldız',
        description: 'Seviye 5\'e ulaş',
        icon: '⭐',
        category: BadgeCategory.achievement,
        tier: BadgeTier.bronze,
        requiredValue: 5,
      ),
      const Badge(
        id: 'level_10',
        name: 'Deneyimli',
        description: 'Seviye 10\'a ulaş',
        icon: '🌟',
        category: BadgeCategory.achievement,
        tier: BadgeTier.silver,
        requiredValue: 10,
      ),
      const Badge(
        id: 'level_25',
        name: 'Usta',
        description: 'Seviye 25\'e ulaş',
        icon: '💫',
        category: BadgeCategory.achievement,
        tier: BadgeTier.gold,
        requiredValue: 25,
      ),
      const Badge(
        id: 'level_50',
        name: 'Efsane',
        description: 'Seviye 50\'ye ulaş',
        icon: '✨',
        category: BadgeCategory.achievement,
        tier: BadgeTier.platinum,
        requiredValue: 50,
      ),
      const Badge(
        id: 'points_1000',
        name: 'Bin Puan',
        description: '1000 puan kazan',
        icon: '🎯',
        category: BadgeCategory.achievement,
        tier: BadgeTier.silver,
        requiredValue: 1000,
      ),
      const Badge(
        id: 'points_10000',
        name: 'On Bin Puan',
        description: '10000 puan kazan',
        icon: '🏅',
        category: BadgeCategory.achievement,
        tier: BadgeTier.gold,
        requiredValue: 10000,
      ),
      
      // Özel Rozetler
      const Badge(
        id: 'early_bird',
        name: 'Erken Kuş',
        description: 'Sabah 6-8 arası haber oku',
        icon: '🐦',
        category: BadgeCategory.special,
        tier: BadgeTier.bronze,
        requiredValue: 1,
      ),
      const Badge(
        id: 'night_owl',
        name: 'Gece Kuşu',
        description: 'Gece 00-04 arası haber oku',
        icon: '🦉',
        category: BadgeCategory.special,
        tier: BadgeTier.bronze,
        requiredValue: 1,
      ),
      const Badge(
        id: 'weekend_reader',
        name: 'Hafta Sonu Okuyucusu',
        description: 'Hafta sonu 10 haber oku',
        icon: '☕',
        category: BadgeCategory.special,
        tier: BadgeTier.silver,
        requiredValue: 10,
      ),
    ];
  }
  
  /// XP kazandır
  Future<XPGainResult> addXP(int amount, String reason) async {
    final oldLevel = _state.userLevel.level;
    final newTotalXP = _state.userLevel.totalXP + amount;
    final newCurrentXP = _state.userLevel.currentXP + amount;
    
    // Seviye atlama kontrolü
    int level = _state.userLevel.level;
    int currentXP = newCurrentXP;
    int requiredXP = _state.userLevel.requiredXP;
    bool leveledUp = false;
    
    while (currentXP >= requiredXP) {
      currentXP -= requiredXP;
      level++;
      requiredXP = _calculateRequiredXP(level);
      leveledUp = true;
    }
    
    final newUserLevel = UserLevel(
      level: level,
      title: _getLevelTitle(level),
      currentXP: currentXP,
      requiredXP: requiredXP,
      totalXP: newTotalXP,
    );
    
    _state = _state.copyWith(
      userLevel: newUserLevel,
      totalPoints: _state.totalPoints + amount,
    );
    
    await _saveState();
    
    // Seviye rozetlerini kontrol et
    if (leveledUp) {
      await _checkLevelBadges(level);
    }
    
    // Puan rozetlerini kontrol et
    await _checkPointsBadges(_state.totalPoints);
    
    return XPGainResult(
      xpGained: amount,
      reason: reason,
      leveledUp: leveledUp,
      oldLevel: oldLevel,
      newLevel: level,
      newUserLevel: newUserLevel,
    );
  }
  
  /// Seviye için gereken XP'yi hesapla
  int _calculateRequiredXP(int level) {
    // Her seviye için gereken XP artıyor
    return 100 + (level - 1) * 50;
  }
  
  /// Seviye başlığını al
  String _getLevelTitle(int level) {
    if (level < 5) return 'Yeni Okuyucu';
    if (level < 10) return 'Meraklı Okuyucu';
    if (level < 15) return 'Düzenli Okuyucu';
    if (level < 20) return 'Haber Takipçisi';
    if (level < 25) return 'Haber Uzmanı';
    if (level < 30) return 'Haber Gurusu';
    if (level < 40) return 'Haber Ustası';
    if (level < 50) return 'Haber Efsanesi';
    return 'Haber Tanrısı';
  }
  
  /// Haber okuma kaydı
  Future<List<Badge>> recordArticleRead({
    required String category,
    required int totalArticlesRead,
  }) async {
    final unlockedBadges = <Badge>[];
    
    // XP kazandır
    await addXP(10, 'Haber okuma');
    
    // Günlük seriyi güncelle
    await _updateDailyStreak();
    
    // Okuma rozetlerini kontrol et
    final readingBadges = await _checkReadingBadges(totalArticlesRead);
    unlockedBadges.addAll(readingBadges);
    
    // Seri rozetlerini kontrol et
    final streakBadges = await _checkStreakBadges(_state.dailyStreak);
    unlockedBadges.addAll(streakBadges);
    
    // Özel zaman rozetlerini kontrol et
    final timeBadges = await _checkTimeBadges();
    unlockedBadges.addAll(timeBadges);
    
    return unlockedBadges;
  }
  
  /// Favori ekleme kaydı
  Future<List<Badge>> recordFavoriteAdded(int totalFavorites) async {
    final unlockedBadges = <Badge>[];
    
    // XP kazandır
    await addXP(5, 'Favorilere ekleme');
    
    // Favori rozetlerini kontrol et
    final favoriteBadges = await _checkFavoriteBadges(totalFavorites);
    unlockedBadges.addAll(favoriteBadges);
    
    return unlockedBadges;
  }
  
  /// Paylaşım kaydı
  Future<List<Badge>> recordShare(int totalShares) async {
    final unlockedBadges = <Badge>[];
    
    // XP kazandır
    await addXP(15, 'Haber paylaşma');
    
    // Paylaşım rozetlerini kontrol et
    final shareBadges = await _checkShareBadges(totalShares);
    unlockedBadges.addAll(shareBadges);
    
    return unlockedBadges;
  }
  
  /// Arama kaydı
  Future<List<Badge>> recordSearch(int totalSearches) async {
    final unlockedBadges = <Badge>[];
    
    // XP kazandır
    await addXP(2, 'Arama yapma');
    
    // Arama rozetlerini kontrol et
    final searchBadges = await _checkSearchBadges(totalSearches);
    unlockedBadges.addAll(searchBadges);
    
    return unlockedBadges;
  }
  
  /// Günlük seriyi güncelle
  Future<void> _updateDailyStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_state.lastActivityDate != null) {
      final lastActivity = DateTime(
        _state.lastActivityDate!.year,
        _state.lastActivityDate!.month,
        _state.lastActivityDate!.day,
      );
      
      final difference = today.difference(lastActivity).inDays;
      
      if (difference == 0) {
        // Bugün zaten aktivite var, değişiklik yok
        return;
      } else if (difference == 1) {
        // Dün aktivite vardı, seri devam ediyor
        final newStreak = _state.dailyStreak + 1;
        final newLongestStreak = newStreak > _state.longestStreak
            ? newStreak
            : _state.longestStreak;
        
        _state = _state.copyWith(
          dailyStreak: newStreak,
          longestStreak: newLongestStreak,
          lastActivityDate: now,
        );
      } else {
        // Seri kırıldı
        _state = _state.copyWith(
          dailyStreak: 1,
          lastActivityDate: now,
        );
      }
    } else {
      // İlk aktivite
      _state = _state.copyWith(
        dailyStreak: 1,
        lastActivityDate: now,
      );
    }
    
    await _saveState();
  }
  
  /// Okuma rozetlerini kontrol et
  Future<List<Badge>> _checkReadingBadges(int totalArticlesRead) async {
    return _checkBadgesByCategory(
      BadgeCategory.reading,
      totalArticlesRead,
      ['first_read', 'reader_10', 'reader_50', 'reader_100', 'reader_500', 'reader_1000'],
    );
  }
  
  /// Seri rozetlerini kontrol et
  Future<List<Badge>> _checkStreakBadges(int streak) async {
    return _checkBadgesByCategory(
      BadgeCategory.streak,
      streak,
      ['streak_3', 'streak_7', 'streak_30', 'streak_100', 'streak_365'],
    );
  }
  
  /// Favori rozetlerini kontrol et
  Future<List<Badge>> _checkFavoriteBadges(int totalFavorites) async {
    return _checkBadgesByCategory(
      BadgeCategory.favorites,
      totalFavorites,
      ['favorite_1', 'favorite_10', 'favorite_50', 'favorite_100'],
    );
  }
  
  /// Paylaşım rozetlerini kontrol et
  Future<List<Badge>> _checkShareBadges(int totalShares) async {
    return _checkBadgesByCategory(
      BadgeCategory.sharing,
      totalShares,
      ['share_1', 'share_10', 'share_50'],
    );
  }
  
  /// Arama rozetlerini kontrol et
  Future<List<Badge>> _checkSearchBadges(int totalSearches) async {
    return _checkBadgesByCategory(
      BadgeCategory.exploration,
      totalSearches,
      ['search_10'],
    );
  }
  
  /// Seviye rozetlerini kontrol et
  Future<List<Badge>> _checkLevelBadges(int level) async {
    return _checkBadgesByCategory(
      BadgeCategory.achievement,
      level,
      ['level_5', 'level_10', 'level_25', 'level_50'],
    );
  }
  
  /// Puan rozetlerini kontrol et
  Future<List<Badge>> _checkPointsBadges(int totalPoints) async {
    return _checkBadgesByCategory(
      BadgeCategory.achievement,
      totalPoints,
      ['points_1000', 'points_10000'],
    );
  }
  
  /// Zaman bazlı rozetleri kontrol et
  Future<List<Badge>> _checkTimeBadges() async {
    final unlockedBadges = <Badge>[];
    final now = DateTime.now();
    final hour = now.hour;
    
    // Erken kuş (06:00 - 08:00)
    if (hour >= 6 && hour < 8) {
      final badge = await _unlockBadge('early_bird');
      if (badge != null) unlockedBadges.add(badge);
    }
    
    // Gece kuşu (00:00 - 04:00)
    if (hour >= 0 && hour < 4) {
      final badge = await _unlockBadge('night_owl');
      if (badge != null) unlockedBadges.add(badge);
    }
    
    return unlockedBadges;
  }
  
  /// Kategoriye göre rozetleri kontrol et
  Future<List<Badge>> _checkBadgesByCategory(
    BadgeCategory category,
    int currentValue,
    List<String> badgeIds,
  ) async {
    final unlockedBadges = <Badge>[];
    
    for (final badgeId in badgeIds) {
      final badgeIndex = _state.badges.indexWhere((b) => b.id == badgeId);
      if (badgeIndex == -1) continue;
      
      final badge = _state.badges[badgeIndex];
      if (badge.isUnlocked) continue;
      
      // İlerlemeyi güncelle
      final progress = (currentValue / badge.requiredValue).clamp(0.0, 1.0);
      final updatedBadge = badge.copyWith(progress: progress);
      
      if (currentValue >= badge.requiredValue) {
        // Rozet açıldı!
        final unlockedBadge = updatedBadge.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          progress: 1.0,
        );
        
        final badges = List<Badge>.from(_state.badges);
        badges[badgeIndex] = unlockedBadge;
        _state = _state.copyWith(badges: badges);
        
        unlockedBadges.add(unlockedBadge);
      } else {
        // Sadece ilerlemeyi güncelle
        final badges = List<Badge>.from(_state.badges);
        badges[badgeIndex] = updatedBadge;
        _state = _state.copyWith(badges: badges);
      }
    }
    
    if (unlockedBadges.isNotEmpty) {
      await _saveState();
    }
    
    return unlockedBadges;
  }
  
  /// Rozeti aç
  Future<Badge?> _unlockBadge(String badgeId) async {
    final badgeIndex = _state.badges.indexWhere((b) => b.id == badgeId);
    if (badgeIndex == -1) return null;
    
    final badge = _state.badges[badgeIndex];
    if (badge.isUnlocked) return null;
    
    final unlockedBadge = badge.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      progress: 1.0,
    );
    
    final badges = List<Badge>.from(_state.badges);
    badges[badgeIndex] = unlockedBadge;
    _state = _state.copyWith(badges: badges);
    
    await _saveState();
    
    return unlockedBadge;
  }
  
  /// Kategoriye göre rozetleri getir
  List<Badge> getBadgesByCategory(BadgeCategory category) {
    return _state.badges.where((b) => b.category == category).toList();
  }
  
  /// Açılmış rozetleri getir
  List<Badge> getUnlockedBadges() {
    return _state.badges.where((b) => b.isUnlocked).toList();
  }
  
  /// Kilitli rozetleri getir
  List<Badge> getLockedBadges() {
    return _state.badges.where((b) => !b.isUnlocked).toList();
  }
  
  /// Son açılan rozetleri getir
  List<Badge> getRecentlyUnlockedBadges({int limit = 5}) {
    final unlocked = getUnlockedBadges();
    unlocked.sort((a, b) => (b.unlockedAt ?? DateTime(2000))
        .compareTo(a.unlockedAt ?? DateTime(2000)));
    return unlocked.take(limit).toList();
  }
}

/// XP kazanım sonucu
class XPGainResult {
  final int xpGained;
  final String reason;
  final bool leveledUp;
  final int oldLevel;
  final int newLevel;
  final UserLevel newUserLevel;

  const XPGainResult({
    required this.xpGained,
    required this.reason,
    required this.leveledUp,
    required this.oldLevel,
    required this.newLevel,
    required this.newUserLevel,
  });
}