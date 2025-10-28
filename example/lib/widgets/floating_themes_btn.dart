import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:map_themes/map_themes.dart';

class FloatingThemeBtnsWidget extends StatelessWidget {
  FloatingThemeBtnsWidget({super.key, required this.manager});
  final MapThemeManager manager;

  final _key = GlobalKey<ExpandableFabState>();
  Color textColor(String mapStyle) {
    return switch (mapStyle) {
      'nightBlue' => Colors.blue,
      'retro' => Colors.amber,
      'night' => Colors.blueGrey,
      _ => Colors.black,
    };
  }

  IconData styleIcons(String mapStyle) {
    return switch (mapStyle) {
      'nightBlue' => Icons.nightlight_outlined,
      'night' => Icons.dark_mode,
      'retro' => Icons.filter_vintage,
      'dark' => Icons.nights_stay_rounded,
      'original' => Icons.wb_sunny_outlined,
      _ => Icons.sunny,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      key: _key,
      type: ExpandableFabType.up,
      pos: ExpandableFabPos.right,
      fanAngle: 180,
      distance: 70,
      overlayStyle: ExpandableFabOverlayStyle(blur: 2, color: Colors.black.withValues(alpha: 0.2)),
      openButtonBuilder: FloatingActionButtonBuilder(
        size: 80,
        builder: (context, controller, _) {
          return const SizedBox.square(
            dimension: 60,
            child: Card(
              color: Colors.amberAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
              elevation: 5,
              child: Icon(Icons.map),
            ),
          );
        },
      ),
      closeButtonBuilder: FloatingActionButtonBuilder(
        size: 80,
        builder: (context, controller, _) {
          return const SizedBox.square(
            dimension: 60,
            child: Card(
              color: Colors.amberAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
              elevation: 5,
              child: Icon(Icons.close),
            ),
          );
        },
      ),
      children: [
        ...List.generate(manager.allThemes.length, (index) {
          final mapStyle = manager.allThemes.keys.elementAt(index);
          return FloatingActionButton.extended(
            backgroundColor: Colors.white,
            heroTag: mapStyle,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              side: BorderSide(color: Colors.amberAccent, width: 1),
            ),
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                state.toggle();
              }
              manager.setTheme(mapStyle);
            },
            label: Text(mapStyle.toUpperCase()),
            icon: Icon(styleIcons(mapStyle), color: textColor(mapStyle)),
          );
        }),
      ],
    );
  }
}
