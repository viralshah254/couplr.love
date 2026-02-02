import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/grow_models.dart';
import '../../../theme/app_tokens.dart';

/// Ritual card: title, frequency, next due, complete action.
class RitualCard extends StatelessWidget {
  const RitualCard({
    super.key,
    required this.ritual,
    this.onComplete,
    this.onTap,
  });

  final Ritual ritual;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  String _frequencyLabel(RitualFrequency f) {
    switch (f) {
      case RitualFrequency.daily:
        return 'Daily';
      case RitualFrequency.weekly:
        return 'Weekly';
      case RitualFrequency.biweekly:
        return 'Every 2 weeks';
      case RitualFrequency.monthly:
        return 'Monthly';
    }
  }

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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(Icons.repeat_rounded, color: accent, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ritual.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _frequencyLabel(ritual.frequency),
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
              if (ritual.description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ritual.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                ),
              ],
              if (ritual.nextDue != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Next: ${DateFormat.MMMd().format(ritual.nextDue!)}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isDark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
              if (onComplete != null) ...[
                const SizedBox(height: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onComplete!();
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Mark done'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
