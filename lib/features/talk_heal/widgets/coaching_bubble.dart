import 'package:flutter/material.dart';

import '../../../theme/app_tokens.dart';

/// Non-judgmental AI coaching message bubble for joint session.
class CoachingBubble extends StatelessWidget {
  const CoachingBubble({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark ? AppColors.secondaryDark : AppColors.secondary;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.psychology_rounded,
            size: 20,
            color: secondary.withValues(alpha: 0.9),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurface,
                      height: 1.35,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
