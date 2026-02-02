import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/conversation_models.dart';
import '../../../theme/app_tokens.dart';

/// Guided conversation card: prompt, timer, voice note button, AI rewrite.
class GuidedConversationCard extends StatefulWidget {
  const GuidedConversationCard({
    super.key,
    required this.step,
    this.onRewrite,
    this.onVoiceNote,
    this.isActive = true,
  });

  final ConversationStep step;
  final Future<String?> Function(String rawText)? onRewrite;
  final VoidCallback? onVoiceNote;
  final bool isActive;

  @override
  State<GuidedConversationCard> createState() => _GuidedConversationCardState();
}

class _GuidedConversationCardState extends State<GuidedConversationCard> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _rewriting = false;
  String? _rewrittenText;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.step.timerSeconds ?? 0;
    if (widget.isActive && _secondsLeft > 0) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _requestRewrite() async {
    final raw = _textController.text.trim();
    if (raw.isEmpty || widget.onRewrite == null) return;
    HapticFeedback.lightImpact();
    setState(() => _rewriting = true);
    final result = await widget.onRewrite!(raw);
    if (!mounted) return;
    setState(() {
      _rewriting = false;
      _rewrittenText = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.step.prompt,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.step.timerSeconds != null && widget.step.timerSeconds! > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: accent),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _formatSeconds(_secondsLeft),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: accent,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Type your response...',
                border: OutlineInputBorder(),
              ),
              onTap: () => HapticFeedback.selectionClick(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (widget.onVoiceNote != null)
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onVoiceNote!();
                    },
                    icon: const Icon(Icons.mic_rounded),
                    tooltip: 'Voice note',
                  ),
                if (widget.onRewrite != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  FilledButton.icon(
                    onPressed: _rewriting ? null : _requestRewrite,
                    icon: _rewriting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(_rewriting ? 'Rewriting...' : 'AI rewrite'),
                  ),
                ],
              ],
            ),
            if (_rewrittenText != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 18, color: accent),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        _rewrittenText!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatSeconds(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
