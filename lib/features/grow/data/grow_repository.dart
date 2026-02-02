import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'grow_models.dart';

abstract class GrowRepository {
  Future<GrowOverview> getOverview();
  Future<List<HabitChallenge>> getChallenges();
  Future<List<Badge>> getBadges();
  Future<List<Ritual>> getRituals();
  Future<List<DatePlan>> getDatePlans();
  Future<void> completeHabit(String challengeId);
  Future<void> completeRitual(String ritualId);
  Future<void> addRitual(Ritual ritual);
  Future<void> addDatePlan(DatePlan plan);
}

class MockGrowRepository implements GrowRepository {
  List<HabitChallenge> _challenges = [];
  List<Badge> _badges = [];
  List<Ritual> _rituals = [];
  List<DatePlan> _datePlans = [];

  MockGrowRepository() {
    _challenges = [
      const HabitChallenge(
        id: '1',
        title: 'Daily gratitude',
        description: 'Share one thing you\'re grateful for',
        currentStreak: 7,
        targetStreak: 30,
        completedToday: true,
      ),
      const HabitChallenge(
        id: '2',
        title: 'Check-in streak',
        description: 'Quick daily check-in',
        currentStreak: 3,
        targetStreak: 7,
        completedToday: false,
      ),
    ];
    _badges = [
      Badge(
        id: '1',
        title: 'First week',
        description: '7-day streak',
        earnedAt: DateTime(2025, 1, 25),
      ),
      Badge(
        id: '2',
        title: 'Gratitude duo',
        description: '10 gratitude entries together',
        earnedAt: DateTime(2025, 1, 20),
      ),
    ];
    _rituals = [
      Ritual(
        id: '1',
        title: 'Weekly check-in',
        description: '15 min together',
        frequency: RitualFrequency.weekly,
        nextDue: DateTime.now().add(const Duration(days: 2)),
        lastCompletedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Ritual(
        id: '2',
        title: 'Morning intention',
        frequency: RitualFrequency.daily,
        nextDue: DateTime.now(),
      ),
    ];
    _datePlans = [
      DatePlan(
        id: '1',
        title: 'Coffee walk',
        description: '30 min walk + coffee',
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        category: 'Outdoor',
      ),
      const DatePlan(
        id: '2',
        title: 'Cooking together',
        description: 'Try a new recipe',
        category: 'Home',
      ),
    ];
  }

  @override
  Future<GrowOverview> getOverview() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return GrowOverview(
      challenges: _challenges,
      badges: _badges,
      rituals: _rituals,
      upcomingDates: _datePlans.where((d) => !d.isCompleted).toList(),
    );
  }

  @override
  Future<List<HabitChallenge>> getChallenges() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_challenges);
  }

  @override
  Future<List<Badge>> getBadges() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_badges);
  }

  @override
  Future<List<Ritual>> getRituals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_rituals);
  }

  @override
  Future<List<DatePlan>> getDatePlans() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_datePlans);
  }

  @override
  Future<void> completeHabit(String challengeId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final i = _challenges.indexWhere((c) => c.id == challengeId);
    if (i >= 0) {
      final c = _challenges[i];
      _challenges[i] = HabitChallenge(
        id: c.id,
        title: c.title,
        description: c.description,
        currentStreak: c.currentStreak + 1,
        targetStreak: c.targetStreak,
        completedToday: true,
        iconId: c.iconId,
      );
    }
  }

  @override
  Future<void> completeRitual(String ritualId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    final i = _rituals.indexWhere((r) => r.id == ritualId);
    if (i >= 0) {
      final r = _rituals[i];
      DateTime? next;
      switch (r.frequency) {
        case RitualFrequency.daily:
          next = now.add(const Duration(days: 1));
          break;
        case RitualFrequency.weekly:
          next = now.add(const Duration(days: 7));
          break;
        case RitualFrequency.biweekly:
          next = now.add(const Duration(days: 14));
          break;
        case RitualFrequency.monthly:
          next = DateTime(now.year, now.month + 1, now.day);
          break;
      }
      _rituals[i] = Ritual(
        id: r.id,
        title: r.title,
        description: r.description,
        frequency: r.frequency,
        nextDue: next,
        lastCompletedAt: now,
      );
    }
  }

  @override
  Future<void> addRitual(Ritual ritual) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _rituals = [..._rituals, ritual];
  }

  @override
  Future<void> addDatePlan(DatePlan plan) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _datePlans = [..._datePlans, plan];
  }
}

final growRepositoryProvider = Provider<GrowRepository>((ref) {
  return MockGrowRepository();
});

final growOverviewProvider = FutureProvider<GrowOverview>((ref) {
  return ref.watch(growRepositoryProvider).getOverview();
});

final habitChallengesProvider = FutureProvider<List<HabitChallenge>>((ref) {
  return ref.watch(growRepositoryProvider).getChallenges();
});

final badgesProvider = FutureProvider<List<Badge>>((ref) {
  return ref.watch(growRepositoryProvider).getBadges();
});

final ritualsProvider = FutureProvider<List<Ritual>>((ref) {
  return ref.watch(growRepositoryProvider).getRituals();
});

final datePlansProvider = FutureProvider<List<DatePlan>>((ref) {
  return ref.watch(growRepositoryProvider).getDatePlans();
});
