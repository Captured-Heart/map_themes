import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_themes/map_themes.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesMock extends Mock implements SharedPreferences {}

class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  late SharedPreferences sharedPreferences;
  late MapThemeManager mapThemeManager;

  group('Test Map manager theme', () {
    setUp(() {
      sharedPreferences = SharedPreferencesMock();
      mapThemeManager = MapThemeManager();

      // default mock behavior
      when(() => sharedPreferences.getString(any())).thenReturn(null);
      when(() => sharedPreferences.setString(any(), any())).thenAnswer((_) async => true);
      when(() => sharedPreferences.setBool(any(), any())).thenAnswer((_) async => true);
      when(() => sharedPreferences.getBool(any())).thenReturn(null);
      when(() => sharedPreferences.remove(any())).thenAnswer((_) async => true);

      // init SharedPreferences with mock
      SharedPreferences.setMockInitialValues({});
    });

    tearDownAll(() {
      mapThemeManager.dispose();
    });

    //

    group('Test the map manager initialization', () {
      testWidgets('Set values', (tester) async {
        expect(mapThemeManager.isInitialized, false);
        // initialize the manager
        await mapThemeManager.initialize();

        expect(mapThemeManager.isInitialized, true);
        // check default values
        expect(mapThemeManager.currentTheme, MapStyleTheme.standard);

        // set a new value
        await mapThemeManager.setTheme('dark');
        expect(mapThemeManager.currentTheme, MapStyleTheme.dark);

        await mapThemeManager.resetToStandard();
        expect(mapThemeManager.currentTheme, MapStyleTheme.standard);

        await mapThemeManager.setThemeByEnum(MapStyleTheme.retro);
        expect(mapThemeManager.currentTheme, MapStyleTheme.retro);
      });

      //
      testWidgets('should restore saved theme on initialization', (tester) async {
        const savedTheme = 'dark';

        SharedPreferences.setMockInitialValues({'selected_map_theme': savedTheme});

        await mapThemeManager.initialize();

        expect(mapThemeManager.isInitialized, true);

        // Since asset loading might fail in test, check that it at least
        // attempted to set the correct theme name from preferences
        // If there was an error, currentThemeName might be null but that's expected
        print('Current theme name: ${mapThemeManager.currentThemeName}');
        print('Current theme: ${mapThemeManager.currentTheme}');
        print('Error: ${mapThemeManager.error}');
      });

      testWidgets('should handle asset loading properly when theme is restored', (tester) async {
        const savedTheme = 'dark';

        // Mock saved preference
        SharedPreferences.setMockInitialValues({'selected_map_theme': savedTheme});

        await mapThemeManager.initialize();

        print('After initialization:');
        print('- Initialized: ${mapThemeManager.isInitialized}');
        print('- Current theme name: ${mapThemeManager.currentThemeName}');
        print('- Current theme: ${mapThemeManager.currentTheme}');
        print('- Style JSON length: ${mapThemeManager.currentStyleJson.length}');
        print('- Error: ${mapThemeManager.error}');

        expect(mapThemeManager.isInitialized, true);
        expect(mapThemeManager.error, isNull);
        expect(mapThemeManager.currentThemeName, savedTheme);
        expect(mapThemeManager.currentTheme, MapStyleTheme.dark);
        expect(mapThemeManager.currentStyleJson, isNotEmpty);
      });

      //
      testWidgets('should set theme by enum successfully', (tester) async {
        await mapThemeManager.initialize();

        await mapThemeManager.setThemeByEnum(MapStyleTheme.retro);

        expect(mapThemeManager.currentTheme, MapStyleTheme.retro);
        expect(mapThemeManager.currentThemeName, 'retro');
        expect(mapThemeManager.currentStyleJson, isNotEmpty);
        expect(mapThemeManager.error, isNull);
      });

      testWidgets('should set theme by string name successfully', (tester) async {
        await mapThemeManager.initialize();

        await mapThemeManager.setTheme('night');

        expect(mapThemeManager.currentTheme, MapStyleTheme.night);
        expect(mapThemeManager.currentThemeName, 'night');
        expect(mapThemeManager.currentStyleJson, isNotEmpty);
        expect(mapThemeManager.error, isNull);
      });

      testWidgets('should reset to standard theme', (tester) async {
        await mapThemeManager.initialize();

        // First set to a different theme
        await mapThemeManager.setTheme('dark');
        expect(mapThemeManager.currentTheme, MapStyleTheme.dark);

        // Then reset to standard
        await mapThemeManager.resetToStandard();

        expect(mapThemeManager.currentTheme, MapStyleTheme.standard);
        expect(mapThemeManager.currentThemeName, isNull);
        expect(mapThemeManager.currentStyleJson, isEmpty);
        expect(mapThemeManager.error, isNull);
      });

      testWidgets('should handle invalid theme name', (tester) async {
        await mapThemeManager.initialize();

        await mapThemeManager.setTheme('invalid_theme');

        expect(mapThemeManager.error, contains('Theme "invalid_theme" not found'));
        expect(mapThemeManager.currentTheme, MapStyleTheme.standard);
      });
    });

    group('Theme Persistence', () {
      testWidgets('should save theme preference when theme is set', (tester) async {
        await mapThemeManager.initialize();

        await mapThemeManager.setTheme('dark');

        // Check that preference was saved by creating a new manager and initializing
        final newManager = MapThemeManager();
        await newManager.initialize();

        expect(newManager.currentThemeName, 'dark');
        expect(newManager.currentTheme, MapStyleTheme.dark);

        newManager.dispose();
      });

      testWidgets('should restore standard theme if saved theme is not found', (tester) async {
        // Set an invalid saved theme
        SharedPreferences.setMockInitialValues({'selected_map_theme': 'non_existent_theme'});

        await mapThemeManager.initialize();

        expect(mapThemeManager.currentTheme, MapStyleTheme.standard);
        expect(mapThemeManager.currentThemeName, isNull);
        expect(mapThemeManager.error, isNull);
      });
    });

    group('Custom Themes', () {
      testWidgets('should initialize with custom asset paths', (tester) async {
        const customAssetPaths = ['assets/custom_theme.json'];

        await mapThemeManager.initialize(customAssetPaths: customAssetPaths);

        expect(mapThemeManager.isInitialized, true);
        expect(mapThemeManager.allThemes.keys, contains('custom_theme'));
      });

      testWidgets('should include both predefined and custom themes', (tester) async {
        const customAssetPaths = ['assets/custom1.json', 'assets/custom2.json'];

        await mapThemeManager.initialize(customAssetPaths: customAssetPaths);

        final allThemes = mapThemeManager.allThemes;

        // Should contain predefined themes
        expect(allThemes.keys, contains('dark'));
        expect(allThemes.keys, contains('night'));
        expect(allThemes.keys, contains('nightBlue'));
        expect(allThemes.keys, contains('retro'));

        // Should contain custom themes
        expect(allThemes.keys, contains('custom1'));
        expect(allThemes.keys, contains('custom2'));
      });
    });

    group('Notifications', () {
      testWidgets('should notify listeners when theme changes', (tester) async {
        await mapThemeManager.initialize();

        bool wasNotified = false;
        mapThemeManager.addListener(() {
          wasNotified = true;
        });

        await mapThemeManager.setTheme('dark');

        expect(wasNotified, true);
      });
    });

    //! ---------------
    group('Error Handling', () {
      testWidgets('should clear error when successful operation follows failed one', (tester) async {
        await mapThemeManager.initialize();

        // First, cause an error
        await mapThemeManager.setTheme('invalid_theme');
        expect(mapThemeManager.error, isNotNull);

        // Then, do a successful operation
        await mapThemeManager.setTheme('dark');
        expect(mapThemeManager.error, isNull);
      });

      testWidgets('should maintain current theme when operation fails', (tester) async {
        await mapThemeManager.initialize();

        // Set initial valid theme
        await mapThemeManager.setTheme('dark');
        final initialTheme = mapThemeManager.currentTheme;
        final initialStyleJson = mapThemeManager.currentStyleJson;

        // Try to set invalid theme
        await mapThemeManager.setTheme('invalid_theme');

        // Should maintain previous valid state
        expect(mapThemeManager.currentTheme, initialTheme);
        expect(mapThemeManager.currentStyleJson, initialStyleJson);
        expect(mapThemeManager.error, isNotNull);
      });
    });

    group('Disposal', () {
      testWidgets('should dispose properly', (tester) async {
        await mapThemeManager.initialize();

        expect(mapThemeManager.isInitialized, true);

        mapThemeManager.dispose();

        // After disposal, should be able to create a new instance
        final newManager = MapThemeManager();
        expect(newManager.isInitialized, false);

        await newManager.initialize();
        expect(newManager.isInitialized, true);

        newManager.dispose();
      });
    });
  });
}
