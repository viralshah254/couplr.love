import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/task_bank_models.dart';
import '../data/task_bank_repository.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Data bank: things to do — Individual | Couple tabs.
class ThingsToDoScreen extends ConsumerStatefulWidget {
  const ThingsToDoScreen({super.key});

  @override
  ConsumerState<ThingsToDoScreen> createState() => _ThingsToDoScreenState();
}

class _ThingsToDoScreenState extends ConsumerState<ThingsToDoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Things to do'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Individual'),
            Tab(text: 'Couple'),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.welcomeGradientLight,
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _TaskList(type: TaskType.individual),
            _TaskList(type: TaskType.couple),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.type});

  final TaskType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = type == TaskType.individual
        ? ref.watch(individualSuggestionsProvider)
        : ref.watch(coupleSuggestionsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final sage = isDark ? AppColors.secondaryDark : AppColors.secondary;

    return async.when(
      data: (list) => ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final task = list[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _TaskCard(
              task: task,
              accent: type == TaskType.couple ? sage : primary,
              onTap: () {
                HapticFeedback.lightImpact();
                if (task.actionRoute != null && task.actionRoute!.isNotEmpty) {
                  context.push(task.actionRoute!);
                }
              },
            ),
          );
        },
      ),
      loading: () => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          SkeletonLoader(child: SkeletonCard(lineCount: 2)),
          SizedBox(height: AppSpacing.sm),
          SkeletonLoader(child: SkeletonCard(lineCount: 2)),
          SizedBox(height: AppSpacing.sm),
          SkeletonLoader(child: SkeletonCard(lineCount: 2)),
        ],
      ),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(
          type == TaskType.individual ? individualSuggestionsProvider : coupleSuggestionsProvider,
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.accent,
    required this.onTap,
  });

  final TaskSuggestion task;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    final icon = _iconForId(task.iconId);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(icon, size: 28, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (task.subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        task.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                    if (task.durationMinutes != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${task.durationMinutes} min',
                        style: theme.textTheme.labelSmall?.copyWith(color: muted),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForId(String? id) {
    switch (id) {
      case 'breath':
        return Icons.air_rounded;
      case 'journal':
        return Icons.book_rounded;
      case 'gratitude':
        return Icons.volunteer_activism_rounded;
      case 'checkin':
        return Icons.chat_bubble_outline_rounded;
      case 'conflict':
        return Icons.handshake_rounded;
      case 'date':
        return Icons.favorite_rounded;
      case 'ritual':
        return Icons.schedule_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }
}
