import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_themes/map_themes.dart';
import 'package:map_themes_example/constant.dart';

/// In this method, we demonstrate how to use the CustomBuilder in the ThemeSelectorWidget
/// You are free to save the selected theme to SharedPreferences or your preferred storage
/// Here, you are in charge of applying the selected theme to the GoogleMap widget
class CustomThemeSelectorView extends StatefulWidget {
  const CustomThemeSelectorView({super.key});

  @override
  State<CustomThemeSelectorView> createState() => _CustomThemeSelectorViewState();
}

class _CustomThemeSelectorViewState extends State<CustomThemeSelectorView> {
  String mapStyles = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('(Step 4) Custom Theme Selector Widget', style: Theme.of(context).textTheme.bodyLarge)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: ThemeSelectorWidget(
        /// You can provide your own custom asset paths here, it automatically replaces the default ones
        customAssetPaths: ['assets/barca.json', 'assets/liverpool.json'],
        onThemeChanged: (mapStyleJson) async {
          /// You can save th e selected theme to SharedPreferences or your preferred storage here
          /// For demonstration, we just update the map style directly
          setState(() {
            mapStyles = mapStyleJson;
          });
        },
        customBuilder: ({
          required allThemes,
          required context,
          required currentTheme,
          required currentThemeName,
          required isEnabled,
          required onThemeSelected,
          required style,
        }) {
          return PopupMenuButton<String>(
            tooltip: 'Select Map Theme',
            color: style.backgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: Colors.green, width: 5.0)),
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            elevation: 4,
            enabled: isEnabled,
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Select Theme:'), Icon(Icons.map, color: isEnabled ? style.selectedBackgroundColor : style.backgroundColor, size: 50)],
            ),
            onSelected: (theme) {
              onThemeSelected(theme);
            },
            itemBuilder: (context) {
              return allThemes
                  .map(
                    (theme) => PopupMenuItem<String>(value: theme, child: Text(theme, style: style.selectedTextStyle?.copyWith(color: Colors.black))),
                  )
                  .toList();
            },
          );
        },
      ),
      body: GoogleMap(
        initialCameraPosition: cameraInitialPosition,
        style: mapStyles,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        onMapCreated: (controller) {},
        myLocationEnabled: true,
      ),
    );
  }
}
