import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/conflict_repair_models.dart';
import '../data/conflict_repair_repository.dart';
import '../widgets/emotion_chip.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';

const _sessionId = 'repair-1';
const _partnerId = 'user-1';

/// Private conflict input: feelings, triggers, what I want, free text.
/// Fully private — AI analyzes without exposing to partner.
class ConflictPrivateInputScreen extends ConsumerStatefulWidget {
  const ConflictPrivateInputScreen({super.key});

  @override
  ConsumerState<ConflictPrivateInputScreen> createState() =>
      _ConflictPrivateInputScreenState();
}

class _ConflictPrivateInputScreenState
    extends ConsumerState<ConflictPrivateInputScreen> {
  final _triggersController = TextEditingController();
  final _whatIWantController = TextEditingController();
  final _freeTextController = TextEditingController();
  final Set<String> _selectedFeelings = {};
  bool _submitted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _triggersController.dispose();
    _whatIWantController.dispose();
    _freeTextController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final triggers = _triggersController.text.trim();
    final whatIWant = _whatIWantController.text.trim();
    final freeText = _freeTextController.text.trim();
    if (_selectedFeelings.isEmpty && triggers.isEmpty && whatIWant.isEmpty && freeText.isEmpty) {
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);
    final repo = ref.read(conflictRepairRepositoryProvider);
    await repo.submitFullPrivateInput(
      _sessionId,
      _partnerId,
      feelings: _selectedFeelings.toList(),
      triggers: triggers.isEmpty ? null : triggers,
      whatIWant: whatIWant.isEmpty ? null : whatIWant,
      freeText: freeText.isEmpty ? null : freeText,
    );
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionAsync = ref.watch(conflictRepairSessionProvider(_sessionId));

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.welcomeGradientLight,
        ),
        child: SafeArea(
          child: sessionAsync.when(
            data: (session) {
              final myInput = session.privateInputs.cast<PrivateInput?>().firstWhere(
                    (i) => i?.partnerId == _partnerId,
                    orElse: () => null,
                  );
              final bothSubmitted = session.privateInputs.length >= 2;
              final submitted = _submitted || myInput != null;

              return ConflictPrivateInputContent(
                submitted: submitted,
                bothSubmitted: bothSubmitted,
                selectedFeelings: _selectedFeelings,
                triggersController: _triggersController,
                whatIWantController: _whatIWantController,
                freeTextController: _freeTextController,
                isSubmitting: _isSubmitting,
                onToggleFeeling: (f) {
                  setState(() {
                    if (_selectedFeelings.contains(f)) {
                      _selectedFeelings.remove(f);
                    } else {
                      _selectedFeelings.add(f);
                    }
                  });
                },
                onSubmit: _submit,
                onStartCooling: () {
                  HapticFeedback.lightImpact();
                  context.push('/talk/repair/cooling');
                },
                onBack: () => context.pop(),
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
        title: const Text('Your perspective'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
    );
  }
}

class ConflictPrivateInputContent extends StatelessWidget {
  const ConflictPrivateInputContent({
    super.key,
    required this.submitted,
    required this.bothSubmitted,
    required this.selectedFeelings,
    required this.triggersController,
    required this.whatIWantController,
    required this.freeTextController,
    required this.isSubmitting,
    required this.onToggleFeeling,
    required this.onSubmit,
    required this.onStartCooling,
    required this.onBack,
  });

  final bool submitted;
  final bool bothSubmitted;
  final Set<String> selectedFeelings;
  final TextEditingController triggersController;
  final TextEditingController whatIWantController;
  final TextEditingController freeTextController;
  final bool isSubmitting;
  final void Function(String) onToggleFeeling;
  final VoidCallback onSubmit;
  final VoidCallback onStartCooling;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    if (submitted && bothSubmitted) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(Icons.check_circle_rounded, size: 48, color: primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Both of you have shared. When you’re ready, start a short cooling moment, then the joint session.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: muted,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: onStartCooling,
                    icon: const Icon(Icons.timer_rounded, size: 22),
                    label: const Text('Start cooling (10 sec)'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (submitted) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(Icons.lock_rounded, size: 48, color: primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Saved. When your partner submits, start together.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: muted,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.lock_rounded, size: 28, color: primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'When things get heated — share here. Private. Only a shared agenda goes to both.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: muted,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          children: kConflictFeelingTags
              .map((f) => EmotionChip(
                    label: f,
                    selected: selectedFeelings.contains(f),
                    onTap: () => onToggleFeeling(f),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'What triggered this?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: triggersController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'What happened?',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'What do you want from this conversation?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: whatIWantController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'One thing that would help...',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Anything else? (optional)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: muted),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: freeTextController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Additional thoughts...',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: isSubmitting ? null : onSubmit,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit (private)'),
        ),
      ],
    );
  }
}
