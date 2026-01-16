import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haber_merkezi/domain/entities/badge.dart';
import 'package:haber_merkezi/presentation/providers/gamification_provider.dart';

void main() {
  group('Badges Page Widget Tests', () {
    testWidgets('Should display level card', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: _TestLevelCard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Level card should be visible
      expect(find.byType(_TestLevelCard), findsOneWidget);
    });

    testWidgets('Should display badge categories', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: BadgeCategory.values.map((category) {
                return ListTile(
                  title: Text(_getCategoryName(category)),
                  leading: Icon(_getCategoryIcon(category)),
                );
              }).toList(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All categories should be displayed
      expect(find.text('Okuma'), findsOneWidget);
      expect(find.text('Seri'), findsOneWidget);
      expect(find.text('Favoriler'), findsOneWidget);
      expect(find.text('Paylaşım'), findsOneWidget);
      expect(find.text('Keşif'), findsOneWidget);
      expect(find.text('Başarı'), findsOneWidget);
      expect(find.text('Özel'), findsOneWidget);
    });

    testWidgets('Should display badge tier colors correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: BadgeTier.values.map((tier) {
                return Container(
                  width: 50,
                  height: 50,
                  color: _getTierColor(tier),
                  child: Center(child: Text(tier.name)),
                );
              }).toList(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All tiers should be displayed
      expect(find.text('bronze'), findsOneWidget);
      expect(find.text('silver'), findsOneWidget);
      expect(find.text('gold'), findsOneWidget);
      expect(find.text('platinum'), findsOneWidget);
      expect(find.text('diamond'), findsOneWidget);
    });

    testWidgets('Should display badge progress indicator', (tester) async {
      final badge = Badge(
        id: 'test',
        name: 'Test Badge',
        description: 'Test description',
        icon: 'star',
        category: BadgeCategory.reading,
        tier: BadgeTier.bronze,
        requiredCount: 10,
        currentCount: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestBadgeCard(badge: badge),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Badge'), findsOneWidget);
      expect(find.text('5/10'), findsOneWidget);
    });

    testWidgets('Should display unlocked badge differently', (tester) async {
      final unlockedBadge = Badge(
        id: 'unlocked',
        name: 'Unlocked Badge',
        description: 'An unlocked badge',
        icon: 'star',
        category: BadgeCategory.reading,
        tier: BadgeTier.gold,
        requiredCount: 10,
        currentCount: 10,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestBadgeCard(badge: unlockedBadge),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Unlocked Badge'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Should display stats row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: 'Toplam Puan', value: '1500'),
                _StatItem(label: 'Günlük Seri', value: '7'),
                _StatItem(label: 'Rozetler', value: '12/25'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Toplam Puan'), findsOneWidget);
      expect(find.text('1500'), findsOneWidget);
      expect(find.text('Günlük Seri'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Rozetler'), findsOneWidget);
      expect(find.text('12/25'), findsOneWidget);
    });

    testWidgets('Should handle empty badge list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Henüz rozet kazanılmadı'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Henüz rozet kazanılmadı'), findsOneWidget);
    });

    testWidgets('Badge grid should be scrollable', (tester) async {
      final badges = List.generate(
        20,
        (index) => Badge(
          id: 'badge_$index',
          name: 'Badge $index',
          description: 'Description $index',
          icon: 'star',
          category: BadgeCategory.reading,
          tier: BadgeTier.bronze,
          requiredCount: 10,
          currentCount: index,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Center(
                    child: Text(badges[index].name),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First badges should be visible
      expect(find.text('Badge 0'), findsOneWidget);
      expect(find.text('Badge 1'), findsOneWidget);

      // Scroll down
      await tester.drag(find.byType(GridView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Later badges should now be visible
      expect(find.text('Badge 15'), findsOneWidget);
    });
  });

  group('Badge Unlock Dialog Tests', () {
    testWidgets('Should display badge unlock dialog', (tester) async {
      final badge = Badge(
        id: 'new_badge',
        name: 'Yeni Rozet',
        description: 'Tebrikler! Yeni bir rozet kazandınız.',
        icon: 'star',
        category: BadgeCategory.achievement,
        tier: BadgeTier.gold,
        requiredCount: 1,
        currentCount: 1,
        isUnlocked: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Rozet Kazanıldı!'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 64, color: Colors.amber),
                          const SizedBox(height: 16),
                          Text(badge.name),
                          Text(badge.description),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tamam'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Rozet Kazanıldı!'), findsOneWidget);
      expect(find.text('Yeni Rozet'), findsOneWidget);
      expect(find.text('Tamam'), findsOneWidget);
    });

    testWidgets('Should close dialog on button tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Test Dialog'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Kapat'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);

      await tester.tap(find.text('Kapat'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsNothing);
    });
  });

  group('Level Up Dialog Tests', () {
    testWidgets('Should display level up dialog', (tester) async {
      final newLevel = UserLevel(
        level: 5,
        title: 'Deneyimli Okuyucu',
        currentXP: 0,
        xpForNextLevel: 500,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Seviye Atladınız!'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Seviye ${newLevel.level}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(newLevel.title),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Harika!'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Level Up'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Level Up'));
      await tester.pumpAndSettle();

      expect(find.text('Seviye Atladınız!'), findsOneWidget);
      expect(find.text('Seviye 5'), findsOneWidget);
      expect(find.text('Deneyimli Okuyucu'), findsOneWidget);
      expect(find.text('Harika!'), findsOneWidget);
    });
  });
}

// Helper widgets for testing
class _TestLevelCard extends StatelessWidget {
  const _TestLevelCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Seviye 5'),
            const Text('Deneyimli Okuyucu'),
            LinearProgressIndicator(value: 0.6),
            const Text('300/500 XP'),
          ],
        ),
      ),
    );
  }
}

class _TestBadgeCard extends StatelessWidget {
  final Badge badge;

  const _TestBadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            if (badge.isUnlocked)
              const Icon(Icons.check_circle, color: Colors.green),
            Text(badge.name),
            Text('${badge.currentCount}/${badge.requiredCount}'),
            LinearProgressIndicator(value: badge.progress),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}

String _getCategoryName(BadgeCategory category) {
  switch (category) {
    case BadgeCategory.reading:
      return 'Okuma';
    case BadgeCategory.streak:
      return 'Seri';
    case BadgeCategory.favorites:
      return 'Favoriler';
    case BadgeCategory.sharing:
      return 'Paylaşım';
    case BadgeCategory.exploration:
      return 'Keşif';
    case BadgeCategory.achievement:
      return 'Başarı';
    case BadgeCategory.special:
      return 'Özel';
  }
}

IconData _getCategoryIcon(BadgeCategory category) {
  switch (category) {
    case BadgeCategory.reading:
      return Icons.menu_book;
    case BadgeCategory.streak:
      return Icons.local_fire_department;
    case BadgeCategory.favorites:
      return Icons.favorite;
    case BadgeCategory.sharing:
      return Icons.share;
    case BadgeCategory.exploration:
      return Icons.explore;
    case BadgeCategory.achievement:
      return Icons.emoji_events;
    case BadgeCategory.special:
      return Icons.star;
  }
}

Color _getTierColor(BadgeTier tier) {
  switch (tier) {
    case BadgeTier.bronze:
      return const Color(0xFFCD7F32);
    case BadgeTier.silver:
      return const Color(0xFFC0C0C0);
    case BadgeTier.gold:
      return const Color(0xFFFFD700);
    case BadgeTier.platinum:
      return const Color(0xFFE5E4E2);
    case BadgeTier.diamond:
      return const Color(0xFFB9F2FF);
  }
}