import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:couplr/theme/app_tokens.dart';

import '../data/community_repository.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Saved threads list.
class SavedThreadsScreen extends ConsumerWidget {
  const SavedThreadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedThreadsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved threads'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: savedAsync.when(
        data: (threads) {
          if (threads.isEmpty) {
            return EmptyState(
              title: 'No saved threads',
              subtitle: 'Save threads from the community to find them here.',
              icon: Icons.bookmark_border_rounded,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: threads.length,
            itemBuilder: (context, i) {
              final t = threads[i];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ListTile(
                  title: Text(t.title),
                  subtitle: t.body != null ? Text(t.body!, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/community/thread/${t.id}'),
                ),
              );
            },
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const [
            SkeletonLoader(child: SkeletonCard(lineCount: 2)),
          ],
        ),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(savedThreadsProvider),
        ),
      ),
    );
  }
}
