import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/insights_models.dart';
import '../../../theme/app_tokens.dart';

/// Line chart for mood over time (1–5 scale).
class MoodLineChart extends StatelessWidget {
  const MoodLineChart({super.key, required this.points});

  final List<MoodPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No mood data yet')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm, top: AppSpacing.sm),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (points.length - 1).toDouble(),
            minY: 1,
            maxY: 5,
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (_) => FlLine(
                color: (isDark ? AppColors.onSurfaceDark : AppColors.onSurface)
                    .withValues(alpha: 0.1),
                strokeWidth: 1,
              ),
              drawVerticalLine: false,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: (points.length / 5).clamp(1.0, double.infinity),
                  getTitlesWidget: (value, _) {
                    final i = value.toInt().clamp(0, points.length - 1);
                    if (i >= points.length) return const SizedBox.shrink();
                    final d = points[i].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${d.month}/${d.day}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppColors.onSurfaceVariantDark
                                  : AppColors.onSurfaceVariant,
                            ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: lineColor,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: lineColor.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 250),
        ),
      ),
    );
  }
}
