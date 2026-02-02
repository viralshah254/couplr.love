import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_tokens.dart';

/// Small indicator that content is encrypted (lock icon + label).
class EncryptionIndicator extends StatelessWidget {
  const EncryptionIndicator({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.8)
        : AppColors.onSurfaceVariant.withValues(alpha: 0.8);

    if (compact) {
      return Semantics(
        label: 'Encrypted',
        child: Icon(
          Icons.lock_rounded,
          size: 14,
          color: color,
        ),
      );
    }

    return Semantics(
      label: 'Encrypted',
      child: InkWell(
        onTap: () => HapticFeedback.selectionClick(),
        borderRadius: BorderRadius.circular(AppRadii.xs),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, size: 14, color: color),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                'Encrypted',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
