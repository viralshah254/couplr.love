import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/notifications/data/notification_provider.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';

/// Notifications settings: daily reminders (4 smart notifications/day), quiet hours.
class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends ConsumerState<NotificationsSettingsScreen> {
  bool _reminders = true;
  bool _quietHours = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final service = ref.read(notificationServiceProvider);
    final reminders = await service.dailyRemindersEnabled;
    final quiet = await service.quietHoursEnabled;
    if (mounted) {
      setState(() {
        _reminders = reminders;
        _quietHours = quiet;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.welcomeGradientLight,
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                children: [
                Text(
                  'Smart reminders to open Couplr — catchy, urgent, and actionable. Up to 4 a day.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingsSwitchTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Daily reminders',
                  subtitle: 'Morning, noon, afternoon & evening — don\'t miss a beat',
                  value: _reminders,
                  onChanged: (v) async {
                    HapticFeedback.lightImpact();
                    setState(() => _reminders = v);
                    final service = ref.read(notificationServiceProvider);
                    if (v) {
                      await service.requestPermission();
                      await service.scheduleDailyReminders();
                    } else {
                      await service.setDailyRemindersEnabled(false);
                    }
                  },
                ),
                _SettingsSwitchTile(
                  icon: Icons.nights_stay_outlined,
                  title: 'Quiet hours',
                  subtitle: 'Pause reminders at night (10 PM – 7 AM)',
                  value: _quietHours,
                  onChanged: (v) async {
                    HapticFeedback.lightImpact();
                    setState(() => _quietHours = v);
                    await ref.read(notificationServiceProvider).setQuietHoursEnabled(v);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    'When you tap a notification, Couplr opens to the right place — Home, Talk & Heal, or Things to do.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
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
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
