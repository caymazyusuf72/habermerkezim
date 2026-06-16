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

      // Verify app is running - MaterialApp her zaman olmalı
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have interactive elements', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Uygulama yüklendikten sonra en az bir tıklanabilir element olmalı
      final buttons = find.byType(ElevatedButton);
      final iconButtons = find.byType(IconButton);
      final inkWells = find.byType(InkWell);
      final gestureDetectors = find.byType(GestureDetector);

      final totalInteractive =
          buttons.evaluate().length +
          iconButtons.evaluate().length +
          inkWells.evaluate().length +
          gestureDetectors.evaluate().length;

      expect(
        totalInteractive,
        greaterThan(0),
        reason: 'Uygulama en az bir etkileşimli element içermeli',
      );
    });

    testWidgets('App should display text content', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Uygulama yüklendikten sonra metin widget'ları olmalı
      final textWidgets = find.byType(Text);
      expect(
        textWidgets.evaluate().isNotEmpty,
        true,
        reason: 'Uygulama metin içermeli',
      );
    });
  });

  group('Error Handling Tests', () {
    testWidgets('App should handle startup gracefully', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App crash etmeden yüklenmeli
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Performance Tests', () {
    testWidgets('App should load within acceptable time', (tester) async {
      final stopwatch = Stopwatch()..start();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      stopwatch.stop();

      // App 10 saniye içinde yüklenmeli
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(10000),
        reason: 'Uygulama 10 saniye içinde yüklenmeli',
      );
    });
  });
}
