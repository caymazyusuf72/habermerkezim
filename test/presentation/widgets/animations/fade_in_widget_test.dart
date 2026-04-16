import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/presentation/widgets/animations/fade_in_widget.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('FadeInWidget', () {
    testWidgets('child widget render edilmeli', (tester) async {
      // Act
      await pumpApp(
        tester,
        const FadeInWidget(
          child: Text('Fade In İçerik'),
        ),
      );

      // Assert
      expect(find.byType(FadeInWidget), findsOneWidget);
      expect(find.text('Fade In İçerik'), findsOneWidget);
    });

    testWidgets('animasyon başlangıçta opacity 0 olmalı', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeInWidget(
              duration: Duration(seconds: 1),
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Assert - FadeTransition kullanıyor
      final fadeTransition = tester.widget<FadeTransition>(
        find.byType(FadeTransition),
      );
      expect(fadeTransition.opacity.value, 0.0);
    });

    testWidgets('animasyon tamamlandığında opacity 1 olmalı', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeInWidget(
              duration: Duration(milliseconds: 500),
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Animasyonu tamamla
      await tester.pumpAndSettle();

      // Assert
      final fadeTransition = tester.widget<FadeTransition>(
        find.byType(FadeTransition),
      );
      expect(fadeTransition.opacity.value, 1.0);
    });

    testWidgets('delay ile animasyon gecikmeli başlamalı', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeInWidget(
              duration: Duration(milliseconds: 300),
              delay: Duration(milliseconds: 500),
              child: Text('Gecikmeli'),
            ),
          ),
        ),
      );

      // Delay süresi geçmeden opacity 0 olmalı
      await tester.pump(const Duration(milliseconds: 200));
      var fadeTransition = tester.widget<FadeTransition>(
        find.byType(FadeTransition),
      );
      expect(fadeTransition.opacity.value, 0.0);

      // Delay + animasyon süresi sonrası opacity 1 olmalı
      await tester.pumpAndSettle();
      fadeTransition = tester.widget<FadeTransition>(
        find.byType(FadeTransition),
      );
      expect(fadeTransition.opacity.value, 1.0);
    });

    testWidgets('özel duration ile çalışmalı', (tester) async {
      // Act
      await pumpApp(
        tester,
        const FadeInWidget(
          duration: Duration(milliseconds: 100),
          child: Text('Hızlı'),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Hızlı'), findsOneWidget);
    });

    testWidgets('özel beginOpacity ile çalışmalı', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeInWidget(
              beginOpacity: 0.5,
              duration: Duration(milliseconds: 500),
              child: Text('Yarı Saydam'),
            ),
          ),
        ),
      );

      // Başlangıçta opacity 0.5 olmalı
      final fadeTransition = tester.widget<FadeTransition>(
        find.byType(FadeTransition),
      );
      expect(fadeTransition.opacity.value, 0.5);
    });
  });

  group('FadeInScaleWidget', () {
    testWidgets('child widget render edilmeli', (tester) async {
      // Act
      await pumpApp(
        tester,
        const FadeInScaleWidget(
          child: Text('Scale İçerik'),
        ),
      );

      // Assert
      expect(find.byType(FadeInScaleWidget), findsOneWidget);
      expect(find.text('Scale İçerik'), findsOneWidget);
    });

    testWidgets('animasyon tamamlandığında görünür olmalı', (tester) async {
      // Act
      await pumpApp(
        tester,
        const FadeInScaleWidget(
          duration: Duration(milliseconds: 300),
          child: Text('Scale Test'),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - widget görünür olmalı
      expect(find.text('Scale Test'), findsOneWidget);
    });

    testWidgets('delay ile çalışmalı', (tester) async {
      // Act
      await pumpApp(
        tester,
        const FadeInScaleWidget(
          delay: Duration(milliseconds: 200),
          duration: Duration(milliseconds: 300),
          child: Text('Gecikmeli Scale'),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Gecikmeli Scale'), findsOneWidget);
    });
  });
}