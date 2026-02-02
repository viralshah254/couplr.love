import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Semantic theme extensions for Couplr. Use design tokens via AppColors, AppSpacing, AppRadii, AppMotion.
extension CouplrThemeExtensions on ThemeData {
  /// Convenience: standard card padding from tokens.
  EdgeInsets get cardPadding => const EdgeInsets.all(AppSpacing.md);
  /// Convenience: standard card radius from tokens.
  double get cardRadius => AppRadii.lg;

  /// Warm welcome gradient (light): cream to soft peach.
  LinearGradient get welcomeGradientLight => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          brightness == Brightness.light ? AppColors.background : AppColors.backgroundDark,
          (brightness == Brightness.light ? AppColors.primary : AppColors.primaryDarkMode)
              .withValues(alpha: 0.06),
        ],
      );

  /// Accent gradient for CTAs (primary → primaryLight).
  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: brightness == Brightness.dark
            ? [AppColors.primaryDarkMode, AppColors.primaryDarkMode.withValues(alpha: 0.85)]
            : [AppColors.primary, AppColors.primaryLight],
      );
}
