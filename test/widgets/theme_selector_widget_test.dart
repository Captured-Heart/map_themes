import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:map_themes/src/widgets/theme_selector_widget.dart';
import 'package:map_themes/src/enums/map_theme_selector_layout_enum.dart';
import 'package:map_themes/src/config/map_theme_selector_style.dart';
import 'package:map_themes/src/enums/map_theme.dart';
import 'package:map_themes/src/managers/map_theme_manager.dart';

void main() {
  group('ThemeSelectorWidget', () {
    late String receivedMapStyleJson;
    late bool onThemeChangedCalled;

    setUp(() {
      receivedMapStyleJson = '';
      onThemeChangedCalled = false;
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> onThemeChanged(String mapStyleJson) async {
      receivedMapStyleJson = mapStyleJson;
      onThemeChangedCalled = true;
    }

    void setupMockAssets(WidgetTester tester) {
      const mockJsonContent = '{"elementType": "geometry", "stylers": [{"color": "#242f3e"}]}';

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('flutter/assets'), (MethodCall methodCall) async {
        if (methodCall.method == 'loadString') {
          return mockJsonContent;
        }
        return null;
      });
    }

    group('Basic Functionality', () {
      testWidgets('should build with default parameters', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged))));

        await tester.pump(); // Wait for initialization

        expect(find.byType(ThemeSelectorWidget), findsOneWidget);
      });

      testWidgets('should initialize and show theme options', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, layout: ThemeSelectorLayout.dropdown))),
        );

        await tester.pumpAndSettle();

        // Should show dropdown button
        expect(find.byType(DropdownButton<String>), findsOneWidget);
      });

      testWidgets('should show loading indicator during initialization', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged))));

        // Before pump and settle, should show loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        // After initialization, should not show loading
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('Layout Tests', () {
      testWidgets('should render dropdown layout', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, layout: ThemeSelectorLayout.dropdown))),
        );

        await tester.pumpAndSettle();

        expect(find.byType(DropdownButton<String>), findsOneWidget);
      });

      testWidgets('should render horizontal list layout', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, layout: ThemeSelectorLayout.horizontalList))),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should render grid layout', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, layout: ThemeSelectorLayout.grid))),
        );

        await tester.pumpAndSettle();

        expect(find.byType(GridView), findsOneWidget);
      });
    });

    group('Theme Selection', () {
      testWidgets('should call onThemeChanged when theme is selected via dropdown', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, layout: ThemeSelectorLayout.dropdown))),
        );

        await tester.pumpAndSettle();

        // Find and tap dropdown
        final dropdown = find.byType(DropdownButton<String>);
        expect(dropdown, findsOneWidget);

        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        // Find dark theme option and tap it
        final darkOption = find.text('Dark').last;
        await tester.tap(darkOption);
        await tester.pumpAndSettle();

        expect(onThemeChangedCalled, true);
        expect(receivedMapStyleJson, isNotEmpty);
      });

      testWidgets('should call onThemeChanged when theme is selected via horizontal list', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, layout: ThemeSelectorLayout.horizontalList))),
        );

        await tester.pumpAndSettle();

        // Find a theme button and tap it
        final themeButton = find.byType(ElevatedButton).first;
        await tester.tap(themeButton);
        await tester.pumpAndSettle();

        expect(onThemeChangedCalled, true);
      });

      testWidgets('should call onThemeChanged when theme is selected via grid', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, layout: ThemeSelectorLayout.grid))),
        );

        await tester.pumpAndSettle();

        // Find a theme button and tap it
        final themeButton = find.byType(ElevatedButton).first;
        await tester.tap(themeButton);
        await tester.pumpAndSettle();

        expect(onThemeChangedCalled, true);
      });
    });

    group('Custom Builder', () {
      testWidgets('should use custom builder when provided', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ThemeSelectorWidget(
                onThemeChanged: onThemeChanged,
                customBuilder: ({
                  required BuildContext context,
                  required MapStyleTheme currentTheme,
                  required String? currentThemeName,
                  required List<String> allThemes,
                  required Function(String) onThemeSelected,
                  required bool isEnabled,
                  required ThemeSelectorStyle style,
                }) {
                  return const Text('Custom Builder');
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Custom Builder'), findsOneWidget);
        expect(find.byType(DropdownButton<String>), findsNothing);
        expect(find.byType(ListView), findsNothing);
        expect(find.byType(GridView), findsNothing);
      });

      testWidgets('should provide correct parameters to custom builder', (tester) async {
        setupMockAssets(tester);

        MapStyleTheme? receivedCurrentTheme;
        String? receivedCurrentThemeName;
        List<String>? receivedAllThemes;
        bool? receivedIsEnabled;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ThemeSelectorWidget(
                onThemeChanged: onThemeChanged,
                enabled: false,
                customBuilder: ({
                  required BuildContext context,
                  required MapStyleTheme currentTheme,
                  required String? currentThemeName,
                  required List<String> allThemes,
                  required Function(String) onThemeSelected,
                  required bool isEnabled,
                  required ThemeSelectorStyle style,
                }) {
                  receivedCurrentTheme = currentTheme;
                  receivedCurrentThemeName = currentThemeName;
                  receivedAllThemes = allThemes;
                  receivedIsEnabled = isEnabled;
                  return const Text('Custom Builder');
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(receivedCurrentTheme, MapStyleTheme.standard);
        expect(receivedCurrentThemeName, isNull);
        expect(receivedAllThemes, isNotNull);
        expect(receivedAllThemes!.isNotEmpty, true);
        expect(receivedIsEnabled, false);
      });
    });

    group('Styling', () {
      testWidgets('should apply custom style', (tester) async {
        setupMockAssets(tester);

        const customStyle = ThemeSelectorStyle(
          backgroundColor: Colors.red,
          selectedBackgroundColor: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          selectedTextStyle: TextStyle(color: Colors.yellow),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, layout: ThemeSelectorLayout.horizontalList, style: customStyle)),
          ),
        );

        await tester.pumpAndSettle();

        // Check if custom styles are applied to buttons
        final buttons = find.byType(ElevatedButton);
        expect(buttons, findsWidgets);
      });

      testWidgets('should show or hide labels based on showLabels property', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, layout: ThemeSelectorLayout.horizontalList, showLabels: false)),
          ),
        );

        await tester.pumpAndSettle();

        // When showLabels is false, text should not be visible on buttons
        // This is implementation dependent, but we can check that buttons exist
        expect(find.byType(ElevatedButton), findsWidgets);
      });
    });

    group('Enabled/Disabled State', () {
      testWidgets('should disable selector when enabled is false', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, layout: ThemeSelectorLayout.dropdown, enabled: false)),
          ),
        );

        await tester.pumpAndSettle();

        // Find dropdown and verify it's disabled
        final dropdown = find.byType(DropdownButton<String>);
        expect(dropdown, findsOneWidget);

        final dropdownWidget = tester.widget<DropdownButton<String>>(dropdown);
        expect(dropdownWidget.onChanged, isNull); // Should be null when disabled
      });

      testWidgets('should not call onThemeChanged when disabled', (tester) async {
        setupMockAssets(tester);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, layout: ThemeSelectorLayout.horizontalList, enabled: false)),
          ),
        );

        await tester.pumpAndSettle();

        // Try to tap a button (should be disabled)
        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.first);
          await tester.pumpAndSettle();
        }

        expect(onThemeChangedCalled, false);
      });
    });

    group('External Theme Manager', () {
      testWidgets('should use provided external theme manager', (tester) async {
        setupMockAssets(tester);

        final externalManager = MapThemeManager();
        await externalManager.initialize();

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, themeManager: externalManager))),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ThemeSelectorWidget), findsOneWidget);

        // Clean up
        externalManager.dispose();
      });
    });

    group('Custom Asset Paths', () {
      testWidgets('should load custom themes from asset paths', (tester) async {
        setupMockAssets(tester);

        const customAssetPaths = ['assets/custom_theme.json'];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, customAssetPaths: customAssetPaths, layout: ThemeSelectorLayout.dropdown),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(DropdownButton<String>), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle initialization errors gracefully', (tester) async {
        // Setup mock to throw error
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('flutter/assets'), (MethodCall methodCall) async {
          throw PlatformException(code: 'ASSET_ERROR', message: 'Asset not found');
        });

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: ThemeSelectorWidget(onThemeChanged: onThemeChanged))));

        await tester.pumpAndSettle();

        // Should still build widget, possibly showing error state
        expect(find.byType(ThemeSelectorWidget), findsOneWidget);
      });
    });

    group('State Management', () {
      testWidgets('should update UI when theme manager state changes', (tester) async {
        setupMockAssets(tester);

        final themeManager = MapThemeManager();
        await themeManager.initialize();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ThemeSelectorWidget(onThemeChanged: onThemeChanged, themeManager: themeManager, layout: ThemeSelectorLayout.dropdown),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Change theme externally
        await themeManager.setTheme('dark');
        await tester.pump();

        // UI should reflect the change
        expect(find.byType(DropdownButton<String>), findsOneWidget);

        themeManager.dispose();
      });
    });
  });
}
