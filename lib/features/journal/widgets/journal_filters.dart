import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/journal_models.dart';
import '../../../theme/app_tokens.dart';

/// Journal filters: visibility (all / shared / private) and optional date chip.
class JournalFiltersBar extends StatelessWidget {
  const JournalFiltersBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    this.onCalendarTap,
  });

  final JournalFilter currentFilter;
  final void Function(JournalFilter) onFilterChanged;
  final VoidCallback? onCalendarTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          SegmentedButton<JournalVisibility>(
            segments: const [
              ButtonSegment(value: JournalVisibility.all, label: Text('All')),
              ButtonSegment(value: JournalVisibility.shared, label: Text('Shared')),
              ButtonSegment(value: JournalVisibility.private, label: Text('Private')),
            ],
            selected: {currentFilter.visibility},
            onSelectionChanged: (s) {
              HapticFeedback.selectionClick();
              onFilterChanged(currentFilter.copyWith(visibility: s.first));
            },
          ),
          const SizedBox(width: AppSpacing.md),
          if (onCalendarTap != null)
            IconButton.filled(
              onPressed: () {
                HapticFeedback.lightImpact();
                onCalendarTap!();
              },
              icon: const Icon(Icons.calendar_month_rounded),
              tooltip: 'Calendar',
            ),
        ],
      ),
    );
  }
}
