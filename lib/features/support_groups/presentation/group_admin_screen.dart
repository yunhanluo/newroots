import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/support_group.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/support_group_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';

/// Admin review of suggested support groups.
class GroupAdminScreen extends ConsumerStatefulWidget {
  const GroupAdminScreen({super.key});

  @override
  ConsumerState<GroupAdminScreen> createState() => _GroupAdminScreenState();
}

class _GroupAdminScreenState extends ConsumerState<GroupAdminScreen> {
  bool _pendingOnly = true;
  bool _rejecting = false;
  String? _busyId;
  String? _busyAppealId;
  String? _error;
  String? _confirmRejectId;
  final _rejectReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }

  Future<void> _approve(GroupSuggestion suggestion) async {
    setState(() {
      _busyId = suggestion.id;
      _confirmRejectId = null;
      _error = null;
    });
    try {
      await ref.read(supportGroupServiceProvider).approveSuggestion(suggestion);
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _startReject(GroupSuggestion suggestion) {
    setState(() {
      _confirmRejectId = suggestion.id;
      _rejectReasonController.clear();
      _error = null;
    });
  }

  void _cancelReject() {
    setState(() {
      _confirmRejectId = null;
      _rejectReasonController.clear();
    });
  }

  Future<void> _confirmReject(GroupSuggestion suggestion) async {
    if (_rejecting) return;
    setState(() {
      _rejecting = true;
      _busyId = suggestion.id;
      _error = null;
    });
    try {
      await ref.read(supportGroupServiceProvider).rejectSuggestion(
            suggestion,
            reason: _rejectReasonController.text,
          );
      if (!mounted) return;
      setState(() {
        _confirmRejectId = null;
        _rejectReasonController.clear();
      });
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) {
        setState(() {
          _rejecting = false;
          _busyId = null;
        });
      }
    }
  }

  Future<void> _restoreAppeal(GroupPost post) async {
    setState(() {
      _busyAppealId = post.id;
      _error = null;
    });
    try {
      await ref.read(supportGroupServiceProvider).restoreRemovedPost(
            groupId: post.groupId,
            postId: post.id,
          );
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busyAppealId = null);
    }
  }

  Future<void> _denyAppeal(GroupPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline this appeal?'),
        content: const Text(
          'The post will be permanently deleted. The author will be told the appeal was declined.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete post'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busyAppealId = post.id;
      _error = null;
    });
    try {
      await ref.read(supportGroupServiceProvider).denyPostAppeal(
            groupId: post.groupId,
            postId: post.id,
          );
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busyAppealId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      return const BrandScaffold(
        title: 'Group admin',
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Only admins can review group suggestions.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final suggestionsAsync = ref.watch(groupSuggestionsProvider);
    final appealsAsync = ref.watch(pendingPostAppealsProvider);
    final groupTitles = {
      for (final group in ref.watch(supportGroupsProvider).value ?? const [])
        group.id: group.title,
    };

    return BrandScaffold(
      title: 'Group admin',
      body: suggestionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Could not load suggestions. Deploy Firestore rules, then try again.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (suggestions) {
          final visible = _pendingOnly
              ? suggestions
                  .where((s) => s.status == GroupSuggestionStatus.pending)
                  .toList()
              : suggestions;
          final appeals = appealsAsync.value ?? const <GroupPost>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              const Text(
                'Post appeals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hidden posts stay for 7 days. Restore one to show it in the group again.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Colors.black87.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 12),
              if (appealsAsync.hasError)
                const Text(
                  'Could not load appeals. Deploy Firestore indexes, then try again.',
                )
              else if (appeals.isEmpty)
                Text(
                  'No pending appeals.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87.withValues(alpha: 0.65),
                  ),
                )
              else
                for (final post in appeals) ...[
                  _AppealCard(
                    post: post,
                    groupTitle: groupTitles[post.groupId] ?? 'Group',
                    busy: _busyAppealId == post.id,
                    onOpen: post.groupId.isEmpty
                        ? null
                        : () => context.pushNamed(
                              Routes.supportGroupPost,
                              pathParameters: {
                                'groupId': post.groupId,
                                'postId': post.id,
                              },
                            ),
                    onRestore: () => _restoreAppeal(post),
                    onDeny: () => _denyAppeal(post),
                  ),
                  const SizedBox(height: 12),
                ],
              const SizedBox(height: 28),
              const Text(
                'Group suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Approve a suggestion to open the group for everyone to join.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Colors.black87.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  label: const Text('Pending only'),
                  selected: _pendingOnly,
                  onSelected: (value) => setState(() => _pendingOnly = value),
                  selectedColor: kBrandGreen.withValues(alpha: 0.16),
                  checkmarkColor: kBrandGreen,
                  side: BorderSide(color: kBrandGreen.withValues(alpha: 0.22)),
                  backgroundColor: Colors.white,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _pendingOnly
                        ? 'No pending suggestions right now.'
                        : 'No suggestions yet.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87.withValues(alpha: 0.65),
                    ),
                  ),
                )
              else
                for (final suggestion in visible) ...[
                  _SuggestionCard(
                    suggestion: suggestion,
                    busy: _busyId == suggestion.id,
                    confirmingReject: _confirmRejectId == suggestion.id,
                    rejectReasonController: _rejectReasonController,
                    rejecting: _rejecting,
                    onApprove: () => _approve(suggestion),
                    onReject: () => _startReject(suggestion),
                    onCancelReject: _cancelReject,
                    onConfirmReject: () => _confirmReject(suggestion),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.busy,
    required this.confirmingReject,
    required this.rejectReasonController,
    required this.rejecting,
    required this.onApprove,
    required this.onReject,
    required this.onCancelReject,
    required this.onConfirmReject,
  });

  final GroupSuggestion suggestion;
  final bool busy;
  final bool confirmingReject;
  final TextEditingController rejectReasonController;
  final bool rejecting;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onCancelReject;
  final VoidCallback onConfirmReject;

  @override
  Widget build(BuildContext context) {
    final pending = suggestion.status == GroupSuggestionStatus.pending;
    final when = suggestion.createdAt == null
        ? ''
        : DateFormat('MMM d, y').format(suggestion.createdAt!.toLocal());
    final who = suggestion.suggesterEmail.isNotEmpty
        ? suggestion.suggesterEmail
        : suggestion.suggesterName;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(suggestion.category.icon, color: kBrandGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusChip(status: suggestion.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              [
                suggestion.category.label,
                suggestion.region,
                if (when.isNotEmpty) when,
              ].join(' · '),
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              suggestion.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suggested by $who',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87.withValues(alpha: 0.55),
              ),
            ),
            if (suggestion.rejectReason != null &&
                suggestion.rejectReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Reason: ${suggestion.rejectReason}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
            if (pending) ...[
              if (confirmingReject) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: rejectReasonController,
                  enabled: !rejecting,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Why is this group being declined? (optional)',
                    counterText: '',
                    filled: true,
                    fillColor: kBrandPageBg,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: rejecting ? null : onCancelReject,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: rejecting ? null : onConfirmReject,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: rejecting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Decline'),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: busy ? null : onReject,
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: busy ? null : onApprove,
                        child: busy
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final GroupSuggestionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      GroupSuggestionStatus.pending => const Color(0xFFB78103),
      GroupSuggestionStatus.approved => kBrandGreen,
      GroupSuggestionStatus.rejected => const Color(0xFFB3261E),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AppealCard extends StatelessWidget {
  const _AppealCard({
    required this.post,
    required this.groupTitle,
    required this.busy,
    required this.onRestore,
    required this.onDeny,
    this.onOpen,
  });

  final GroupPost post;
  final String groupTitle;
  final bool busy;
  final VoidCallback? onOpen;
  final VoidCallback onRestore;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    final deadline = post.purgeAt == null
        ? ''
        : DateFormat('MMM d').format(post.purgeAt!.toLocal());
    final appeal = post.appealMessage.trim();

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.displayTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              [
                groupTitle,
                if (deadline.isNotEmpty) 'Held until $deadline',
              ].join(' · '),
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87.withValues(alpha: 0.6),
              ),
            ),
            if (post.removedReason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Removed: ${post.removedReason}',
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
            if (appeal.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Appeal: $appeal',
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                if (onOpen != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : onOpen,
                      child: const Text('Open'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : onDeny,
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: busy ? null : onRestore,
                    child: busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Restore'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
