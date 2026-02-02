import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/experts_repository.dart';
import '../../../theme/app_tokens.dart';

/// Ask-an-Expert: submit a question (optionally to a specific expert).
class AskExpertScreen extends ConsumerStatefulWidget {
  const AskExpertScreen({super.key, this.expertId});

  final String? expertId;

  @override
  ConsumerState<AskExpertScreen> createState() => _AskExpertScreenState();
}

class _AskExpertScreenState extends ConsumerState<AskExpertScreen> {
  final _bodyController = TextEditingController();
  String? _selectedExpertId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedExpertId = widget.expertId;
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty) return;
    final experts = ref.read(expertsListProvider).valueOrNull;
    final expertId = _selectedExpertId ?? (experts != null && experts.isNotEmpty ? experts.first.id : null);
    if (expertId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an expert')),
      );
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _submitting = true);
    await ref.read(expertsRepositoryProvider).submitQuestion(expertId, body);
    ref.invalidate(myQuestionsProvider);
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Question submitted. You\'ll be notified when answered.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final expertsAsync = ref.watch(expertsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask an Expert'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Submit your question anonymously. An expert will respond.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            expertsAsync.when(
              data: (experts) {
                if (experts.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose expert (optional)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedExpertId ?? (experts.isNotEmpty ? experts.first.id : null),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: experts
                          .map((e) => DropdownMenuItem(value: e.id, child: Text(e.displayName)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedExpertId = v),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            Text(
              'Your question',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _bodyController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe your situation or question...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
