import 'package:flutter/material.dart';

/// Breakpoints for responsive layout (mobile-first, tablet optimized).
/// Use with MediaQuery or LayoutBuilder to switch between single-pane and two-pane.
class AppBreakpoints {
  AppBreakpoints._();

  /// Compact: phone portrait/landscape (< 600 logical px).
  static const double compact = 600;

  /// Medium: tablet portrait, large phone landscape (600–839).
  static const double medium = 840;

  /// Expanded: tablet landscape, desktop (>= 840).
  static const double expanded = 840;

  /// Default width for list pane in two-pane layout.
  static const double listPaneWidth = 360;

  /// True when width >= [compact] (tablet portrait or wider).
  static bool isMediumOrWider(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= compact;
  }

  /// True when width >= [expanded] (tablet landscape or wider). Use for two-pane.
  static bool isWide(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= expanded;
  }

  /// True when height is relatively short (e.g. landscape phone).
  static bool isShort(BuildContext context) {
    return MediaQuery.sizeOf(context).height < 500;
  }
}
