/// A guided conversation session: list of steps/prompts with optional timer per turn.
class GuidedConversation {
  const GuidedConversation({
    required this.id,
    required this.title,
    required this.steps,
    this.durationMinutes,
  });

  final String id;
  final String title;
  final List<ConversationStep> steps;
  final int? durationMinutes;
}

/// One step in a guided conversation: prompt, optional timer, voice note, AI rewrite.
class ConversationStep {
  const ConversationStep({
    required this.id,
    required this.prompt,
    this.timerSeconds,
    this.order = 0,
    this.voiceNoteUrl,
    this.rewrittenText,
  });

  final String id;
  final String prompt;
  final int? timerSeconds;
  final int order;
  final String? voiceNoteUrl;
  final String? rewrittenText;
}
