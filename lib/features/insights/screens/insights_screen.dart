import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/insights_repository.dart';
import '../widgets/bar_chart_section.dart';
import '../widgets/mood_line_chart.dart';
import '../../../theme/app_tokens.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Insights: charts for mood, conflicts, appreciation, engagement.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodAsync = ref.watch(moodHistoryProvider);
    final conflictsAsync = ref.watch(conflictsByWeekProvider);
    final appreciationAsync = ref.watch(appreciationByWeekProvider);
    final engagementAsync = ref.watch(engagementByWeekProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(moodHistoryProvider);
          ref.invalidate(conflictsByWeekProvider);
          ref.invalidate(appreciationByWeekProvider);
          ref.invalidate(engagementByWeekProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Section(
                title: 'Mood',
                subtitle: 'How you\'ve been feeling (1–5)',
                child: moodAsync.when(
                  data: (points) => MoodLineChart(points: points),
                  loading: () => const SizedBox(
                    height: 220,
                    child: Center(
                      child: SkeletonLoader(
                        child: SkeletonCard(lineCount: 4),
                      ),
                    ),
                  ),
                  error: (e, _) => ErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(moodHistoryProvider),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Section(
                title: 'Conflicts',
                subtitle: 'Conflict repair sessions per week',
                child: conflictsAsync.when(
                  data: (points) => BarChartSection(
                    points: points,
                    title: 'Sessions per week',
                  ),
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(
                      child: SkeletonLoader(
                        child: SkeletonCard(lineCount: 3),
                      ),
                    ),
                  ),
                  error: (e, _) => ErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(conflictsByWeekProvider),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Section(
                title: 'Appreciation',
                subtitle: 'Gratitude entries per week',
                child: appreciationAsync.when(
                  data: (points) => BarChartSection(
                    points: points,
                    title: 'Entries per week',
                  ),
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(
                      child: SkeletonLoader(
                        child: SkeletonCard(lineCount: 3),
                      ),
                    ),
                  ),
                  error: (e, _) => ErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(appreciationByWeekProvider),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Section(
                title: 'Engagement',
                subtitle: 'Activities & sessions per week',
                child: engagementAsync.when(
                  data: (points) => BarChartSection(
                    points: points,
                    title: 'Activities per week',
                  ),
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(
                      child: SkeletonLoader(
                        child: SkeletonCard(lineCount: 3),
                      ),
                    ),
                  ),
                  error: (e, _) => ErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(engagementByWeekProvider),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
