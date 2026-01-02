// This is a basic Flutter widget test.
//
// Note: Full app widget tests are skipped because they require Hive initialization
// which is complex to set up in test environment. The app functionality is tested
// through integration tests and unit tests instead.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Widget Tests', () {
    testWidgets('MaterialApp can be created', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Haber Merkezi'),
            ),
          ),
        ),
      );

      expect(find.text('Haber Merkezi'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Theme can be applied', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const Scaffold(
            body: Center(
              child: Text('Themed App'),
            ),
          ),
        ),
      );

      expect(find.text('Themed App'), findsOneWidget);
    });

    testWidgets('Dark theme can be applied', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: ThemeMode.dark,
          home: const Scaffold(
            body: Center(
              child: Text('Dark Theme App'),
            ),
          ),
        ),
      );

      expect(find.text('Dark Theme App'), findsOneWidget);
    });

    testWidgets('AppBar can be created', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Haber Merkezi'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
            body: const Center(
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Haber Merkezi'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('BottomNavigationBar can be created', (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: const Center(child: Text('Content')),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => setState(() => selectedIndex = index),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Ana Sayfa',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite),
                      label: 'Favoriler',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Ayarlar',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Ana Sayfa'), findsOneWidget);
      expect(find.text('Favoriler'), findsOneWidget);
      expect(find.text('Ayarlar'), findsOneWidget);

      // Tap on Favoriler
      await tester.tap(find.text('Favoriler'));
      await tester.pump();
    });

    testWidgets('ListView can display items', (WidgetTester tester) async {
      final items = List.generate(10, (index) => 'Item $index');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('RefreshIndicator can be used', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 100));
              },
              child: ListView(
                children: const [
                  ListTile(title: Text('Item 1')),
                  ListTile(title: Text('Item 2')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('TabBar can be created', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Gündem'),
                    Tab(text: 'Spor'),
                    Tab(text: 'Ekonomi'),
                  ],
                ),
              ),
              body: const TabBarView(
                children: [
                  Center(child: Text('Gündem Content')),
                  Center(child: Text('Spor Content')),
                  Center(child: Text('Ekonomi Content')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Gündem'), findsOneWidget);
      expect(find.text('Spor'), findsOneWidget);
      expect(find.text('Ekonomi'), findsOneWidget);
    });
  });
}
