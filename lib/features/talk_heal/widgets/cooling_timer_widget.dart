import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_tokens.dart';

/// Cooling timer: countdown before viewing shared agenda. Calm, motion-first.
class CoolingTimerWidget extends StatefulWidget {
  const CoolingTimerWidget({
    super.key,
    required this.totalSeconds,
    required this.onComplete,
  });

  final int totalSeconds;
  final VoidCallback onComplete;

  @override
  State<CoolingTimerWidget> createState() => _CoolingTimerWidgetState();
}

class _CoolingTimerWidgetState extends State<CoolingTimerWidget>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalSeconds;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _runTimer();
  }

  Future<void> _runTimer() async {
    while (_remaining > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        HapticFeedback.mediumImpact();
        widget.onComplete();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final progress = _remaining / widget.totalSeconds;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Take a breath',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Shared agenda in',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 100 + (_pulseController.value * 8),
                height: 100 + (_pulseController.value * 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.2),
                ),
                child: Text(
                  '$_remaining',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: accent,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }
}
