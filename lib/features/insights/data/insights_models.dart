/// Mood data point (1–5 scale) for charting.
class MoodPoint {
  const MoodPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

/// Conflict event for charting (count per period).
class ConflictEvent {
  const ConflictEvent({required this.date});

  final DateTime date;
}

/// Appreciation / gratitude entry for charting.
class AppreciationPoint {
  const AppreciationPoint({required this.date});

  final DateTime date;
}

/// Engagement (sessions, activities) for charting.
class EngagementPoint {
  const EngagementPoint({required this.date, required this.count});

  final DateTime date;
  final int count;
}

/// Aggregated data for a chart (e.g. per week).
class ChartDataPoint {
  const ChartDataPoint({required this.label, required this.value});

  final String label;
  final double value;
}
