import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/support_group.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/services/support_group_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'appeal_post_dialog.dart';

/// Status when an admin has hidden a post pending appeal or deletion.
class RemovedPostBanner extends ConsumerWidget {
  const RemovedPostBanner({
    super.key,
    required this.post,
    this.compact = false,
    this.isAuthor = false,
  });

  final GroupPost post;
  final bool compact;
  final bool isAuthor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!post.removed) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final pending = post.appealStatus == PostAppealStatus.pending;
    final color = kBrandGreen;
    final deadline = post.purgeAt == null
        ? ''
        : DateFormat('MMM d').format(post.purgeAt!.toLocal());
    final title = pending
        ? l10n.groupsAppealSent
        : l10n.groupsModerationHidden;
    var body = post.removedReason.trim().isNotEmpty
        ? l10n.groupsReasonPrefix(post.removedReason)
        : l10n.groupsHiddenByAdmin;
    if (!pending && deadline.isNotEmpty) {
      body = '$body ${l10n.groupsDeletedAfter(deadline)}';
    } else if (pending) {
      body = '$body ${l10n.groupsAppealPendingReview}';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12, compact ? 8 : 10, 12, compact ? 8 : 10),
      decoration: BoxDecoration(
        color: const Color(0xFFB3261E).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                pending
                    ? Icons.hourglass_top_outlined
                    : Icons.visibility_off_outlined,
                size: compact ? 16 : 18,
                color: const Color(0xFFB3261E),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: compact ? 12 : 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB3261E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: compact ? 12 : 13,
                        height: 1.35,
                        color: Colors.black87.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isAuthor && post.canAppealRemoval) ...[
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                backgroundColor: color,
              ),
              onPressed: () => _appeal(context, ref),
              child: Text(l10n.groupsAppeal),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _appeal(BuildContext context, WidgetRef ref) async {
    final message = await showAppealPostDialog(context: context);
    if (message == null || !context.mounted) return;
    try {
      await ref.read(supportGroupServiceProvider).appealPostRemoval(
            groupId: post.groupId,
            postId: post.id,
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
