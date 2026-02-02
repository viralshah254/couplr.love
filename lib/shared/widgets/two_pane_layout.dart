import 'package:flutter/material.dart';

import '../../core/layout/app_breakpoints.dart';

/// Responsive two-pane layout: list on the left, detail on the right when wide;
/// list only when narrow (detail shown via navigation).
class TwoPaneLayout extends StatelessWidget {
  const TwoPaneLayout({
    super.key,
    required this.listPane,
    required this.detailPane,
    this.breakpointWidth = AppBreakpoints.expanded,
    this.listPaneWidth = AppBreakpoints.listPaneWidth,
    this.listPaneMinWidth,
  });

  /// Left pane (e.g. list of items).
  final Widget listPane;

  /// Right pane (e.g. detail or placeholder). Shown only when [breakpointWidth] is met.
  final Widget detailPane;

  /// Minimum width to show two panes.
  final double breakpointWidth;

  /// Width of the list pane when two panes are shown.
  final double listPaneWidth;

  /// Optional minimum width for the list pane.
  final double? listPaneMinWidth;

  /// Whether the current context is wide enough for two panes.
  static bool isTwoPane(BuildContext context, [double? breakpoint]) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= (breakpoint ?? AppBreakpoints.expanded);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showTwoPane = width >= breakpointWidth;

    if (showTwoPane) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: listPaneWidth,
            child: listPane,
          ),
          Expanded(child: detailPane),
        ],
      );
    }

    return listPane;
  }
}
