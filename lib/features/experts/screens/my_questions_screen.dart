import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/experts_models.dart';
import '../data/experts_repository.dart';
import '../../../theme/app_tokens.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// My submitted questions to experts.
class MyQuestionsScreen extends ConsumerWidget {
  const MyQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(myQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My questions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return EmptyState(
              title: 'No questions yet',
              subtitle: 'Ask an expert and your questions will appear here.',
              icon: Icons.help_outline_rounded,
              actionLabel: 'Ask an Expert',
              onAction: () => context.push('/experts/ask'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: questions.length,
            itemBuilder: (context, i) {
              final q = questions[i];
              return _QuestionCard(question: q);
            },
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const [
            SkeletonLoader(child: SkeletonCard(lineCount: 2)),
          ],
        ),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(myQuestionsProvider),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final ExpertQuestion question;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark
        ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.8)
        : AppColors.onSurfaceVariant.withValues(alpha: 0.8);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: (question.status == QuestionStatus.answered
                            ? (isDark ? AppColors.primaryDarkMode : AppColors.primary)
                            : muted)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Text(
                    question.status.name,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat.MMMd().format(question.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              question.body,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (question.response != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                question.response!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: muted,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
