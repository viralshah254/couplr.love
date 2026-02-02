import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_bank_models.dart';

/// Data bank: things to do individually and as couples.
abstract class TaskBankRepository {
  Future<List<TaskSuggestion>> getIndividualSuggestions();
  Future<List<TaskSuggestion>> getCoupleSuggestions();
  Future<UndoneCounts> getUndoneCounts();
  Future<List<TaskSuggestion>> getCoupleTasksForHome(int limit);
  Future<void> markTaskCompleted(String taskId);
}

class MockTaskBankRepository implements TaskBankRepository {
  final List<String> _completedTaskIds = [];
  static const List<TaskSuggestion> _individual = [
    TaskSuggestion(
      id: 'ind-1',
      title: '5 min breathing',
      subtitle: 'Calm your nervous system',
      type: TaskType.individual,
      category: 'Self-care',
      durationMinutes: 5,
      actionRoute: '/talk',
      iconId: 'breath',
    ),
    TaskSuggestion(
      id: 'ind-2',
      title: 'Journal prompt',
      subtitle: 'One thing you felt today',
      type: TaskType.individual,
      category: 'Reflection',
      durationMinutes: 3,
      actionRoute: '/journal/new',
      iconId: 'journal',
    ),
    TaskSuggestion(
      id: 'ind-3',
      title: 'Gratitude note',
      subtitle: 'Write one thing you\'re grateful for',
      type: TaskType.individual,
      category: 'Gratitude',
      durationMinutes: 2,
      actionRoute: '/journal/new',
      iconId: 'gratitude',
    ),
    TaskSuggestion(
      id: 'ind-4',
      title: 'Self-check-in',
      subtitle: 'How am I really doing?',
      type: TaskType.individual,
      category: 'Reflection',
      durationMinutes: 5,
      actionRoute: '/talk',
      iconId: 'checkin',
    ),
    TaskSuggestion(
      id: 'ind-5',
      title: 'Conflict prep',
      subtitle: 'Note your side before talking',
      type: TaskType.individual,
      category: 'Conflict',
      durationMinutes: 5,
      actionRoute: '/talk/repair/input',
      iconId: 'conflict',
    ),
  ];

  static const List<TaskSuggestion> _couple = [
    TaskSuggestion(
      id: 'couple-1',
      title: 'Weekly check-in',
      subtitle: '10 min together',
      type: TaskType.couple,
      category: 'Check-in',
      durationMinutes: 10,
      actionRoute: '/talk',
      iconId: 'checkin',
    ),
    TaskSuggestion(
      id: 'couple-2',
      title: 'Share one appreciation',
      subtitle: 'Tell each other one thing',
      type: TaskType.couple,
      category: 'Gratitude',
      durationMinutes: 5,
      actionRoute: '/talk',
      iconId: 'gratitude',
    ),
    TaskSuggestion(
      id: 'couple-3',
      title: 'Conflict repair',
      subtitle: 'Private input → joint session',
      type: TaskType.couple,
      category: 'Conflict',
      durationMinutes: 15,
      actionRoute: '/talk/repair',
      iconId: 'conflict',
    ),
    TaskSuggestion(
      id: 'couple-4',
      title: 'Gratitude moment',
      subtitle: 'Both share something',
      type: TaskType.couple,
      category: 'Gratitude',
      durationMinutes: 5,
      actionRoute: '/talk',
      iconId: 'gratitude',
    ),
    TaskSuggestion(
      id: 'couple-5',
      title: 'Date idea: 15 min walk',
      subtitle: 'No phones, just talk',
      type: TaskType.couple,
      category: 'Connection',
      durationMinutes: 15,
      actionRoute: '/grow/dates',
      iconId: 'date',
    ),
    TaskSuggestion(
      id: 'couple-6',
      title: 'Ritual: evening recap',
      subtitle: 'One highlight each',
      type: TaskType.couple,
      category: 'Ritual',
      durationMinutes: 5,
      actionRoute: '/grow/rituals',
      iconId: 'ritual',
    ),
  ];

  @override
  Future<List<TaskSuggestion>> getIndividualSuggestions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_individual);
  }

  @override
  Future<List<TaskSuggestion>> getCoupleSuggestions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_couple);
  }

  @override
  Future<UndoneCounts> getUndoneCounts() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final coupleDone = _completedTaskIds.where((id) => id.startsWith('couple-')).length;
    final coupleTotal = _couple.length;
    return UndoneCounts(
      pendingTalk: 2,
      coupleTasksUndone: (coupleTotal - coupleDone).clamp(0, 99),
      journalTodayUndone: 1,
      growPending: 1,
      conflictResolutionPending: 0,
    );
  }

  @override
  Future<List<TaskSuggestion>> getCoupleTasksForHome(int limit) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _couple.take(limit).toList();
  }

  @override
  Future<void> markTaskCompleted(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_completedTaskIds.contains(taskId)) {
      _completedTaskIds.add(taskId);
    }
  }
}

final taskBankRepositoryProvider = Provider<TaskBankRepository>((ref) {
  return MockTaskBankRepository();
});

final individualSuggestionsProvider = FutureProvider<List<TaskSuggestion>>((ref) {
  return ref.watch(taskBankRepositoryProvider).getIndividualSuggestions();
});

final coupleSuggestionsProvider = FutureProvider<List<TaskSuggestion>>((ref) {
  return ref.watch(taskBankRepositoryProvider).getCoupleSuggestions();
});

final undoneCountsProvider = FutureProvider<UndoneCounts>((ref) {
  return ref.watch(taskBankRepositoryProvider).getUndoneCounts();
});

final coupleTasksForHomeProvider = FutureProvider<List<TaskSuggestion>>((ref) {
  return ref.watch(taskBankRepositoryProvider).getCoupleTasksForHome(3);
});
