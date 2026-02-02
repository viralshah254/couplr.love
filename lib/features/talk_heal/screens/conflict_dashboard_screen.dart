import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/conflict_repair_models.dart';
import '../data/conflict_repair_repository.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

const _partnerId = 'user-1';

/// Private conflict dashboard: resolutions, streak, badges, follow-up suggestions.
class ConflictDashboardScreen extends ConsumerWidget {
  const ConflictDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(conflictResolutionHistoryProvider(_partnerId));
    final streakAsync = ref.watch(conflictResolutionStreakProvider(_partnerId));

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.welcomeGradientLight,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                'Conflict dashboard',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your resolutions, streak, and follow-up suggestions.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              streakAsync.when(
                data: (streak) => _StreakCard(streak: streak),
                loading: () => const SkeletonLoader(
                  child: SkeletonCard(titleHeight: 48, subtitleHeight: 20, lineCount: 1),
                ),
                error: (e, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.lg),
              historyAsync.when(
                data: (history) => _HistorySection(history: history),
                loading: () => const SkeletonLoader(
                  child: SkeletonCard(lineCount: 3),
                ),
                error: (e, _) => ErrorState(
                  message: e.toString(),
                  onRetry: () =>
                      ref.invalidate(conflictResolutionHistoryProvider(_partnerId)),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Conflict dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDarkMode : AppColors.accent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(Icons.local_fire_department_rounded, size: 32, color: accent),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streak',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: accent,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                  ),
                  Text(
                    streak == 1
                        ? 'Resolution this week'
                        : 'Resolutions this week',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.history});

  final List<ResolutionRecord> history;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent resolutions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (history.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'No resolutions yet. Complete a joint session to see them here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: muted,
                    ),
              ),
            ),
          )
        else
          ...history.take(10).map(
                (r) => Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle_rounded,
                      color: isDark
                          ? AppColors.primaryDarkMode
                          : AppColors.primary,
                    ),
                    title: Text(
                      '${r.stepsCompleted} steps completed',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      _formatDate(r.completedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${d.month}/${d.day}/${d.year}';
  }
}
