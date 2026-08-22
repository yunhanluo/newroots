import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/support_group.dart';
import '../../../../core/services/support_group_service.dart';

/// In-app notice when an admin removes a group the user had joined.
class DeletedGroupNotice extends ConsumerWidget {
  const DeletedGroupNotice({super.key, required this.group});

  final SupportGroup group;

  static const _color = Color(0xFFB3261E);

  Future<void> _dismiss(WidgetRef ref) {
    return ref
        .read(supportGroupServiceProvider)
        .markDeletedNoticeSeen(group.id);
  }

  Future<void> _remove(WidgetRef ref) {
    return ref.read(supportGroupServiceProvider).leaveGroup(group.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reason = group.deletedReason.trim();
    final body = reason.isNotEmpty
        ? '"${group.title}" was removed. Reason: $reason'
        : '"${group.title}" was removed by an admin.';

    return Material(
      color: _color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2, right: 8),
                  child: Icon(
                    Icons.info_outline,
                    color: _color,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'A group you joined was removed',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _color,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 8, 12, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    foregroundColor: _color,
                    side: BorderSide(color: _color.withValues(alpha: 0.5)),
                  ),
                  onPressed: () => _remove(ref),
                  child: const Text('Remove from my groups'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
