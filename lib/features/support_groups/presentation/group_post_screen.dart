import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/support_group.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/support_group_service.dart';
import '../../../core/theme/brand_colors.dart';
import 'widgets/delete_post_dialog.dart';
import 'widgets/group_moderation_banner.dart';
import 'widgets/group_post_image.dart';
import 'widgets/removed_post_banner.dart';

/// One post or question and the replies under it.
class GroupPostScreen extends ConsumerStatefulWidget {
  const GroupPostScreen({
    super.key,
    required this.groupId,
    required this.postId,
  });

  final String groupId;
  final String postId;

  @override
  ConsumerState<GroupPostScreen> createState() => _GroupPostScreenState();
}

class _GroupPostScreenState extends ConsumerState<GroupPostScreen> {
  final _replyController = TextEditingController();
  final _focusNode = FocusNode();
  bool _sending = false;
  String? _error;

  (String, String) get _key => (widget.groupId, widget.postId);

  @override
  void dispose() {
    _replyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(supportGroupServiceProvider).createReply(
            groupId: widget.groupId,
            postId: widget.postId,
            text: text,
          );
      if (!mounted) return;
      _replyController.clear();
      _focusNode.requestFocus();
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deletePost() async {
    final post = ref.read(groupPostProvider(_key)).value;
    if (post == null) return;
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
            postId: widget.postId,
            removalReason: requireReason ? reason : null,
          );
      if (!mounted) return;
      Navigator.of(context).maybePop();
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _editReply(GroupReply reply) async {
    final controller = TextEditingController(text: reply.text);
    final saved = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit reply'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 8,
          maxLength: 2000,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Write a reply…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved == null || !mounted) return;
    if (saved.isEmpty) {
      setState(() => _error = 'Write a reply first.');
      return;
    }
    if (saved == reply.text) return;
    try {
      await ref.read(supportGroupServiceProvider).updateReply(
            groupId: widget.groupId,
            postId: widget.postId,
            replyId: reply.id,
            text: saved,
          );
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _deleteReply(GroupReply reply) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this reply?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(supportGroupServiceProvider).deleteReply(
            groupId: widget.groupId,
            postId: widget.postId,
            replyId: reply.id,
          );
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(groupPostProvider(_key));
    final repliesAsync = ref.watch(groupRepliesProvider(_key));
    final uid = ref.watch(authStateProvider).value?.uid;
    final isAdmin = ref.watch(isAdminProvider);

    return postAsync.when(
      loading: () => Scaffold(
        backgroundColor: kBrandPageBg,
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: kBrandPageBg,
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: Text('Could not load this post.')),
      ),
      data: (post) {
        if (post == null) {
          return Scaffold(
            backgroundColor: kBrandPageBg,
            appBar: AppBar(title: const Text('Post')),
            body: const Center(child: Text('This post was removed.')),
          );
        }

        final mine = uid != null && post.authorUid == uid;
        final canDeletePost = !post.removed && (mine || isAdmin);
        final isQuestion = post.kind == GroupPostKind.question;
        final visible = post.isVisibleInFeed(viewerUid: uid, isAdmin: isAdmin);
        if (!visible) {
          return Scaffold(
            backgroundColor: kBrandPageBg,
            appBar: AppBar(title: const Text('Post')),
            body: const Center(child: Text('This post was removed.')),
          );
        }
        final canReply = post.moderation.isApproved && !post.removed;

        return Scaffold(
          backgroundColor: kBrandPageBg,
          appBar: AppBar(
            title: Text(isQuestion ? 'Question' : 'Post'),
            actions: [
              if (canDeletePost)
                PopupMenuButton<String>(
                  tooltip: 'Post options',
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') _deletePost();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    _OriginalPost(
                      post: post,
                      mine: mine,
                      isAdmin: isAdmin,
                      canDelete: canDeletePost,
                      onDelete: _deletePost,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (canReply) ...[
                      Text(
                        isQuestion ? 'Answers' : 'Replies',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      repliesAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, _) => const Text(
                          'Could not load replies.',
                        ),
                        data: (replies) {
                          if (replies.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                isQuestion
                                    ? 'No answers yet. Be the first to help.'
                                    : 'No replies yet. Start the conversation.',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Colors.black87.withValues(alpha: 0.65),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (final reply in replies)
                                _ReplyTile(
                                  reply: reply,
                                  mine: uid != null && reply.authorUid == uid,
                                  isAdmin: isAdmin,
                                  canEdit: uid != null && reply.authorUid == uid,
                                  canDelete: isAdmin ||
                                      (uid != null && reply.authorUid == uid),
                                  onEdit: () => _editReply(reply),
                                  onDelete: () => _deleteReply(reply),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              if (canReply)
                _ReplyComposer(
                  controller: _replyController,
                  focusNode: _focusNode,
                  sending: _sending,
                  hint: isQuestion ? 'Write an answer…' : 'Write a reply…',
                  onSend: _send,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OriginalPost extends StatelessWidget {
  const _OriginalPost({
    required this.post,
    required this.mine,
    this.isAdmin = false,
    this.canDelete = false,
    this.onDelete,
  });

  final GroupPost post;
  final bool mine;
  final bool isAdmin;
  final bool canDelete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final time = post.createdAt == null
        ? ''
        : DateFormat('MMM d · h:mm a').format(post.createdAt!.toLocal());
    final isQuestion = post.kind == GroupPostKind.question;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isQuestion
                      ? const Color(0xFFF3E8D4)
                      : kBrandGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  post.kind.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color:
                        isQuestion ? const Color(0xFF8A5A12) : kBrandGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${mine ? 'You' : post.authorName}${time.isEmpty ? '' : ' · $time'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87.withValues(alpha: 0.55),
                  ),
                ),
              ),
              if (canDelete)
                PopupMenuButton<String>(
                  tooltip: 'Post options',
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Colors.black54,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
            ],
          ),
          if (post.removed) ...[
            const SizedBox(height: 10),
            RemovedPostBanner(
              post: post,
              isAuthor: mine,
            ),
          ] else if (!post.moderation.isApproved) ...[
            const SizedBox(height: 10),
            GroupModerationBanner(
              moderation: post.moderation,
              isAdmin: isAdmin,
            ),
          ],
          const SizedBox(height: 10),
          Text(
            post.displayTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          if (post.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            SelectableText(
              post.text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
              ),
            ),
          ],
          if (post.hasImage && !post.moderation.isRejected) ...[
            const SizedBox(height: 12),
            GroupPostImageGallery(imagePaths: post.imagePaths),
          ],
        ],
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({
    required this.reply,
    required this.mine,
    required this.canEdit,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
    this.isAdmin = false,
  });

  final GroupReply reply;
  final bool mine;
  final bool canEdit;
  final bool canDelete;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final time = reply.createdAt == null
        ? ''
        : DateFormat('MMM d · h:mm a').format(reply.createdAt!.toLocal());
    final edited = reply.editedAt != null;
    final meta = [
      if (mine) 'You' else reply.authorName,
      if (time.isNotEmpty) time,
      if (edited) 'Edited',
    ].join(' · ');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBrandGreen.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kBrandGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (!reply.moderation.isApproved) ...[
                    GroupModerationBanner(
                      moderation: reply.moderation,
                      compact: true,
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 8),
                  ],
                  SelectableText(
                    reply.text,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (canEdit || canDelete)
            PopupMenuButton<String>(
              tooltip: 'Reply options',
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert, size: 20, color: Colors.black54),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                if (canEdit)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                if (canDelete)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ReplyComposer extends StatelessWidget {
  const _ReplyComposer({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.hint,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: 2000,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: hint,
                    counterText: '',
                    filled: true,
                    fillColor: kBrandPageBg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton.filled(
                onPressed: sending ? null : onSend,
                style: IconButton.styleFrom(
                  backgroundColor: kBrandGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(48, 48),
                ),
                icon: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                tooltip: 'Reply',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
