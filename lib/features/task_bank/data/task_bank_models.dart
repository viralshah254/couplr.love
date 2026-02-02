/// A suggested task from the data bank — individual or couple.
class TaskSuggestion {
  const TaskSuggestion({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    this.category,
    this.durationMinutes,
    this.actionRoute,
    this.iconId,
  });

  final String id;
  final String title;
  final String? subtitle;
  final TaskType type;
  final String? category;
  final int? durationMinutes;
  final String? actionRoute;
  final String? iconId;
}

enum TaskType { individual, couple }

/// Completion record for a task (so we can show done/undone).
class TaskCompletion {
  const TaskCompletion({
    required this.taskId,
    required this.completedAt,
    this.userId,
  });

  final String taskId;
  final DateTime completedAt;
  final String? userId;
}

/// Undone counts across the app — for badges and home strip.
class UndoneCounts {
  const UndoneCounts({
    this.pendingTalk = 0,
    this.coupleTasksUndone = 0,
    this.journalTodayUndone = 0,
    this.growPending = 0,
    this.conflictResolutionPending = 0,
  });

  final int pendingTalk;
  final int coupleTasksUndone;
  final int journalTodayUndone;
  final int growPending;
  final int conflictResolutionPending;

  int get total =>
      pendingTalk + coupleTasksUndone + journalTodayUndone + growPending + conflictResolutionPending;
}
