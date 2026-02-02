import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_tokens.dart';

/// Selectable chip for feelings/emotions in private conflict input.
class EmotionChip extends StatelessWidget {
  const EmotionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final surface = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Material(
        color: selected ? primary.withValues(alpha: 0.2) : surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppRadii.full),
          child: AnimatedContainer(
            duration: AppMotion.normal,
            curve: AppMotion.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? primary : (isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
