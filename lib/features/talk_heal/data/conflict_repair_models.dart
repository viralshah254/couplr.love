/// Private input from one partner (never shown to the other).
/// AI analyzes for tone, emotional state, and needs — analysis only is used for agenda.
class PrivateInput {
  const PrivateInput({
    required this.partnerId,
    this.text,
    this.feelings = const [],
    this.triggers,
    this.whatIWant,
    this.freeText,
    this.submittedAt,
    this.aiAnalysis,
  });

  final String partnerId;
  /// Legacy / short input.
  final String? text;
  /// Feelings selected (e.g. frustrated, hurt, anxious).
  final List<String> feelings;
  /// What triggered the conflict.
  final String? triggers;
  /// What I want from this conversation.
  final String? whatIWant;
  /// Optional free-form thoughts.
  final String? freeText;
  final DateTime? submittedAt;
  /// AI analysis (tone, emotional state, needs) — never exposed to partner.
  final PrivateInputAnalysis? aiAnalysis;
}

/// AI analysis of private input — used only to build joint agenda; never shared.
class PrivateInputAnalysis {
  const PrivateInputAnalysis({
    this.tone,
    this.emotionalState,
    this.needs = const [],
  });

  final String? tone;
  final String? emotionalState;
  final List<String> needs;
}

/// One agenda item from AI synthesis of both private inputs.
class AgendaItem {
  const AgendaItem({
    required this.id,
    required this.title,
    this.detail,
    this.suggestedPhrasing,
    this.order = 0,
  });

  final String id;
  final String title;
  final String? detail;
  /// Example phrasing for this step (e.g. "I feel... when...").
  final String? suggestedPhrasing;
  final int order;
}

/// One step in the joint session — with coaching and completion state.
class JointSessionStep {
  const JointSessionStep({
    required this.id,
    required this.title,
    this.detail,
    this.suggestedPhrasing,
    this.coachingMessage,
    this.order = 0,
    this.completedAt,
  });

  final String id;
  final String title;
  final String? detail;
  final String? suggestedPhrasing;
  final String? coachingMessage;
  final int order;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  JointSessionStep copyWith({
    DateTime? completedAt,
  }) {
    return JointSessionStep(
      id: id,
      title: title,
      detail: detail,
      suggestedPhrasing: suggestedPhrasing,
      coachingMessage: coachingMessage,
      order: order,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Cooling phase: countdown before viewing shared agenda.
class CoolingState {
  const CoolingState({
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  final int secondsRemaining;
  final int totalSeconds;
  bool get isActive => secondsRemaining > 0;
}

/// Conflict repair session state.
class ConflictRepairSession {
  const ConflictRepairSession({
    required this.id,
    this.privateInputs = const [],
    this.agendaItems = const [],
    this.jointSteps = const [],
    this.currentStepIndex = 0,
    this.cooling,
    this.phase = ConflictRepairPhase.privateInput,
    this.completedAt,
  });

  final String id;
  final List<PrivateInput> privateInputs;
  final List<AgendaItem> agendaItems;
  /// Resolved steps for joint session (with completion).
  final List<JointSessionStep> jointSteps;
  final int currentStepIndex;
  final CoolingState? cooling;
  final ConflictRepairPhase phase;
  final DateTime? completedAt;

  bool get bothPartnersSubmitted =>
      privateInputs.length >= 2 || privateInputs.any((i) => i.submittedAt != null);
  bool get isJointSessionReady =>
      phase == ConflictRepairPhase.sharedAgenda || jointSteps.isNotEmpty;
}

enum ConflictRepairPhase {
  privateInput,
  cooling,
  sharedAgenda,
  jointSession,
  completed,
}

/// Record of a completed resolution for dashboard.
class ResolutionRecord {
  const ResolutionRecord({
    required this.sessionId,
    required this.completedAt,
    this.stepsCompleted = 0,
    this.followUpSuggestedAt,
  });

  final String sessionId;
  final DateTime completedAt;
  final int stepsCompleted;
  final DateTime? followUpSuggestedAt;
}

/// Conflict insight (patterns, suggestions) — for dashboard / follow-up.
class ConflictInsight {
  const ConflictInsight({
    this.patternDescription,
    this.preventativeSuggestion,
    this.reflectionQuestions = const [],
  });

  final String? patternDescription;
  final String? preventativeSuggestion;
  final List<String> reflectionQuestions;
}

/// Predefined feeling tags for private input.
const List<String> kConflictFeelingTags = [
  'Frustrated',
  'Hurt',
  'Anxious',
  'Unheard',
  'Angry',
  'Sad',
  'Overwhelmed',
  'Disappointed',
  'Worried',
  'Calm',
];
