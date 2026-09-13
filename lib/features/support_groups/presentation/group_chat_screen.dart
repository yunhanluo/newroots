import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/support_group.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/support_group_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/delete_post_dialog.dart';
import 'widgets/group_moderation_banner.dart';
import 'widgets/group_post_image.dart';
import 'widgets/removed_post_banner.dart';

/// Member feed for one support group: posts and questions, not a live chat.
class GroupChatScreen extends ConsumerStatefulWidget {
  const GroupChatScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  bool _joining = false;
  bool _optimisticMember = false;
  String? _error;

  Future<void> _join(SupportGroup group) async {
    if (group.deleted) return;
    setState(() {
      _joining = true;
      _error = null;
    });
    try {
      await ref.read(supportGroupServiceProvider).joinGroup(group);
      if (!mounted) return;
      setState(() => _optimisticMember = true);
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _leave(String title) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.groupsLeaveConfirmTitle),
        content: Text(l10n.groupsLeaveConfirmBody(title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.groupsLeaveShort),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(supportGroupServiceProvider).leaveGroup(widget.groupId);
      if (!mounted) return;
      setState(() => _optimisticMember = false);
      Navigator.of(context).maybePop();
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  void _openCompose(GroupPostKind kind) {
    context.pushNamed(
      Routes.supportGroupCompose,
      pathParameters: {'groupId': widget.groupId},
      queryParameters: {'kind': kind.name},
    );
  }

  void _openPost(GroupPost post) {
    context.pushNamed(
      Routes.supportGroupPost,
      pathParameters: {
        'groupId': widget.groupId,
        'postId': post.id,
      },
    );
  }

  Future<void> _deletePost(GroupPost post) async {
    final uid = ref.read(authStateProvider).value?.uid;
    final requireReason =
        ref.read(isAdminProvider) && uid != null && post.authorUid != uid;
    final reason = await showDeletePostDialog(
      context: context,
      requireReason: requireReason,
    );
    if (reason == null || !mounted) return;
    try {
      await ref.read(supportGroupServiceProvider).deletePost(
            groupId: widget.groupId,
            postId: post.id,
            removalReason: requireReason ? reason : null,
          );
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groupAsync = ref.watch(supportGroupProvider(widget.groupId));
    final myIds = ref.watch(myGroupIdsProvider);
    final uid = ref.watch(authStateProvider).value?.uid;
    final isMember = _optimisticMember || myIds.contains(widget.groupId);
    final memberCount =
        ref.watch(groupMemberCountProvider(widget.groupId)).value;

    return groupAsync.when(
      loading: () => Scaffold(
        backgroundColor: kBrandPageBg,
        appBar: AppBar(title: Text(l10n.groupsFallbackTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: kBrandPageBg,
        appBar: AppBar(title: Text(l10n.groupsFallbackTitle)),
        body: Center(child: Text(l10n.groupsLoadError)),
      ),
      data: (group) {
        if (group == null) {
          return Scaffold(
            backgroundColor: kBrandPageBg,
            appBar: AppBar(title: Text(l10n.groupsFallbackTitle)),
            body: Center(child: Text(l10n.groupsUnavailable)),
          );
        }

        if (group.deleted) {
          return Scaffold(
            backgroundColor: kBrandPageBg,
            appBar: AppBar(title: Text(group.title)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  group.deletedReason.isNotEmpty
                      ? l10n.groupsRemovedWithReason(group.deletedReason)
                      : l10n.groupsRemovedAdmin,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: kBrandPageBg,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.title),
                Text(
                  memberCount == null
                      ? group.region
                      : '${group.region} · ${memberCount == 1 ? l10n.groupsMemberOne : l10n.groupsMemberCount(memberCount)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            actions: [
              if (isMember)
                TextButton(
                  onPressed: () => _leave(group.title),
                  child: Text(
                    l10n.groupsLeaveShort,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black87.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.groupsPrivacyNotice,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87.withValues(alpha: 0.65),
                      ),
                    ),
                    if (isMember) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _openCompose(GroupPostKind.post),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: Text(l10n.groupsNewPost),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _openCompose(GroupPostKind.question),
                              icon: const Icon(Icons.help_outline, size: 18),
                              label: Text(l10n.groupsAskQuestion),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: isMember
                    ? _PostFeed(
                        groupId: widget.groupId,
                        uid: uid,
                        onOpen: _openPost,
                        onDelete: _deletePost,
                      )
                    : _JoinPrompt(
                        joining: _joining,
                        onJoin: () => _join(group),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _JoinPrompt extends StatelessWidget {
  const _JoinPrompt({required this.joining, required this.onJoin});

  final bool joining;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 40,
              color: kBrandGreen.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.groupsJoinToRead,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.groupsJoinPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: joining ? null : onJoin,
              child: joining
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.groupsJoinGroup),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostFeed extends ConsumerWidget {
  const _PostFeed({
    required this.groupId,
    required this.uid,
    required this.onOpen,
    required this.onDelete,
  });

  final String groupId;
  final String? uid;
  final ValueChanged<GroupPost> onOpen;
  final ValueChanged<GroupPost> onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final postsAsync = ref.watch(groupPostsProvider(groupId));
    final isAdmin = ref.watch(isAdminProvider);
    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.groupsPostsLoadError,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.groupsNoPostsYet,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.black87.withValues(alpha: 0.65),
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          itemCount: posts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final post = posts[index];
            return _PostCard(
              post: post,
              mine: uid != null && post.authorUid == uid,
              isAdmin: isAdmin,
              onOpen: () => onOpen(post),
              onDelete: !post.removed &&
                      (isAdmin || (uid != null && post.authorUid == uid))
                  ? () => onDelete(post)
                  : null,
            );
          },
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.mine,
    required this.onOpen,
    this.onDelete,
    this.isAdmin = false,
  });

  final GroupPost post;
  final bool mine;
  final bool isAdmin;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final time = post.createdAt == null
        ? ''
        : DateFormat('MMM d · h:mm a').format(post.createdAt!.toLocal());
    final replies = post.replyCount < 0 ? 0 : post.replyCount;
    final isQuestion = post.kind == GroupPostKind.question;
    final preview = post.text.trim();
    final showBody = post.moderation.isApproved || mine || isAdmin;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _KindChip(kind: post.kind),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${mine ? l10n.groupsYou : post.authorName}${time.isEmpty ? '' : ' · $time'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    PopupMenuButton<String>(
                      tooltip: l10n.groupsPostOptions,
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.black54,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') onDelete!();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.actionDelete),
                        ),
                      ],
                    ),
                ],
              ),
              if (post.removed) ...[
                const SizedBox(height: 10),
                RemovedPostBanner(
                  post: post,
                  compact: true,
                  isAuthor: mine,
                ),
              ] else if (!post.moderation.isApproved) ...[
                const SizedBox(height: 10),
                GroupModerationBanner(
                  moderation: post.moderation,
                  compact: true,
                  isAdmin: isAdmin,
                ),
              ],
              if (showBody) ...[
                const SizedBox(height: 8),
                Text(
                  post.displayTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                if (preview.isNotEmpty &&
                    (post.title.isNotEmpty || preview != post.displayTitle)) ...[
                  const SizedBox(height: 6),
                  Text(
                    preview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black87.withValues(alpha: 0.72),
                    ),
                  ),
                ],
                if (post.hasImage && !post.moderation.isRejected) ...[
                  const SizedBox(height: 10),
                  IgnorePointer(
                    child: GroupPostImageGallery(
                      imagePaths: post.imagePaths,
                      height: 160,
                      interactive: false,
                    ),
                  ),
                ],
              ],
              if (post.moderation.isApproved) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      isQuestion
                          ? Icons.forum_outlined
                          : Icons.chat_bubble_outline,
                      size: 16,
                      color: kBrandGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      replies == 0
                          ? (isQuestion
                              ? l10n.groupsNoAnswersYet
                              : l10n.groupsNoRepliesYet)
                          : replies == 1
                              ? l10n.groupsReplyOne
                              : l10n.groupsReplyMany(replies),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kBrandGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({required this.kind});

  final GroupPostKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isQuestion = kind == GroupPostKind.question;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isQuestion
            ? const Color(0xFFF3E8D4)
            : kBrandGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isQuestion ? l10n.groupsKindQuestion : l10n.groupsKindPost,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isQuestion ? const Color(0xFF8A5A12) : kBrandGreen,
        ),
      ),
    );
  }
}
