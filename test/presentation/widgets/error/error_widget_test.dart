import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/presentation/widgets/error/error_widget.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('CustomErrorWidget', () {
    testWidgets('network error gösterimi', (tester) async {
      // Act
      await pumpApp(
        tester,
        CustomErrorWidget.network(
          onRetry: () {},
        ),
      );

      // Assert
      expect(find.byType(CustomErrorWidget), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('İnternet Bağlantısı Yok'), findsOneWidget);
    });

    testWidgets('server error gösterimi', (tester) async {
      // Act
      await pumpApp(
        tester,
        CustomErrorWidget.server(
          onRetry: () {},
        ),
      );

      // Assert
      expect(find.byType(CustomErrorWidget), findsOneWidget);
      expect(find.byIcon(Icons.dns_outlined), findsOneWidget);
      expect(find.text('Sunucu Hatası'), findsOneWidget);
    });

    testWidgets('empty state gösterimi', (tester) async {
      // Act
      await pumpApp(
        tester,
        CustomErrorWidget.empty(
          customMessage: 'Sonuç bulunamadı',
        ),
      );

      // Assert
      expect(find.byType(CustomErrorWidget), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Sonuç Bulunamadı'), findsOneWidget);
    });

    testWidgets('timeout error gösterimi', (tester) async {
      // Act
      await pumpApp(
        tester,
        CustomErrorWidget.timeout(
          onRetry: () {},
        ),
      );

      // Assert
      expect(find.byType(CustomErrorWidget), findsOneWidget);
      expect(find.byIcon(Icons.timer_off), findsOneWidget);
      expect(find.text('Zaman Aşımı'), findsOneWidget);
    });

    testWidgets('retry callback çağrılmalı', (tester) async {
      // Arrange
      var retryCalled = false;

      await pumpApp(
        tester,
        CustomErrorWidget.network(
          onRetry: () => retryCalled = true,
        ),
      );

      // Act - retry butonunu bul ve tıkla
      final retryButton = find.byType(ElevatedButton);
      if (retryButton.evaluate().isNotEmpty) {
        await tester.tap(retryButton.first);
        await tester.pump();
      }

      // Assert
      expect(retryCalled, true);
    });

    testWidgets('compact modda gösterilmeli', (tester) async {
      // Act
      await pumpApp(
        tester,
        CustomErrorWidget(
          error: 'Test hatası',
          isCompact: true,
          errorType: ErrorType.general,
          onRetry: () {},
        ),
      );

      // Assert
      expect(find.byType(CustomErrorWidget), findsOneWidget);
      // Compact mod Row kullanır
      expect(find.text('Yenile'), findsOneWidget);
    });

    testWidgets('custom message gösterilmeli', (tester) async {
      // Act
      await pumpApp(
        tester,
        CustomErrorWidget.network(
          customMessage: 'Özel hata mesajı',
          onRetry: () {},
        ),
      );

      // Assert
      expect(find.text('Özel hata mesajı'), findsOneWidget);
    });
  });

  group('EmptyStateWidget', () {
    testWidgets('render edilmeli', (tester) async {
      // Act
      await pumpApp(
        tester,
        const EmptyStateWidget(
          title: 'Boş',
          message: 'Henüz içerik yok',
          icon: Icons.inbox_outlined,
        ),
      );

      // Assert
      expect(find.text('Boş'), findsOneWidget);
      expect(find.text('Henüz içerik yok'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('action button gösterilmeli', (tester) async {
      // Arrange
      var actionCalled = false;

      // Act
      await pumpApp(
        tester,
        EmptyStateWidget(
          title: 'Boş',
          message: 'İçerik yok',
          onAction: () => actionCalled = true,
          actionText: 'Yenile',
        ),
      );

      // Assert
      expect(find.text('Yenile'), findsOneWidget);

      // Action butona tıkla
      await tester.tap(find.text('Yenile'));
      await tester.pump();
      expect(actionCalled, true);
    });
  });

  group('NoInternetWidget', () {
    testWidgets('render edilmeli', (tester) async {
      // Act
      await pumpApp(
        tester,
        NoInternetWidget(onRetry: () {}),
      );

      // Assert
      expect(find.byType(CustomErrorWidget), findsOneWidget);
    });
  });

  group('ErrorType', () {
    test('tüm hata türleri tanımlı olmalı', () {
      expect(ErrorType.values, hasLength(7));
      expect(ErrorType.values, contains(ErrorType.network));
      expect(ErrorType.values, contains(ErrorType.server));
      expect(ErrorType.values, contains(ErrorType.empty));
      expect(ErrorType.values, contains(ErrorType.timeout));
      expect(ErrorType.values, contains(ErrorType.rss));
      expect(ErrorType.values, contains(ErrorType.cache));
      expect(ErrorType.values, contains(ErrorType.general));
    });
  });

  group('ErrorInfo', () {
    test('doğru değerlerle oluşturulmalı', () {
      // Act
      final info = ErrorInfo(
        icon: Icons.error,
        color: Colors.red,
        title: 'Test Error',
        retryIcon: Icons.refresh,
        retryText: 'Tekrar Dene',
      );

      // Assert
      expect(info.icon, Icons.error);
      expect(info.color, Colors.red);
      expect(info.title, 'Test Error');
      expect(info.retryIcon, Icons.refresh);
      expect(info.retryText, 'Tekrar Dene');
    });

    test('varsayılan retry değerleri olmalı', () {
      // Act
      final info = ErrorInfo(
        icon: Icons.error,
        color: Colors.red,
        title: 'Test',
      );

      // Assert
      expect(info.retryIcon, Icons.refresh);
      expect(info.retryText, 'Yeniden Dene');
    });
  });
}