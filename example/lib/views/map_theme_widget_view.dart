import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_themes/map_themes.dart';
import 'package:map_themes_example/constant.dart';

class MapThemeWidgetView extends StatefulWidget {
  const MapThemeWidgetView({super.key});

  @override
  State<MapThemeWidgetView> createState() => _MapThemeWidgetViewState();
}

class _MapThemeWidgetViewState extends State<MapThemeWidgetView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('(Step 1) Map Theme Widget View', style: Theme.of(context).textTheme.bodyLarge)),
      body: MapThemeWidget(
        // selectorLayout: ThemeSelectorLayout.dropdown,
        // showSelector: false,
        // assets: [
        //   'assets/map_styles/standard.json',
        //   'assets/map_styles/silver.json',
        //   'assets/map_styles/night.json',
        //   'assets/map_styles/aubergine.json',
        // ],
        builder: (mapStyleJson) {
          print('Map Style JSON: $mapStyleJson');
          return GoogleMap(
            initialCameraPosition: cameraInitialPosition,
            style: mapStyleJson,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (controller) {},
            myLocationEnabled: true,
          );
        },
      ),
    );
  }
}
