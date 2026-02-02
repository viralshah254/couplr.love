import 'package:flutter/material.dart';

/// Design tokens: colors, typography, spacing, radii, elevation, motion.
/// Semantic roles and theming extensions build on these.

// ——— Colors (warm, welcoming palette — blush rose + sage + cream)
class AppColors {
  AppColors._();

  // Primary: warm blush rose — inviting, not harsh
  static const Color primary = Color(0xFFC17B86);
  static const Color primaryLight = Color(0xFFE0A5AE);
  static const Color primaryDark = Color(0xFFA05D68);

  // Secondary: soft sage — calm, supportive
  static const Color secondary = Color(0xFF6B8B7A);
  static const Color secondaryLight = Color(0xFF8FAA9A);
  static const Color secondaryDark = Color(0xFF556D5E);

  // Surfaces: warm cream / ivory (welcoming, easy on the eyes)
  static const Color surface = Color(0xFFF8F6F2);
  static const Color surfaceVariant = Color(0xFFEFEBE6);
  static const Color background = Color(0xFFF5F1EC);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF2A2D2A);
  static const Color onSurface = Color(0xFF2C2A28);
  static const Color onSurfaceVariant = Color(0xFF5E5B58);
  static const Color onBackground = Color(0xFF2C2A28);

  static const Color error = Color(0xFFC45C5C);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color outline = Color(0xFFD8D3CC);
  static const Color outlineVariant = Color(0xFFE8E4DE);

  // Accent: soft honey / gold — warmth and positivity
  static const Color accent = Color(0xFFC4A574);
  static const Color accentLight = Color(0xFFDDC9A0);

  // Dark mode: warm charcoal (not cold blue-grey)
  static const Color primaryDarkMode = Color(0xFFE0A5AE);
  static const Color surfaceDark = Color(0xFF25232C);
  static const Color surfaceVariantDark = Color(0xFF2E2C36);
  static const Color backgroundDark = Color(0xFF1C1B22);
  static const Color onSurfaceDark = Color(0xFFF2EFEA);
  static const Color onSurfaceVariantDark = Color(0xFFB0ADB5);
  static const Color accentDarkMode = Color(0xFFDDC9A0);
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

// ——— Radii (rounded, friendly cards and chips)
class AppRadii {
  AppRadii._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double full = 9999;
}

// ——— Elevation (soft shadows for depth without harshness)
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
