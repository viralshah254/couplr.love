import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'conversation_models.dart';

abstract class ConversationRepository {
  Future<List<GuidedConversation>> getConversations();
  Future<GuidedConversation?> getConversation(String id);
  Future<String?> requestRewrite(String stepId, String rawText);
  Future<void> saveVoiceNote(String stepId, String url);
}

class MockConversationRepository implements ConversationRepository {
  @override
  Future<List<GuidedConversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      GuidedConversation(
        id: '1',
        title: 'Weekly check-in',
        durationMinutes: 10,
        steps: [
          ConversationStep(
            id: '1a',
            order: 0,
            prompt: 'What\'s one thing you appreciated about your partner this week?',
            timerSeconds: 120,
          ),
          ConversationStep(
            id: '1b',
            order: 1,
            prompt: 'Share one hope for the week ahead.',
            timerSeconds: 120,
          ),
        ],
      ),
      GuidedConversation(
        id: '2',
        title: 'Conflict repair',
        durationMinutes: 15,
        steps: [
          ConversationStep(
            id: '2a',
            order: 0,
            prompt: 'Each share your perspective in one sentence. Use "I feel..."',
            timerSeconds: 90,
          ),
        ],
      ),
    ];
  }

  @override
  Future<GuidedConversation?> getConversation(String id) async {
    final list = await getConversations();
    try {
      return list.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> requestRewrite(String stepId, String rawText) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return 'I feel hurt when we don\'t get to talk before bed. I\'d love to find a time that works for both of us.';
  }

  @override
  Future<void> saveVoiceNote(String stepId, String url) async {}
}

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return MockConversationRepository();
});

/// Selected session id for two-pane layout (tablet).
final selectedConversationSessionIdProvider = StateProvider<String?>((ref) => null);

final conversationsListProvider = FutureProvider<List<GuidedConversation>>((ref) {
  return ref.watch(conversationRepositoryProvider).getConversations();
});

final conversationDetailProvider =
    FutureProvider.family<GuidedConversation?, String>((ref, id) {
  return ref.watch(conversationRepositoryProvider).getConversation(id);
});
