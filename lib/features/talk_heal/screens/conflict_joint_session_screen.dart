import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/conflict_repair_models.dart';
import '../data/conflict_repair_repository.dart';
import '../widgets/coaching_bubble.dart';
import '../widgets/conflict_progress_steps.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';

const _sessionId = 'repair-1';

/// Joint session: step-by-step guided conversation with progress and coaching.
class ConflictJointSessionScreen extends ConsumerStatefulWidget {
  const ConflictJointSessionScreen({super.key});

  @override
  ConsumerState<ConflictJointSessionScreen> createState() =>
      _ConflictJointSessionScreenState();
}

class _ConflictJointSessionScreenState
    extends ConsumerState<ConflictJointSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _transitionController, curve: AppMotion.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _transitionController, curve: AppMotion.easeOut),
    );
    _transitionController.forward();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  Future<void> _completeStep(int index) async {
    HapticFeedback.lightImpact();
    final repo = ref.read(conflictRepairRepositoryProvider);
    await repo.completeStep(_sessionId, index);
    if (!mounted) return;
    ref.invalidate(conflictRepairSessionProvider(_sessionId));
  }

  Future<void> _completeSession() async {
    HapticFeedback.mediumImpact();
    final repo = ref.read(conflictRepairRepositoryProvider);
    await repo.completeSession(_sessionId);
    if (!mounted) return;
    ref.invalidate(conflictRepairSessionProvider(_sessionId));
    context.go('/talk/repair');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepsAsync = ref.watch(conflictRepairSessionProvider(_sessionId));

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.welcomeGradientLight,
        ),
        child: SafeArea(
          child: stepsAsync.when(
            data: (session) {
              final steps = session.jointSteps;
              if (steps.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final completedCount =
                  steps.where((s) => s.isCompleted).length;
              final currentIndex = completedCount.clamp(0, steps.length - 1);
              final currentStep = steps[currentIndex];
              final isLastStep = currentIndex == steps.length - 1;
              final allCompleted = completedCount >= steps.length;

              if (allCompleted) {
                return _CompletionView(
                  stepsCount: steps.length,
                  onDone: _completeSession,
                );
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: ConflictProgressSteps(
                          total: steps.length,
                          completedCount: completedCount,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          child: _StepCard(
                            step: currentStep,
                            stepIndex: currentIndex + 1,
                            totalSteps: steps.length,
                            onAcknowledge: () => _completeStep(currentIndex),
                            isLastStep: isLastStep,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Something went wrong. ${e.toString()}'),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Joint session'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.onAcknowledge,
    required this.isLastStep,
  });

  final JointSessionStep step;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onAcknowledge;
  final bool isLastStep;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step $stepIndex of $totalSteps',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: muted,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              step.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (step.detail != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                step.detail!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: muted,
                      height: 1.35,
                    ),
              ),
            ],
            if (step.suggestedPhrasing != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote_rounded, size: 20, color: primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        step.suggestedPhrasing!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: isDark
                                  ? AppColors.onSurfaceDark
                                  : AppColors.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (step.coachingMessage != null)
              CoachingBubble(message: step.coachingMessage!),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onAcknowledge,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
              child: Text(isLastStep ? 'Complete step' : 'Acknowledge & next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({
    required this.stepsCount,
    required this.onDone,
  });

  final int stepsCount;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration_rounded, size: 64, color: primary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'You did it',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You’ve completed all $stepsCount steps. Small steps like this build trust and understanding.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: muted,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
