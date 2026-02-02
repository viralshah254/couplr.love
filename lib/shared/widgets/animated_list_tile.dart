import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_tokens.dart';

/// List item that fades and slides in for a polished list appearance.
/// Use for list builders; [index] drives staggered delay.
class AnimatedListTile extends StatefulWidget {
  const AnimatedListTile({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = AppMotion.normal,
    this.curve = AppMotion.easeOut,
  });

  final Widget child;
  final int index;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedListTile> createState() => _AnimatedListTileState();
}

class _AnimatedListTileState extends State<AnimatedListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    final delay = (widget.index * 30).clamp(0, 150);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

/// Wraps [onTap] with haptic feedback. Use for list tiles and cards.
void handleListTap(VoidCallback onTap) {
  HapticFeedback.lightImpact();
  onTap();
}
