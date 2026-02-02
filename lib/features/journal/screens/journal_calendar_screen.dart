import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/journal_models.dart';
import '../data/journal_repository.dart';
import '../widgets/journal_entry_card.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Journal calendar: pick a date, see entries for that day.
class JournalCalendarScreen extends ConsumerStatefulWidget {
  const JournalCalendarScreen({super.key});

  @override
  ConsumerState<JournalCalendarScreen> createState() => _JournalCalendarScreenState();
}

class _JournalCalendarScreenState extends ConsumerState<JournalCalendarScreen> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final datesAsync = ref.watch(journalDatesWithEntriesProvider);
    final entriesAsync = _selectedDate == null
        ? const AsyncValue<List<JournalEntry>>.data([])
        : ref.watch(journalEntriesForDateProvider(_selectedDate!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal calendar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.welcomeGradientLight),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: datesAsync.when(
              data: (dates) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      ...dates.take(14).map((d) {
                        final isSelected = _selectedDate != null &&
                            _selectedDate!.year == d.year &&
                            _selectedDate!.month == d.month &&
                            _selectedDate!.day == d.day;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: FilterChip(
                            label: Text(
                              '${d.month}/${d.day}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : null,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedDate = selected ? d : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: SkeletonBox(width: double.infinity, height: 40),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  e.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _selectedDate == null
                ? Center(
                    child: Text(
                      'Tap a date to see entries',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariant,
                          ),
                    ),
                  )
                : entriesAsync.when(
                    data: (entries) {
                      if (entries.isEmpty) {
                        return EmptyState(
                          title: 'No entries on this day',
                          subtitle: 'Try another date.',
                          icon: Icons.calendar_today_rounded,
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: entries.length,
                        itemBuilder: (context, i) {
                          final entry = entries[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: JournalEntryCard(
                              entry: entry,
                              onTap: () => context.push('/journal/entry/${entry.id}'),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: const [
                        SkeletonLoader(child: SkeletonCard(lineCount: 2)),
                      ],
                    ),
                    error: (e, _) => ErrorState(
                      message: e.toString(),
                      onRetry: () {
                        if (_selectedDate != null) {
                          ref.invalidate(journalEntriesForDateProvider(_selectedDate!));
                        }
                      },
                    ),
                  ),
          ),
        ],
        ),
      ),
    );
  }
}
