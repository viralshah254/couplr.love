import 'package:flutter/material.dart';

/// Placeholder for shared reusable widgets (skeleton loaders, empty/error states, etc.).
class CouplrPlaceholder extends StatelessWidget {
  const CouplrPlaceholder({super.key, this.label = 'Shared widget'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label));
  }
}
