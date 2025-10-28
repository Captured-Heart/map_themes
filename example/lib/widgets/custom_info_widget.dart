import 'package:flutter/material.dart';

class CustomInfoWidget extends StatelessWidget {
  const CustomInfoWidget({super.key, required this.title, required this.subtitle1, required this.subtitle2});

  final String title, subtitle1, subtitle2;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(subtitle1, style: Theme.of(context).textTheme.bodySmall),
              Text(subtitle2, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
