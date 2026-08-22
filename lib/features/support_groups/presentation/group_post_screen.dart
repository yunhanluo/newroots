import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/support_group.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/support_group_service.dart';
import '../../../core/theme/brand_colors.dart';
import 'widgets/group_post_image.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this post?'),
        content: const Text('Replies will be removed too. This cannot be undone.'),
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
      await ref.read(supportGroupServiceProvider).deletePost(
            groupId: widget.groupId,
            postId: widget.postId,
          );
      if (!mounted) return;
      Navigator.of(context).maybePop();
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
        final canDeletePost = mine || isAdmin;
        final isQuestion = post.kind == GroupPostKind.question;

        return Scaffold(
          backgroundColor: kBrandPageBg,
          appBar: AppBar(
            title: Text(isQuestion ? 'Question' : 'Post'),
            actions: [
              if (canDeletePost)
                IconButton(
                  tooltip: 'Delete',
                  onPressed: _deletePost,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    _OriginalPost(post: post, mine: mine),
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
                                canDelete: isAdmin ||
                                    (uid != null && reply.authorUid == uid),
                                onDelete: () => _deleteReply(reply),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
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
  const _OriginalPost({required this.post, required this.mine});

  final GroupPost post;
  final bool mine;

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
            ],
          ),
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
          if (post.hasImage) ...[
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
    required this.canDelete,
    required this.onDelete,
  });

  final GroupReply reply;
  final bool mine;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final time = reply.createdAt == null
        ? ''
        : DateFormat('MMM d · h:mm a').format(reply.createdAt!.toLocal());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
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
                    '${mine ? 'You' : reply.authorName}${time.isEmpty ? '' : ' · $time'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kBrandGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
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
          if (canDelete)
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.close, size: 18),
              visualDensity: VisualDensity.compact,
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
