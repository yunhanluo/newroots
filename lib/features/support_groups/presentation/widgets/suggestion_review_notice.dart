import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/support_group.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/support_group_service.dart';
import '../../../../core/theme/brand_colors.dart';

/// In-app notice when an admin has approved or declined a user's suggestion.
class SuggestionReviewNotice extends ConsumerWidget {
  const SuggestionReviewNotice({super.key, required this.suggestion});

  final GroupSuggestion suggestion;

  Future<void> _openGroup(BuildContext context, WidgetRef ref) async {
    final groupId = suggestion.groupId;
    await ref
        .read(supportGroupServiceProvider)
        .markSuggestionSeen(suggestion.id);
    if (!context.mounted || groupId == null || groupId.isEmpty) return;
    context.pushNamed(
      Routes.supportGroupDetail,
      pathParameters: {'groupId': groupId},
    );
  }

  Future<void> _dismiss(WidgetRef ref) {
    return ref
        .read(supportGroupServiceProvider)
        .markSuggestionSeen(suggestion.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approved = suggestion.status == GroupSuggestionStatus.approved;
    final color = approved ? kBrandGreen : const Color(0xFFB3261E);
    final title = approved
        ? 'Your group was approved'
        : 'Your group suggestion was declined';
    final body = approved
        ? '"${suggestion.title}" is now open. You were added as a member.'
        : (suggestion.rejectReason != null &&
                suggestion.rejectReason!.isNotEmpty)
            ? '"${suggestion.title}" was not added. Reason: ${suggestion.rejectReason}'
            : '"${suggestion.title}" was not added. You can suggest another group.';

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
                IconButton(
                  onPressed: () => _dismiss(ref),
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Dismiss',
                ),
              ],
            ),
            if (approved &&
                suggestion.groupId != null &&
                suggestion.groupId!.isNotEmpty)
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
                    onPressed: () => _openGroup(context, ref),
                    child: const Text('Open group'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
