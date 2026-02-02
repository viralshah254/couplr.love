import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/experts_repository.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';

/// Live room: Coming soon — placeholder for live session with expert.
class LiveRoomScreen extends ConsumerWidget {
  const LiveRoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final roomAsync = ref.watch(liveRoomProvider(roomId));
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live room'),
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
        child: roomAsync.when(
          data: (room) {
            if (room == null) {
              return const Center(child: Text('Room not found'));
            }
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
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Text(
                        'Coming soon',
                        style: theme.textTheme.labelLarge?.copyWith(color: accent, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      room.isLive
                          ? 'Live sessions with experts will be available here.'
                          : 'Join when the session starts.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                      textAlign: TextAlign.center,
                    ),
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
      ),
    );
  }
}
