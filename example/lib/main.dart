import 'package:flutter/material.dart';
import 'package:map_themes_example/views/custom_theme_selector_view.dart';
import 'package:map_themes_example/views/map_theme_manager_view.dart';
import 'package:map_themes_example/views/map_theme_widget_view.dart';
import 'package:map_themes_example/views/theme_selector_widget_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapHomePage(),
      onGenerateTitle: (context) => 'Map Themes Example App',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return switch (settings.name) {
              '/map-theme-widget' => const MapThemeWidgetView(),
              '/theme-selector-widget' => const ThemeSelectorWidgetView(),
              '/map-theme-manager' => const MapThemeManagerView(),
              '/custom-theme-selector' => const CustomThemeSelectorView(),
              _ => const SizedBox(),
            };
          },
        );
      },
    );
  }
}

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  int? _selectedIndex;
  bool _isLoading = false;
  void _updateSelectedIndex(int index) {
    _setLoading();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _setLoading() {
    _isLoading = true;
    Future.delayed(const Duration(milliseconds: 700)).then((_) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return switch (_selectedIndex) {
                0 => const MapThemeWidgetView(),
                1 => const ThemeSelectorWidgetView(),
                2 => const MapThemeManagerView(),
                3 => const CustomThemeSelectorView(),
                _ => const SizedBox(),
              };
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Themes "example" app')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        children: [
          Text(
            'Choose one of the following methods to integrate map themes into your app:',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.start,
          ),
          //
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8.0,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Step ${index + 1}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  HomeMapThemeOptionListTile(
                    onTap: () => _updateSelectedIndex(index),
                    isLoading: _isLoading && _selectedIndex == index,
                    isSelected: _selectedIndex == index,
                    title: ['Use "MapThemeWidget"', 'Use "ThemeSelectorWidget"', 'Use "MapThemeManager" directly', 'Custom theme selector'][index],
                    subtitle:
                        [
                          'Wrap your map widget with MapThemeWidget to get map display and theme selector UI.',
                          'Use ThemeSelectorWidget to provide a theme selection UI and handle theme changes.',
                          'Use MapThemeManager to manage themes programmatically.',
                          'use custom UI & assetPaths to select and apply map themes.',
                        ][index],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeMapThemeOptionListTile extends StatelessWidget {
  const HomeMapThemeOptionListTile({super.key, required this.title, required this.subtitle, this.isSelected = false, this.onTap, this.isLoading});
  final String title, subtitle;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      transform: isSelected ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.1),
        color: isSelected ? Colors.grey.shade200 : null,
        boxShadow: [if (isSelected) BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing:
            isLoading == true ? SizedBox.square(dimension: 18, child: const CircularProgressIndicator()) : const Icon(Icons.chevron_right_outlined),
        dense: true,
      ),
    );
  }
}
