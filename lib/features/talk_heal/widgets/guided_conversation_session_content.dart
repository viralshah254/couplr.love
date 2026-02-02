import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/conversation_repository.dart';
import 'guided_conversation_card.dart';
import '../../../theme/app_tokens.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Reusable session body (for full screen or two-pane detail).
class GuidedConversationSessionContent extends ConsumerWidget {
  const GuidedConversationSessionContent({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(conversationDetailProvider(sessionId));
    final repo = ref.read(conversationRepositoryProvider);

    return sessionAsync.when(
      data: (conversation) {
        if (conversation == null) {
          return const Center(child: Text('Not found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: conversation.steps.length,
          itemBuilder: (context, i) {
            final step = conversation.steps[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: GuidedConversationCard(
                step: step,
                isActive: i == 0,
                onRewrite: (raw) => repo.requestRewrite(step.id, raw),
                onVoiceNote: () {},
              ),
            );
          },
        );
      },
      loading: () => ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          SkeletonLoader(child: SkeletonCard(lineCount: 3)),
        ],
      ),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(conversationDetailProvider(sessionId)),
      ),
    );
  }
}
