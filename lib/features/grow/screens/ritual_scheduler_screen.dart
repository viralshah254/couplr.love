import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/grow_models.dart';
import '../data/grow_repository.dart';
import '../widgets/ritual_card.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Ritual scheduler: list of rituals, add ritual, mark done.
class RitualSchedulerScreen extends ConsumerWidget {
  const RitualSchedulerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ritualsAsync = ref.watch(ritualsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ritual scheduler'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddRitualSheet(context, ref),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.welcomeGradientLight),
        child: ritualsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              title: 'No rituals yet',
              subtitle: 'Schedule a recurring ritual to do together.',
              icon: Icons.repeat_rounded,
              actionLabel: 'Add ritual',
              onAction: () => _showAddRitualSheet(context, ref),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(ritualsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final r = list[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: RitualCard(
                    ritual: r,
                    onComplete: () async {
                      await ref.read(growRepositoryProvider).completeRitual(r.id);
                      ref.invalidate(ritualsProvider);
                      ref.invalidate(growOverviewProvider);
                    },
                    onTap: () {},
                  ),
                );
              },
            ),
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: const [
            SkeletonLoader(child: SkeletonCard(lineCount: 2)),
            SizedBox(height: AppSpacing.md),
            SkeletonLoader(child: SkeletonCard(lineCount: 2)),
          ],
        ),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(ritualsProvider),
        ),
        ),
      ),
    );
  }

  void _showAddRitualSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddRitualSheet(
        onAdd: (ritual) async {
          await ref.read(growRepositoryProvider).addRitual(ritual);
          ref.invalidate(ritualsProvider);
          ref.invalidate(growOverviewProvider);
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

class _AddRitualSheet extends StatefulWidget {
  const _AddRitualSheet({required this.onAdd});

  final void Function(Ritual ritual) onAdd;

  @override
  State<_AddRitualSheet> createState() => _AddRitualSheetState();
}

class _AddRitualSheetState extends State<_AddRitualSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  RitualFrequency _frequency = RitualFrequency.weekly;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Text(
            'Add ritual',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Weekly check-in',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'e.g. 15 min together',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Frequency',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<RitualFrequency>(
            segments: const [
              ButtonSegment(value: RitualFrequency.daily, label: Text('Daily')),
              ButtonSegment(value: RitualFrequency.weekly, label: Text('Weekly')),
              ButtonSegment(value: RitualFrequency.monthly, label: Text('Monthly')),
            ],
            selected: {_frequency},
            onSelectionChanged: (s) => setState(() => _frequency = s.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () {
              final title = _titleController.text.trim();
              if (title.isEmpty) return;
              widget.onAdd(Ritual(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
                frequency: _frequency,
                nextDue: DateTime.now(),
              ));
            },
            child: const Text('Add ritual'),
          ),
        ],
      ),
    );
  }
}
