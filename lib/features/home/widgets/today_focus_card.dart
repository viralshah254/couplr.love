import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/home_dashboard_repository.dart';
import '../../../theme/app_tokens.dart';

/// Today's focus: one intentional action or prompt.
class TodayFocusCard extends StatelessWidget {
  const TodayFocusCard({
    super.key,
    required this.focus,
    this.onTap,
  });

  final TodayFocus focus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return Card(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny_rounded, size: 20, color: accent),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Today\'s focus',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                focus.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (focus.subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  focus.subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
