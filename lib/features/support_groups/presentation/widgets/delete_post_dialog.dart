import 'package:flutter/material.dart';

/// Confirms deleting a post. Admins removing someone else's post must give a reason.
///
/// Returns `null` if cancelled, an empty string for a self-delete, or the
/// admin's reason when [requireReason] is true.
Future<String?> showDeletePostDialog({
  required BuildContext context,
  required bool requireReason,
}) {
  if (!requireReason) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this post?'),
        content: const Text(
          'Replies will be removed too. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Delete'),
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
      setState(() => _error = 'Please say why this post is being removed.');
      return;
    }
    Navigator.pop(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remove this post?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The post will be hidden from the group. The author has 7 days to appeal. If they do not, or a moderator declines the appeal, it will be deleted.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              maxLength: 400,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'e.g. This broke the group rules.',
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
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Remove post'),
        ),
      ],
    );
  }
}
