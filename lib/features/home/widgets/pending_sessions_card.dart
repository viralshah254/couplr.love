import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/home_dashboard_repository.dart';
import '../../../theme/app_tokens.dart';

/// Pending sessions: Talk & Heal or rituals waiting to be done.
class PendingSessionsCard extends StatelessWidget {
  const PendingSessionsCard({
    super.key,
    required this.sessions,
    this.onTapSession,
    this.onSeeAll,
  });

  final List<PendingSession> sessions;
  final void Function(PendingSession)? onTapSession;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.primaryDarkMode
                          : AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Pending sessions',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                if (sessions.isNotEmpty && onSeeAll != null)
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onSeeAll!();
                    },
                    child: const Text('See all'),
                  ),
              ],
            ),
            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'No pending sessions. You\'re all caught up.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                ),
              )
            else
              ...sessions.take(3).map(
                    (s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(s.title),
                      subtitle: s.subtitle != null
                          ? Text(s.subtitle!)
                          : (s.scheduledAt != null
                              ? Text(
                                  DateFormat.jm().format(s.scheduledAt!),
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              : null),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTapSession?.call(s);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
