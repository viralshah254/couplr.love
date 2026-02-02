import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/home_dashboard_repository.dart';
import 'widgets/couple_score_gauge.dart';
import 'widgets/talk_and_it_types_sheet.dart';
import '../task_bank/data/task_bank_models.dart';
import '../task_bank/data/task_bank_repository.dart';
import '../../core/accessibility/app_semantics.dart';
import '../../core/layout/app_breakpoints.dart';
import '../../theme/app_tokens.dart';
import '../../theme/theme_extensions.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/two_pane_layout.dart';
import '../talk_heal/widgets/ai_coach_fab.dart';

/// Smart home dashboard: couple score, conflict sense, growth analytics, talk-and-it-types, CTAs.
/// On tablet (wide), uses two-pane: nav list | dashboard.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final isWide = AppBreakpoints.isWide(context);

    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: const AiCoachFab(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: theme.welcomeGradientLight,
        ),
        child: SafeArea(
          child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeDashboardProvider);
          },
          child: dashboardAsync.when(
            data: (data) {
              if (data.error != null) {
                return ErrorState(
                  message: data.error!,
                  onRetry: () => ref.invalidate(homeDashboardProvider),
                );
              }
              final undoneCounts = ref.watch(undoneCountsProvider).valueOrNull;
              final coupleTasks = ref.watch(coupleTasksForHomeProvider).valueOrNull;
              if (isWide) {
                return TwoPaneLayout(
                  listPane: _HomeNavPane(),
                  detailPane: _DashboardContent(
                    data: data,
                    undoneCounts: undoneCounts,
                    coupleTasks: coupleTasks ?? [],
                  ),
                );
              }
              return _DashboardContent(
                data: data,
                undoneCounts: undoneCounts,
                coupleTasks: coupleTasks ?? [],
              );
            },
            loading: () => const _DashboardSkeleton(),
            error: (err, _) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.invalidate(homeDashboardProvider),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

/// Left nav for tablet: sections (Dashboard current, then Talk, Grow, Journal, etc.).
class _HomeNavPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        ListTile(
          leading: Icon(Icons.dashboard_rounded, color: accent),
          title: const Text('Dashboard'),
          subtitle: Text(
            'You\'re here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant,
                ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.chat_bubble_rounded),
          title: const Text('Talk & Heal'),
          onTap: () => context.push('/talk'),
        ),
        ListTile(
          leading: const Icon(Icons.eco_rounded),
          title: const Text('Grow'),
          onTap: () => context.push('/grow'),
        ),
        ListTile(
          leading: const Icon(Icons.book_rounded),
          title: const Text('Journal'),
          onTap: () => context.push('/journal'),
        ),
        ListTile(
          leading: const Icon(Icons.people_rounded),
          title: const Text('Community'),
          onTap: () => context.push('/community'),
        ),
        ListTile(
          leading: const Icon(Icons.psychology_rounded),
          title: const Text('Experts'),
          onTap: () => context.push('/experts'),
        ),
        ListTile(
          leading: const Icon(Icons.insights_rounded),
          title: const Text('Insights'),
          onTap: () => context.push('/insights'),
        ),
        ListTile(
          leading: const Icon(Icons.auto_awesome_rounded),
          title: const Text('Premium'),
          onTap: () => context.push('/paywall'),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent({
    required this.data,
    this.undoneCounts,
    this.coupleTasks = const [],
  });

  final HomeDashboardData data;
  final UndoneCounts? undoneCounts;
  final List<TaskSuggestion> coupleTasks;

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariant;
    final data = widget.data;
    final undoneCounts = widget.undoneCounts;
    final coupleTasks = widget.coupleTasks;

    return FadeTransition(
      opacity: _entranceAnimation,
      child: CustomScrollView(
      slivers: [
        // Hero: fix your relationship + use alone or invite partner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
            child: semanticHeading(
              level: 1,
              label: 'Fix your relationship. Use alone or invite your partner.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fix your relationship',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Use alone or invite your partner.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: muted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Undone strip: counts at a glance
        if (undoneCounts != null && undoneCounts.total > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _UndoneStrip(counts: undoneCounts),
            ),
          ),
        SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.sm)),
        // Invite partner: visual card when not linked
        if (!data.isPartnerLinked)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _InvitePartnerCard(onTap: () => context.push('/partner-link')),
            ),
          ),
        SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.md)),
        // Couple score: circular gauge (visual)
        if (data.coupleScore != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _CoupleScoreCard(score: data.coupleScore!, onTap: () => context.push('/talk/conflict-dashboard')),
            ),
          ),
        SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.md)),
        // Conflict sense: visual mood (tense / okay / calm)
        if (data.conflictSense != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _ConflictSenseCard(
                sense: data.conflictSense!,
                onCta: () => context.push('/talk/repair'),
              ),
            ),
          ),
        SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.md)),
        // Talk and it types: prominent CTA
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _TalkAndItTypesCard(
              onTap: () {
                TalkAndItTypesSheet.show(
                  context,
                  onSendToConflict: (text) => context.push('/talk/repair/input'),
                  onSendToJournal: (text) => context.push('/journal/new'),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
        // Growth analytics: You + Together
        if (data.growthAnalytics != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _GrowthAnalyticsRow(analytics: data.growthAnalytics!),
            ),
          ),
        SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
        // Things to do together (couple tasks from data bank)
        if (coupleTasks.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _CoupleTasksSection(
                tasks: coupleTasks,
                onSeeAll: () => context.push('/things-to-do'),
              ),
            ),
          ),
        SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
        // Today's focus (one primary CTA)
        if (data.todayFocus != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _PrimaryFocusCard(
                focus: data.todayFocus!,
                onTap: () {},
              ),
            ),
          ),
        SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.lg)),
        // Secondary: streak + pending
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _SecondaryRow(
              streak: data.streak,
              pendingCount: data.pendingSessions.length,
              onSeePending: () => context.push('/talk'),
              onTapPendingSession: (s) => context.push('/talk/session/${s.id}'),
              pendingSessions: data.pendingSessions,
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.xl)),
        // Explore grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Explore',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: muted,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: AppSpacing.sm)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 2.4,
            ),
            delegate: SliverChildListDelegate([
              _ExploreTile(label: 'Things to do', icon: Icons.check_circle_outline_rounded, onTap: () => context.push('/things-to-do')),
              _ExploreTile(label: 'Grow', icon: Icons.eco_rounded, onTap: () => context.push('/grow')),
              _ExploreTile(label: 'Journal', icon: Icons.book_rounded, onTap: () => context.push('/journal')),
              _ExploreTile(label: 'Community', icon: Icons.forum_rounded, onTap: () => context.push('/community')),
              _ExploreTile(label: 'Experts', icon: Icons.psychology_rounded, onTap: () => context.push('/experts')),
              _ExploreTile(label: 'Insights', icon: Icons.insights_rounded, onTap: () => context.push('/insights')),
              _ExploreTile(label: 'Premium', icon: Icons.auto_awesome_rounded, onTap: () => context.push('/paywall')),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    ),
    );
  }
}

/// Invite partner: visual card (two people + link). Shown when not linked.
class _InvitePartnerCard extends StatelessWidget {
  const _InvitePartnerCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_rounded, size: 32, color: primary),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: Icon(Icons.link_rounded, size: 20, color: primary.withValues(alpha: 0.8)),
                    ),
                    Icon(Icons.person_rounded, size: 32, color: primary),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite your partner',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      'Fix things together',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Undone strip: counts at a glance (Talk • Couple • Journal • Grow).
class _UndoneStrip extends StatelessWidget {
  const _UndoneStrip({required this.counts});

  final UndoneCounts counts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    final parts = <Widget>[];
    if (counts.pendingTalk > 0) {
      parts.add(_UndonePill(label: 'Talk', count: counts.pendingTalk, color: primary));
    }
    if (counts.coupleTasksUndone > 0) {
      parts.add(_UndonePill(label: 'Couple', count: counts.coupleTasksUndone, color: AppColors.secondary));
    }
    if (counts.journalTodayUndone > 0) {
      parts.add(_UndonePill(label: 'Journal', count: counts.journalTodayUndone, color: primary));
    }
    if (counts.growPending > 0) {
      parts.add(_UndonePill(label: 'Grow', count: counts.growPending, color: AppColors.accent));
    }
    if (counts.conflictResolutionPending > 0) {
      parts.add(_UndonePill(label: 'Conflict', count: counts.conflictResolutionPending, color: AppColors.error));
    }
    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(Icons.pending_actions_rounded, size: 18, color: muted),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${counts.total} to do',
              style: theme.textTheme.labelMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ...parts.expand((w) => [w, const SizedBox(width: AppSpacing.sm)]).toList()..removeLast(),
          ],
        ),
      ),
    );
  }
}

class _UndonePill extends StatelessWidget {
  const _UndonePill({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Couple tasks section: things to do together from data bank.
class _CoupleTasksSection extends StatelessWidget {
  const _CoupleTasksSection({
    required this.tasks,
    required this.onSeeAll,
  });

  final List<TaskSuggestion> tasks;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Things to do together',
              style: theme.textTheme.titleSmall?.copyWith(color: muted),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onSeeAll();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...tasks.take(3).map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _CoupleTaskTile(
                  task: task,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (task.actionRoute != null && task.actionRoute!.isNotEmpty) {
                      context.push(task.actionRoute!);
                    }
                  },
                ),
              ),
            ),
      ],
    );
  }
}

class _CoupleTaskTile extends StatelessWidget {
  const _CoupleTaskTile({required this.task, required this.onTap});

  final TaskSuggestion task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sage = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

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
                  color: sage.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(Icons.favorite_rounded, size: 22, color: sage),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: theme.textTheme.titleMedium),
                    if (task.subtitle != null)
                      Text(
                        task.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    if (task.durationMinutes != null)
                      Text(
                        '${task.durationMinutes} min',
                        style: theme.textTheme.labelSmall?.copyWith(color: muted),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Couple score: circular gauge (visual) + short label + trend.
class _CoupleScoreCard extends StatelessWidget {
  const _CoupleScoreCard({required this.score, this.onTap});

  final CoupleScore score;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sage = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            CoupleScoreGauge(
              scorePercent: score.scorePercent,
              size: 140,
              strokeWidth: 10,
              onTap: onTap,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Compatibility',
              style: theme.textTheme.labelMedium?.copyWith(color: muted),
            ),
            if (score.trendAmount != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    score.trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    size: 16,
                    color: score.trendUp ? sage : AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '${score.trendUp ? "+" : ""}${score.trendAmount}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: score.trendUp ? sage : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Conflict sense: visual mood (tense / okay / calm) + one short line + CTA.
class _ConflictSenseCard extends StatelessWidget {
  const _ConflictSenseCard({
    required this.sense,
    required this.onCta,
  });

  final ConflictSense sense;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final sage = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;
    final isCalm = sense.status == ConflictSense.statusCalm;
    final isTense = sense.status == ConflictSense.statusUnresolved;

    IconData moodIcon;
    Color moodColor;
    if (isCalm) {
      moodIcon = Icons.sentiment_satisfied_rounded;
      moodColor = sage;
    } else if (isTense) {
      moodIcon = Icons.sentiment_dissatisfied_rounded;
      moodColor = AppColors.error;
    } else {
      moodIcon = Icons.sentiment_neutral_rounded;
      moodColor = primary;
    }

    return Card(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onCta();
        },
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Icon(moodIcon, size: 40, color: moodColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sense.message,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sense.ctaLabel != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        sense.ctaLabel!,
                        style: theme.textTheme.labelMedium?.copyWith(color: primary),
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
}

/// Talk and it types: big mic visual + one line.
class _TalkAndItTypesCard extends StatelessWidget {
  const _TalkAndItTypesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Icon(Icons.mic_rounded, size: 36, color: primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Talk and it types — speak, we\'ll type it.',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Growth analytics: You + Together (visual: numbers + icons).
class _GrowthAnalyticsRow extends StatelessWidget {
  const _GrowthAnalyticsRow({required this.analytics});

  final GrowthAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final sage = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_rounded, size: 20, color: primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'You',
                        style: theme.textTheme.labelMedium?.copyWith(color: muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${analytics.selfResolutionsThisMonth}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: primary,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        'resolutions',
                        style: theme.textTheme.labelSmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, size: 18, color: sage),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        '${analytics.selfStreakDays} day streak',
                        style: theme.textTheme.labelSmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/talk/conflict-dashboard');
              },
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite_rounded, size: 20, color: sage),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Together',
                          style: theme.textTheme.labelMedium?.copyWith(color: muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${analytics.coupleJointSessionsThisMonth}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: sage,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          'sessions',
                          style: theme.textTheme.labelSmall?.copyWith(color: muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      analytics.coupleScoreTrend,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: sage,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Single prominent CTA: today's one focus — hopeful, easy to tap.
class _PrimaryFocusCard extends StatelessWidget {
  const _PrimaryFocusCard({
    required this.focus,
    this.onTap,
  });

  final TodayFocus focus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final gradient = theme.primaryGradient;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                focus.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (focus.subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  focus.subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact row: streak chip + "X things waiting" link.
class _SecondaryRow extends StatelessWidget {
  const _SecondaryRow({
    required this.streak,
    required this.pendingCount,
    required this.onSeePending,
    required this.onTapPendingSession,
    required this.pendingSessions,
  });

  final StreakInfo streak;
  final int pendingCount;
  final VoidCallback onSeePending;
  final void Function(PendingSession) onTapPendingSession;
  final List<PendingSession> pendingSessions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sage = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: sage.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department_rounded, size: 18, color: sage),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${streak.currentStreak} day streak',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        if (pendingCount > 0)
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (pendingCount == 1 && pendingSessions.isNotEmpty) {
                onTapPendingSession(pendingSessions.first);
              } else {
                onSeePending();
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              pendingCount == 1 ? '1 thing waiting' : '$pendingCount things waiting',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
      ],
    );
  }
}

/// Small tile for Explore grid — icon + label only.
class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return Card(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(
            child: SkeletonCard(titleHeight: 28, subtitleHeight: 18, lineCount: 2),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonLoader(
            child: SkeletonCard(titleHeight: 56, subtitleHeight: 20, lineCount: 2),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonLoader(
            child: SkeletonCard(titleHeight: 36, subtitleHeight: 14, lineCount: 1),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SkeletonLoader(
            child: SkeletonCard(titleHeight: 20, subtitleHeight: 14, lineCount: 1),
          ),
        ],
      ),
    );
  }
}
