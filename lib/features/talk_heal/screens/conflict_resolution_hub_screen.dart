import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/conflict_repair_models.dart';
import '../data/conflict_repair_repository.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

const _sessionId = 'repair-1';
const _partnerId = 'user-1';

/// Entry point for Conflict Resolution: Start, Continue, or Dashboard.
class ConflictResolutionHubScreen extends ConsumerWidget {
  const ConflictResolutionHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(conflictRepairSessionProvider(_sessionId));
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.welcomeGradientLight,
        ),
        child: SafeArea(
          child: sessionAsync.when(
            data: (session) => _HubContent(
              session: session,
              onStartPrivateInput: () {
                HapticFeedback.lightImpact();
                context.push('/talk/repair/input');
              },
              onOpenDashboard: () {
                HapticFeedback.lightImpact();
                context.push('/talk/conflict-dashboard');
              },
            ),
            loading: () => ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const [
                SkeletonLoader(child: SkeletonCard(lineCount: 3)),
                SizedBox(height: AppSpacing.md),
                SkeletonLoader(child: SkeletonCard(lineCount: 2)),
              ],
            ),
            error: (e, _) => ErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(conflictRepairSessionProvider(_sessionId)),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Conflict resolution'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
    );
  }
}

class _HubContent extends StatelessWidget {
  const _HubContent({
    required this.session,
    required this.onStartPrivateInput,
    required this.onOpenDashboard,
  });

  final ConflictRepairSession session;
  final VoidCallback onStartPrivateInput;
  final VoidCallback onOpenDashboard;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    final myInput = session.privateInputs.cast<PrivateInput?>().firstWhere(
          (i) => i?.partnerId == _partnerId,
          orElse: () => null,
        );
    final bothSubmitted = session.privateInputs.length >= 2;
    final canStartJoint = bothSubmitted || (session.jointSteps.isNotEmpty);
    final isCompleted = session.phase == ConflictRepairPhase.completed;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Fix things alone or with your partner. Private input → smart agenda → guided conversation.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: muted,
                height: 1.4,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (isCompleted) ...[
          _StatusCard(
            icon: Icons.check_circle_rounded,
            title: 'Done',
            subtitle: 'You’ve finished this resolution. Start a new one or view dashboard.',
            accent: primary,
          ),
          const SizedBox(height: AppSpacing.md),
        ] else if (canStartJoint && session.jointSteps.isEmpty) ...[
          _StatusCard(
            icon: Icons.handshake_rounded,
            title: 'Ready together',
            subtitle: 'Start the guided conversation.',
            accent: primary,
          ),
          const SizedBox(height: AppSpacing.md),
        ] else if (myInput != null && !bothSubmitted) ...[
          _StatusCard(
            icon: Icons.schedule_rounded,
            title: 'Waiting for partner',
            subtitle: 'You’ve shared your perspective. When they submit, start together.',
            accent: primary,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        FilledButton.icon(
          onPressed: isCompleted ? onStartPrivateInput : onStartPrivateInput,
          icon: Icon(isCompleted ? Icons.add_rounded : Icons.edit_rounded, size: 22),
          label: Text(isCompleted ? 'Start new' : (myInput == null ? 'Share your side' : 'Edit')),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
          ),
        ),
        if (canStartJoint && session.jointSteps.isEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/talk/repair/cooling');
            },
            icon: const Icon(Icons.handshake_rounded, size: 22),
            label: const Text('Start joint session'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
            ),
          ),
        ],
        if (session.jointSteps.isNotEmpty && !isCompleted) ...[
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/talk/repair/session');
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: const Text('Continue joint session'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: TextButton.icon(
            onPressed: onOpenDashboard,
            icon: const Icon(Icons.insights_rounded, size: 20),
            label: const Text('Conflict dashboard'),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
