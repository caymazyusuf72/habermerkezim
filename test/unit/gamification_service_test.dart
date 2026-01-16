import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/domain/entities/badge.dart';

void main() {
  group('Badge Entity Tests', () {
    test('Badge should be created with correct properties', () {
      final badge = Badge(
        id: 'test_badge',
        name: 'Test Badge',
        description: 'A test badge',
        icon: 'star',
        category: BadgeCategory.reading,
        tier: BadgeTier.bronze,
        requiredCount: 10,
        currentCount: 5,
      );

      expect(badge.id, 'test_badge');
      expect(badge.name, 'Test Badge');
      expect(badge.description, 'A test badge');
      expect(badge.category, BadgeCategory.reading);
      expect(badge.tier, BadgeTier.bronze);
      expect(badge.requiredCount, 10);
      expect(badge.currentCount, 5);
      expect(badge.isUnlocked, false);
    });

    test('Badge should be unlocked when currentCount >= requiredCount', () {
      final unlockedBadge = Badge(
        id: 'unlocked_badge',
        name: 'Unlocked Badge',
        description: 'An unlocked badge',
        icon: 'star',
        category: BadgeCategory.reading,
        tier: BadgeTier.silver,
        requiredCount: 10,
        currentCount: 10,
        isUnlocked: true,
      );

      expect(unlockedBadge.isUnlocked, true);
    });

    test('Badge progress should be calculated correctly', () {
      final badge = Badge(
        id: 'progress_badge',
        name: 'Progress Badge',
        description: 'A badge with progress',
        icon: 'star',
        category: BadgeCategory.favorites,
        tier: BadgeTier.gold,
        requiredCount: 100,
        currentCount: 50,
      );

      expect(badge.progress, 0.5);
    });

    test('Badge progress should not exceed 1.0', () {
      final badge = Badge(
        id: 'over_badge',
        name: 'Over Badge',
        description: 'A badge with over progress',
        icon: 'star',
        category: BadgeCategory.sharing,
        tier: BadgeTier.platinum,
        requiredCount: 10,
        currentCount: 15,
        isUnlocked: true,
      );

      expect(badge.progress, 1.0);
    });

    test('Badge copyWith should work correctly', () {
      final original = Badge(
        id: 'original',
        name: 'Original',
        description: 'Original badge',
        icon: 'star',
        category: BadgeCategory.reading,
        tier: BadgeTier.bronze,
        requiredCount: 10,
        currentCount: 5,
      );

      final updated = original.copyWith(
        currentCount: 10,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.currentCount, 10);
      expect(updated.isUnlocked, true);
      expect(updated.unlockedAt, isNotNull);
    });
  });

  group('BadgeCategory Tests', () {
    test('All badge categories should have correct values', () {
      expect(BadgeCategory.values.length, 7);
      expect(BadgeCategory.values.contains(BadgeCategory.reading), true);
      expect(BadgeCategory.values.contains(BadgeCategory.streak), true);
      expect(BadgeCategory.values.contains(BadgeCategory.favorites), true);
      expect(BadgeCategory.values.contains(BadgeCategory.sharing), true);
      expect(BadgeCategory.values.contains(BadgeCategory.exploration), true);
      expect(BadgeCategory.values.contains(BadgeCategory.achievement), true);
      expect(BadgeCategory.values.contains(BadgeCategory.special), true);
    });
  });

  group('BadgeTier Tests', () {
    test('All badge tiers should have correct values', () {
      expect(BadgeTier.values.length, 5);
      expect(BadgeTier.values.contains(BadgeTier.bronze), true);
      expect(BadgeTier.values.contains(BadgeTier.silver), true);
      expect(BadgeTier.values.contains(BadgeTier.gold), true);
      expect(BadgeTier.values.contains(BadgeTier.platinum), true);
      expect(BadgeTier.values.contains(BadgeTier.diamond), true);
    });
  });

  group('UserLevel Tests', () {
    test('UserLevel should be created with correct properties', () {
      final level = UserLevel(
        level: 5,
        title: 'Deneyimli Okuyucu',
        currentXP: 450,
        xpForNextLevel: 500,
      );

      expect(level.level, 5);
      expect(level.title, 'Deneyimli Okuyucu');
      expect(level.currentXP, 450);
      expect(level.xpForNextLevel, 500);
    });

    test('UserLevel progress should be calculated correctly', () {
      final level = UserLevel(
        level: 3,
        title: 'Okuyucu',
        currentXP: 150,
        xpForNextLevel: 300,
      );

      expect(level.progressToNextLevel, 0.5);
    });

    test('UserLevel progress should not exceed 1.0', () {
      final level = UserLevel(
        level: 10,
        title: 'Usta',
        currentXP: 1000,
        xpForNextLevel: 500,
      );

      expect(level.progressToNextLevel, 1.0);
    });
  });

  group('GamificationState Tests', () {
    test('GamificationState.initial should have default values', () {
      final state = GamificationState.initial();

      expect(state.badges, isEmpty);
      expect(state.userLevel.level, 1);
      expect(state.totalPoints, 0);
      expect(state.dailyStreak, 0);
      expect(state.unlockedBadgesCount, 0);
    });

    test('GamificationState copyWith should work correctly', () {
      final initial = GamificationState.initial();
      final updated = initial.copyWith(
        totalPoints: 100,
        dailyStreak: 5,
      );

      expect(updated.totalPoints, 100);
      expect(updated.dailyStreak, 5);
      expect(updated.badges, initial.badges);
    });
  });

  group('XPGainResult Tests', () {
    test('XPGainResult should track level up correctly', () {
      final result = XPGainResult(
        xpGained: 50,
        totalXP: 150,
        leveledUp: true,
        newLevel: UserLevel(
          level: 2,
          title: 'Okuyucu',
          currentXP: 50,
          xpForNextLevel: 200,
        ),
      );

      expect(result.xpGained, 50);
      expect(result.totalXP, 150);
      expect(result.leveledUp, true);
      expect(result.newLevel.level, 2);
    });

    test('XPGainResult should handle no level up', () {
      final result = XPGainResult(
        xpGained: 10,
        totalXP: 60,
        leveledUp: false,
        newLevel: UserLevel(
          level: 1,
          title: 'Yeni Başlayan',
          currentXP: 60,
          xpForNextLevel: 100,
        ),
      );

      expect(result.leveledUp, false);
      expect(result.newLevel.level, 1);
    });
  });
}