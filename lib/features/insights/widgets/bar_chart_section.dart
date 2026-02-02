import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/insights_models.dart';
import '../../../theme/app_tokens.dart';

/// Bar chart for weekly data (conflicts, appreciation, engagement).
class BarChartSection extends StatelessWidget {
  const BarChartSection({super.key, required this.points, required this.title});

  final List<ChartDataPoint> points;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data yet')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final maxY = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final maxYAxis = (maxY + 1).clamp(1.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
          ),
        ),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxYAxis,
              barTouchData: BarTouchData(enabled: false),
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
                    reservedSize: 28,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt().clamp(0, points.length - 1);
                      if (i >= points.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          points[i].label,
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
              barGroups: points.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.value,
                      color: barColor,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                  showingTooltipIndicators: [],
                );
              }).toList(),
            ),
            duration: const Duration(milliseconds: 250),
          ),
        ),
      ],
    );
  }
}
