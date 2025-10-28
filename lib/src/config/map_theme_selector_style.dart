import 'package:flutter/material.dart';

/// Styling options for the theme selector
class ThemeSelectorStyle {
  /// Text style for unselected items
  final TextStyle? textStyle;

  /// Text style for selected items
  final TextStyle? selectedTextStyle;

  /// Background color for unselected items
  final Color? backgroundColor;

  /// Background color for selected items
  final Color? selectedBackgroundColor;

  const ThemeSelectorStyle({this.textStyle, this.selectedTextStyle, this.backgroundColor, this.selectedBackgroundColor});

  /// Default styling based on theme
  factory ThemeSelectorStyle.defaultStyle(BuildContext context) {
    final theme = Theme.of(context);
    return ThemeSelectorStyle(
      textStyle: theme.textTheme.bodyMedium,
      selectedTextStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
      backgroundColor: theme.colorScheme.surface,
      selectedBackgroundColor: theme.colorScheme.primary,
    );
  }
}
