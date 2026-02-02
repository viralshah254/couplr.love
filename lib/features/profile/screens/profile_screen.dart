import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_tokens.dart';
import '../../../theme/app_theme.dart';

/// Profile screen: header + settings (theme mode, notifications, privacy, account, about).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentMode = ref.watch(appThemeProvider).mode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        children: [
          const SizedBox(height: AppSpacing.sm),
          _ProfileHeader(isDark: isDark),
          const SizedBox(height: AppSpacing.xl),
          _SectionHeader(title: 'Settings'),
          const SizedBox(height: AppSpacing.sm),
          _SettingsCard(
            isDark: isDark,
            children: [
              _SettingsRow(
                icon: Icons.palette_outlined,
                label: 'Appearance',
                trailing: _ThemeModeSegmented(
                  value: currentMode,
                  onChanged: (mode) {
                    HapticFeedback.lightImpact();
                    ref.read(appThemeProvider.notifier).state =
                        ref.read(appThemeProvider).copyWith(mode: mode);
                  },
                ),
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                subtitle: 'Reminders & check-ins',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/profile/notifications');
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                label: 'Privacy',
                subtitle: 'Data & sharing',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/profile/privacy');
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                label: 'Account',
                subtitle: 'Email, password, partner',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/profile/account');
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                label: 'About',
                subtitle: 'Version, terms, support',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/profile/about');
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_rounded, size: 36, color: primary),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Profile & settings',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: muted,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.isDark,
    required this.children,
  });

  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: accent),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: accent),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: muted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Divider(
      height: 1,
      indent: AppSpacing.md + 22 + AppSpacing.md,
      endIndent: AppSpacing.md,
      color: isDark
          ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.2)
          : AppColors.outlineVariant,
    );
  }
}

/// Segmented control for Light / Dark / System.
class _ThemeModeSegmented extends StatelessWidget {
  const _ThemeModeSegmented({
    required this.value,
    required this.onChanged,
  });

  final ThemeMode value;
  final void Function(ThemeMode) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final surface = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'Light',
            selected: value == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
            primary: primary,
          ),
          _Segment(
            label: 'Dark',
            selected: value == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
            primary: primary,
          ),
          _Segment(
            label: 'System',
            selected: value == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
            primary: primary,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primary,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: selected ? primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected
                      ? AppColors.onPrimary
                      : (isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant),
                ),
          ),
        ),
      ),
    );
  }
}
