import 'package:flutter/material.dart';

/// Accessibility helpers for WCAG-aligned semantics and large text.
/// Use [semanticLabel] on interactive widgets and images when the label
/// is not obvious from content.

/// Wraps [child] with a semantic label for screen readers.
Widget semanticButton({
  required String label,
  String? hint,
  required Widget child,
  VoidCallback? onTap,
}) {
  return Semantics(
    button: true,
    label: label,
    hint: hint,
    child: child,
  );
}

/// Wraps [child] with a semantic heading for structure.
Widget semanticHeading({
  required String label,
  required int level,
  required Widget child,
}) {
  return Semantics(
    header: true,
    label: label,
    child: child,
  );
}

/// Wraps [child] with semantic live region for dynamic content.
Widget semanticLiveRegion({
  required String label,
  required Widget child,
}) {
  return Semantics(
    liveRegion: true,
    label: label,
    child: child,
  );
}
