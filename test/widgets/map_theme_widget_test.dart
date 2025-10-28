import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:map_themes/src/widgets/map_theme_widget.dart';
import 'package:map_themes/src/widgets/theme_selector_widget.dart';
import 'package:map_themes/src/enums/map_theme_selector_layout_enum.dart';
import 'package:map_themes/src/config/map_theme_selector_style.dart';
import 'package:map_themes/src/managers/map_theme_manager.dart';

import '../utils/mock_main_widget.dart';

void main() {
  group('MapThemeWidget', () {
    late String receivedMapStyleJson;
    late bool builderCalled;

    setUp(() {
      receivedMapStyleJson = '';
      builderCalled = false;
      SharedPreferences.setMockInitialValues({});
    });

    void onBuild(String mapStyleJson) {
      builderCalled = true;
      receivedMapStyleJson = mapStyleJson;
    }

    group('Basic Functionality', () {
      //
      testWidgets('should build with default parameters', (tester) async {
        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder)));

        await tester.pump(); // Initial pump

        expect(find.byType(MapThemeWidget), findsOneWidget);
      });

      testWidgets('should show loading indicator during initialization', (tester) async {
        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder)));

        // Should show loading initially
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        // After initialization, should show map
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byKey(const Key('mock_map')), findsOneWidget);
      });

      testWidgets('should call builder with correct map style', (tester) async {
        await tester.pumpWidget(
          mockMainWidget(child: MapThemeWidget(builder: (stringValue) => mapBuilder(stringValue, onBuild: () => onBuild(stringValue)))),
        );

        await tester.pumpAndSettle();

        expect(builderCalled, true);
        expect(receivedMapStyleJson, isEmpty); // Should be empty for standard theme
        expect(find.text('Map with style: standard'), findsOneWidget);
      });
    });

    group('Theme Selector Visibility', () {
      testWidgets('should show theme selector by default', (tester) async {
        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder)));

        await tester.pumpAndSettle();

        expect(find.byType(ThemeSelectorWidget), findsOneWidget);
      });

      testWidgets('should hide theme selector when showSelector is false', (tester) async {
        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder, showSelector: false)));

        await tester.pumpAndSettle();

        expect(find.byType(ThemeSelectorWidget), findsNothing);
        expect(find.byKey(const Key('mock_map')), findsOneWidget);
      });
    });

    group('Theme Selector Positioning', () {
      testWidgets('should position selector at top-right by default', (tester) async {
        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder)));

        await tester.pumpAndSettle();
        final position = find.byType(Positioned);
        expect(position, findsOneWidget);

        final positionedWidget = tester.widget<Positioned>(position);

        expect(positionedWidget, isNotNull);
        expect(positionedWidget.top, isNotNull);
        expect(positionedWidget.right, isNotNull);
      });

      testWidgets('should position selector at custom alignment', (tester) async {
        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder, selectorAlignment: Alignment.bottomLeft)));

        await tester.pumpAndSettle();

        final positioned = find.byType(Positioned);
        expect(positioned, findsOneWidget);

        final positionedWidget = tester.widget<Positioned>(positioned);
        expect(positionedWidget.bottom, isNotNull);
        expect(positionedWidget.left, isNotNull);
      });
    });

    group('Theme Selector Layout', () {
      testWidgets('should use horizontal list layout by default', (tester) async {
        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder)));

        await tester.pumpAndSettle();

        expect(find.byType(ThemeSelectorWidget), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('should use custom selector layout', (tester) async {
        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder, selectorLayout: ThemeSelectorLayout.dropdown)));

        await tester.pumpAndSettle();

        expect(find.byType(DropdownButton<String>), findsOneWidget);
      });
    });

    group('Theme Changes', () {
      testWidgets('should update map when theme changes via selector', (tester) async {
        String? initialStyle;
        String? lastReceivedStyle;
        bool isFirstBuild = true;

        await tester.pumpWidget(
          mockMainWidget(
            child: MapThemeWidget(
              builder: (style) {
                if (isFirstBuild) {
                  initialStyle = style;
                  isFirstBuild = false;
                }
                lastReceivedStyle = style;
                print('Received style: $style');
                return mapBuilder(style);
              },
              selectorLayout: ThemeSelectorLayout.dropdown,
            ),
          ),
        );

        await tester.pumpAndSettle();

        print('Initial style: $initialStyle');

        // Change theme via dropdown
        final dropdown = find.byType(DropdownButton<String>);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        // Select night theme (not Night - check the actual text)
        final nightOption = find.text('Night');
        expect(nightOption, findsOneWidget);
        await tester.tap(nightOption);
        await tester.pumpAndSettle();

        print('Final style: $lastReceivedStyle');

        // Map should be rebuilt with new style (different from initial)
        expect(lastReceivedStyle, isNot(equals(initialStyle)));
        // Night theme should have actual JSON content
        expect(lastReceivedStyle, isNotEmpty);
      });

      testWidgets('should call onThemeChanged callback', (tester) async {
        String? callbackReceivedStyle;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapThemeWidget(
                builder: mapBuilder,
                selectorLayout: ThemeSelectorLayout.dropdown,
                onThemeChanged: (style) {
                  callbackReceivedStyle = style;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Change theme
        final dropdown = find.byType(DropdownButton<String>);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        final darkOption = find.text('Dark').last;
        await tester.tap(darkOption);
        await tester.pumpAndSettle();

        expect(callbackReceivedStyle, isNotNull);
        expect(callbackReceivedStyle, isNotEmpty);
      });
    });

    group('External Theme Manager', () {
      testWidgets('should use provided external theme manager', (tester) async {
        final externalManager = MapThemeManager();
        await externalManager.initialize();

        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder, themeManager: externalManager)));

        await tester.pumpAndSettle();

        expect(find.byType(MapThemeWidget), findsOneWidget);
        expect(find.byKey(const Key('mock_map')), findsOneWidget);

        // Clean up
        externalManager.dispose();
      });

      testWidgets('should create own theme manager when none provided', (tester) async {
        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder)));

        await tester.pumpAndSettle();

        expect(find.byType(MapThemeWidget), findsOneWidget);
        expect(find.byKey(const Key('mock_map')), findsOneWidget);
      });

      testWidgets('should not dispose external theme manager', (tester) async {
        final externalManager = MapThemeManager();
        await externalManager.initialize();

        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder, themeManager: externalManager)));

        await tester.pumpAndSettle();

        // Remove the widget
        await tester.pumpWidget(mockMainWidget(child: Text('Empty')));

        // External manager should still be usable
        expect(externalManager.isInitialized, true);

        externalManager.dispose();
      });
    });

    group('Selector Styling', () {
      testWidgets('should apply custom selector style', (tester) async {
        const customStyle = ThemeSelectorStyle(backgroundColor: Colors.red, selectedBackgroundColor: Colors.blue);

        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder, selectorStyle: customStyle)));

        await tester.pumpAndSettle();

        expect(find.byType(ThemeSelectorWidget), findsOneWidget);
      });

      testWidgets('should apply custom selector background decoration', (tester) async {
        const decoration = BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.all(Radius.circular(8)));

        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder, selectorBackgroundDecoration: decoration)));

        await tester.pumpAndSettle();

        expect(find.byType(ThemeSelectorWidget), findsOneWidget);
        final container = find.byType(Container);
        expect(container, findsWidgets);
      });
    });

    group('State Management', () {
      testWidgets('should update when external theme manager changes', (tester) async {
        final themeManager = MapThemeManager();
        await themeManager.initialize();

        String? lastMapStyle;

        await tester.pumpWidget(
          mockMainWidget(
            child: MapThemeWidget(
              builder: (style) {
                lastMapStyle = style;
                return mapBuilder(style);
              },
              themeManager: themeManager,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final initialStyle = lastMapStyle;

        // Change theme externally
        await themeManager.setTheme('dark');
        await tester.pump();

        // Widget should update
        expect(lastMapStyle, isNot(equals(initialStyle)));

        themeManager.dispose();
      });

      testWidgets('should maintain state when widget is rebuilt', (tester) async {
        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder, key: const Key('map_widget'))));

        await tester.pumpAndSettle();

        // Rebuild with same key
        await tester.pumpWidget(
          mockMainWidget(
            child: MapThemeWidget(
              builder: mapBuilder,
              key: const Key('map_widget'),
              showSelector: false, // Change a property
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(MapThemeWidget), findsOneWidget);
        expect(find.byType(ThemeSelectorWidget), findsNothing);
      });
    });

    group('Widget Lifecycle', () {
      testWidgets('should dispose owned theme manager on widget disposal', (tester) async {
        await tester.pumpWidget(mockMainWidget(child: MapThemeWidget(builder: mapBuilder)));

        await tester.pumpAndSettle();

        expect(find.byType(MapThemeWidget), findsOneWidget);

        // Remove the widget
        await tester.pumpWidget(mockMainWidget(child: Text('Empty')));

        // Should dispose cleanly without errors
        expect(find.byType(MapThemeWidget), findsNothing);
      });
    });
  });
}
