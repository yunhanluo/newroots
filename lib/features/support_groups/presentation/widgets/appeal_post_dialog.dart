import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.groupsAppealTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.groupsAppealIntro),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              maxLength: 400,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.groupsAppealLabel,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(l10n.groupsSendAppeal),
        ),
      ],
    );
  }
}
