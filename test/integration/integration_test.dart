import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:map_themes/map_themes.dart';

void main() {
  group('Map Themes Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Complete theme switching workflow', (tester) async {
      // Real assets work better than mocked ones

      String currentMapStyle = '';

      // Build complete app with MapThemeWidget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Map Themes Test')),
            body: MapThemeWidget(
              builder: (mapStyle) {
                currentMapStyle = mapStyle;
                return Container(
                  key: const Key('map_container'),
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[300],
                  child: Center(child: Text(mapStyle.isEmpty ? 'Standard Map' : 'Styled Map', style: const TextStyle(fontSize: 24))),
                );
              },
              selectorLayout: ThemeSelectorLayout.dropdown,
              onThemeChanged: (style) {
                debugPrint('Theme changed to: ${style.isEmpty ? "standard" : "custom"}');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Debug: Print what we find
      final dropdownButton = find.byType(DropdownButton<String>);
      expect(dropdownButton, findsOneWidget);

      final dropdownWidget = tester.widget<DropdownButton<String>>(dropdownButton);
      print('Dropdown current value: ${dropdownWidget.value}');
      print('Dropdown items count: ${dropdownWidget.items?.length}');
      print('Dropdown items values: ${dropdownWidget.items?.map((item) => item.value).toList()}');

      // Verify initial state
      expect(find.text('Standard Map'), findsOneWidget);
      expect(find.byKey(const Key('map_container')), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(currentMapStyle, isEmpty);

      // Test theme switching
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Switch to dark theme
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      // Verify theme changed
      expect(find.text('Styled Map'), findsOneWidget);
      expect(currentMapStyle, isNotEmpty);
      expect(currentMapStyle, contains('#212121')); // Dark theme color

      // Switch to retro theme
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retro').last);
      await tester.pumpAndSettle();

      // Verify retro theme
      expect(currentMapStyle, contains('#ebe3cd')); // Retro theme color

      // Switch back to standard
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Standard').last);
      await tester.pumpAndSettle();

      // Verify back to standard
      expect(find.text('Standard Map'), findsOneWidget);
      expect(currentMapStyle, isEmpty);
    });

    testWidgets('Theme persistence across app restarts', (tester) async {
      // Real assets work better than mocked ones

      // First app launch - set a theme
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapThemeWidget(
              builder: (mapStyle) => Container(key: const Key('map_container'), child: Text(mapStyle.isEmpty ? 'Standard' : 'Styled')),
              selectorLayout: ThemeSelectorLayout.dropdown,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Set dark theme
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      expect(find.text('Styled'), findsOneWidget);

      // Simulate app restart by creating new widget tree
      await tester.pumpWidget(const SizedBox()); // Clear current widget
      await tester.pump();

      // "Restart" app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapThemeWidget(
              builder: (mapStyle) => Container(key: const Key('map_container_restart'), child: Text(mapStyle.isEmpty ? 'Standard' : 'Styled')),
              selectorLayout: ThemeSelectorLayout.dropdown,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should restore dark theme
      expect(find.text('Styled'), findsOneWidget);
    });

    testWidgets('Theme selector with different layouts', (tester) async {
      // Real assets work better than mocked ones

      // Test horizontal list layout
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: (style) async {}, layout: ThemeSelectorLayout.horizontalList))),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      // final buttons = find.byType(ElevatedButton);
      // expect(buttons, findsWidgets);

      // // Test theme selection
      // await tester.tap(buttons.first);
      // await tester.pumpAndSettle();

      // Switch to grid layout
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: (style) async {}, layout: ThemeSelectorLayout.grid))),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('Theme selector basic functionality', (tester) async {
      String receivedStyle = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeSelectorWidget(
              onThemeChanged: (style) async {
                receivedStyle = style;
              },
              layout: ThemeSelectorLayout.dropdown,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dropdown is present
      expect(find.byType(DropdownButton<String>), findsOneWidget);

      // Open dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Should include predefined themes
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Night'), findsOneWidget);
      expect(find.text('Retro'), findsOneWidget);

      // Select dark theme
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      expect(receivedStyle, isNotEmpty);
      expect(receivedStyle, contains('#212121')); // Dark theme color
    });

    testWidgets('Multiple MapThemeWidget instances', (tester) async {
      // Test multiple MapThemeWidget instances working together
      String firstMapStyle = '';
      String secondMapStyle = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: MapThemeWidget(
                    builder: (style) {
                      firstMapStyle = style;
                      return Container(key: const Key('first_map'), child: Text('First Map: ${style.isEmpty ? "Standard" : "Styled"}'));
                    },
                  ),
                ),
                Expanded(
                  child: MapThemeWidget(
                    builder: (style) {
                      secondMapStyle = style;
                      return Container(key: const Key('second_map'), child: Text('Second Map: ${style.isEmpty ? "Standard" : "Styled"}'));
                    },
                    selectorLayout: ThemeSelectorLayout.horizontalList,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both maps should start with standard theme
      expect(find.text('First Map: Standard'), findsOneWidget);
      expect(find.text('Second Map: Standard'), findsOneWidget);
      expect(firstMapStyle, isEmpty);
      expect(secondMapStyle, isEmpty);
    });

    testWidgets('Theme manager direct usage', (tester) async {
      final manager = MapThemeManager();
      await manager.initialize();

      expect(manager.isInitialized, true);
      expect(manager.currentTheme, MapStyleTheme.standard);
      expect(manager.currentStyleJson, isEmpty);

      // Test direct theme changes
      await manager.setTheme('dark');
      expect(manager.currentThemeName, 'dark');
      expect(manager.currentTheme, MapStyleTheme.dark);
      expect(manager.currentStyleJson, isNotEmpty);

      await manager.setThemeByEnum(MapStyleTheme.retro);
      expect(manager.currentTheme, MapStyleTheme.retro);

      await manager.resetToStandard();
      expect(manager.currentTheme, MapStyleTheme.standard);
      expect(manager.currentStyleJson, isEmpty);

      await manager.clearThemePreference();
      expect(manager.currentTheme, MapStyleTheme.standard);

      manager.dispose();
      expect(manager.currentStyleJson, isEmpty);
      expect(manager.isInitialized, false);
    });
  });
}
