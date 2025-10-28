import 'package:flutter/material.dart';
import 'package:map_themes/src/enums/map_theme_selector_layout_enum.dart';
import 'package:map_themes/src/config/map_theme_selector_style.dart';
import 'package:map_themes/src/managers/map_theme_manager.dart';
import 'package:map_themes/src/widgets/theme_selector_widget.dart';

/// A widget that manages map themes and provides both theme selection and map display
///
class MapThemeWidget extends StatefulWidget {
  /// Builder function that receives the current map style JSON
  final Widget Function(String mapStyleJson) builder;

  /// Whether to show the theme selector
  final bool showSelector;

  /// Alignment of the theme selector on the map
  final AlignmentGeometry selectorAlignment;

  /// Layout style for the theme selector
  final ThemeSelectorLayout selectorLayout;

  /// Custom styling for the theme selector
  final ThemeSelectorStyle? selectorStyle;

  /// External MapThemeManager instance (optional), If not provided, creates its own instance
  final MapThemeManager? themeManager;

  /// Callback when theme changes, returns the new map style JSON
  final void Function(String mapStyleJson)? onThemeChanged;

  /// Customizes the background decoration of the selector container
  final BoxDecoration? selectorBackgroundDecoration;

  const MapThemeWidget({
    super.key,
    required this.builder,
    this.showSelector = true,
    this.selectorAlignment = Alignment.topRight,
    this.selectorLayout = ThemeSelectorLayout.horizontalList,
    this.selectorStyle,
    this.themeManager,
    this.onThemeChanged,
    this.selectorBackgroundDecoration,
  });

  @override
  State<MapThemeWidget> createState() => _MapThemeWidgetState();
}

class _MapThemeWidgetState extends State<MapThemeWidget> {
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
      await _themeManager.initialize();
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeManager,
      builder: (context, _) {
        if (!_themeManager.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Map widget
            Positioned.fill(child: widget.builder(_themeManager.currentStyleJson)),

            // Theme selector (if enabled)
            if (widget.showSelector)
              Align(
                alignment: widget.selectorAlignment,
                child: SafeArea(
                  child: DecoratedBox(
                    decoration:
                        widget.selectorBackgroundDecoration ??
                        BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8.0, offset: const Offset(0, 2))],
                        ),
                    child: ThemeSelectorWidget(
                      onThemeChanged: (mapStyleJson) async {
                        widget.onThemeChanged?.call(mapStyleJson);
                      },
                      layout: widget.selectorLayout,
                      style: widget.selectorStyle,
                      themeManager: _themeManager,
                    ),
                  ),
                ),
              ),

            if (_themeManager.isLoading)
              Positioned(
                top: 16,
                left: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8.0)),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        ),
                        SizedBox(width: 8),
                        Text('Loading theme...', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
