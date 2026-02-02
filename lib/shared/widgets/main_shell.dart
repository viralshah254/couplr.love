import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_tokens.dart';
import '../../features/task_bank/data/task_bank_models.dart';
import '../../features/task_bank/data/task_bank_repository.dart';

/// Persistent bottom navigation shell for main app tabs.
/// Shows clear icons, labels, and undone counts (badges); haptic feedback on tap.
class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const List<_NavItem> _items = [
    _NavItem(path: '/home', label: 'Home', icon: Icons.home_rounded),
    _NavItem(path: '/talk', label: 'Talk', icon: Icons.chat_bubble_rounded),
    _NavItem(path: '/grow', label: 'Grow', icon: Icons.eco_rounded),
    _NavItem(path: '/journal', label: 'Journal', icon: Icons.book_rounded),
    _NavItem(path: '/more', label: 'More', icon: Icons.menu_rounded),
  ];

  int _selectedIndex(GoRouterState state) {
    final path = state.uri.path;
    for (var i = 0; i < _items.length; i++) {
      if (path == _items[i].path || path.startsWith('${_items[i].path}/')) {
        return i;
      }
    }
    return 0;
  }

  int _badgeCountForIndex(int i, UndoneCounts? counts) {
    if (counts == null) return 0;
    switch (i) {
      case 0:
        return counts.total;
      case 1:
        return counts.pendingTalk;
      case 2:
        return counts.growPending;
      case 3:
        return counts.journalTodayUndone;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = GoRouterState.of(context);
    final index = _selectedIndex(state);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counts = ref.watch(undoneCountsProvider).valueOrNull;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.onSurfaceDark : AppColors.onSurface)
                  .withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final selected = index == i;
                final badgeCount = _badgeCountForIndex(i, counts);
                return _NavBarTile(
                  label: item.label,
                  icon: item.icon,
                  selected: selected,
                  badgeCount: badgeCount > 0 ? badgeCount : null,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (index != i) {
                      navigationShell.goBranch(i);
                      context.go(item.path);
                    }
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.path, required this.label, required this.icon});
  final String path;
  final String label;
  final IconData icon;
}

class _NavBarTile extends StatelessWidget {
  const _NavBarTile({
    required this.label,
    required this.icon,
    required this.selected,
    this.badgeCount,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final int? badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final color = selected
        ? primary
        : (isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant);

    return Semantics(
      selected: selected,
      button: true,
      label: badgeCount != null ? '$label, $badgeCount to do' : label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 26, color: color),
                  if (badgeCount != null && badgeCount! > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxs,
                          vertical: 1,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(AppRadii.full),
                        ),
                        child: Text(
                          badgeCount! > 99 ? '99+' : '$badgeCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
