import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/grow_models.dart' show Badge;
import '../../../theme/app_tokens.dart';

/// Badge chip or card for earned badges.
class BadgeChip extends StatelessWidget {
  const BadgeChip({
    super.key,
    required this.badge,
    this.compact = false,
  });

  final Badge badge;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.secondaryDark : AppColors.secondary;

    if (compact) {
      return Tooltip(
        message: badge.title,
        child: Material(
          color: accent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadii.full),
          child: InkWell(
            onTap: () => HapticFeedback.selectionClick(),
            borderRadius: BorderRadius.circular(AppRadii.full),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 24,
                color: accent,
              ),
            ),
          ),
        ),
      );
    }

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
              child: Icon(Icons.emoji_events_rounded, color: accent, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    badge.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (badge.description != null)
                    Text(
                      badge.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariant,
                          ),
                    ),
                  if (badge.earnedAt != null)
                    Text(
                      'Earned ${DateFormat.yMMMd().format(badge.earnedAt!)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
