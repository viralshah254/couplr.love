import 'package:flutter/material.dart';

import '../../../theme/app_tokens.dart';

/// Horizontal progress indicator for joint session steps (completed / current / upcoming).
class ConflictProgressSteps extends StatelessWidget {
  const ConflictProgressSteps({
    super.key,
    required this.total,
    required this.completedCount,
  });

  final int total;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Row(
      children: List.generate(total, (i) {
        final isCompleted = i < completedCount;
        final isCurrent = i == completedCount;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: i < total - 1 ? AppSpacing.xs : 0,
            ),
            child: AnimatedContainer(
              duration: AppMotion.normal,
              curve: AppMotion.easeOut,
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted
                    ? primary
                    : (isCurrent
                        ? primary.withValues(alpha: 0.4)
                        : muted.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}
