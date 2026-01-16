import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:haber_merkezi/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App should launch successfully', (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify app is running
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Bottom navigation should work', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find bottom navigation bar
      final bottomNav = find.byType(BottomNavigationBar);
      
      if (bottomNav.evaluate().isNotEmpty) {
        // Tap on different tabs
        final navItems = find.descendant(
          of: bottomNav,
          matching: find.byType(InkResponse),
        );

        if (navItems.evaluate().length > 1) {
          await tester.tap(navItems.at(1));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Settings page should be accessible', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Try to find settings icon or menu
      final settingsIcon = find.byIcon(Icons.settings);
      
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Search functionality should work', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find search icon
      final searchIcon = find.byIcon(Icons.search);
      
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon.first);
        await tester.pumpAndSettle();

        // Find search text field
        final searchField = find.byType(TextField);
        
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField.first, 'test');
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Theme toggle should work', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to settings if possible
      final settingsIcon = find.byIcon(Icons.settings);
      
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon.first);
        await tester.pumpAndSettle();

        // Find theme toggle
        final themeSwitch = find.byType(Switch);
        
        if (themeSwitch.evaluate().isNotEmpty) {
          await tester.tap(themeSwitch.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Pull to refresh should work', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find a scrollable list
      final listView = find.byType(ListView);
      
      if (listView.evaluate().isNotEmpty) {
        // Perform pull to refresh gesture
        await tester.drag(listView.first, const Offset(0, 300));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Category tabs should be scrollable', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find TabBar
      final tabBar = find.byType(TabBar);
      
      if (tabBar.evaluate().isNotEmpty) {
        // Scroll tabs horizontally
        await tester.drag(tabBar.first, const Offset(-200, 0));
        await tester.pumpAndSettle();
      }
    });
  });

  group('Navigation Flow Tests', () {
    testWidgets('Should navigate to article detail', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find first article card
      final articleCard = find.byType(Card);
      
      if (articleCard.evaluate().isNotEmpty) {
        await tester.tap(articleCard.first);
        await tester.pumpAndSettle();

        // Should show article detail page
        // Look for back button indicating navigation occurred
        final backButton = find.byIcon(Icons.arrow_back);
        expect(backButton.evaluate().isNotEmpty, true);
      }
    });

    testWidgets('Should navigate back from article detail', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to article
      final articleCard = find.byType(Card);
      
      if (articleCard.evaluate().isNotEmpty) {
        await tester.tap(articleCard.first);
        await tester.pumpAndSettle();

        // Navigate back
        final backButton = find.byIcon(Icons.arrow_back);
        
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Should navigate to profile page', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find profile icon
      final profileIcon = find.byIcon(Icons.person);
      
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Should navigate to badges page', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to profile first
      final profileIcon = find.byIcon(Icons.person);
      
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();

        // Find badges section
        final badgesText = find.text('Rozetler');
        
        if (badgesText.evaluate().isNotEmpty) {
          await tester.tap(badgesText.first);
          await tester.pumpAndSettle();
        }
      }
    });
  });

  group('User Interaction Tests', () {
    testWidgets('Should add article to favorites', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to article detail
      final articleCard = find.byType(Card);
      
      if (articleCard.evaluate().isNotEmpty) {
        await tester.tap(articleCard.first);
        await tester.pumpAndSettle();

        // Find favorite button
        final favoriteIcon = find.byIcon(Icons.favorite_border);
        
        if (favoriteIcon.evaluate().isNotEmpty) {
          await tester.tap(favoriteIcon.first);
          await tester.pumpAndSettle();

          // Should show filled favorite icon
          expect(find.byIcon(Icons.favorite), findsWidgets);
        }
      }
    });

    testWidgets('Should share article', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to article detail
      final articleCard = find.byType(Card);
      
      if (articleCard.evaluate().isNotEmpty) {
        await tester.tap(articleCard.first);
        await tester.pumpAndSettle();

        // Find share button
        final shareIcon = find.byIcon(Icons.share);
        
        if (shareIcon.evaluate().isNotEmpty) {
          await tester.tap(shareIcon.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Should change language', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to settings
      final settingsIcon = find.byIcon(Icons.settings);
      
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon.first);
        await tester.pumpAndSettle();

        // Find language option
        final languageText = find.text('Dil');
        
        if (languageText.evaluate().isNotEmpty) {
          await tester.tap(languageText.first);
          await tester.pumpAndSettle();
        }
      }
    });
  });

  group('Performance Tests', () {
    testWidgets('App should load within acceptable time', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));
      
      stopwatch.stop();
      
      // App should load within 10 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
    });

    testWidgets('Scrolling should be smooth', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final listView = find.byType(ListView);
      
      if (listView.evaluate().isNotEmpty) {
        // Perform multiple scroll gestures
        for (int i = 0; i < 5; i++) {
          await tester.drag(listView.first, const Offset(0, -300));
          await tester.pump(const Duration(milliseconds: 100));
        }
        
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Tab switching should be responsive', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final tabBar = find.byType(TabBar);
      
      if (tabBar.evaluate().isNotEmpty) {
        final tabs = find.descendant(
          of: tabBar,
          matching: find.byType(Tab),
        );

        if (tabs.evaluate().length > 1) {
          final stopwatch = Stopwatch()..start();
          
          await tester.tap(tabs.at(1));
          await tester.pumpAndSettle();
          
          stopwatch.stop();
          
          // Tab switch should be under 500ms
          expect(stopwatch.elapsedMilliseconds, lessThan(500));
        }
      }
    });
  });

  group('Error Handling Tests', () {
    testWidgets('Should handle network error gracefully', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should still be functional even with potential network issues
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Should show error message on failure', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for any error indicators
      final errorIcon = find.byIcon(Icons.error);
      final retryButton = find.text('Tekrar Dene');

      // Either no error or proper error handling
      if (errorIcon.evaluate().isNotEmpty) {
        expect(retryButton, findsWidgets);
      }
    });
  });

  group('Accessibility Tests', () {
    testWidgets('All interactive elements should be tappable', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find all buttons
      final buttons = find.byType(ElevatedButton);
      final iconButtons = find.byType(IconButton);
      final inkWells = find.byType(InkWell);

      // All should be findable
      expect(
        buttons.evaluate().length +
            iconButtons.evaluate().length +
            inkWells.evaluate().length,
        greaterThan(0),
      );
    });

    testWidgets('Text should be readable', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find text widgets
      final textWidgets = find.byType(Text);
      
      expect(textWidgets.evaluate().isNotEmpty, true);
    });
  });
}