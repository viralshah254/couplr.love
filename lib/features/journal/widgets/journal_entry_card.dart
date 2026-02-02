import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/journal_models.dart';
import 'encryption_indicator.dart';
import '../../../theme/app_tokens.dart';

/// Journal entry card: title, preview, date, private/shared, encryption, photo/audio.
class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  final JournalEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark
        ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.8)
        : AppColors.onSurfaceVariant.withValues(alpha: 0.8);

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
                  if (entry.isPrivate)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: muted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 12, color: muted),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            'Private',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: muted,
                                ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 12, color: accent),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            'Shared',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: accent,
                                ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  if (entry.isEncrypted) const EncryptionIndicator(compact: true),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                entry.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (entry.preview.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  entry.preview,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: muted,
                      ),
                  ),
                ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: muted),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    DateFormat.MMMd().format(entry.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: muted,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  if (entry.hasPhoto) ...[
                    Icon(Icons.image_rounded, size: 14, color: muted),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  if (entry.hasAudio) ...[
                    Icon(Icons.mic_rounded, size: 14, color: muted),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
