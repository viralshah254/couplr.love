import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'conflict_repair_models.dart';

/// AI integration hooks for conflict resolution.
/// In production, these call your backend; here we use mock responses.
abstract class ConflictResolutionAiService {
  /// Analyze private input — tone, emotional state, underlying needs.
  /// Never expose raw input or analysis to the other partner.
  Future<PrivateInputAnalysis> analyzePrivateInput(PrivateInput input);

  /// Generate shared session agenda from both partners' analyses (not raw input).
  Future<List<JointSessionStep>> generateJointAgenda(
    PrivateInputAnalysis analysisA,
    PrivateInputAnalysis analysisB,
  );

  /// Get a short coaching message for the current step (non-judgmental).
  Future<String?> getCoachingForStep(String sessionId, int stepIndex);

  /// Get reflection questions for follow-up / growth.
  Future<List<String>> getReflectionQuestions(String sessionId);

  /// Get insights on patterns and preventative strategies.
  Future<ConflictInsight?> getInsights(String sessionId);
}

class MockConflictResolutionAiService implements ConflictResolutionAiService {
  @override
  Future<PrivateInputAnalysis> analyzePrivateInput(PrivateInput input) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return PrivateInputAnalysis(
      tone: 'reflective',
      emotionalState: 'open',
      needs: ['to be heard', 'reassurance'],
    );
  }

  @override
  Future<List<JointSessionStep>> generateJointAgenda(
    PrivateInputAnalysis analysisA,
    PrivateInputAnalysis analysisB,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      JointSessionStep(
        id: '1',
        order: 0,
        title: 'Listen without interrupting',
        detail: 'Each person shares for 2 minutes. No rebuttals yet.',
        suggestedPhrasing: 'I hear you. Can you say more about...?',
        coachingMessage: 'Take a breath. Listening first builds safety.',
      ),
      JointSessionStep(
        id: '2',
        order: 1,
        title: 'Use "I feel" statements',
        detail: 'Focus on your experience, not blame.',
        suggestedPhrasing: 'I feel... when... I need...',
        coachingMessage: 'Stick to your own feelings — it helps both of you.',
      ),
      JointSessionStep(
        id: '3',
        order: 2,
        title: 'One ask each',
        detail: 'What would help you feel better?',
        suggestedPhrasing: 'It would help me if...',
        coachingMessage: 'Small, specific asks are easier to honor.',
      ),
      JointSessionStep(
        id: '4',
        order: 3,
        title: 'Acknowledge and close',
        detail: 'Summarize what you heard and one next step.',
        suggestedPhrasing: 'So what I heard is... Next time I will...',
        coachingMessage: 'Acknowledging each other closes the loop.',
      ),
    ];
  }

  @override
  Future<String?> getCoachingForStep(String sessionId, int stepIndex) async {
    await Future.delayed(const Duration(milliseconds: 200));
    const messages = [
      'Take your time. There’s no rush.',
      'It’s okay to pause if things feel intense.',
      'Acknowledging each other’s feelings goes a long way.',
    ];
    return messages[stepIndex % messages.length];
  }

  @override
  Future<List<String>> getReflectionQuestions(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      'What did you learn about your partner’s perspective?',
      'What’s one small thing you can do differently next time?',
      'What do you appreciate about how you handled this?',
    ];
  }

  @override
  Future<ConflictInsight?> getInsights(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ConflictInsight(
      patternDescription: 'Recurring topics around communication and time.',
      preventativeSuggestion: 'Try a weekly 10-minute check-in to surface small concerns early.',
      reflectionQuestions: [
        'When do we communicate best?',
        'What helps us feel safe to bring up hard topics?',
      ],
    );
  }
}

final conflictResolutionAiServiceProvider = Provider<ConflictResolutionAiService>((ref) {
  return MockConflictResolutionAiService();
});

abstract class ConflictRepairRepository {
  Future<ConflictRepairSession> getOrCreateSession(String id);
  Future<void> submitPrivateInput(String sessionId, String partnerId, String text);
  Future<void> submitFullPrivateInput(
    String sessionId,
    String partnerId, {
    List<String>? feelings,
    String? triggers,
    String? whatIWant,
    String? freeText,
  });
  Future<List<AgendaItem>> getAgendaAfterCooling(String sessionId);
  Future<List<JointSessionStep>> getJointSessionSteps(String sessionId);
  Future<void> completeStep(String sessionId, int stepIndex);
  Future<void> completeSession(String sessionId);
  Future<List<ResolutionRecord>> getResolutionHistory(String partnerId);
  Future<int> getResolutionStreak(String partnerId);
  Future<ConflictInsight?> getSessionInsights(String sessionId);
}

class MockConflictRepairRepository implements ConflictRepairRepository {
  final ConflictResolutionAiService _ai = MockConflictResolutionAiService();
  final Map<String, ConflictRepairSession> _sessions = {};
  final Map<String, List<PrivateInput>> _inputs = {};
  final Map<String, List<JointSessionStep>> _jointSteps = {};
  final List<ResolutionRecord> _resolutionHistory = [];
  final Map<String, List<PrivateInputAnalysis>> _analyses = {};

  @override
  Future<ConflictRepairSession> getOrCreateSession(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _sessions[id] ??= ConflictRepairSession(id: id);
    _inputs[id] ??= [];
    _jointSteps[id] ??= [];
    _analyses[id] ??= [];
    return _sessions[id]!;
  }

  @override
  Future<void> submitPrivateInput(String sessionId, String partnerId, String text) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _inputs[sessionId] ??= [];
    final idx = list.indexWhere((i) => i.partnerId == partnerId);
    final input = PrivateInput(
      partnerId: partnerId,
      text: text,
      submittedAt: DateTime.now(),
    );
    final analysis = await _ai.analyzePrivateInput(input);
    if (idx >= 0) {
      list[idx] = input;
      if (_analyses[sessionId]!.length > idx) {
        _analyses[sessionId]![idx] = analysis;
      } else {
        _analyses[sessionId]!.add(analysis);
      }
    } else {
      list.add(input);
      _analyses[sessionId]!.add(analysis);
    }
    _sessions[sessionId] = ConflictRepairSession(
      id: sessionId,
      privateInputs: List.from(list),
      agendaItems: _sessions[sessionId]!.agendaItems,
      jointSteps: _jointSteps[sessionId] ?? [],
      phase: ConflictRepairPhase.privateInput,
    );
  }

  @override
  Future<void> submitFullPrivateInput(
    String sessionId,
    String partnerId, {
    List<String>? feelings,
    String? triggers,
    String? whatIWant,
    String? freeText,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final list = _inputs[sessionId] ??= [];
    final idx = list.indexWhere((i) => i.partnerId == partnerId);
    final input = PrivateInput(
      partnerId: partnerId,
      feelings: feelings ?? [],
      triggers: triggers,
      whatIWant: whatIWant,
      freeText: freeText,
      submittedAt: DateTime.now(),
    );
    final analysis = await _ai.analyzePrivateInput(input);
    if (idx >= 0) {
      list[idx] = input;
      if (_analyses[sessionId]!.length > idx) {
        _analyses[sessionId]![idx] = analysis;
      } else {
        _analyses[sessionId]!.add(analysis);
      }
    } else {
      list.add(input);
      _analyses[sessionId] ??= [];
      _analyses[sessionId]!.add(analysis);
      // Demo: simulate partner submission so joint session can be tested with one user
      if (list.length == 1) {
        list.add(PrivateInput(
          partnerId: 'partner-2',
          feelings: const ['Calm'],
          submittedAt: DateTime.now(),
        ));
        _analyses[sessionId]!.add(const PrivateInputAnalysis(
          tone: 'neutral',
          emotionalState: 'open',
          needs: ['to be heard'],
        ));
      }
    }
    _sessions[sessionId] = ConflictRepairSession(
      id: sessionId,
      privateInputs: List.from(list),
      agendaItems: _sessions[sessionId]!.agendaItems,
      jointSteps: _jointSteps[sessionId] ?? [],
      phase: ConflictRepairPhase.privateInput,
    );
  }

  @override
  Future<List<AgendaItem>> getAgendaAfterCooling(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockAgenda();
  }

  List<AgendaItem> _mockAgenda() {
    return [
      const AgendaItem(id: '1', title: 'Listen without interrupting', detail: 'Each person gets 2 minutes.', order: 0),
      const AgendaItem(id: '2', title: 'Use "I feel" statements', detail: 'Avoid blame.', order: 1),
      const AgendaItem(id: '3', title: 'One ask each', detail: 'What would help you feel better?', order: 2),
      const AgendaItem(id: '4', title: 'Acknowledge and close', detail: 'Summarize and one next step.', order: 3),
    ];
  }

  @override
  Future<List<JointSessionStep>> getJointSessionSteps(String sessionId) async {
    final analyses = _analyses[sessionId] ?? [];
    if (analyses.length >= 2 && (_jointSteps[sessionId] ?? []).isEmpty) {
      final steps = await _ai.generateJointAgenda(analyses[0], analyses[1]);
      _jointSteps[sessionId] = steps;
      _sessions[sessionId] = ConflictRepairSession(
        id: sessionId,
        privateInputs: _sessions[sessionId]!.privateInputs,
        agendaItems: _sessions[sessionId]!.agendaItems,
        jointSteps: steps,
        phase: ConflictRepairPhase.jointSession,
      );
      return steps;
    }
    return _jointSteps[sessionId] ?? [];
  }

  @override
  Future<void> completeStep(String sessionId, int stepIndex) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final steps = _jointSteps[sessionId] ?? [];
    if (stepIndex < steps.length) {
      final updated = steps.map((s) {
        if (s.order == stepIndex) {
          return s.copyWith(completedAt: DateTime.now());
        }
        return s;
      }).toList();
      _jointSteps[sessionId] = updated;
      _sessions[sessionId] = ConflictRepairSession(
        id: sessionId,
        privateInputs: _sessions[sessionId]!.privateInputs,
        agendaItems: _sessions[sessionId]!.agendaItems,
        jointSteps: updated,
        currentStepIndex: stepIndex + 1,
        phase: stepIndex + 1 >= steps.length ? ConflictRepairPhase.completed : ConflictRepairPhase.jointSession,
      );
    }
  }

  @override
  Future<void> completeSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final steps = _jointSteps[sessionId] ?? [];
    _resolutionHistory.add(ResolutionRecord(
      sessionId: sessionId,
      completedAt: DateTime.now(),
      stepsCompleted: steps.length,
    ));
    _sessions[sessionId] = ConflictRepairSession(
      id: sessionId,
      privateInputs: _sessions[sessionId]!.privateInputs,
      agendaItems: _sessions[sessionId]!.agendaItems,
      jointSteps: steps,
      phase: ConflictRepairPhase.completed,
      completedAt: DateTime.now(),
    );
  }

  @override
  Future<List<ResolutionRecord>> getResolutionHistory(String partnerId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_resolutionHistory)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  @override
  Future<int> getResolutionStreak(String partnerId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_resolutionHistory.isEmpty) return 0;
    int streak = 0;
    final now = DateTime.now();
    for (final r in _resolutionHistory.reversed) {
      final days = now.difference(r.completedAt).inDays;
      if (days <= 7) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Future<ConflictInsight?> getSessionInsights(String sessionId) async {
    return _ai.getInsights(sessionId);
  }
}

final conflictRepairRepositoryProvider = Provider<ConflictRepairRepository>((ref) {
  return MockConflictRepairRepository();
});

final conflictRepairSessionProvider =
    FutureProvider.family<ConflictRepairSession, String>((ref, id) async {
  final repo = ref.watch(conflictRepairRepositoryProvider);
  return repo.getOrCreateSession(id);
});

final conflictResolutionHistoryProvider =
    FutureProvider.family<List<ResolutionRecord>, String>((ref, partnerId) async {
  final repo = ref.watch(conflictRepairRepositoryProvider);
  return repo.getResolutionHistory(partnerId);
});

final conflictResolutionStreakProvider =
    FutureProvider.family<int, String>((ref, partnerId) async {
  final repo = ref.watch(conflictRepairRepositoryProvider);
  return repo.getResolutionStreak(partnerId);
});
