import 'package:flutter/material.dart';

/// Design tokens: colors, typography, spacing, radii, elevation, motion.
/// Semantic roles and theming extensions build on these.

// ——— Colors (slightly darker, clean palette — soft rose + sage-teal)
class AppColors {
  AppColors._();

  // Primary: soft rose — a bit deeper
  static const Color primary = Color(0xFFB86B76);
  static const Color primaryLight = Color(0xFFD4959E);
  static const Color primaryDark = Color(0xFF965660);

  // Secondary: sage-teal — a bit deeper
  static const Color secondary = Color(0xFF5C7D6E);
  static const Color secondaryLight = Color(0xFF7D9D8E);
  static const Color secondaryDark = Color(0xFF4A6658);

  // Surfaces: slightly darker warm grey (not bright white)
  static const Color surface = Color(0xFFF2EFEA);
  static const Color surfaceVariant = Color(0xFFE8E4DE);
  static const Color background = Color(0xFFEDE9E4);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF2D2D2A);
  static const Color onSurface = Color(0xFF2A2826);
  static const Color onSurfaceVariant = Color(0xFF5A5754);
  static const Color onBackground = Color(0xFF2A2826);

  static const Color error = Color(0xFFC45C5C);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color outline = Color(0xFFCEC9C2);
  static const Color outlineVariant = Color(0xFFE0DCD6);

  // Accent: soft honey gold
  static const Color accent = Color(0xFFB8956A);
  static const Color accentLight = Color(0xFFD4BC90);

  // Dark mode: soft charcoal
  static const Color primaryDarkMode = Color(0xFFD4959E);
  static const Color surfaceDark = Color(0xFF1E1D26);
  static const Color surfaceVariantDark = Color(0xFF282730);
  static const Color backgroundDark = Color(0xFF16151C);
  static const Color onSurfaceDark = Color(0xFFF0EDEA);
  static const Color onSurfaceVariantDark = Color(0xFFA8A5B0);
  static const Color accentDarkMode = Color(0xFFD4BC90);
}

// ——— Typography (serif headlines = warmth; rounded sans = friendly)
class AppTypography {
  AppTypography._();

  static const String _serif = 'Georgia';
  static const String _sans = 'SF Pro Display';

  static TextStyle get displayLarge => const TextStyle(
        fontFamily: _serif,
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      );
  static TextStyle get displayMedium => const TextStyle(
        fontFamily: _serif,
        fontSize: 32,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get displaySmall => const TextStyle(
        fontFamily: _serif,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get headlineLarge => const TextStyle(
        fontFamily: _serif,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get headlineMedium => const TextStyle(
        fontFamily: _serif,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get headlineSmall => const TextStyle(
        fontFamily: _serif,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get titleLarge => const TextStyle(
        fontFamily: _sans,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get titleMedium => const TextStyle(
        fontFamily: _sans,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get titleSmall => const TextStyle(
        fontFamily: _sans,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: _sans,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );
  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: _sans,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );
  static TextStyle get bodySmall => const TextStyle(
        fontFamily: _sans,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );
  static TextStyle get labelLarge => const TextStyle(
        fontFamily: _sans,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get labelMedium => const TextStyle(
        fontFamily: _sans,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get labelSmall => const TextStyle(
        fontFamily: _sans,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      );
}

// ——— Spacing
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

// ——— Radii (rounded cards)
class AppRadii {
  AppRadii._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;
}

// ——— Elevation
class AppElevation {
  AppElevation._();

  static const double none = 0;
  static const double sm = 1;
  static const double md = 2;
  static const double lg = 4;
}

// ——— Motion curves
class AppMotion {
  AppMotion._();

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
