import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable confirmation dialog for destructive actions (e.g. delete).
/// Returns true if user confirmed, false if cancelled.
Future<bool> showConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
  bool isDanger = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop(false);
          },
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop(true);
          },
          style: isDanger
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
