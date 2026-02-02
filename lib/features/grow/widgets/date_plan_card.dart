import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/grow_models.dart';
import '../../../theme/app_tokens.dart';

/// Date plan card: title, description, scheduled time, category.
class DatePlanCard extends StatelessWidget {
  const DatePlanCard({
    super.key,
    required this.plan,
    this.onTap,
    this.onComplete,
  });

  final DatePlan plan;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.secondaryDark : AppColors.secondary;

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
                    child: Icon(Icons.favorite_rounded, color: accent, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (plan.scheduledAt != null)
                          Text(
                            DateFormat.MMMd().add_jm().format(plan.scheduledAt!),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.onSurfaceVariantDark
                                      : AppColors.onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (plan.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                      ),
                      child: Text(
                        plan.category!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: accent,
                            ),
                      ),
                    ),
                ],
              ),
              if (plan.description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  plan.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                ),
              ],
              if (!plan.isCompleted && onComplete != null) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onComplete!();
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Mark as done'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
