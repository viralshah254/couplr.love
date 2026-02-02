import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/grow_models.dart';
import '../../../theme/app_tokens.dart';

/// Habit challenge card: title, streak, progress, complete action.
class HabitChallengeCard extends StatelessWidget {
  const HabitChallengeCard({
    super.key,
    required this.challenge,
    this.onComplete,
    this.onTap,
  });

  final HabitChallenge challenge;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final target = challenge.targetStreak ?? 30;
    final progress = target > 0 ? (challenge.currentStreak / target).clamp(0.0, 1.0) : 0.0;

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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (challenge.description != null)
                          Text(
                            challenge.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.onSurfaceVariantDark
                                      : AppColors.onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${challenge.currentStreak}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: accent,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'day streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              if (challenge.targetStreak != null) ...[
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${challenge.currentStreak} / $target days',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                ),
              ],
              if (!challenge.completedToday && onComplete != null) ...[
                const SizedBox(height: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onComplete!();
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Mark done today'),
                ),
              ],
              if (challenge.completedToday)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 18, color: accent),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Done today',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: accent,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
