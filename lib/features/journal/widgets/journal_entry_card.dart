import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/journal_models.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final secondary = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Card(
      elevation: AppElevation.sm,
      shadowColor: (isDark ? AppColors.onSurfaceDark : AppColors.onSurface)
          .withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(
          color: (entry.isPrivate ? secondary : primary).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
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
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: secondary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 14, color: secondary),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            'Private',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 14, color: primary),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            'Shared',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  if (entry.isEncrypted)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xxs),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 14,
                        color: muted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                entry.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                ),
              ),
              if (entry.preview.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  entry.preview,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: muted),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    DateFormat.MMMd().format(entry.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
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
