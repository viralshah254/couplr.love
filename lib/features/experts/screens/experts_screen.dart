import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/experts_models.dart';
import '../data/experts_repository.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Experts: list of experts + entry to Ask-an-Expert and live rooms.
class ExpertsScreen extends ConsumerWidget {
  const ExpertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expertsAsync = ref.watch(expertsListProvider);
    final roomsAsync = ref.watch(liveRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Experts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'My questions',
            onPressed: () => context.push('/experts/questions'),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.welcomeGradientLight),
        child: expertsAsync.when(
        data: (experts) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.push('/experts/ask'),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Ask an Expert'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Live rooms',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              roomsAsync.when(
                data: (rooms) {
                  if (rooms.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        'No live rooms right now.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.onSurfaceVariantDark
                                  : AppColors.onSurfaceVariant,
                            ),
                      ),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: rooms
                        .map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _LiveRoomCard(
                              room: r,
                              onTap: () => context.push('/experts/live/${r.id}'),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const SkeletonLoader(child: SkeletonCard(lineCount: 2)),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Experts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...experts.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ExpertCard(
                    expert: e,
                    onTap: () => context.push('/experts/ask?expert=${e.id}'),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: const [
            SkeletonLoader(child: SkeletonCard(lineCount: 2)),
            SizedBox(height: AppSpacing.md),
            SkeletonLoader(child: SkeletonCard(lineCount: 2)),
          ],
        ),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(expertsListProvider),
        ),
        ),
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  const _ExpertCard({required this.expert, required this.onTap});

  final Expert expert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.2),
          child: Text(
            expert.displayName.isNotEmpty ? expert.displayName[0].toUpperCase() : '?',
            style: TextStyle(color: accent, fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(expert.displayName),
        subtitle: expert.specialty != null
            ? Text(
                expert.specialty!,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _LiveRoomCard extends StatelessWidget {
  const _LiveRoomCard({required this.room, required this.onTap});

  final LiveRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final liveColor = room.isLive ? (isDark ? AppColors.secondaryDark : AppColors.secondary) : null;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Icon(
          room.isLive ? Icons.live_tv_rounded : Icons.schedule_rounded,
          color: liveColor,
        ),
        title: Text(room.title),
        subtitle: room.scheduledAt != null
            ? Text(
                room.scheduledAt!.toIso8601String().substring(0, 16).replaceFirst('T', ' '),
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: room.isLive
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: liveColor?.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: liveColor)),
              )
            : const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
