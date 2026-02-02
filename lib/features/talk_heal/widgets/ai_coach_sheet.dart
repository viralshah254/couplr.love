import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_tokens.dart';

/// AI coach bottom sheet: Rewrite, De-escalate, Prepare for talk, Insight preview.
class AiCoachSheet extends StatelessWidget {
  const AiCoachSheet({
    super.key,
    this.onRewrite,
    this.onDeEscalate,
    this.onPrepareForTalk,
    this.onInsightPreview,
  });

  final VoidCallback? onRewrite;
  final VoidCallback? onDeEscalate;
  final VoidCallback? onPrepareForTalk;
  final VoidCallback? onInsightPreview;

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onRewrite,
    VoidCallback? onDeEscalate,
    VoidCallback? onPrepareForTalk,
    VoidCallback? onInsightPreview,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiCoachSheet(
        onRewrite: onRewrite,
        onDeEscalate: onDeEscalate,
        onPrepareForTalk: onPrepareForTalk,
        onInsightPreview: onInsightPreview,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.5)
                    : AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(Icons.psychology_rounded, color: accent, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AI Coach',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose an action',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SheetTile(
            icon: Icons.auto_awesome_rounded,
            label: 'Rewrite',
            subtitle: 'Soften how you say it',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              onRewrite?.call();
            },
          ),
          _SheetTile(
            icon: Icons.water_drop_rounded,
            label: 'De-escalate',
            subtitle: 'Cool down the tone',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              onDeEscalate?.call();
            },
          ),
          _SheetTile(
            icon: Icons.forum_rounded,
            label: 'Prepare for talk',
            subtitle: 'Get talking points',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              onPrepareForTalk?.call();
            },
          ),
          _SheetTile(
            icon: Icons.lightbulb_outline_rounded,
            label: 'Insight preview',
            subtitle: 'See what might help',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              onInsightPreview?.call();
            },
          ),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Icon(icon, color: accent, size: 22),
      ),
      title: Text(label),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
