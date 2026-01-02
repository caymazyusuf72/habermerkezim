import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haber_merkezi/core/utils/responsive_helper.dart';

void main() {
  group('ResponsiveHelper Tests', () {
    testWidgets('should detect mobile device type for small screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return MediaQuery(
                data: const MediaQueryData(size: Size(375, 667)), // iPhone SE
                child: Builder(
                  builder: (context) {
                    final helper = ResponsiveHelper(context);
                    expect(helper.deviceType, DeviceType.mobile);
                    expect(helper.isMobile, true);
                    expect(helper.isTablet, false);
                    expect(helper.isDesktop, false);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('should detect tablet device type for medium screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return MediaQuery(
                data: const MediaQueryData(size: Size(768, 1024)), // iPad
                child: Builder(
                  builder: (context) {
                    final helper = ResponsiveHelper(context);
                    expect(helper.deviceType, DeviceType.tablet);
                    expect(helper.isMobile, false);
                    expect(helper.isTablet, true);
                    expect(helper.isDesktop, false);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('should detect desktop device type for large screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return MediaQuery(
                data: const MediaQueryData(size: Size(1200, 800)), // Desktop
                child: Builder(
                  builder: (context) {
                    final helper = ResponsiveHelper(context);
                    expect(helper.deviceType, DeviceType.desktop);
                    expect(helper.isMobile, false);
                    expect(helper.isTablet, false);
                    expect(helper.isDesktop, true);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('should return correct grid columns for different device types', (tester) async {
      // Mobile
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 667)),
            child: Builder(
              builder: (context) {
                final helper = ResponsiveHelper(context);
                expect(helper.gridColumns, 1);
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
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final helper = ResponsiveHelper(context);
                expect(helper.gridColumns, 2);
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
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final helper = ResponsiveHelper(context);
                expect(helper.gridColumns, 3);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should return correct horizontal padding', (tester) async {
      // Mobile
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 667)),
            child: Builder(
              builder: (context) {
                final helper = ResponsiveHelper(context);
                expect(helper.horizontalPadding, 16.0);
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
            data: const MediaQueryData(size: Size(768, 1024)),
            child: Builder(
              builder: (context) {
                final helper = ResponsiveHelper(context);
                expect(helper.horizontalPadding, 24.0);
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
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final helper = ResponsiveHelper(context);
                expect(helper.horizontalPadding, 32.0);
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
            data: const MediaQueryData(size: Size(375, 667)),
            child: Builder(
              builder: (context) {
                final helper = ResponsiveHelper(context);
                expect(helper.isPortrait, true);
                expect(helper.isLandscape, false);
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
            data: const MediaQueryData(size: Size(667, 375)),
            child: Builder(
              builder: (context) {
                final helper = ResponsiveHelper(context);
                expect(helper.isPortrait, false);
                expect(helper.isLandscape, true);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DeviceType Tests', () {
    test('DeviceType enum should have correct values', () {
      expect(DeviceType.values.length, 4);
      expect(DeviceType.values.contains(DeviceType.mobile), true);
      expect(DeviceType.values.contains(DeviceType.tablet), true);
      expect(DeviceType.values.contains(DeviceType.desktop), true);
      expect(DeviceType.values.contains(DeviceType.largeDesktop), true);
    });
  });
}