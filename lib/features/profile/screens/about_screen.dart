import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_tokens.dart';

/// About: version, terms, privacy policy, support.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'Couplr',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Version $appVersion',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _AboutTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              HapticFeedback.lightImpact();
              // Placeholder: open URL or in-app terms
            },
          ),
          _AboutTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
          _AboutTile(
            icon: Icons.help_outline_rounded,
            title: 'Support',
            subtitle: 'Get help or contact us',
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: 22, color: accent),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
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
