import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_tokens.dart';

/// Bottom sheet: "Talk and it types" — mic, listening state, transcribed text.
/// Mock STT: tap to simulate listening then show placeholder text; real STT can be wired later.
class TalkAndItTypesSheet extends StatefulWidget {
  const TalkAndItTypesSheet({
    super.key,
    this.onTranscribed,
    this.onSendToConflict,
    this.onSendToJournal,
  });

  final void Function(String text)? onTranscribed;
  final void Function(String text)? onSendToConflict;
  final void Function(String text)? onSendToJournal;

  static Future<String?> show(
    BuildContext context, {
    void Function(String text)? onTranscribed,
    void Function(String text)? onSendToConflict,
    void Function(String text)? onSendToJournal,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TalkAndItTypesSheet(
        onTranscribed: onTranscribed,
        onSendToConflict: onSendToConflict,
        onSendToJournal: onSendToJournal,
      ),
    );
  }

  @override
  State<TalkAndItTypesSheet> createState() => _TalkAndItTypesSheetState();
}

class _TalkAndItTypesSheetState extends State<TalkAndItTypesSheet>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _transcribed = '';
  final _textController = TextEditingController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isListening = true;
      _transcribed = '';
      _textController.clear();
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _transcribed = 'I felt a bit unheard when we talked about the weekend. I\'d like us to check in more often.';
      _textController.text = _transcribed;
    });
  }

  void _stopListening() {
    HapticFeedback.lightImpact();
    setState(() => _isListening = false);
  }

  void _done() {
    HapticFeedback.lightImpact();
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onTranscribed?.call(text);
      Navigator.of(context).pop(text);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final muted = isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: muted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Talk and it types',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tap the mic and speak. Your words appear here — use them for a check-in, conflict input, or journal.',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isListening ? _stopListening : _startListening,
                        onLongPress: _startListening,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 80 + (_isListening ? _pulseController.value * 12 : 0),
                          height: 80 + (_isListening ? _pulseController.value * 12 : 0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening
                                ? primary.withValues(alpha: 0.2)
                                : primary.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                            size: 36,
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  _isListening ? 'Listening...' : 'Tap to talk',
                  style: theme.textTheme.labelMedium?.copyWith(color: muted),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'What you say will appear here...',
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                onChanged: (v) => setState(() => _transcribed = v),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (_transcribed.trim().isNotEmpty) ...[
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onSendToConflict?.call(_textController.text.trim());
                        Navigator.of(context).pop(_textController.text.trim());
                      },
                      icon: const Icon(Icons.handshake_rounded, size: 20),
                      label: const Text('Use for conflict'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onSendToJournal?.call(_textController.text.trim());
                        Navigator.of(context).pop(_textController.text.trim());
                      },
                      icon: const Icon(Icons.book_rounded, size: 20),
                      label: const Text('Save to journal'),
                    ),
                  ],
                  const Spacer(),
                  FilledButton(
                    onPressed: _done,
                    child: const Text('Done'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
