import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// Shimmer skeleton for loading states. Use for cards and list items.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.baseColor ??
        (isDark
            ? AppColors.surfaceVariantDark.withValues(alpha: 0.6)
            : AppColors.surfaceVariant.withValues(alpha: 0.6));
    final highlight = widget.highlightColor ??
        (isDark
            ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.2)
            : AppColors.onSurfaceVariant.withValues(alpha: 0.15));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [base, highlight, base],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Simple box skeleton (no shimmer). Use for lines/blocks.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? AppColors.surfaceVariantDark.withValues(alpha: 0.8)
        : AppColors.surfaceVariant.withValues(alpha: 0.8);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadii.xs),
      ),
    );
  }
}

/// Card-shaped skeleton for dashboard widgets.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.titleHeight = 20,
    this.subtitleHeight = 14,
    this.lineCount = 2,
    this.padding = AppSpacing.md,
  });

  final double titleHeight;
  final double subtitleHeight;
  final int lineCount;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonBox(width: 120, height: titleHeight),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: double.infinity, height: subtitleHeight),
          if (lineCount > 1) ...[
            SizedBox(height: AppSpacing.xs),
            SkeletonBox(width: 200, height: subtitleHeight),
          ],
        ],
      ),
    );
  }
}
