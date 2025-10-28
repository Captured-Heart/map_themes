import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_themes/map_themes.dart';

void main() {
  // texts for default themeSelector

  group('Texting Theme Selectors', () {
    testWidgets('When ThemeSelectorStyle is created with null values', (tester) async {
      const style = ThemeSelectorStyle(textStyle: null, selectedTextStyle: null, backgroundColor: null, selectedBackgroundColor: null);

      expect(style.backgroundColor, isNull);
      expect(style.selectedBackgroundColor, isNull);
      expect(style.textStyle, isNull);
      expect(style.selectedTextStyle, isNull);
    });

    testWidgets('When ThemeSelectorStyle is created with custom values', (tester) async {
      final style = ThemeSelectorStyle(
        textStyle: TextStyle(color: const Color(0xFF000000), fontSize: 14),
        selectedTextStyle: TextStyle(color: const Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.bold),
        backgroundColor: Color(0xFFFFFFFF),
        selectedBackgroundColor: Color(0xFF2196F3),
      );

      expect(style.backgroundColor, isA<Color>());
      expect(style.textStyle?.fontSize, allOf(isNotNull, isA<num>()));
      expect(style.selectedTextStyle?.fontWeight, isA<FontWeight>());

      // i want to check if the hex colors can be found in the flutter color class [Colors.white]
      expect(style.backgroundColor, Colors.white);
      expect(style.backgroundColor, isNot(Colors.black));
    });

    testWidgets('Test the theme selector in materialApp', (tester) async {
      //
      await tester.pumpWidget(
        MaterialApp(
          home: Theme(
            data: ThemeData(
              colorScheme: ColorScheme.light(brightness: Brightness.light, primary: Colors.pink, onPrimary: Colors.white, surface: Colors.white),
              textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.green)),
            ),
            child: Builder(
              builder: (context) {
                final style = ThemeSelectorStyle.defaultStyle(context);
                final theme = Theme.of(context);

                expect(style.textStyle, theme.textTheme.bodyMedium);
                expect(style.textStyle?.color, Colors.green);
                expect(theme.colorScheme.brightness, Brightness.light);

                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });
  });
}
