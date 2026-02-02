import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/grow_repository.dart';
import '../widgets/habit_challenge_card.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Habit challenges list with streaks and complete action.
class HabitChallengesScreen extends ConsumerWidget {
  const HabitChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final challengesAsync = ref.watch(habitChallengesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit challenges'),
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
        child: challengesAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              title: 'No challenges yet',
              subtitle: 'Add a habit to track together.',
              icon: Icons.trending_up_rounded,
              actionLabel: 'Add challenge',
              onAction: () {},
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(habitChallengesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final c = list[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: HabitChallengeCard(
                    challenge: c,
                    onComplete: () async {
                      await ref.read(growRepositoryProvider).completeHabit(c.id);
                      ref.invalidate(habitChallengesProvider);
                      ref.invalidate(growOverviewProvider);
                    },
                    onTap: () {},
                  ),
                );
              },
            ),
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: const [
            SkeletonLoader(child: SkeletonCard(lineCount: 3)),
            SizedBox(height: AppSpacing.md),
            SkeletonLoader(child: SkeletonCard(lineCount: 3)),
          ],
        ),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(habitChallengesProvider),
        ),
        ),
      ),
    );
  }
}
