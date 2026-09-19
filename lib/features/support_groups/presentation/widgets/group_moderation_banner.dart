import 'package:flutter/material.dart';

import '../../../../core/models/support_group.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Status banner for a post or reply that is still being checked or was hidden.
class GroupModerationBanner extends StatelessWidget {
  const GroupModerationBanner({
    super.key,
    required this.moderation,
    this.compact = false,
    this.isAdmin = false,
  });

  final GroupModeration moderation;
  final bool compact;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    if (moderation.isApproved) return const SizedBox.shrink();

    final pending = moderation.isPending;
    final color = pending ? kBrandGreen : const Color(0xFFB3261E);
    final l10n = AppLocalizations.of(context);
    final title = pending
        ? l10n.groupsModerationChecking
        : l10n.groupsModerationHidden;
    var body = pending
        ? l10n.groupsModerationPendingBody
        : _hiddenReason(l10n, moderation);
    if (isAdmin && moderation.isRejected && moderation.category.isNotEmpty) {
      body = '$body (admin: ${moderation.category})';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12, compact ? 8 : 10, 12, compact ? 8 : 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            pending ? Icons.hourglass_top_outlined : Icons.visibility_off_outlined,
            size: compact ? 16 : 18,
            color: color,
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
                    color: color,
                  ),
                ),
                if (body.isNotEmpty) ...[
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _hiddenReason(AppLocalizations l10n, GroupModeration moderation) {
  return switch (moderation.category) {
    'pii' => l10n.groupsModerationHiddenPii,
    'scam' => l10n.groupsModerationHiddenScam,
    'hate' => l10n.groupsModerationHiddenHate,
    'harassment' => l10n.groupsModerationHiddenHarassment,
    'sexual' => l10n.groupsModerationHiddenSexual,
    'self_harm' => l10n.groupsModerationHiddenSelfHarm,
    'violence' => l10n.groupsModerationHiddenViolence,
    _ => l10n.groupsModerationHiddenGeneric,
  };
}
