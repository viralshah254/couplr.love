import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:couplr/theme/app_tokens.dart';
import 'package:couplr/theme/theme_extensions.dart';

import '../data/premium_models.dart';
import '../data/premium_repository.dart';

/// Paywall with elegant blurred preview and trial CTA.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String? _selectedPackageId;
  bool _purchasing = false;
  bool _restoring = false;

  Future<void> _purchase(PremiumRepository repo) async {
    final id = _selectedPackageId;
    if (id == null) return;
    HapticFeedback.lightImpact();
    setState(() => _purchasing = true);
    try {
      await repo.purchasePackage(id);
      if (!mounted) return;
      context.pop(true);
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('Purchase failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore(PremiumRepository repo) async {
    HapticFeedback.lightImpact();
    setState(() => _restoring = true);
    try {
      await repo.restorePurchases();
      if (!mounted) return;
      final status = await repo.status;
      if (!mounted) return;
      if (status == SubscriptionStatus.subscribed ||
          status == SubscriptionStatus.inTrial) {
        context.pop(true);
      } else {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('No purchases to restore')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ref.watch(premiumRepositoryProvider);
    final offeringAsync = ref.watch(currentOfferingProvider);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Warm gradient behind blur
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(gradient: theme.welcomeGradientLight),
          ),
          // Blurred preview background (premium content tease)
          _BlurredPreviewBackground(isDark: isDark),
          // Content
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => context.pop(false),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: offeringAsync.when(
                      data: (offering) {
                        if (offering == null || offering.packages.isEmpty) {
                          return const Center(
                            child: Text('No offerings available'),
                          );
                        }
                        final best = offering.packages
                            .where((p) => p.isBestValue)
                            .toList();
                        _selectedPackageId ??= best.isNotEmpty
                            ? best.first.id
                            : offering.packages.first.id;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              offering.paywallTitle ?? 'Unlock Premium',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              offering.paywallSubtitle ??
                                  'Get the most out of Couplr.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: isDark
                                        ? AppColors.onSurfaceVariantDark
                                        : AppColors.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            ...offering.packages.map(
                              (pkg) => _PackageTile(
                                package: pkg,
                                selectedPackageId: _selectedPackageId,
                                accent: accent,
                                onTap: () => setState(
                                  () => _selectedPackageId = pkg.id,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            FilledButton(
                              onPressed: _purchasing
                                  ? null
                                  : () => _purchase(repo),
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                              ),
                              child: _purchasing
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Continue'),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              onPressed: _restoring ? null : () => _restore(repo),
                              child: _restoring
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Restore purchases'),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Center(
                        child: Text('Error: $e'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Blurred background suggesting premium content.
class _BlurredPreviewBackground extends StatelessWidget {
  const _BlurredPreviewBackground({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1C1C1E),
                  const Color(0xFF2C2C2E),
                  const Color(0xFF1C1C1E),
                ]
              : [
                  const Color(0xFFF8F6F4),
                  const Color(0xFFEFEBE7),
                  const Color(0xFFE8E4E0),
                ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fake premium content preview (cards, text)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 64,
                    color: (isDark ? AppColors.primaryDarkMode : AppColors.primary)
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'AI insights • Conflict repair • Private journal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: (isDark
                                  ? AppColors.onSurfaceVariantDark
                                  : AppColors.onSurfaceVariant)
                              .withValues(alpha: 0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Blur overlay
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: (isDark ? const Color(0xFF121214) : Colors.white)
                    .withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({
    required this.package,
    required this.selectedPackageId,
    required this.accent,
    required this.onTap,
  });

  final PremiumPackage package;
  final String? selectedPackageId;
  final Color accent;
  final VoidCallback onTap;

  bool get isSelected => selectedPackageId == package.id;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        borderRadius: BorderRadius.circular(AppRadii.md),
        color: isSelected
            ? accent.withValues(alpha: 0.15)
            : Theme.of(context).cardTheme.color,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? accent : (Theme.of(context).colorScheme.outline),
                          width: 2,
                        ),
                        color: isSelected ? accent.withValues(alpha: 0.3) : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.circle, size: 12, color: accent)
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            package.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (package.isBestValue) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xs),
                              ),
                              child: Text(
                                'Best value',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: accent),
                              ),
                            ),
                          ],
                          if (package.trialDays != null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${package.trialDays}-day free trial',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: accent,
                                  ),
                            ),
                          ],
                        ],
                      ),
                      if (package.subtitle.isNotEmpty)
                        Text(
                          package.subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.8),
                              ),
                        ),
                    ],
                  ),
                ),
                Text(
                  package.price,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: accent,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
