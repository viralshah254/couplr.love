import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/onboarding_repository.dart';
import '../../theme/app_tokens.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

const _pages = [
  _OnboardingPage(
    title: 'Grow Together',
    subtitle: 'Invite your partner into a shared space. Set intentions, track progress, and celebrate wins as a team.',
    icon: Icons.eco_rounded,
  ),
  _OnboardingPage(
    title: 'AI Coach',
    subtitle: 'Guided conversations and a gentle mediator when things get tough. Resolve conflict and communicate better.',
    icon: Icons.psychology_rounded,
  ),
  _OnboardingPage(
    title: 'Private Space',
    subtitle: 'Your data stays yours. End-to-end encryption where it matters. We never sell or share your relationship data.',
    icon: Icons.lock_rounded,
  ),
];

/// Onboarding carousel: 3 screens (Grow Together, AI Coach, Private Space).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  Future<void> _complete() async {
    final repo = await ref.read(onboardingRepositoryProvider.future);
    await repo.setOnboardingComplete();
    if (!mounted) return;
    context.go('/auth');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            p.icon,
                            size: 80,
                            color: isDark
                                ? AppColors.primaryDarkMode
                                : AppColors.primary,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            p.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            p.subtitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDark
                                      ? AppColors.onSurfaceVariantDark
                                      : AppColors.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: AppMotion.normal,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.full),
                        color: _currentPage == i
                            ? (isDark
                                ? AppColors.primaryDarkMode
                                : AppColors.primary)
                            : (isDark
                                ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.5)
                                : AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: AppMotion.normal,
                          curve: AppMotion.easeInOut,
                        );
                      } else {
                        _complete();
                      }
                    },
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Next' : 'Get started',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
