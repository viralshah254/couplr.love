import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/home_dashboard_repository.dart';
import '../../../theme/app_tokens.dart';

/// Gratitude reminder: prompt to log or view partner's response.
class GratitudeReminderCard extends StatelessWidget {
  const GratitudeReminderCard({
    super.key,
    required this.reminder,
    this.onAddGratitude,
    this.onViewPartner,
  });

  final GratitudeReminder reminder;
  final VoidCallback? onAddGratitude;
  final VoidCallback? onViewPartner;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.secondaryDark : AppColors.secondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.volunteer_activism_rounded, size: 20, color: accent),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Gratitude',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              reminder.prompt,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
            ),
            if (reminder.partnerResponse != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote_rounded, size: 18, color: accent),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        reminder.partnerResponse!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (onAddGratitude != null)
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onAddGratitude!();
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add yours'),
                  ),
                if (reminder.partnerResponse != null && onViewPartner != null)
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onViewPartner!();
                    },
                    child: const Text('View all'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
