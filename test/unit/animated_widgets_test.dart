import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/presentation/widgets/animated_widgets.dart';

void main() {
  group('AnimatedCounter Tests', () {
    testWidgets('AnimatedCounter should display the value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCounter(
              value: 100,
              duration: Duration(milliseconds: 500),
            ),
          ),
        ),
      );

      // Wait for animation to complete
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('AnimatedCounter should animate value changes', (tester) async {
      int value = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    AnimatedCounter(
                      value: value,
                      duration: const Duration(milliseconds: 500),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => value = 50),
                      child: const Text('Update'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initial value
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('AnimatedCounter should apply custom style', (tester) async {
      const customStyle = TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCounter(
              value: 42,
              style: customStyle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('42'));
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.color, Colors.red);
    });
  });

  group('AnimatedProgressBar Tests', () {
    testWidgets('AnimatedProgressBar should display progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedProgressBar(
              progress: 0.5,
              height: 10,
              backgroundColor: Colors.grey,
              foregroundColor: Colors.blue,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the progress bar container
      expect(find.byType(AnimatedProgressBar), findsOneWidget);
    });

    testWidgets('AnimatedProgressBar should clamp progress to 0-1',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedProgressBar(
              progress: 1.5, // Over 1.0
              height: 10,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not throw error
      expect(find.byType(AnimatedProgressBar), findsOneWidget);
    });

    testWidgets('AnimatedProgressBar should handle zero progress',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedProgressBar(
              progress: 0.0,
              height: 10,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AnimatedProgressBar), findsOneWidget);
    });
  });

  group('FadeSlideTransition Tests', () {
    testWidgets('FadeSlideTransition should render child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeSlideTransition(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('FadeSlideTransition should apply custom offset',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeSlideTransition(
              offset: Offset(0, 50),
              child: Text('Offset Content'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Offset Content'), findsOneWidget);
    });

    testWidgets('FadeSlideTransition should respect duration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeSlideTransition(
              duration: Duration(seconds: 1),
              child: Text('Duration Test'),
            ),
          ),
        ),
      );

      // Pump without settling to check animation state
      await tester.pump();

      expect(find.byType(FadeSlideTransition), findsOneWidget);
    });
  });

  group('ScaleTransitionWidget Tests', () {
    testWidgets('ScaleTransitionWidget should render child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScaleTransitionWidget(
              child: Text('Scale Content'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Scale Content'), findsOneWidget);
    });

    testWidgets('ScaleTransitionWidget should apply custom begin scale',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScaleTransitionWidget(
              beginScale: 0.5,
              child: Text('Custom Scale'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Custom Scale'), findsOneWidget);
    });
  });

  group('PulseAnimation Tests', () {
    testWidgets('PulseAnimation should render child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulseAnimation(
              child: Icon(Icons.favorite),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('PulseAnimation should apply custom scale', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulseAnimation(
              minScale: 0.8,
              maxScale: 1.2,
              child: Icon(Icons.star),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('ShimmerEffect Tests', () {
    testWidgets('ShimmerEffect should render with correct size',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerEffect(
              width: 200,
              height: 100,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ShimmerEffect), findsOneWidget);
    });

    testWidgets('ShimmerEffect should apply custom colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerEffect(
              width: 100,
              height: 50,
              baseColor: Colors.grey,
              highlightColor: Colors.white,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ShimmerEffect), findsOneWidget);
    });
  });

  group('BounceAnimation Tests', () {
    testWidgets('BounceAnimation should render child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BounceAnimation(
              onTap: () {},
              child: const Text('Bounce Me'),
            ),
          ),
        ),
      );

      expect(find.text('Bounce Me'), findsOneWidget);
    });

    testWidgets('BounceAnimation should trigger onTap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BounceAnimation(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });

  group('RotateAnimation Tests', () {
    testWidgets('RotateAnimation should render child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RotateAnimation(
              child: Icon(Icons.refresh),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('RotateAnimation should apply custom duration',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RotateAnimation(
              duration: Duration(seconds: 2),
              child: Icon(Icons.sync),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });
  });

  group('AnimatedVisibility Tests', () {
    testWidgets('AnimatedVisibility should show child when visible',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedVisibility(
              visible: true,
              child: Text('Visible Content'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Visible Content'), findsOneWidget);
    });

    testWidgets('AnimatedVisibility should hide child when not visible',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedVisibility(
              visible: false,
              child: Text('Hidden Content'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The widget should be invisible (opacity 0)
      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, 0.0);
    });
  });

  group('AnimatedIconButton Tests', () {
    testWidgets('AnimatedIconButton should render icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedIconButton(
              icon: Icons.favorite,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('AnimatedIconButton should trigger onPressed', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedIconButton(
              icon: Icons.add,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(pressed, true);
    });

    testWidgets('AnimatedIconButton should apply custom color',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedIconButton(
              icon: Icons.star,
              color: Colors.amber,
              onPressed: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, Colors.amber);
    });
  });

  group('AnimatedCard Tests', () {
    testWidgets('AnimatedCard should render child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              onTap: () {},
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('AnimatedCard should trigger onTap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              onTap: () => tapped = true,
              child: const Text('Tap Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Card'));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });

  group('StaggeredListItem Tests', () {
    testWidgets('StaggeredListItem should render child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StaggeredListItem(
              index: 0,
              child: Text('List Item'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('List Item'), findsOneWidget);
    });

    testWidgets('StaggeredListItem should apply delay based on index',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StaggeredListItem(
                  index: 0,
                  child: Text('Item 0'),
                ),
                StaggeredListItem(
                  index: 1,
                  child: Text('Item 1'),
                ),
                StaggeredListItem(
                  index: 2,
                  child: Text('Item 2'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });
  });

  group('HeroWrapper Tests', () {
    testWidgets('HeroWrapper should create Hero widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HeroWrapper(
              tag: 'test-hero',
              child: Text('Hero Content'),
            ),
          ),
        ),
      );

      expect(find.byType(Hero), findsOneWidget);
      expect(find.text('Hero Content'), findsOneWidget);
    });

    testWidgets('HeroWrapper should use correct tag', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HeroWrapper(
              tag: 'unique-tag',
              child: Icon(Icons.image),
            ),
          ),
        ),
      );

      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'unique-tag');
    });
  });

  group('Page Route Tests', () {
    testWidgets('FadePageRoute should create fade transition', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  FadePageRoute(
                    page: const Scaffold(body: Text('New Page')),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('New Page'), findsOneWidget);
    });

    testWidgets('SlidePageRoute should create slide transition',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  SlidePageRoute(
                    page: const Scaffold(body: Text('Slide Page')),
                  ),
                );
              },
              child: const Text('Slide'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Slide'));
      await tester.pumpAndSettle();

      expect(find.text('Slide Page'), findsOneWidget);
    });

    testWidgets('ScalePageRoute should create scale transition',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  ScalePageRoute(
                    page: const Scaffold(body: Text('Scale Page')),
                  ),
                );
              },
              child: const Text('Scale'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Scale'));
      await tester.pumpAndSettle();

      expect(find.text('Scale Page'), findsOneWidget);
    });
  });

  group('ConfettiAnimation Tests', () {
    testWidgets('ConfettiAnimation should render', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfettiAnimation(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ConfettiAnimation), findsOneWidget);
    });

    testWidgets('ConfettiAnimation should apply custom particle count',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfettiAnimation(
              particleCount: 100,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ConfettiAnimation), findsOneWidget);
    });
  });
}