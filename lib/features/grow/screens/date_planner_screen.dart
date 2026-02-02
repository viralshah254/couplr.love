import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/grow_models.dart';
import '../data/grow_repository.dart';
import '../widgets/date_plan_card.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Date planner: list of planned dates, add date.
class DatePlannerScreen extends ConsumerWidget {
  const DatePlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plansAsync = ref.watch(datePlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Date planner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddDateSheet(context, ref),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.welcomeGradientLight),
        child: plansAsync.when(
        data: (list) {
          final upcoming = list.where((d) => !d.isCompleted).toList();
          if (upcoming.isEmpty) {
            return EmptyState(
              title: 'No dates planned',
              subtitle: 'Plan a date to look forward to together.',
              icon: Icons.favorite_rounded,
              actionLabel: 'Plan a date',
              onAction: () => _showAddDateSheet(context, ref),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(datePlansProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: upcoming.length,
              itemBuilder: (context, i) {
                final d = upcoming[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: DatePlanCard(
                    plan: d,
                    onTap: () {},
                    onComplete: () async {
                      // In real app: mark plan as completed
                      ref.invalidate(datePlansProvider);
                      ref.invalidate(growOverviewProvider);
                    },
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
          onRetry: () => ref.invalidate(datePlansProvider),
        ),
        ),
      ),
    );
  }

  void _showAddDateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddDateSheet(
        onAdd: (plan) async {
          await ref.read(growRepositoryProvider).addDatePlan(plan);
          ref.invalidate(datePlansProvider);
          ref.invalidate(growOverviewProvider);
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

class _AddDateSheet extends StatefulWidget {
  const _AddDateSheet({required this.onAdd});

  final void Function(DatePlan plan) onAdd;

  @override
  State<_AddDateSheet> createState() => _AddDateSheetState();
}

class _AddDateSheetState extends State<_AddDateSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
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
            'Plan a date',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Coffee walk',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'e.g. 30 min walk + coffee',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Category (optional)',
              hintText: 'e.g. Outdoor, Home',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () {
              final title = _titleController.text.trim();
              if (title.isEmpty) return;
              widget.onAdd(DatePlan(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
                scheduledAt: DateTime.now().add(const Duration(days: 1)),
                category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
              ));
            },
            child: const Text('Add date'),
          ),
        ],
      ),
    );
  }
}
