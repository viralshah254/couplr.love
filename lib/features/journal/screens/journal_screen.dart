import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/journal_models.dart';
import '../data/journal_repository.dart';
import '../widgets/journal_entry_card.dart';
import '../widgets/journal_entry_detail_content.dart';
import '../widgets/journal_filters.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/two_pane_layout.dart';

/// Journal timeline: shared/private entries with filters and calendar.
/// On tablet (wide), uses two-pane: list | entry detail.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(journalFilterProvider);
    final entriesAsync = ref.watch(journalEntriesProvider);
    final selectedId = ref.watch(selectedJournalEntryIdProvider);
    final isWide = AppBreakpoints.isWide(context);

    Widget listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        JournalFiltersBar(
          currentFilter: filter,
          onFilterChanged: (f) {
            ref.read(journalFilterProvider.notifier).state = f;
          },
          onCalendarTap: () => context.push('/journal/calendar'),
        ),
        Expanded(
          child: entriesAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return EmptyState(
                  title: filter.visibility == JournalVisibility.private
                      ? 'No private entries'
                      : filter.visibility == JournalVisibility.shared
                          ? 'No shared entries'
                          : 'No journal entries yet',
                  subtitle: 'Tap + to add an entry.',
                  icon: Icons.book_rounded,
                  actionLabel: 'Add entry',
                  onAction: () => context.push('/journal/new'),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(journalEntriesProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final entry = entries[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: JournalEntryCard(
                        entry: entry,
                        onTap: () {
                          if (isWide) {
                            ref.read(selectedJournalEntryIdProvider.notifier).state = entry.id;
                          } else {
                            context.push('/journal/entry/${entry.id}');
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: const [
                SkeletonLoader(child: SkeletonCard(lineCount: 3)),
                SizedBox(height: AppSpacing.md),
                SkeletonLoader(child: SkeletonCard(lineCount: 3)),
                SizedBox(height: AppSpacing.md),
                SkeletonLoader(child: SkeletonCard(lineCount: 2)),
              ],
            ),
            error: (e, _) => ErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(journalEntriesProvider),
            ),
          ),
        ),
      ],
    );

    Widget detailPane = selectedId == null
        ? Center(
            child: Text(
              'Select an entry',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
            ),
          )
        : JournalEntryDetailContent(entryId: selectedId);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/journal/new'),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.welcomeGradientLight,
        ),
        child: isWide
            ? TwoPaneLayout(
                listPane: listContent,
                detailPane: detailPane,
              )
            : listContent,
      ),
    );
  }
}
