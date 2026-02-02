import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/community_models.dart';
import '../data/community_repository.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Forum room: list of threads (anonymous), with reactions count.
class ForumRoomScreen extends ConsumerWidget {
  const ForumRoomScreen({super.key, required this.roomId, this.roomTitle});

  final String roomId;
  final String? roomTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final threadsAsync = ref.watch(forumThreadsProvider(roomId));

    return Scaffold(
      appBar: AppBar(
        title: Text(roomTitle ?? 'Room'),
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
        child: threadsAsync.when(
        data: (threads) {
          if (threads.isEmpty) {
            return EmptyState(
              title: 'No threads yet',
              subtitle: 'Be the first to start a conversation.',
              icon: Icons.forum_rounded,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: threads.length,
            itemBuilder: (context, i) {
              final t = threads[i];
              return _ThreadCard(
                thread: t,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/community/thread/${t.id}');
                },
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
          onRetry: () => ref.invalidate(forumThreadsProvider(roomId)),
        ),
        ),
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread, required this.onTap});

  final ForumThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark
        ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.8)
        : AppColors.onSurfaceVariant.withValues(alpha: 0.8);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (thread.isModerated)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: Icon(Icons.verified_rounded, size: 16, color: muted),
                    ),
                  Expanded(
                    child: Text(
                      thread.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              if (thread.body != null && thread.body!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  thread.body!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.favorite_border_rounded, size: 14, color: muted),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '${thread.reactionCount}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(Icons.chat_bubble_outline_rounded, size: 14, color: muted),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '${thread.replyCount}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat.MMMd().format(thread.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
