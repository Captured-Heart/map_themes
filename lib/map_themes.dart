/// Dynamic Map Themes Plugin
///
/// A Flutter plugin that allows developers to easily style Google Maps and other maps
/// with predefined themes like dark, night, retro, and custom styles.
///
/// ## Features
///
/// -  **5+ Built-in Themes**: Standard, Dark, Night, Night Blue, Retro
/// -  **Easy Integration**: Simple API with ChangeNotifier
/// -  **Auto Persistence**: Automatically saves user's theme preference
/// -  **Highly Testable**: Clean architecture with comprehensive test coverage
///
/// ## Quick Start
///
/// ```dart
/// import 'package:map_themes/map_themes.dart';
///
///
/// // There are three main ways to use the package:
/// // 1. Using MapThemeManager directly
/// final MapThemeManager themeManager = MapThemeManager();
/// // you can initialize it once in your app initState
/// await themeManager.initialize();
/// // Set theme
/// await themeManager.setTheme(MapStyleTheme.dark);
/// // Get current style JSON and pass to your map widget
/// String currentStyle = themeManager.currentStyleJson;
/// // 2. Using MapThemeWidget which combines map display and theme selection
/// MapThemeWidget(
///   builder: (mapStyle) {
///     return GoogleMap(
///       initialCameraPosition: _initialPosition,
///       style: mapStyle.isEmpty ? null : mapStyle,
///   // ... other properties
///     );
///   },
/// ),
/// // 3. Using ThemeSelectorWidget to provide a theme selection UI
/// ThemeSelectorWidget(
///   onThemeChanged: (themeJSON) async {
///     setState(() {
///       _currentMapStyle = themeJSON;
///     });
///   },
///   layout: ThemeSelectorLayout.dropdown,
/// ),
/// //  Apply the updated mapstyle to Google Maps
/// GoogleMap(
///   mapType: MapType.normal,
///   style:  _currentMapStyle,
///   // ... other properties
/// )
/// ```
///
/// ## Available Themes
///
/// - `MapTheme.standard` - Default Google Maps appearance
/// - `MapTheme.dark` - Dark theme perfect for night mode
/// - `MapTheme.night` - Night theme with blue undertones
/// - `MapTheme.nightBlue` - Deeper night theme with blue accents
/// - `MapTheme.retro` - Vintage/retro styling
///
library map_themes;

// Widgets
export 'src/widgets/map_theme_widget.dart';
export 'src/widgets/theme_selector_widget.dart';
// Enums
export 'src/enums/map_theme_selector_layout_enum.dart';
export 'src/enums/map_theme.dart';
// Config/Styles
export 'src/config/map_theme_selector_style.dart';
// Managers
export 'src/managers/map_theme_manager.dart';
