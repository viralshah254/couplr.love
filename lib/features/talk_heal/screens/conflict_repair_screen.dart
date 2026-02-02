import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/conflict_repair_models.dart';
import '../data/conflict_repair_repository.dart';
import '../widgets/cooling_timer_widget.dart';
import '../../../theme/app_tokens.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

const _sessionId = 'repair-1';
const _partnerId = 'user-1'; // In real app from auth
const _coolingSeconds = 10;

/// Conflict repair: private input → cooling timer → shared AI agenda.
class ConflictRepairScreen extends ConsumerStatefulWidget {
  const ConflictRepairScreen({super.key});

  @override
  ConsumerState<ConflictRepairScreen> createState() => _ConflictRepairScreenState();
}

class _ConflictRepairScreenState extends ConsumerState<ConflictRepairScreen> {
  final _inputController = TextEditingController();
  bool _submitted = false;
  bool _showCooling = false;
  bool _showAgenda = false;
  List<AgendaItem> _agenda = [];
  bool _agendaLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _submitPrivateInput() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    final repo = ref.read(conflictRepairRepositoryProvider);
    await repo.submitPrivateInput(_sessionId, _partnerId, text);
    if (!mounted) return;
    setState(() => _submitted = true);
  }

  void _startCooling() {
    HapticFeedback.lightImpact();
    setState(() => _showCooling = true);
  }

  void _onCoolingComplete() async {
    setState(() {
      _showCooling = false;
      _agendaLoading = true;
    });
    final repo = ref.read(conflictRepairRepositoryProvider);
    final items = await repo.getAgendaAfterCooling(_sessionId);
    if (!mounted) return;
    setState(() {
      _agendaLoading = false;
      _agenda = items;
      _showAgenda = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(conflictRepairSessionProvider(_sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conflict repair'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: sessionAsync.when(
        data: (session) {
          if (_showCooling) {
            return CoolingTimerWidget(
              totalSeconds: _coolingSeconds,
              onComplete: _onCoolingComplete,
            );
          }
          if (_agendaLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_showAgenda && _agenda.isNotEmpty) {
            return _AgendaView(agenda: _agenda);
          }
          return _PrivateInputView(
            submitted: _submitted,
            inputController: _inputController,
            onSubmit: _submitPrivateInput,
            onStartCooling: _startCooling,
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const [
            SkeletonLoader(child: SkeletonCard(lineCount: 3)),
          ],
        ),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(conflictRepairSessionProvider(_sessionId)),
        ),
      ),
    );
  }
}

class _PrivateInputView extends StatelessWidget {
  const _PrivateInputView({
    required this.submitted,
    required this.inputController,
    required this.onSubmit,
    required this.onStartCooling,
  });

  final bool submitted;
  final TextEditingController inputController;
  final VoidCallback onSubmit;
  final VoidCallback onStartCooling;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.primaryDarkMode
                            : AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Private — only you see this',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Write what you\'re feeling. Your partner will do the same. The AI will create a shared agenda for a calm conversation.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: inputController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'I feel...',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !submitted,
                  ),
                  if (!submitted) ...[
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: onSubmit,
                      child: const Text('Submit (private)'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (submitted) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Both partners can submit. When ready, start the cooling period.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onStartCooling,
              icon: const Icon(Icons.timer_rounded, size: 20),
              label: const Text('Start cooling (${_coolingSeconds}s)'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AgendaView extends StatelessWidget {
  const _AgendaView({required this.agenda});

  final List<AgendaItem> agenda;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          'Shared agenda',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Use this as a guide for your conversation.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...agenda.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              leading: CircleAvatar(
                backgroundColor: (isDark
                        ? AppColors.primaryDarkMode
                        : AppColors.primary)
                    .withValues(alpha: 0.2),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: isDark
                      ? AppColors.primaryDarkMode
                      : AppColors.primary,
                ),
              ),
              title: Text(item.title),
              subtitle: item.detail != null ? Text(item.detail!) : null,
            ),
          ),
        ),
      ],
    );
  }
}
