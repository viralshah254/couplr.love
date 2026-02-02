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
import '../../../shared/widgets/skeleton_loader.dart';

/// Thread detail: OP + replies, reactions, report, save.
class ThreadDetailScreen extends ConsumerWidget {
  const ThreadDetailScreen({super.key, required this.threadId});

  final String threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final threadAsync = ref.watch(forumThreadDetailProvider(threadId));
    final postsAsync = ref.watch(forumPostsProvider(threadId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Report',
            onPressed: () => _showReportDialog(context, ref),
          ),
          threadAsync.when(
            data: (thread) => IconButton(
              icon: Icon(thread != null && thread.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
              tooltip: thread != null && thread.isSaved ? 'Unsave' : 'Save',
              onPressed: thread == null
                  ? null
                  : () async {
                      await ref.read(communityRepositoryProvider).saveThread(threadId, !thread.isSaved);
                      ref.invalidate(forumThreadDetailProvider(threadId));
                      ref.invalidate(savedThreadsProvider);
                    },
            ),
            loading: () => IconButton(icon: const Icon(Icons.bookmark_border_rounded), onPressed: () {}),
            error: (_, __) => IconButton(icon: const Icon(Icons.bookmark_border_rounded), onPressed: () {}),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.welcomeGradientLight),
        child: threadAsync.when(
        data: (thread) {
          if (thread == null) {
            return const Center(child: Text('Thread not found'));
          }
          return postsAsync.when(
            data: (posts) => SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostCard(
                    title: thread.title,
                    body: thread.body,
                    createdAt: thread.createdAt,
                    reactionCount: thread.reactionCount,
                    onReact: () {
                      HapticFeedback.lightImpact();
                      ref.read(communityRepositoryProvider).react(threadId, ReactionType.like, true);
                      ref.invalidate(forumThreadDetailProvider(threadId));
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Replies (${posts.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...posts.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _PostCard(
                        body: p.body,
                        createdAt: p.createdAt,
                        reactionCount: p.reactionCount,
                        onReact: () {
                          HapticFeedback.lightImpact();
                          ref.read(communityRepositoryProvider).react(p.id, ReactionType.like, false);
                          ref.invalidate(forumPostsProvider(threadId));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorState(message: e.toString()),
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: const [SkeletonLoader(child: SkeletonCard(lineCount: 3))],
        ),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(forumThreadDetailProvider(threadId)),
        ),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report thread'),
        content: const Text(
          'Report this thread for moderation? Your report is anonymous.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(communityRepositoryProvider).reportThread(threadId, 'report');
              Navigator.of(ctx).pop();
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    this.title,
    this.body,
    required this.createdAt,
    this.reactionCount = 0,
    required this.onReact,
  });

  final String? title;
  final String? body;
  final DateTime createdAt;
  final int reactionCount;
  final VoidCallback onReact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark
        ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.8)
        : AppColors.onSurfaceVariant.withValues(alpha: 0.8);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            if (body != null && body!.isNotEmpty)
              Text(
                body!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onReact,
                  icon: const Icon(Icons.favorite_border_rounded, size: 18),
                  label: Text('$reactionCount'),
                ),
                const Spacer(),
                Text(
                  DateFormat.MMMd().add_jm().format(createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
