import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/journal_repository.dart';
import '../widgets/journal_entry_detail_content.dart';
import '../../../theme/theme_extensions.dart';
import '../../../shared/widgets/confirm_delete_dialog.dart';

/// Journal entry detail: full body, photos, audio, encryption indicator.
/// Includes delete with confirmation (deletion UX).
class JournalEntryDetailScreen extends ConsumerWidget {
  const JournalEntryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('Entry'),
        ),
        leading: Semantics(
          label: 'Back',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        actions: [
          Semantics(
            label: 'Delete this entry',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _onDelete(context, ref),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: theme.welcomeGradientLight),
        child: JournalEntryDetailContent(entryId: entryId),
      ),
    );
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Delete entry?',
      message: 'This cannot be undone. The entry will be permanently removed.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !context.mounted) return;
    HapticFeedback.mediumImpact();
    await ref.read(journalRepositoryProvider).deleteEntry(entryId);
    ref.invalidate(journalEntriesProvider);
    ref.invalidate(journalEntryDetailProvider(entryId));
    ref.invalidate(journalDatesWithEntriesProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Entry deleted')),
    );
    context.pop();
  }
}
