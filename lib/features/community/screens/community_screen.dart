import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/community_models.dart';
import '../data/community_repository.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Community: list of forum rooms + saved threads entry.
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.welcomeGradientLight,
        ),
        child: roomsAsync.when(
          data: (rooms) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(forumRoomsProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tips, support, and shared wins',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Anonymous — say what you need.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final room = rooms[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _RoomTile(
                            room: room,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push('/community/room/${room.id}');
                            },
                          ),
                        );
                      },
                      childCount: rooms.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
              ],
            ),
          ),
          loading: () => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: const [
              SkeletonLoader(child: SkeletonCard(lineCount: 2)),
              SizedBox(height: AppSpacing.md),
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
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({required this.room, required this.onTap});

  final ForumRoom room;
  final VoidCallback onTap;

  Color _accentForRoom(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (room.id) {
      case '1':
        return isDark ? AppColors.primaryDarkMode : AppColors.primary;
      case '2':
        return isDark ? AppColors.secondaryDark : AppColors.secondary;
      case '3':
        return isDark ? AppColors.accentDarkMode : AppColors.accent;
      default:
        return isDark ? AppColors.primaryDarkMode : AppColors.primary;
    }
  }

  IconData _iconForRoom() {
    switch (room.id) {
      case '1':
        return Icons.chat_bubble_outline_rounded;
      case '2':
        return Icons.handshake_rounded;
      case '3':
        return Icons.celebration_rounded;
      default:
        return Icons.forum_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = _accentForRoom(context);
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Card(
      elevation: AppElevation.sm,
      shadowColor: (isDark ? AppColors.onSurfaceDark : AppColors.onSurface)
          .withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(
          color: accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(_iconForRoom(), color: accent, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      room.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                      ),
                    ),
                    if (room.description != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        room.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${room.threadCount}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right_rounded, color: muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
