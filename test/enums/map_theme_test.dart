import 'package:flutter_test/flutter_test.dart';
import 'package:map_themes/src/enums/map_theme.dart';

void main() {
  group('MapStyleTheme Enum Tests', () {
    test('should have correct display names', () {
      expect(MapStyleTheme.standard.displayName, 'Standard');
      expect(MapStyleTheme.dark.displayName, 'Dark');
      expect(MapStyleTheme.night.displayName, 'Night');
      expect(MapStyleTheme.nightBlue.displayName, 'Night Blue');
      expect(MapStyleTheme.retro.displayName, 'Retro');
    });

    test('should have correct enum names', () {
      expect(MapStyleTheme.standard.name, 'standard');
      expect(MapStyleTheme.dark.name, 'dark');
      expect(MapStyleTheme.night.name, 'night');
      expect(MapStyleTheme.nightBlue.name, 'nightBlue');
      expect(MapStyleTheme.retro.name, 'retro');
    });

    test('should create from name correctly', () {
      expect(MapStyleTheme.fromName('standard'), MapStyleTheme.standard);
      expect(MapStyleTheme.fromName('dark'), MapStyleTheme.dark);
      expect(MapStyleTheme.fromName('night'), MapStyleTheme.night);
      expect(MapStyleTheme.fromName('nightBlue'), MapStyleTheme.nightBlue);
      expect(MapStyleTheme.fromName('retro'), MapStyleTheme.retro);
    });

    test('should default to standard for invalid names', () {
      expect(MapStyleTheme.fromName('null'), MapStyleTheme.standard);
      // test empty string
      expect(MapStyleTheme.fromName(''), MapStyleTheme.standard);
      // i want to test a random string
      expect(MapStyleTheme.fromName('g8ugg0pbv'), MapStyleTheme.standard);
    });

    test('Check the length', () {
      final themes = MapStyleTheme.values;
      expect(themes, hasLength(5));

      expect(themes.indexOf(MapStyleTheme.standard), 0);
      expect(themes.indexOf(MapStyleTheme.retro), 4);
    });
  });
}
