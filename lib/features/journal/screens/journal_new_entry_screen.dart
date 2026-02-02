import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/journal_models.dart';
import '../data/journal_repository.dart';
import '../../../theme/app_tokens.dart';

/// New journal entry: title, body, private toggle, placeholders for photo/audio.
class JournalNewEntryScreen extends ConsumerStatefulWidget {
  const JournalNewEntryScreen({super.key});

  @override
  ConsumerState<JournalNewEntryScreen> createState() => _JournalNewEntryScreenState();
}

class _JournalNewEntryScreenState extends ConsumerState<JournalNewEntryScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isPrivate = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _saving = true);
    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: _bodyController.text.trim().isEmpty ? null : _bodyController.text.trim(),
      createdAt: DateTime.now(),
      isPrivate: _isPrivate,
      hasPhoto: false,
      hasAudio: false,
      isEncrypted: true,
      authorId: 'user-1',
    );
    await ref.read(journalRepositoryProvider).addEntry(entry);
    if (!mounted) return;
    ref.invalidate(journalEntriesProvider);
    ref.invalidate(journalDatesWithEntriesProvider);
    setState(() => _saving = false);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New entry'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Give your entry a title',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Write here',
                hintText: 'What\'s on your mind?',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              title: const Text('Private (only you)'),
              subtitle: Text(
                _isPrivate ? 'Partner won\'t see this' : 'Visible to both',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _isPrivate,
              onChanged: (v) => setState(() => _isPrivate = v),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.image_rounded, size: 20),
              label: const Text('Add photo'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mic_rounded, size: 20),
              label: const Text('Add voice note'),
            ),
          ],
        ),
      ),
    );
  }
}
