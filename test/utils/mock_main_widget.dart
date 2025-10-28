import 'package:flutter/material.dart';

Widget mockMainWidget({required Widget child}) {
  return MaterialApp(home: Scaffold(body: child));
}

Widget mapBuilder(String mapStyleJson, {VoidCallback? onBuild}) {
  if (onBuild != null) {
    onBuild();
  }
  return Container(key: const Key('mock_map'), child: Text('Map with style: ${mapStyleJson.isEmpty ? "standard" : "styled"}'));
}
