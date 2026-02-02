import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_tokens.dart';

/// Light and dark ThemeData built from design tokens.
class AppThemeData {
  const AppThemeData({
    required this.light,
    required this.dark,
    required this.mode,
  });

  final ThemeData light;
  final ThemeData dark;
  final ThemeMode mode;

  AppThemeData copyWith({ThemeMode? mode}) {
    return AppThemeData(
      light: light,
      dark: dark,
      mode: mode ?? this.mode,
    );
  }

  static ThemeData _buildLight() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        error: AppColors.error,
        onError: AppColors.onError,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.onSurface),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.onSurface),
        displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.onSurface),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.onSurface),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.onSurface),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.onSurface),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.onSurface),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.onSurface),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.onSurface),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.onSurface),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.onSurface),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppElevation.sm,
        shadowColor: AppColors.onSurface.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        margin: const EdgeInsets.all(AppSpacing.sm),
        clipBehavior: Clip.antiAlias,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
    );
  }

  static ThemeData _buildDark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDarkMode,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.onSecondary,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        error: AppColors.error,
        onError: AppColors.onError,
        outline: AppColors.outlineVariant,
        outlineVariant: AppColors.outline,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.onSurfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryDarkMode,
        unselectedItemColor: AppColors.onSurfaceVariantDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.onSurfaceDark),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.onSurfaceDark),
        displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.onSurfaceDark),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.onSurfaceDark),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.onSurfaceDark),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.onSurfaceDark),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.onSurfaceDark),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.onSurfaceDark),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.onSurfaceDark),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceDark),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceDark),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariantDark),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.onSurfaceDark),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariantDark),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariantDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: AppElevation.sm,
        shadowColor: AppColors.onSurfaceDark.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        margin: const EdgeInsets.all(AppSpacing.sm),
        clipBehavior: Clip.antiAlias,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.onSurfaceVariantDark.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkMode,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryDarkMode,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
    );
  }
}

final appThemeProvider = StateProvider<AppThemeData>((ref) {
  return AppThemeData(
    light: AppThemeData._buildLight(),
    dark: AppThemeData._buildDark(),
    mode: ThemeMode.system,
  );
});
