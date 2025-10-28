import 'package:flutter/material.dart';
import 'package:map_themes/src/enums/map_theme_selector_layout_enum.dart';
import 'package:map_themes/src/config/map_theme_selector_style.dart';
import 'package:map_themes/src/enums/map_theme.dart';
import 'package:map_themes/src/managers/map_theme_manager.dart';

/// A customizable widget for selecting map themes
///
/// This widget provides a clean UI for users to select different map themes.
/// It can be customized with different layouts, styling options, or completely custom builders.
class ThemeSelectorWidget extends StatefulWidget {
  /// Callback when theme is changed
  final Future<void> Function(String mapStyleJson) onThemeChanged;

  /// Layout style for the selector (ignored if customBuilder is provided)
  final ThemeSelectorLayout layout;

  /// Custom styling for the selector
  final ThemeSelectorStyle? style;

  /// Whether to show theme names
  final bool showLabels;

  /// Whether the selector is enabled
  final bool enabled;

  /// External MapThemeManager instance (optional), If not provided, creates its own instance
  final MapThemeManager? themeManager;

  /// Custom asset paths for the themes
  /// If not provided, only predefined themes are available
  final List<String>? customAssetPaths;

  /// Custom builder function that allows users to create their own selector UI
  ///
  /// This function receives:
  /// - `context`: Build context
  /// - `currentTheme`: The currently selected theme enum
  /// - `currentThemeName`: The currently selected theme name (for custom themes)
  /// - `allThemes`: Map of all available themes (name -> asset path)
  /// - `onThemeSelected`: Callback to call when a theme is selected
  /// - `isEnabled`: Whether the selector should be enabled
  /// - `style`: The effective style to use
  ///
  /// If provided, this overrides the built-in layouts (dropdown, horizontalList, grid)
  final Widget Function({
    required BuildContext context,
    required MapStyleTheme currentTheme,
    required String? currentThemeName,
    required List<String> allThemes,
    required Future<void> Function(String themeName) onThemeSelected,
    required bool isEnabled,
    required ThemeSelectorStyle style,
  })?
  customBuilder;

  const ThemeSelectorWidget({
    super.key,
    required this.onThemeChanged,
    this.layout = ThemeSelectorLayout.dropdown,
    this.style,
    this.showLabels = true,
    this.enabled = true,
    this.themeManager,
    this.customBuilder,
    this.customAssetPaths,
  });

  @override
  State<ThemeSelectorWidget> createState() => _ThemeSelectorWidgetState();
}

class _ThemeSelectorWidgetState extends State<ThemeSelectorWidget> {
  late MapThemeManager _themeManager;
  bool _ownsThemeManager = false;

  @override
  void initState() {
    super.initState();
    if (widget.themeManager != null) {
      _themeManager = widget.themeManager!;
      _ownsThemeManager = false;
    } else {
      _themeManager = MapThemeManager();
      _ownsThemeManager = true;
    }
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    if (!_themeManager.isInitialized) {
      await _themeManager.initialize(customAssetPaths: widget.customAssetPaths);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (_ownsThemeManager) {
      _themeManager.dispose();
    }
    super.dispose();
  }

  /// Helper method to handle theme selection
  Future<void> _handleThemeSelection(String themeName) async {
    final currentName = _themeManager.currentThemeName ?? _themeManager.currentTheme.name;
    if (themeName != currentName) {
      await _themeManager.setTheme(themeName);
      widget.onThemeChanged(_themeManager.currentStyleJson);
    }
  }

  /// Helper method to get all available theme names (predefined + custom)
  List<String> _getAllThemeNames() {
    if (widget.customAssetPaths != null) {
      return _themeManager.allThemes.keys.where((key) => !MapStyleTheme.values.any((e) => e.name == key)).toList();
    }

    return [
      ...MapStyleTheme.values.map((e) => e.name),
      ..._themeManager.allThemes.keys.where((key) => !MapStyleTheme.values.any((e) => e.name == key)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeManager,
      builder: (context, _) {
        if (!_themeManager.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final effectiveStyle = widget.style ?? ThemeSelectorStyle.defaultStyle(context);

        // Use custom builder if provided
        if (widget.customBuilder != null) {
          return widget.customBuilder!(
            context: context,
            currentTheme: _themeManager.currentTheme,
            currentThemeName: _themeManager.currentThemeName,
            allThemes: _getAllThemeNames(),
            onThemeSelected: _handleThemeSelection,
            isEnabled: widget.enabled,
            style: effectiveStyle,
          );
        }

        // Use built-in layouts
        switch (widget.layout) {
          case ThemeSelectorLayout.dropdown:
            return _buildDropdown(context, effectiveStyle);
          case ThemeSelectorLayout.horizontalList:
            return _buildHorizontalList(context, effectiveStyle);
          case ThemeSelectorLayout.grid:
            return _buildGrid(context, effectiveStyle);
        }
      },
    );
  }

  Widget _buildDropdown(BuildContext context, ThemeSelectorStyle style) {
    final currentThemeName = _themeManager.currentThemeName ?? _themeManager.currentTheme.name;
    final allThemeNames = _getAllThemeNames();

    return DropdownButton<String>(
      value: currentThemeName,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      items:
          allThemeNames.map((themeName) {
            final enumTheme = MapStyleTheme.values.where((e) => e.name == themeName).firstOrNull;
            final displayName = enumTheme?.displayName ?? themeName;

            return DropdownMenuItem<String>(value: themeName, child: Text(widget.showLabels ? displayName : themeName, style: style.textStyle));
          }).toList(),
      onChanged:
          widget.enabled
              ? (themeName) async {
                if (themeName != null) {
                  await _handleThemeSelection(themeName);
                }
              }
              : null,
      style: style.textStyle,
      dropdownColor: style.backgroundColor,
    );
  }

  Widget _buildHorizontalList(BuildContext context, ThemeSelectorStyle style) {
    final currentThemeName = _themeManager.currentThemeName ?? _themeManager.currentTheme.name;
    final allThemeNames = _getAllThemeNames();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            allThemeNames.map((themeName) {
              final isSelected = themeName == currentThemeName;
              return Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: _buildThemeChip(themeName, isSelected, style));
            }).toList(),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, ThemeSelectorStyle style) {
    final currentThemeName = _themeManager.currentThemeName ?? _themeManager.currentTheme.name;
    final allThemeNames = _getAllThemeNames();

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children:
          allThemeNames.map((themeName) {
            final isSelected = themeName == currentThemeName;
            return _buildThemeChip(themeName, isSelected, style);
          }).toList(),
    );
  }

  Widget _buildThemeChip(String themeName, bool isSelected, ThemeSelectorStyle style) {
    final enumTheme = MapStyleTheme.values.where((e) => e.name == themeName).firstOrNull;
    final displayName = enumTheme?.displayName ?? themeName;

    return FilterChip(
      label: Text(widget.showLabels ? displayName : themeName, style: isSelected ? style.selectedTextStyle : style.textStyle),
      checkmarkColor: style.selectedTextStyle?.color,
      selected: isSelected,
      onSelected:
          widget.enabled
              ? (selected) async {
                if (selected) {
                  await _handleThemeSelection(themeName);
                }
              }
              : null,
      backgroundColor: style.backgroundColor,
      selectedColor: style.selectedBackgroundColor,
    );
  }
}
