import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'ai_coach_sheet.dart';
import '../../../theme/app_tokens.dart';

/// Floating AI coach FAB: opens sheet with Rewrite, De-escalate, Prepare for talk, Insight preview.
class AiCoachFab extends StatelessWidget {
  const AiCoachFab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        AiCoachSheet.show(
          context,
          onRewrite: () => _showSnack(context, 'Rewrite — open a conversation to use this'),
          onDeEscalate: () => _showSnack(context, 'De-escalate — open a conversation to use this'),
          onPrepareForTalk: () => context.push('/talk/repair'),
          onInsightPreview: () => _showSnack(context, 'Insight preview — coming soon'),
        );
      },
      backgroundColor: accent,
      icon: const Icon(Icons.psychology_rounded),
      label: const Text('AI Coach'),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}
