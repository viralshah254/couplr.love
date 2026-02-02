import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'insights_models.dart';

abstract class InsightsRepository {
  Future<List<MoodPoint>> getMoodHistory({int days = 30});
  Future<List<ChartDataPoint>> getConflictsByWeek({int weeks = 8});
  Future<List<ChartDataPoint>> getAppreciationByWeek({int weeks = 8});
  Future<List<ChartDataPoint>> getEngagementByWeek({int weeks = 8});
}

class MockInsightsRepository implements InsightsRepository {
  @override
  Future<List<MoodPoint>> getMoodHistory({int days = 30}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return List.generate(days, (i) {
      final d = now.subtract(Duration(days: days - 1 - i));
      final base = 3.2 + (i % 7) * 0.2 - (i % 5) * 0.1;
      final value = (base.clamp(1.0, 5.0) * 10).round() / 10.0;
      return MoodPoint(date: d, value: value);
    });
  }

  @override
  Future<List<ChartDataPoint>> getConflictsByWeek({int weeks = 8}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final labels = List.generate(weeks, (i) {
      final d = now.subtract(Duration(days: (weeks - 1 - i) * 7));
      return '${d.month}/${d.day}';
    });
    final values = [0.0, 1.0, 0.0, 2.0, 1.0, 0.0, 1.0, 0.0];
    return List.generate(weeks, (i) => ChartDataPoint(label: labels[i], value: values[i]));
  }

  @override
  Future<List<ChartDataPoint>> getAppreciationByWeek({int weeks = 8}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final labels = List.generate(weeks, (i) {
      final d = now.subtract(Duration(days: (weeks - 1 - i) * 7));
      return '${d.month}/${d.day}';
    });
    final values = [3.0, 5.0, 4.0, 6.0, 5.0, 7.0, 6.0, 8.0];
    return List.generate(weeks, (i) => ChartDataPoint(label: labels[i], value: values[i]));
  }

  @override
  Future<List<ChartDataPoint>> getEngagementByWeek({int weeks = 8}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final labels = List.generate(weeks, (i) {
      final d = now.subtract(Duration(days: (weeks - 1 - i) * 7));
      return '${d.month}/${d.day}';
    });
    final values = [4.0, 5.0, 3.0, 6.0, 5.0, 7.0, 6.0, 8.0];
    return List.generate(weeks, (i) => ChartDataPoint(label: labels[i], value: values[i]));
  }
}

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  return MockInsightsRepository();
});

final moodHistoryProvider = FutureProvider<List<MoodPoint>>((ref) {
  return ref.watch(insightsRepositoryProvider).getMoodHistory();
});

final conflictsByWeekProvider = FutureProvider<List<ChartDataPoint>>((ref) {
  return ref.watch(insightsRepositoryProvider).getConflictsByWeek();
});

final appreciationByWeekProvider = FutureProvider<List<ChartDataPoint>>((ref) {
  return ref.watch(insightsRepositoryProvider).getAppreciationByWeek();
});

final engagementByWeekProvider = FutureProvider<List<ChartDataPoint>>((ref) {
  return ref.watch(insightsRepositoryProvider).getEngagementByWeek();
});
