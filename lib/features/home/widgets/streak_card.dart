import 'package:flutter/material.dart';

import '../data/home_dashboard_repository.dart';
import '../../../theme/app_tokens.dart';

/// Streak widget: consecutive days with optional label.
class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.streak,
  });

  final StreakInfo streak;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.secondaryDark : AppColors.secondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(Icons.local_fire_department_rounded, color: accent, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${streak.currentStreak}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: accent,
                        ),
                  ),
                  Text(
                    streak.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
