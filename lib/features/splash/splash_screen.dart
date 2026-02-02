import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/data/auth_service.dart';
import '../onboarding/data/onboarding_repository.dart';
import '../partner_link/data/partner_link_repository.dart';
import '../../theme/app_tokens.dart';

/// Animated splash with gradient background and heartbeat pulse.
/// Routes based on auth/onboarding/partner state after a short delay.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _redirectAfterDelay();
  }

  Future<void> _redirectAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    _redirect();
  }

  void _redirect() async {
    final onboardingComplete = await ref.read(onboardingCompleteProvider.future);
    if (!mounted) return;
    if (!onboardingComplete) {
      context.go('/onboarding');
      return;
    }

    final auth = ref.read(authStateProvider).valueOrNull;
    final isLoggedIn = auth != null;
    if (!mounted) return;
    if (!isLoggedIn) {
      context.go('/auth');
      return;
    }

    final partnerState = await ref.read(partnerLinkStateProvider.future);
    if (!mounted) return;
    if (!partnerState.isLinked) {
      context.go('/partner-link');
      return;
    }
    context.go('/home');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.primaryDarkMode.withValues(alpha: 0.4),
                      AppColors.surfaceDark,
                      AppColors.secondaryDark.withValues(alpha: 0.3),
                    ]
                  : [
                      AppColors.primaryLight.withValues(alpha: 0.5),
                      AppColors.surface,
                      AppColors.secondaryLight.withValues(alpha: 0.6),
                    ],
            ),
          ),
          child: Center(
            child: ScaleTransition(
              scale: _pulseScale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Couplr',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Icon(
                    Icons.favorite_rounded,
                    size: 48,
                    color: isDark
                        ? AppColors.secondaryDark
                        : AppColors.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
