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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primary;
                }
                return surface;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.onPrimary;
                }
                return muted;
              }),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (onCalendarTap != null)
            Material(
              color: primary,
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onCalendarTap!();
                },
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(Icons.calendar_month_rounded, color: AppColors.onPrimary, size: 22),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
