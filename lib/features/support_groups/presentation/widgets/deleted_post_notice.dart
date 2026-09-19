import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/support_group.dart';
import '../../../../core/services/support_group_service.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'appeal_post_dialog.dart';

/// In-app notice when an admin hid the user's post, with an appeal option.
class DeletedPostNotice extends ConsumerWidget {
  const DeletedPostNotice({super.key, required this.notice});

  final PostDeletionNotice notice;

  static const _removed = Color(0xFFB3261E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = notice.appealStatus;
    final approved = status == PostAppealStatus.approved;
    final color = approved ? kBrandGreen : _removed;
    final deadline = notice.purgeAt == null
        ? ''
        : DateFormat('MMM d').format(notice.purgeAt!.toLocal());
    final reason = notice.reason.trim();
    final postTitle = notice.postTitle;
    final groupTitle = notice.groupTitle;
    final String title;
    var body = '';
    switch (status) {
      case PostAppealStatus.pending:
        title = l10n.groupsNoticeAppealReviewing;
        body = l10n.groupsNoticeStillHidden(postTitle, groupTitle);
      case PostAppealStatus.approved:
        title = l10n.groupsNoticePostBack;
        body = l10n.groupsNoticeVisibleAgain(postTitle, groupTitle);
      case PostAppealStatus.denied:
        title = l10n.groupsNoticeAppealDeclined;
        body = l10n.groupsNoticeWasRemoved(postTitle, groupTitle);
      case PostAppealStatus.expired:
        title = l10n.groupsNoticePostRemovedTitle;
        body = l10n.groupsNoticeDeletedAfterWindow(postTitle, groupTitle);
      case PostAppealStatus.open:
      case PostAppealStatus.none:
        title = l10n.groupsNoticePostHiddenTitle;
        body = reason.isNotEmpty
            ? l10n.groupsNoticeHiddenReason(postTitle, groupTitle, reason)
            : l10n.groupsNoticeHiddenAdmin(postTitle, groupTitle);
        if (notice.canAppeal && deadline.isNotEmpty) {
          body = '$body ${l10n.groupsNoticeAppealUntil(deadline)}';
        }
    }

    final canDismiss = !notice.canAppeal;

    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8),
                  child: Icon(
                    approved
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    color: color,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canDismiss)
                  IconButton(
                    onPressed: () => ref
                        .read(supportGroupServiceProvider)
                        .markPostDeletionNoticeSeen(notice.id),
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: l10n.groupsNoticeDismiss,
                  ),
              ],
            ),
            if (notice.canAppeal)
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 8, 12, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: kBrandGreen,
                    ),
                    onPressed: () => _appeal(context, ref),
                    child: Text(l10n.groupsAppeal),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _appeal(BuildContext context, WidgetRef ref) async {
    final message = await showAppealPostDialog(context: context);
    if (message == null || !context.mounted) return;
    try {
      await ref.read(supportGroupServiceProvider).appealPostRemoval(
            groupId: notice.groupId,
            postId: notice.postId,
            message: message,
          );
    } on SupportGroupException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }
}
