import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/journal_models.dart';
import '../data/journal_repository.dart';
import 'encryption_indicator.dart';
import '../../../theme/app_tokens.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Reusable journal entry detail body (for full screen or two-pane detail).
class JournalEntryDetailContent extends ConsumerWidget {
  const JournalEntryDetailContent({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(journalEntryDetailProvider(entryId));

    return entryAsync.when(
      data: (entry) {
        if (entry == null) {
          return const Center(child: Text('Entry not found'));
        }
        return _EntryContent(entry: entry);
      },
      loading: () => ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          SkeletonLoader(child: SkeletonCard(lineCount: 4)),
        ],
      ),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(journalEntryDetailProvider(entryId)),
      ),
    );
  }
}

class _EntryContent extends StatelessWidget {
  const _EntryContent({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark
        ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.8)
        : AppColors.onSurfaceVariant.withValues(alpha: 0.8);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                  ),
                  child: Text(
                    'Private',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primaryDarkMode : AppColors.primary)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                  ),
                  child: Text(
                    'Shared',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark ? AppColors.primaryDarkMode : AppColors.primary,
                        ),
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              if (entry.isEncrypted) const EncryptionIndicator(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            entry.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormat.yMMMd().add_jm().format(entry.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
          ),
          if (entry.body != null && entry.body!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              entry.body!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          if (entry.hasPhoto) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: muted.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.image_rounded, size: 48, color: muted),
            ),
          ],
          if (entry.hasAudio) ...[
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.mic_rounded),
              title: const Text('Voice note'),
              tileColor: muted.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
