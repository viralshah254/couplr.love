import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../data/journal_models.dart';
import '../data/journal_repository.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/theme_extensions.dart';

/// New journal entry: title, body, private toggle, photo picker and voice note.
class JournalNewEntryScreen extends ConsumerStatefulWidget {
  const JournalNewEntryScreen({super.key});

  @override
  ConsumerState<JournalNewEntryScreen> createState() => _JournalNewEntryScreenState();
}

class _JournalNewEntryScreenState extends ConsumerState<JournalNewEntryScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _audioRecorder = AudioRecorder();
  bool _isPrivate = false;
  bool _saving = false;
  String? _photoPath;
  String? _audioPath;
  bool _isRecording = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, imageQuality: 85);
    if (xFile != null && mounted) {
      setState(() => _photoPath = xFile.path);
    }
  }

  Future<void> _toggleVoiceNote() async {
    HapticFeedback.lightImpact();
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (mounted && path != null) {
        setState(() {
          _isRecording = false;
          _audioPath = path;
        });
      }
      return;
    }
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/journal_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder.start(const RecordConfig(), path: path);
    if (mounted) {
      setState(() => _isRecording = true);
    }
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
      hasPhoto: _photoPath != null,
      photoUrl: _photoPath,
      hasAudio: _audioPath != null,
      audioUrl: _audioPath,
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
    final theme = Theme.of(context);
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
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.welcomeGradientLight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                  hintText: "What's on your mind?",
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.lg),
              SwitchListTile(
                title: const Text('Private (only you)'),
                subtitle: Text(
                  _isPrivate ? "Partner won't see this" : 'Visible to both',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.image_rounded, size: 20),
                label: Text(_photoPath != null ? 'Photo added' : 'Add photo'),
              ),
              if (_photoPath != null) ...[
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: Image.file(
                    File(_photoPath!),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _toggleVoiceNote,
                icon: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded, size: 20),
                label: Text(
                  _isRecording ? 'Stop recording' : (_audioPath != null ? 'Voice note added' : 'Add voice note'),
                ),
              ),
              if (_isRecording)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'Recording…',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
