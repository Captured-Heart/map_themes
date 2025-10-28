import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/map_theme_config.dart';
import '../enums/map_theme.dart';

class MapThemeManager extends ChangeNotifier {
  MapStyleTheme _currentTheme = MapStyleTheme.standard;
  String _currentStyleJson = '';
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  Map<String, String> _allThemes = {};
  String? _currentThemeName;

  /// Current selected theme
  MapStyleTheme get currentTheme => _currentTheme;

  /// Current map style JSON string
  String get currentStyleJson => _currentStyleJson;

  /// Check if the manager has been initialized
  bool get isInitialized => _isInitialized;

  /// Check if a theme change operation is in progress
  bool get isLoading => _isLoading;

  /// Current error message, null if no error
  String? get error => _error;

  /// All available themes (name -> asset path)
  Map<String, String> get allThemes => Map.unmodifiable(_allThemes);

  /// Current theme name (either predefined or custom)
  String? get currentThemeName => _currentThemeName;

  /// Initialize the theme manager
  Future<void> initialize({List<String>? customAssetPaths}) async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _clearError();

      _loadAllThemes(customAssetPaths);

      final prefs = await SharedPreferences.getInstance();
      final savedThemeName = prefs.getString(MapThemeConfig.themePreferenceKey);

      if (savedThemeName != null && _allThemes.containsKey(savedThemeName)) {
        _currentThemeName = savedThemeName;
        await _loadStyleJson();
      } else {
        _currentTheme = MapStyleTheme.standard;
        _currentThemeName = null;
        _currentStyleJson = '';
      }

      _isInitialized = true;
    } catch (e) {
      _setError('Failed to initialize theme manager: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set theme by name (works for both predefined and custom themes)
  Future<void> setTheme(String themeName) async {
    final currentName = _currentThemeName ?? _currentTheme.name;
    if (currentName == themeName) return;

    try {
      _setLoading(true);
      _clearError();

      if (_allThemes.containsKey(themeName)) {
        _currentThemeName = themeName;
        _currentStyleJson = await _loadAssetString(_allThemes[themeName]!);
        final enumTheme = MapStyleTheme.values.where((t) => t.name == themeName).firstOrNull;
        if (enumTheme != null) {
          _currentTheme = enumTheme;
        }
        notifyListeners();
      } else if (themeName == MapStyleTheme.standard.name) {
        _currentTheme = MapStyleTheme.standard;
        _currentThemeName = null;
        _currentStyleJson = '';
        notifyListeners();
      } else {
        _setError('Theme "$themeName" not found');
        return;
      }

      await _saveThemePreference();
    } catch (e) {
      _setError('Failed to set theme: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set theme using MapStyleTheme enum (for predefined themes)
  Future<void> setThemeByEnum(MapStyleTheme theme) async {
    await setTheme(theme.name);
  }

  /// Reset to standard theme
  Future<void> resetToStandard() async {
    await setTheme(MapStyleTheme.standard.name);
  }

  /// Load all available themes from predefined and custom asset paths
  void _loadAllThemes(List<String>? customAssetPaths) {
    _allThemes.clear();

    for (final assetPath in MapThemeConfig.predefinedThemeAssets) {
      final themeName = _extractThemeNameFromPath(assetPath);
      final enumName = _mapFileNameToEnumName(themeName);
      _allThemes[enumName] = assetPath;
    }

    if (customAssetPaths != null) {
      for (final assetPath in customAssetPaths) {
        final themeName = _extractThemeNameFromPath(assetPath);
        _allThemes[themeName] = assetPath;
      }
    }
  }

  /// Map file names to enum names to handle naming differences
  String _mapFileNameToEnumName(String fileName) {
    switch (fileName) {
      case 'night_blue':
        return 'nightBlue';
      default:
        return fileName;
    }
  }

  /// Extract theme name from asset path
  String _extractThemeNameFromPath(String path) {
    final fileName = path.split('/').last;
    return fileName.replaceAll('.json', '');
  }

  /// Load the style JSON for the current theme
  Future<void> _loadStyleJson() async {
    if (_currentThemeName != null && _allThemes.containsKey(_currentThemeName)) {
      _currentStyleJson = await _loadAssetString(_allThemes[_currentThemeName]!);
      final enumTheme = MapStyleTheme.values.where((t) => t.name == _currentThemeName).firstOrNull;
      if (enumTheme != null) {
        _currentTheme = enumTheme;
      }
    } else {
      _currentStyleJson = '';
      _currentTheme = MapStyleTheme.standard;
    }
  }

  /// Load a string asset, with error handling
  Future<String> _loadAssetString(String path) async {
    try {
      final content = await rootBundle.loadString(path);
      return content;
    } catch (e) {
      throw Exception('Failed to load style from $path: $e');
    }
  }

  /// Save the current theme to SharedPreferences
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeToSave = _currentThemeName ?? _currentTheme.name;
      await prefs.setString(MapThemeConfig.themePreferenceKey, themeToSave);
    } catch (e) {
      throw Exception('Failed to save theme preference: $e');
    }
  }

  /// Clear the saved theme preference
  Future<void> clearThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(MapThemeConfig.themePreferenceKey);
      await resetToStandard();
    } catch (e) {
      _setError('Failed to clear theme preference: $e');
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _currentStyleJson = '';
    _error = null;
    _isInitialized = false;
    _isLoading = false;
    _allThemes.clear();
    _currentThemeName = null;

    super.dispose();
  }
}
