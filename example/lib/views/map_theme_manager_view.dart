import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_themes/map_themes.dart';
import 'package:map_themes_example/constant.dart';
import 'package:map_themes_example/widgets/floating_themes_btn.dart';

class MapThemeManagerView extends StatefulWidget {
  const MapThemeManagerView({super.key});

  @override
  State<MapThemeManagerView> createState() => _MapThemeManagerViewState();
}

class _MapThemeManagerViewState extends State<MapThemeManagerView> {
  final MapThemeManager _themeManager = MapThemeManager();

  @override
  initState() {
    super.initState();

    /// We can initialize the theme manager in the initState
    /// Note that, if you don't initialize it, the default theme will be applied (standard)
    _themeManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    inspect(_themeManager);
    return Scaffold(
      appBar: AppBar(title: Text('(Step 3) Map Theme Manager', style: Theme.of(context).textTheme.bodyLarge)),
      //TODO: CAN ALSO USE YOUR PREFERRED WIDGET TO TRIGGER THEME CHANGES
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton.extended(
      //   label: const Text('"Set Theme in code"\nApply the "MapStyleTheme"'),

      //   onPressed: () {
      //     /// the setTheme method can be used to change the theme even if the class hasn't been initialized
      //     _themeManager.setTheme(MapStyleTheme.retro.name);
      //   },
      // ),
      //! i like the Expandable_fab that's why i imported it for this example
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: FloatingThemeBtnsWidget(manager: _themeManager),
      body: ListenableBuilder(
        listenable: _themeManager,
        builder: (context, _) {
          return GoogleMap(
            initialCameraPosition: cameraInitialPosition,
            style: _themeManager.currentStyleJson,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (controller) {},
            myLocationEnabled: false,
          );
        },
      ),
    );
  }
}
