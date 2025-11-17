# Map Themes Plugin

A Flutter plugin that provides easy-to-use map theming capabilities for Google Maps and other map implementations. Transform your maps with beautiful predefined themes or create custom styling with minimal code.

![Pub Version](https://img.shields.io/pub/v/map_themes.svg)
![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.3.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## UI Shots

<div style="text-align: center">
  <table>
    <tr>
      <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/Captured-Heart/map_themes/refs/heads/main/example/screenshots/dark1.png" width="800" />
      </td>
      <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/Captured-Heart/map_themes/refs/heads/main/example/screenshots/dark.png" width="800" />
      </td>
       <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/Captured-Heart/map_themes/refs/heads/main/example/screenshots/retro1.png" width="800" />
      </td> <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/Captured-Heart/map_themes/refs/heads/main/example/screenshots/retro.png" width="800" />
      </td>
    </tr>
     <tr>
      <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/Captured-Heart/map_themes/refs/heads/main/example/screenshots/night.png" width="800" />
      </td>
      <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/Captured-Heart/map_themes/refs/heads/main/example/screenshots/night1.png" width="800" />
      </td>
       <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/Captured-Heart/map_themes/refs/heads/main/example/screenshots/original.png" width="800" />
      </td> <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/Captured-Heart/map_themes/refs/heads/main/example/screenshots/nightBlue.png" width="800" />
      </td>
    </tr>
  </table>
</div>

## Features

**5+ Built-in Themes**: Standard, Dark, Night, Night Blue, and Retro themes  
**Easy Integration**: Simple API with minimal setup required  
**Auto Persistence**: Automatically saves and restores user's theme preference  
**Three Usage Patterns**: Choose from MapThemeWidget, ThemeSelectorWidget, or MapThemeManager  
**Customizable UI**: Dropdown or horizontal list layouts with custom styling  
**Highly Testable**: Clean architecture with comprehensive test coverage  
**Flexible**: Works with any map widget that accepts style JSON [Currently supporting **Google maps** at the moment]

## Creating Custom Map Styles

### Google Maps Platform Styling Wizard

You can create custom map styles using Google's official [Map Styling Wizard](https://mapstyle.withgoogle.com/):

1. **Visit the Styling Wizard**: Navigate to [https://mapstyle.withgoogle.com/](https://mapstyle.withgoogle.com/)
2. **Choose a Theme**: Start with a base theme (Standard, Silver, Retro, Dark, Night, or Aubergine)
3. **Customize Elements**: Modify colors for roads, water, landmarks, labels, and other map features
4. **Preview Changes**: See real-time updates as you adjust the styling
5. **Export JSON**: Click "Finish" and copy the generated JSON style array
6. **Use in Your App**: Save the JSON to your assets folder and load it using `MapThemeManager` or create a custom `MapTheme` enum value

### SnazzyMaps - Community Map Styles

Explore thousands of free, pre-made map styles at [SnazzyMaps](https://snazzymaps.com/explore):

1. **Browse Styles**: Visit [https://snazzymaps.com/explore](https://snazzymaps.com/explore) to discover community-created themes
2. **Preview on Real Maps**: See how each style looks on actual map data
3. **Filter by Style**: Search by color schemes, tags, or popular themes
4. **Copy JSON**: Click on any style you like and copy the JavaScript Style Array
5. **Integrate**: Save the JSON to your project and reference it in your map implementation


## Demo Video

![map_themes](https://github.com/user-attachments/assets/acbea959-d40e-4aa9-9b39-c5db7ed82581)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  map_themes: ^0.0.1
  google_maps_flutter: ^2.5.0 # or your preferred map package [Only google_maps_flutter at the moment]
```

Then run:

```bash
flutter pub get
```

### Platform Setup

For Google Maps integration, follow the [official setup guide](https://pub.dev/packages/google_maps_flutter#getting-started):

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_API_KEY"/>
```

**iOS** (`ios/Runner/AppDelegate.swift`):

```swift
GMSServices.provideAPIKey("YOUR_API_KEY")
```

## Usage

### Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_themes/map_themes.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapThemeWidget(
        builder: (mapStyle) {
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.4219983, -122.084),
              zoom: 14.0,
            ),
            style: mapStyle.isEmpty ? null : mapStyle,
          );
        },
      ),
    );
  }
}
```

### Three Usage Patterns

#### 1. MapThemeWidget (All-in-One)

Perfect for quick integration with built-in theme selector:

```dart
MapThemeWidget(
  builder: (mapStyle) {
    return GoogleMap(
      initialCameraPosition: _initialPosition,
      style: mapStyle.isEmpty ? null : mapStyle,
      // ... other properties
    );
  },
  showSelector: true,
  selectorAlignment: Alignment.topRight,
  selectorLayout: ThemeSelectorLayout.horizontalList,
)
```

#### 2. ThemeSelectorWidget (Separate Selector)

When you want full control over map and selector placement:

```dart
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _currentMapStyle = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Themes'),
        actions: [
          ThemeSelectorWidget(
            layout: ThemeSelectorLayout.dropdown,
            onThemeChanged: (themeJson) async {
              setState(() {
                _currentMapStyle = themeJson;
              });
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        style: _currentMapStyle.isEmpty ? null : _currentMapStyle,
        // ... other properties
      ),
    );
  }
}
```

#### 3. MapThemeManager (Programmatic Control)

For advanced scenarios requiring direct theme management:

```dart
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapThemeManager _themeManager = MapThemeManager();

  @override
  void initState() {
    super.initState();
    _themeManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _themeManager,
        builder: (context, _) {
          return GoogleMap(
            initialCameraPosition: _initialPosition,
            style: _themeManager.currentStyleJson,
            // ... other properties
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _themeManager.setTheme(MapStyleTheme.dark),
        child: Icon(Icons.palette),
      ),
    );
  }

  @override
  void dispose() {
    _themeManager.dispose();
    super.dispose();
  }
}
```

## Examples

### Custom Asset Themes

Load your own custom theme JSON files:

```dart
ThemeSelectorWidget(
  customAssetPaths: [
    'assets/themes/custom_blue.json',
    'assets/themes/custom_green.json',
  ],
  onThemeChanged: (themeJson) async {
    // Handle theme change
  },
)
```

### Custom Theme Selector UI

Create completely custom selector UI:

```dart
ThemeSelectorWidget(
  customBuilder: ({
    required BuildContext context,
    required MapStyleTheme? currentTheme,
    required String? currentThemeName,
    required List<String> allThemes,
    required Function(String) onThemeSelected,
    required bool isEnabled,
    required ThemeSelectorStyle style,
  }) {
    return Wrap(
      children: allThemes.map((theme) {
        final isSelected = theme == currentThemeName;
        return GestureDetector(
          onTap: () => onThemeSelected(theme),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              theme.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  },
  onThemeChanged: (themeJson) {
    // Handle theme change
  },
)
```

### Shared Theme Manager

Share one theme manager across multiple map widgets:

```dart
class MultiMapScreen extends StatefulWidget {
  @override
  _MultiMapScreenState createState() => _MultiMapScreenState();
}

class _MultiMapScreenState extends State<MultiMapScreen> {
  final MapThemeManager _sharedManager = MapThemeManager();

  @override
  void initState() {
    super.initState();
    _sharedManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Theme selector
        ThemeSelectorWidget(
          themeManager: _sharedManager,
          onThemeChanged: (style) {}, // Optional callback
        ),

        // Multiple maps sharing the same theme
        Expanded(
          child: MapThemeWidget(
            themeManager: _sharedManager,
            showSelector: false,
            builder: (style) => GoogleMap(/* ... */),
          ),
        ),
        Expanded(
          child: MapThemeWidget(
            themeManager: _sharedManager,
            showSelector: false,
            builder: (style) => GoogleMap(/* ... */),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _sharedManager.dispose();
    super.dispose();
  }
}
```

## Customization

### Theme Selector Styling

Customize the appearance of theme selectors:

```dart
ThemeSelectorWidget(
  style: ThemeSelectorStyle(
    backgroundColor: Colors.white,
    selectedBackgroundColor: Colors.blue,
    textColor: Colors.black,
    selectedTextColor: Colors.white,
    borderRadius: 12.0,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    margin: EdgeInsets.all(4),
    elevation: 2.0,
  ),
  layout: ThemeSelectorLayout.horizontalList,
  onThemeChanged: (style) {
    // Handle theme change
  },
)
```

### Map Widget Selector Positioning

Control where the theme selector appears on your map:

```dart
MapThemeWidget(
  builder: (style) => GoogleMap(/* ... */),
  selectorAlignment: Alignment.bottomLeft,
  selectorBackgroundDecoration: BoxDecoration(
    color: Colors.black.withOpacity(0.7),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

## Parameters

### MapThemeWidget Parameters

| Parameter                      | Type                      | Default              | Description                                   |
| ------------------------------ | ------------------------- | -------------------- | --------------------------------------------- |
| `builder`                      | `Widget Function(String)` | **Required**         | Builder function that receives map style JSON |
| `showSelector`                 | `bool`                    | `true`               | Whether to show the theme selector overlay    |
| `selectorAlignment`            | `AlignmentGeometry`       | `Alignment.topRight` | Position of the theme selector on the map     |
| `selectorLayout`               | `ThemeSelectorLayout`     | `horizontalList`     | Layout style for the theme selector           |
| `selectorStyle`                | `ThemeSelectorStyle?`     | `null`               | Custom styling for the theme selector         |
| `themeManager`                 | `MapThemeManager?`        | `null`               | External theme manager instance               |
| `onThemeChanged`               | `Function(String)?`       | `null`               | Callback when theme changes                   |
| `selectorBackgroundDecoration` | `BoxDecoration?`          | `null`               | Custom background decoration for selector     |

### ThemeSelectorWidget Parameters

| Parameter          | Type                            | Default      | Description                               |
| ------------------ | ------------------------------- | ------------ | ----------------------------------------- |
| `onThemeChanged`   | `Future<void> Function(String)` | **Required** | Callback when theme is selected           |
| `layout`           | `ThemeSelectorLayout`           | `dropdown`   | Layout style (dropdown or horizontalList) |
| `style`            | `ThemeSelectorStyle?`           | `null`       | Custom styling for the selector           |
| `showLabels`       | `bool`                          | `true`       | Whether to show theme names               |
| `enabled`          | `bool`                          | `true`       | Whether the selector is interactive       |
| `themeManager`     | `MapThemeManager?`              | `null`       | External theme manager instance           |
| `customBuilder`    | `CustomBuilder?`                | `null`       | Custom builder for complete UI control    |
| `customAssetPaths` | `List<String>?`                 | `null`       | Additional custom theme asset paths       |

### MapThemeManager Properties

| Property           | Type                  | Description                                     |
| ------------------ | --------------------- | ----------------------------------------------- |
| `currentTheme`     | `MapStyleTheme`       | Currently selected predefined theme             |
| `currentStyleJson` | `String`              | Current map style JSON string                   |
| `currentThemeName` | `String?`             | Name of current theme (including custom)        |
| `isInitialized`    | `bool`                | Whether the manager has been initialized        |
| `isLoading`        | `bool`                | Whether a theme change operation is in progress |
| `error`            | `String?`             | Current error message, null if no error         |
| `allThemes`        | `Map<String, String>` | All available themes (name -> asset path)       |

### MapThemeManager Methods

| Method         | Parameters                        | Returns        | Description                            |
| -------------- | --------------------------------- | -------------- | -------------------------------------- |
| `initialize()` | `customAssetPaths: List<String>?` | `Future<void>` | Initialize the manager and load themes |
| `setTheme()`   | `theme: String or MapStyleTheme`  | `Future<void>` | Change to specified theme              |
| `dispose()`    | -                                 | `void`         | Clean up resources                     |

### ThemeSelectorStyle Properties

| Property                  | Type         | Default               | Description                           |
| ------------------------- | ------------ | --------------------- | ------------------------------------- |
| `backgroundColor`         | `Color`      | `Colors.grey[200]`    | Background color for unselected items |
| `selectedBackgroundColor` | `Color`      | `Colors.blue`         | Background color for selected item    |
| `textColor`               | `Color`      | `Colors.black`        | Text color for unselected items       |
| `selectedTextColor`       | `Color`      | `Colors.white`        | Text color for selected item          |
| `borderRadius`            | `double`     | `8.0`                 | Border radius for selector items      |
| `padding`                 | `EdgeInsets` | `EdgeInsets.all(8.0)` | Internal padding for items            |
| `margin`                  | `EdgeInsets` | `EdgeInsets.all(2.0)` | External margin for items             |
| `elevation`               | `double`     | `1.0`                 | Shadow elevation for items            |

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. **Fork and Clone**

   ```bash
   git clone https://github.com/Captured-Heart/map_themes.git
   cd map_themes
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   cd example && flutter pub get
   ```

3. **Run Tests**

   ```bash
   flutter test
   ```

4. **Run Example**
   ```bash
   cd example
   flutter run
   ```

### Contributing Guidelines

- **Code Style**: Follow Dart's official style guide and use `flutter format`
- **Testing**: Maintain test coverage above 90% - add tests for new features
- **Documentation**: Update documentation for API changes
- **Commit Messages**: Use conventional commits (feat:, fix:, docs:, etc.)

Also, look at our [Contributing guidelines](CONTRIBUTING.md)

### Reporting Issues

When reposting an issue, provide us with additional information such as:

- Flutter version and platform
- Minimal reproduction code
- Expected vs actual behavior
- Relevant error messages or logs

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## More Information

- **Documentation**: [Usage Article]()
- **Issues**: [GitHub Issues](https://github.com/Captured-Heart/map_themes/issues)
- **Examples**: Check out the `/example` folder for comprehensive usage examples

### Related Packages

- [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) - Google Maps widget for Flutter
- [shared_preferences](https://pub.dev/packages/shared_preferences) - Platform-agnostic persistent storage

<sub>Built with 💜 by <a href="https://twitter.com/_Captured_Heart">Nkpozi Marcel Kelechi (X: @Captured-Heart)</a></sub>
