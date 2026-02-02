import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/conversation_models.dart';
import '../data/conversation_repository.dart';
import '../widgets/guided_conversation_session_content.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/animated_list_tile.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/two_pane_layout.dart';

/// Guided conversation: list of sessions or one session with steps (cards + timer + voice + AI rewrite).
/// On tablet (wide), uses two-pane: list | session detail.
/// Welcoming design: gradient, hopeful copy, card-style items.
class GuidedConversationScreen extends ConsumerWidget {
  const GuidedConversationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(conversationsListProvider);
    final selectedId = ref.watch(selectedConversationSessionIdProvider);
    final isWide = AppBreakpoints.isWide(context);
    final theme = Theme.of(context);

    Widget listContent = listAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'No conversations yet. When you\'re ready, start with a small step.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Small steps together. Gentle conversations for you and your partner.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...List.generate(list.length, (i) {
              final c = list[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AnimatedListTile(
                  index: i,
                  child: _TalkHealCard(
                    conversation: c,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (isWide) {
                        ref.read(selectedConversationSessionIdProvider.notifier).state = c.id;
                      } else {
                        context.push('/talk/session/${c.id}');
                      }
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'Every conversation counts.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.brightness == Brightness.dark
                      ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.8)
                      : AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          SkeletonLoader(child: SkeletonCard()),
          SizedBox(height: AppSpacing.md),
          SkeletonLoader(child: SkeletonCard()),
        ],
      ),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(conversationsListProvider),
      ),
    );

    Widget detailPane = selectedId == null
        ? Center(
            child: Text(
              'Select a conversation',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
            ),
          )
        : GuidedConversationSessionContent(sessionId: selectedId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk & Heal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.welcomeGradientLight,
        ),
        child: isWide
            ? TwoPaneLayout(
                listPane: listContent,
                detailPane: detailPane,
              )
            : listContent,
      ),
    );
  }
}

/// Card-style list item for a Talk & Heal conversation — warm, welcoming, easy to tap.
class _TalkHealCard extends StatelessWidget {
  const _TalkHealCard({
    required this.conversation,
    required this.onTap,
  });

  final GuidedConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final sage = isDark ? AppColors.secondaryDark : AppColors.secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.onSurfaceDark : AppColors.onSurface)
                    .withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  conversation.id == '2' ? Icons.healing_rounded : Icons.chat_bubble_outline_rounded,
                  color: primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      conversation.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${conversation.steps.length} steps · ${conversation.durationMinutes ?? 0} min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: sage),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single conversation session: steps as guided cards with timer, voice, AI rewrite.
class GuidedConversationSessionScreen extends ConsumerWidget {
  const GuidedConversationSessionScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guided conversation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: GuidedConversationSessionContent(sessionId: sessionId),
    );
  }
}
