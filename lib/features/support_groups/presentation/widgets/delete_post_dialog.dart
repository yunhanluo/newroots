import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Confirms deleting a post. Admins removing someone else's post must give a reason.
///
/// Returns `null` if cancelled, an empty string for a self-delete, or the
/// admin's reason when [requireReason] is true.
Future<String?> showDeletePostDialog({
  required BuildContext context,
  required bool requireReason,
}) {
  final l10n = AppLocalizations.of(context);
  if (!requireReason) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.groupsDeletePostTitle),
        content: Text(l10n.groupsDeletePostBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }

  return showDialog<String>(
    context: context,
    builder: (context) => const _AdminDeletePostDialog(),
  );
}

class _AdminDeletePostDialog extends StatefulWidget {
  const _AdminDeletePostDialog();

  @override
  State<_AdminDeletePostDialog> createState() => _AdminDeletePostDialogState();
}

class _AdminDeletePostDialogState extends State<_AdminDeletePostDialog> {
  final _reasonController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(
        () => _error = AppLocalizations.of(context).groupsRemovePostReasonRequired,
      );
      return;
    }
    Navigator.pop(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.groupsRemovePostTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.groupsRemovePostBody),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              maxLength: 400,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.groupsRemovePostReason,
                hintText: l10n.groupsRemovePostHint,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.groupsRemovePostAction),
        ),
      ],
    );
  }
}
