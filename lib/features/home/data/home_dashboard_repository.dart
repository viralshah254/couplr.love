import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Relationship temperature: 1–5 or 0–100. Calm/warm/cool metaphor.
class RelationshipTemperature {
  const RelationshipTemperature({
    required this.value,
    this.label = 'Warm',
    this.message,
  });

  /// 1 = cool, 5 = warm (or 0–100 scale)
  final int value;
  final String label;
  final String? message;
}

/// Today's focus: one intentional action or prompt.
class TodayFocus {
  const TodayFocus({
    required this.title,
    this.subtitle,
    this.actionId,
  });

  final String title;
  final String? subtitle;
  final String? actionId;
}

/// Streak: consecutive days of a habit or check-in.
class StreakInfo {
  const StreakInfo({
    required this.currentStreak,
    this.label = 'Day streak',
    this.iconId,
  });

  final int currentStreak;
  final String label;
  final String? iconId;
}

/// Pending session: Talk & Heal or ritual waiting to be done.
class PendingSession {
  const PendingSession({
    required this.id,
    required this.title,
    this.subtitle,
    this.scheduledAt,
  });

  final String id;
  final String title;
  final String? subtitle;
  final DateTime? scheduledAt;
}

/// Gratitude reminder: prompt to log or view gratitude.
class GratitudeReminder {
  const GratitudeReminder({
    this.prompt = 'What are you grateful for today?',
    this.partnerResponse,
    this.isEmpty = true,
  });

  final String prompt;
  final String? partnerResponse;
  final bool isEmpty;
}

/// Couple score: compatibility in conflict resolution and relationship health.
class CoupleScore {
  const CoupleScore({
    required this.scorePercent,
    this.label = 'Conflict resolution compatibility',
    this.trendUp = true,
    this.trendAmount,
  });

  final int scorePercent;
  final String label;
  final bool trendUp;
  final int? trendAmount;
}

/// Conflict sense: how the couple is doing (tension, check-in needed, unresolved).
class ConflictSense {
  const ConflictSense({
    required this.status,
    required this.message,
    this.unresolvedCount = 0,
    this.daysSinceCheckIn,
    this.ctaLabel,
  });

  static const String statusCalm = 'calm';
  static const String statusCheckIn = 'check_in';
  static const String statusUnresolved = 'unresolved';

  final String status;
  final String message;
  final int unresolvedCount;
  final int? daysSinceCheckIn;
  final String? ctaLabel;
}

/// Growth analytics: self + couple metrics.
class GrowthAnalytics {
  const GrowthAnalytics({
    required this.selfResolutionsThisMonth,
    required this.selfStreakDays,
    required this.coupleJointSessionsThisMonth,
    required this.coupleScoreTrend,
  });

  final int selfResolutionsThisMonth;
  final int selfStreakDays;
  final int coupleJointSessionsThisMonth;
  final String coupleScoreTrend;
}

/// Home dashboard aggregate. Replace with real API when backend exists.
class HomeDashboardData {
  const HomeDashboardData({
    required this.temperature,
    required this.todayFocus,
    required this.streak,
    required this.pendingSessions,
    required this.gratitudeReminder,
    this.coupleScore,
    this.conflictSense,
    this.growthAnalytics,
    this.isPartnerLinked = false,
    this.error,
  });

  final RelationshipTemperature temperature;
  final TodayFocus? todayFocus;
  final StreakInfo streak;
  final List<PendingSession> pendingSessions;
  final GratitudeReminder gratitudeReminder;
  final CoupleScore? coupleScore;
  final ConflictSense? conflictSense;
  final GrowthAnalytics? growthAnalytics;
  final bool isPartnerLinked;
  final String? error;
}

abstract class HomeDashboardRepository {
  Future<HomeDashboardData> getDashboard();
}

/// Mock implementation for Phase 3 + smart home.
class MockHomeDashboardRepository implements HomeDashboardRepository {
  @override
  Future<HomeDashboardData> getDashboard() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return HomeDashboardData(
      temperature: const RelationshipTemperature(
        value: 4,
        label: 'Warm',
        message: 'You\'re in a good place. Keep the small moments going.',
      ),
      todayFocus: const TodayFocus(
        title: 'Share one appreciation',
        subtitle: 'Tell your partner one thing you appreciated this week.',
        actionId: 'appreciation-1',
      ),
      streak: const StreakInfo(
        currentStreak: 7,
        label: 'Check-in streak',
      ),
      pendingSessions: [
        PendingSession(
          id: '1',
          title: 'Weekly check-in',
          subtitle: '5 min',
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        ),
        PendingSession(
          id: '2',
          title: 'Gratitude moment',
          subtitle: '2 min',
        ),
      ],
      gratitudeReminder: const GratitudeReminder(
        prompt: 'What are you grateful for today?',
        partnerResponse: 'That we had breakfast together.',
        isEmpty: false,
      ),
      coupleScore: const CoupleScore(
        scorePercent: 78,
        label: 'Conflict resolution compatibility',
        trendUp: true,
        trendAmount: 5,
      ),
      conflictSense: const ConflictSense(
        status: ConflictSense.statusCalm,
        message: 'No tension detected. You\'re in sync.',
        unresolvedCount: 0,
        daysSinceCheckIn: 2,
        ctaLabel: 'Quick check-in',
      ),
      growthAnalytics: const GrowthAnalytics(
        selfResolutionsThisMonth: 3,
        selfStreakDays: 7,
        coupleJointSessionsThisMonth: 2,
        coupleScoreTrend: 'Up 5% this month',
      ),
      isPartnerLinked: false,
    );
  }
}

final homeDashboardRepositoryProvider = Provider<HomeDashboardRepository>((ref) {
  return MockHomeDashboardRepository();
});

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) {
  return ref.watch(homeDashboardRepositoryProvider).getDashboard();
});
