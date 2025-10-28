import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_themes/map_themes.dart';
import 'package:map_themes_example/constant.dart';

/// In this method, we demonstrate how to use the ThemeSelectorWidget
/// You are free to save the selected theme to SharedPreferences or your preferred storage
/// Here, you are in charge of applying the selected theme to the GoogleMap widget
class ThemeSelectorWidgetView extends StatefulWidget {
  const ThemeSelectorWidgetView({super.key});

  @override
  State<ThemeSelectorWidgetView> createState() => _ThemeSelectorWidgetViewState();
}

class _ThemeSelectorWidgetViewState extends State<ThemeSelectorWidgetView> {
  String mapStyles = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('(Step 2) Map Theme Selector Widget', style: Theme.of(context).textTheme.bodyLarge)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ThemeSelectorWidget(
        layout: ThemeSelectorLayout.horizontalList,
        // customAssetPaths: ['assets/barca.json', 'assets/liverpool.json'],
        onThemeChanged: (mapStyleJson) async {
          print('Selected Map Style JSON: $mapStyleJson');

          /// You can save the selected theme to SharedPreferences or your preferred storage here
          /// For demonstration, we just update the map style directly
          setState(() {
            mapStyles = mapStyleJson;
          });
        },
        // customBuilder: ({required context, required currentTheme, required isEnabled, required onThemeSelected, required style, required themes}) {
        //   return Text('$themes');
        // },
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
