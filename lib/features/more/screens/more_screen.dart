import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:couplr/theme/app_tokens.dart';

import '../../../shared/widgets/animated_list_tile.dart';

/// More: Community, Experts, Insights, Premium. Shown when "More" tab is selected.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'More',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Community, experts, insights, and premium.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AnimatedListTile(
                  index: 0,
                  child: _MoreTile(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    subtitle: 'Settings & account',
                    accent: isDark ? AppColors.primaryDarkMode : AppColors.primary,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/profile');
                    },
                  ),
                ),
                AnimatedListTile(
                  index: 1,
                  child: _MoreTile(
                    icon: Icons.people_rounded,
                    title: 'Community',
                    subtitle: 'Anonymous forum & support',
                    accent: isDark ? AppColors.secondaryDark : AppColors.secondary,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/community');
                    },
                  ),
                ),
                AnimatedListTile(
                  index: 2,
                  child: _MoreTile(
                    icon: Icons.psychology_rounded,
                    title: 'Experts',
                    subtitle: 'Ask an expert & live rooms',
                    accent: isDark ? AppColors.secondaryDark : AppColors.secondary,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/experts');
                    },
                  ),
                ),
                AnimatedListTile(
                  index: 3,
                  child: _MoreTile(
                    icon: Icons.insights_rounded,
                    title: 'Insights',
                    subtitle: 'Mood, conflicts, appreciation',
                    accent: isDark ? AppColors.primaryDarkMode : AppColors.primary,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/insights');
                    },
                  ),
                ),
                AnimatedListTile(
                  index: 4,
                  child: _MoreTile(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Premium',
                    subtitle: 'Unlock full experience',
                    accent: isDark ? AppColors.primaryDarkMode : AppColors.primary,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/paywall');
                    },
                  ),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: AppElevation.sm,
      shadowColor: (isDark ? AppColors.onSurfaceDark : AppColors.onSurface)
          .withValues(alpha: 0.08),
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
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
