import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/home_dashboard_repository.dart';
import '../../../theme/app_tokens.dart';

/// Relationship temperature widget: 1–5 scale with label and message.
class RelationshipTemperatureCard extends StatelessWidget {
  const RelationshipTemperatureCard({
    super.key,
    required this.temperature,
  });

  final RelationshipTemperature temperature;

  static const int _maxValue = 5;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark
        ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.7)
        : AppColors.onSurfaceVariant.withValues(alpha: 0.7);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 20,
                  color: primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Relationship temperature',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: muted,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: List.generate(_maxValue, (i) {
                final filled = i < temperature.value;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: Icon(
                      filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 28,
                      color: filled
                          ? primary
                          : (isDark
                              ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.4)
                              : AppColors.outlineVariant),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              temperature.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (temperature.message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                temperature.message!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: muted,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
