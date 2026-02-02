import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/privacy_preferences.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';

/// Privacy settings: data & sharing options.
class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;
    final journalVisibility = ref.watch(journalVisibilityProvider);
    final analyticsEnabled = ref.watch(analyticsEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.welcomeGradientLight),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          children: [
            Text(
              'Control how your data is used and shared.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: AppSpacing.lg),
            journalVisibility.when(
              data: (visibility) => _PrivacyTile(
                icon: Icons.visibility_outlined,
                title: 'Journal visibility',
                subtitle: visibility.subtitle,
                onTap: () => _showJournalVisibilitySheet(context, ref, visibility, theme),
              ),
              loading: () => _PrivacyTile(
                icon: Icons.visibility_outlined,
                title: 'Journal visibility',
                subtitle: 'Who can see shared entries',
                onTap: () {},
              ),
              error: (_, __) => _PrivacyTile(
                icon: Icons.visibility_outlined,
                title: 'Journal visibility',
                subtitle: 'Who can see shared entries',
                onTap: () {},
              ),
            ),
            analyticsEnabled.when(
              data: (enabled) => _AnalyticsTile(enabled: enabled),
              loading: () => _AnalyticsTile(enabled: true),
              error: (_, __) => _AnalyticsTile(enabled: true),
            ),
            _PrivacyTile(
              icon: Icons.folder_outlined,
              title: 'Data & export',
              subtitle: 'Download or delete your data',
              onTap: () {
                HapticFeedback.lightImpact();
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showJournalVisibilitySheet(
    BuildContext context,
    WidgetRef ref,
    JournalVisibility current,
    ThemeData theme,
  ) {
    HapticFeedback.lightImpact();
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Who can see shared entries',
                style: theme.textTheme.titleMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: AppSpacing.md),
              ...JournalVisibility.values.map((v) => ListTile(
                    leading: Icon(
                      current == v ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: current == v ? accent : muted,
                      size: 24,
                    ),
                    title: Text(v.label),
                    subtitle: Text(v.subtitle, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                    onTap: () async {
                      await ref.read(privacyPreferencesRepositoryProvider).setJournalVisibility(v);
                      ref.invalidate(journalVisibilityProvider);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsTile extends ConsumerWidget {
  const _AnalyticsTile({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(Icons.analytics_outlined, size: 22, color: accent),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Analytics', style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    'Help improve Couplr (anonymous)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (value) async {
                HapticFeedback.lightImpact();
                await ref.read(privacyPreferencesRepositoryProvider).setAnalyticsEnabled(value);
                ref.invalidate(analyticsEnabledProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyTile extends StatelessWidget {
  const _PrivacyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: 22, color: accent),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
