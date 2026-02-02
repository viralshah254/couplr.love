import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/experts_repository.dart';
import '../../../theme/app_tokens.dart';
import '../../../shared/widgets/error_state.dart';

/// Live room: placeholder for live session with expert.
class LiveRoomScreen extends ConsumerWidget {
  const LiveRoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(liveRoomProvider(roomId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live room'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: roomAsync.when(
        data: (room) {
          if (room == null) {
            return const Center(child: Text('Room not found'));
          }
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    room.isLive ? Icons.live_tv_rounded : Icons.schedule_rounded,
                    size: 64,
                    color: accent,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    room.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  if (room.isLive) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Live session — join when ready',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(liveRoomProvider(roomId)),
        ),
      ),
    );
  }
}
