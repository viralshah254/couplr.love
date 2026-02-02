/// A habit or challenge the couple tracks together.
class HabitChallenge {
  const HabitChallenge({
    required this.id,
    required this.title,
    this.description,
    required this.currentStreak,
    this.targetStreak,
    this.completedToday = false,
    this.iconId,
  });

  final String id;
  final String title;
  final String? description;
  final int currentStreak;
  final int? targetStreak;
  final bool completedToday;
  final String? iconId;
}

/// Badge earned by the couple (e.g. "7-day streak", "First ritual").
class Badge {
  const Badge({
    required this.id,
    required this.title,
    this.description,
    this.iconId,
    this.earnedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? iconId;
  final DateTime? earnedAt;
}

/// Recurring ritual (e.g. weekly check-in, gratitude).
class Ritual {
  const Ritual({
    required this.id,
    required this.title,
    this.description,
    required this.frequency,
    this.nextDue,
    this.lastCompletedAt,
  });

  final String id;
  final String title;
  final String? description;
  final RitualFrequency frequency;
  final DateTime? nextDue;
  final DateTime? lastCompletedAt;
}

enum RitualFrequency { daily, weekly, biweekly, monthly }

/// A planned or suggested date.
class DatePlan {
  const DatePlan({
    required this.id,
    required this.title,
    this.description,
    this.scheduledAt,
    this.isCompleted = false,
    this.category,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime? scheduledAt;
  final bool isCompleted;
  final String? category;
}

/// Aggregate for Grow tab: challenges, badges, rituals, upcoming dates.
class GrowOverview {
  const GrowOverview({
    this.challenges = const [],
    this.badges = const [],
    this.rituals = const [],
    this.upcomingDates = const [],
  });

  final List<HabitChallenge> challenges;
  final List<Badge> badges;
  final List<Ritual> rituals;
  final List<DatePlan> upcomingDates;
}
