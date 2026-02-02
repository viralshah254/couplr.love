import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/grow_repository.dart';
import '../widgets/badge_chip.dart';
import '../widgets/habit_challenge_card.dart';
import '../widgets/ritual_card.dart';
import '../widgets/date_plan_card.dart';
import '../../../theme/app_tokens.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Grow overview: challenges, badges, rituals, date planner entry.
class GrowScreen extends ConsumerWidget {
  const GrowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(growOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grow'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: overviewAsync.when(
        data: (overview) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(growOverviewProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Habit challenges',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (overview.challenges.isEmpty)
                  _EmptySection(
                    message: 'No challenges yet.',
                    actionLabel: 'Add challenge',
                    onAction: () => context.push('/grow/challenges'),
                  )
                else
                  ...overview.challenges.take(2).map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: HabitChallengeCard(
                            challenge: c,
                            onComplete: () async {
                              await ref.read(growRepositoryProvider).completeHabit(c.id);
                              ref.invalidate(growOverviewProvider);
                            },
                            onTap: () => context.push('/grow/challenges'),
                          ),
                        ),
                      ),
                if (overview.challenges.length > 2)
                  TextButton(
                    onPressed: () => context.push('/grow/challenges'),
                    child: const Text('See all challenges'),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Badges',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (overview.badges.isEmpty)
                  _EmptySection(
                    message: 'Earn badges by completing challenges.',
                    onAction: null,
                  )
                else
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: overview.badges.take(6).map((b) => BadgeChip(badge: b, compact: true)).toList(),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rituals',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.push('/grow/rituals'),
                      child: const Text('Schedule'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (overview.rituals.isEmpty)
                  _EmptySection(
                    message: 'No rituals scheduled.',
                    actionLabel: 'Add ritual',
                    onAction: () => context.push('/grow/rituals'),
                  )
                else
                  ...overview.rituals.take(2).map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: RitualCard(
                            ritual: r,
                            onComplete: () async {
                              await ref.read(growRepositoryProvider).completeRitual(r.id);
                              ref.invalidate(growOverviewProvider);
                            },
                            onTap: () => context.push('/grow/rituals'),
                          ),
                        ),
                      ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date planner',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.push('/grow/dates'),
                      child: const Text('Plan date'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (overview.upcomingDates.isEmpty)
                  _EmptySection(
                    message: 'No dates planned.',
                    actionLabel: 'Plan a date',
                    onAction: () => context.push('/grow/dates'),
                  )
                else
                  ...overview.upcomingDates.take(2).map(
                        (d) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: DatePlanCard(
                            plan: d,
                            onTap: () => context.push('/grow/dates'),
                          ),
                        ),
                      ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const [
            SkeletonLoader(child: SkeletonCard(lineCount: 2)),
            SizedBox(height: AppSpacing.md),
            SkeletonLoader(child: SkeletonCard(lineCount: 2)),
            SizedBox(height: AppSpacing.md),
            SkeletonLoader(child: SkeletonCard(lineCount: 1)),
          ],
        ),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(growOverviewProvider),
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
