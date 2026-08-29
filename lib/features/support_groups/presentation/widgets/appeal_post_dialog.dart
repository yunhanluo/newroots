import 'package:flutter/material.dart';

/// Optional message when appealing an admin-hidden post.
///
/// Returns `null` if cancelled, otherwise the (possibly empty) appeal text.
Future<String?> showAppealPostDialog({required BuildContext context}) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _AppealPostDialog(),
  );
}

class _AppealPostDialog extends StatefulWidget {
  const _AppealPostDialog();

  @override
  State<_AppealPostDialog> createState() => _AppealPostDialogState();
}

class _AppealPostDialogState extends State<_AppealPostDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Appeal this removal?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A moderator will review it. If they agree, the post will '
              'show in the group again.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              maxLength: 400,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Why should it stay? (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Send appeal'),
        ),
      ],
    );
  }
}
