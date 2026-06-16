import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/badge.dart';
import '../../core/services/gamification_service.dart';

/// Gamification state provider
final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
      return GamificationNotifier();
    });

/// Gamification notifier
class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(GamificationState.initial()) {
    _init();
  }

  final GamificationService _service = GamificationService.instance;

  Future<void> _init() async {
    try {
      await _service.init();
      state = _service.state;
    } catch (e) {
      debugPrint('❌ GamificationNotifier init error: $e');
    }
  }

  /// Haber okuma kaydı
  Future<List<Badge>> recordArticleRead({
    required String category,
    required int totalArticlesRead,
  }) async {
    try {
      final unlockedBadges = await _service.recordArticleRead(
        category: category,
        totalArticlesRead: totalArticlesRead,
      );
      state = _service.state;
      return unlockedBadges;
    } catch (e) {
      debugPrint('❌ recordArticleRead error: $e');
      return [];
    }
  }

  /// Favori ekleme kaydı
  Future<List<Badge>> recordFavoriteAdded(int totalFavorites) async {
    try {
      final unlockedBadges = await _service.recordFavoriteAdded(totalFavorites);
      state = _service.state;
      return unlockedBadges;
    } catch (e) {
      debugPrint('❌ recordFavoriteAdded error: $e');
      return [];
    }
  }

  /// Paylaşım kaydı
  Future<List<Badge>> recordShare(int totalShares) async {
    try {
      final unlockedBadges = await _service.recordShare(totalShares);
      state = _service.state;
      return unlockedBadges;
    } catch (e) {
      debugPrint('❌ recordShare error: $e');
      return [];
    }
  }

  /// Arama kaydı
  Future<List<Badge>> recordSearch(int totalSearches) async {
    try {
      final unlockedBadges = await _service.recordSearch(totalSearches);
      state = _service.state;
      return unlockedBadges;
    } catch (e) {
      debugPrint('❌ recordSearch error: $e');
      return [];
    }
  }

  /// XP ekle
  Future<XPGainResult?> addXP(int amount, String reason) async {
    try {
      final result = await _service.addXP(amount, reason);
      state = _service.state;
      return result;
    } catch (e) {
      debugPrint('❌ addXP error: $e');
      return null;
    }
  }

  /// Kategoriye göre rozetleri getir
  List<Badge> getBadgesByCategory(BadgeCategory category) {
    return _service.getBadgesByCategory(category);
  }

  /// Açılmış rozetleri getir
  List<Badge> getUnlockedBadges() {
    return _service.getUnlockedBadges();
  }

  /// Kilitli rozetleri getir
  List<Badge> getLockedBadges() {
    return _service.getLockedBadges();
  }

  /// Son açılan rozetleri getir
  List<Badge> getRecentlyUnlockedBadges({int limit = 5}) {
    return _service.getRecentlyUnlockedBadges(limit: limit);
  }

  /// State'i yenile
  void refresh() {
    state = _service.state;
  }
}

/// Kullanıcı seviyesi provider
final userLevelProvider = Provider<UserLevel>((ref) {
  final gamificationState = ref.watch(gamificationProvider);
  return gamificationState.userLevel;
});

/// Toplam puan provider
final totalPointsProvider = Provider<int>((ref) {
  final gamificationState = ref.watch(gamificationProvider);
  return gamificationState.totalPoints;
});

/// Günlük seri provider
final dailyStreakProvider = Provider<int>((ref) {
  final gamificationState = ref.watch(gamificationProvider);
  return gamificationState.dailyStreak;
});

/// Açılmış rozet sayısı provider
final unlockedBadgesCountProvider = Provider<int>((ref) {
  final gamificationState = ref.watch(gamificationProvider);
  return gamificationState.unlockedBadgesCount;
});

/// Tüm rozetler provider
final allBadgesProvider = Provider<List<Badge>>((ref) {
  final gamificationState = ref.watch(gamificationProvider);
  return gamificationState.badges;
});

/// Açılmış rozetler provider
final unlockedBadgesProvider = Provider<List<Badge>>((ref) {
  final gamificationState = ref.watch(gamificationProvider);
  return gamificationState.badges.where((b) => b.isUnlocked).toList();
});

/// Kilitli rozetler provider
final lockedBadgesProvider = Provider<List<Badge>>((ref) {
  final gamificationState = ref.watch(gamificationProvider);
  return gamificationState.badges.where((b) => !b.isUnlocked).toList();
});

/// Kategoriye göre rozetler provider
final badgesByCategoryProvider = Provider.family<List<Badge>, BadgeCategory>((
  ref,
  category,
) {
  final gamificationState = ref.watch(gamificationProvider);
  return gamificationState.badges.where((b) => b.category == category).toList();
});
