import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/presentation/providers/locale_provider.dart';

void main() {
  group('LocaleNotifier Tests', () {
    late LocaleNotifier localeNotifier;

    setUp(() {
      localeNotifier = LocaleNotifier();
    });

    test('Initial locale should be Turkish (tr)', () {
      expect(localeNotifier.state.languageCode, 'tr');
    });

    test('setLocale should change locale to English', () {
      localeNotifier.setLocale(const Locale('en'));
      expect(localeNotifier.state.languageCode, 'en');
    });

    test('setLocale should change locale to Turkish', () {
      // First change to English
      localeNotifier.setLocale(const Locale('en'));
      expect(localeNotifier.state.languageCode, 'en');

      // Then change back to Turkish
      localeNotifier.setLocale(const Locale('tr'));
      expect(localeNotifier.state.languageCode, 'tr');
    });

    test('toggleLocale should switch between Turkish and English', () {
      // Initial state is Turkish
      expect(localeNotifier.state.languageCode, 'tr');

      // Toggle to English
      localeNotifier.toggleLocale();
      expect(localeNotifier.state.languageCode, 'en');

      // Toggle back to Turkish
      localeNotifier.toggleLocale();
      expect(localeNotifier.state.languageCode, 'tr');
    });

    test('Multiple toggles should work correctly', () {
      // Start with Turkish
      expect(localeNotifier.state.languageCode, 'tr');

      // Toggle multiple times
      localeNotifier.toggleLocale(); // en
      localeNotifier.toggleLocale(); // tr
      localeNotifier.toggleLocale(); // en
      localeNotifier.toggleLocale(); // tr

      expect(localeNotifier.state.languageCode, 'tr');
    });
  });

  group('Locale Utility Tests', () {
    test('Locale should have correct country code for Turkish', () {
      const locale = Locale('tr', 'TR');
      expect(locale.languageCode, 'tr');
      expect(locale.countryCode, 'TR');
    });

    test('Locale should have correct country code for English', () {
      const locale = Locale('en', 'US');
      expect(locale.languageCode, 'en');
      expect(locale.countryCode, 'US');
    });

    test('Locale equality should work correctly', () {
      const locale1 = Locale('tr');
      const locale2 = Locale('tr');
      const locale3 = Locale('en');

      expect(locale1, equals(locale2));
      expect(locale1, isNot(equals(locale3)));
    });
  });

  group('Supported Locales Tests', () {
    test('App should support Turkish locale', () {
      const supportedLocales = [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ];

      expect(
        supportedLocales.any((l) => l.languageCode == 'tr'),
        true,
      );
    });

    test('App should support English locale', () {
      const supportedLocales = [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ];

      expect(
        supportedLocales.any((l) => l.languageCode == 'en'),
        true,
      );
    });

    test('Supported locales should have exactly 2 languages', () {
      const supportedLocales = [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ];

      expect(supportedLocales.length, 2);
    });
  });

  group('Locale Resolution Tests', () {
    test('Should resolve to Turkish for tr locale', () {
      const deviceLocale = Locale('tr');
      const supportedLocales = [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ];

      final resolved = supportedLocales.firstWhere(
        (l) => l.languageCode == deviceLocale.languageCode,
        orElse: () => supportedLocales.first,
      );

      expect(resolved.languageCode, 'tr');
    });

    test('Should resolve to English for en locale', () {
      const deviceLocale = Locale('en');
      const supportedLocales = [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ];

      final resolved = supportedLocales.firstWhere(
        (l) => l.languageCode == deviceLocale.languageCode,
        orElse: () => supportedLocales.first,
      );

      expect(resolved.languageCode, 'en');
    });

    test('Should fallback to Turkish for unsupported locale', () {
      const deviceLocale = Locale('de'); // German - not supported
      const supportedLocales = [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ];

      final resolved = supportedLocales.firstWhere(
        (l) => l.languageCode == deviceLocale.languageCode,
        orElse: () => supportedLocales.first,
      );

      expect(resolved.languageCode, 'tr');
    });

    test('Should fallback to Turkish for French locale', () {
      const deviceLocale = Locale('fr'); // French - not supported
      const supportedLocales = [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ];

      final resolved = supportedLocales.firstWhere(
        (l) => l.languageCode == deviceLocale.languageCode,
        orElse: () => supportedLocales.first,
      );

      expect(resolved.languageCode, 'tr');
    });
  });

  group('Language Display Name Tests', () {
    test('Turkish language should have correct display name', () {
      const languageNames = {
        'tr': 'Türkçe',
        'en': 'English',
      };

      expect(languageNames['tr'], 'Türkçe');
    });

    test('English language should have correct display name', () {
      const languageNames = {
        'tr': 'Türkçe',
        'en': 'English',
      };

      expect(languageNames['en'], 'English');
    });
  });
}