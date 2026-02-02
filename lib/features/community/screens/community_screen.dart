import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/community_models.dart';
import '../data/community_repository.dart';
import '../../../theme/app_tokens.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Community: list of forum rooms + saved threads entry.
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(forumRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_rounded),
            tooltip: 'Saved threads',
            onPressed: () => context.push('/community/saved'),
          ),
        ],
      ),
      body: roomsAsync.when(
        data: (rooms) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(forumRoomsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: rooms.length,
            itemBuilder: (context, i) {
              final room = rooms[i];
              return _RoomTile(
                room: room,
                onTap: () => context.push('/community/room/${room.id}'),
              );
            },
          ),
        ),
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const [
            SkeletonLoader(child: SkeletonCard(lineCount: 2)),
            SizedBox(height: AppSpacing.md),
            SkeletonLoader(child: SkeletonCard(lineCount: 2)),
          ],
        ),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(forumRoomsProvider),
        ),
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({required this.room, required this.onTap});

  final ForumRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        title: Text(room.title),
        subtitle: room.description != null
            ? Text(
                room.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant,
                    ),
                )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${room.threadCount}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
