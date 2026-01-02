import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/utils/responsive_helper.dart';

void main() {
  group('ResponsiveHelper Tests', () {
    testWidgets('should detect mobile device type for small screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.deviceType, DeviceType.mobile);
                expect(responsive.isMobile, true);
                expect(responsive.isTablet, false);
                expect(responsive.isDesktop, false);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should detect tablet device type for medium screens', (tester) async {
      // Tablet: 600 <= width < 900
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.deviceType, DeviceType.tablet);
                expect(responsive.isMobile, false);
                expect(responsive.isTablet, true);
                expect(responsive.isDesktop, false);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should detect desktop device type for large screens', (tester) async {
      // Desktop: 900 <= width < 1200
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1000, 900)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.deviceType, DeviceType.desktop);
                expect(responsive.isMobile, false);
                expect(responsive.isTablet, false);
                expect(responsive.isDesktop, true);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should detect largeDesktop device type for very large screens', (tester) async {
      // LargeDesktop: width >= 1200
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.deviceType, DeviceType.largeDesktop);
                expect(responsive.isMobile, false);
                expect(responsive.isTablet, false);
                expect(responsive.isDesktop, true); // isDesktop includes largeDesktop
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should detect orientation correctly', (tester) async {
      // Portrait
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.orientation, ScreenOrientation.portrait);
                expect(responsive.isPortrait, true);
                expect(responsive.isLandscape, false);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Landscape
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 400)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.orientation, ScreenOrientation.landscape);
                expect(responsive.isPortrait, false);
                expect(responsive.isLandscape, true);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should return correct grid columns for mobile portrait', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.gridColumns, 1);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should return correct grid columns for mobile landscape', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 300)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.gridColumns, 2); // Mobile landscape = 2
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should return correct grid columns for tablet portrait', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.gridColumns, 2); // Tablet portrait = 2
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should return correct grid columns for tablet landscape', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.gridColumns, 3); // Tablet landscape = 3
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should return correct grid columns for desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1000, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.gridColumns, 3); // Desktop = 3
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should return correct grid columns for large desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.gridColumns, 4); // Large desktop = 4
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should return correct padding for different device types', (tester) async {
      // Mobile
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.padding, 16);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Tablet
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 1024)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.padding, 24);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Desktop
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: Builder(
              builder: (context) {
                final responsive = ResponsiveHelper(context);
                expect(responsive.padding, 32);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DeviceType enum Tests', () {
    test('should have correct values', () {
      expect(DeviceType.values.length, 4);
      expect(DeviceType.values.contains(DeviceType.mobile), true);
      expect(DeviceType.values.contains(DeviceType.tablet), true);
      expect(DeviceType.values.contains(DeviceType.desktop), true);
      expect(DeviceType.values.contains(DeviceType.largeDesktop), true);
    });

    test('should have correct isMobile property', () {
      expect(DeviceType.mobile.isMobile, true);
      expect(DeviceType.tablet.isMobile, false);
      expect(DeviceType.desktop.isMobile, false);
      expect(DeviceType.largeDesktop.isMobile, false);
    });

    test('should have correct isTablet property', () {
      expect(DeviceType.mobile.isTablet, false);
      expect(DeviceType.tablet.isTablet, true);
      expect(DeviceType.desktop.isTablet, false);
      expect(DeviceType.largeDesktop.isTablet, false);
    });

    test('should have correct isDesktop property', () {
      expect(DeviceType.mobile.isDesktop, false);
      expect(DeviceType.tablet.isDesktop, false);
      expect(DeviceType.desktop.isDesktop, true);
      expect(DeviceType.largeDesktop.isDesktop, true);
    });

    test('should have correct isLargeScreen property', () {
      expect(DeviceType.mobile.isLargeScreen, false);
      expect(DeviceType.tablet.isLargeScreen, true);
      expect(DeviceType.desktop.isLargeScreen, true);
      expect(DeviceType.largeDesktop.isLargeScreen, true);
    });
  });

  group('ScreenOrientation enum Tests', () {
    test('should have correct values', () {
      expect(ScreenOrientation.values.length, 2);
      expect(ScreenOrientation.values.contains(ScreenOrientation.portrait), true);
      expect(ScreenOrientation.values.contains(ScreenOrientation.landscape), true);
    });

    test('should have correct isPortrait property', () {
      expect(ScreenOrientation.portrait.isPortrait, true);
      expect(ScreenOrientation.landscape.isPortrait, false);
    });

    test('should have correct isLandscape property', () {
      expect(ScreenOrientation.portrait.isLandscape, false);
      expect(ScreenOrientation.landscape.isLandscape, true);
    });
  });

  group('ResponsiveBreakpoints Tests', () {
    test('should have correct breakpoint values', () {
      expect(ResponsiveBreakpoints.mobile, 600);
      expect(ResponsiveBreakpoints.tablet, 900);
      expect(ResponsiveBreakpoints.desktop, 1200);
      expect(ResponsiveBreakpoints.largeDesktop, 1800);
    });
  });

  group('ResponsiveBuilder Widget Tests', () {
    testWidgets('should build with ResponsiveHelper', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: ResponsiveBuilder(
              builder: (context, responsive) {
                expect(responsive, isA<ResponsiveHelper>());
                expect(responsive.isMobile, true);
                return const Text('Test');
              },
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('ResponsiveLayout Widget Tests', () {
    testWidgets('should show mobile widget on mobile', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: const ResponsiveLayout(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should show tablet widget on tablet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 1024)),
            child: const ResponsiveLayout(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should show desktop widget on desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: const ResponsiveLayout(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsOneWidget);
    });

    testWidgets('should fallback to mobile when tablet is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 1024)),
            child: const ResponsiveLayout(
              mobile: Text('Mobile'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
    });
  });
}