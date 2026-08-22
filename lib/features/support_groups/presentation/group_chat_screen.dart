import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/support_group.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/support_group_service.dart';
import '../../../core/theme/brand_colors.dart';
import 'widgets/group_post_image.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave this group?'),
        content: Text(
          'You will stop seeing posts in "$title". You can join again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
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

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(supportGroupProvider(widget.groupId));
    final myIds = ref.watch(myGroupIdsProvider);
    final uid = ref.watch(authStateProvider).value?.uid;
    final isMember = _optimisticMember || myIds.contains(widget.groupId);
    final memberCount =
        ref.watch(groupMemberCountProvider(widget.groupId)).value;

    return groupAsync.when(
      loading: () => Scaffold(
        backgroundColor: kBrandPageBg,
        appBar: AppBar(title: const Text('Support group')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: kBrandPageBg,
        appBar: AppBar(title: const Text('Support group')),
        body: const Center(child: Text('Could not load this group.')),
      ),
      data: (group) {
        if (group == null) {
          return Scaffold(
            backgroundColor: kBrandPageBg,
            appBar: AppBar(title: const Text('Support group')),
            body: const Center(child: Text('This group is no longer available.')),
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
                      ? 'This group was removed. Reason: ${group.deletedReason}'
                      : 'This group was removed by an admin.',
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
                      : '${group.region} · $memberCount ${memberCount == 1 ? 'member' : 'members'}',
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
                  child: const Text(
                    'Leave',
                    style: TextStyle(color: Colors.white),
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
                      'Posts and questions are private to members. Be kind, and never '
                      'share immigration status, IDs, or passwords.',
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
                              label: const Text('New post'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _openCompose(GroupPostKind.question),
                              icon: const Icon(Icons.help_outline, size: 18),
                              label: const Text('Ask a question'),
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
            const Text(
              'Join to read posts and reply',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Only members can see posts and questions in this group. Join when you are ready to take part.',
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
                  : const Text('Join group'),
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
  });

  final String groupId;
  final String? uid;
  final ValueChanged<GroupPost> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(groupPostsProvider(groupId));
    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Could not load posts. Join the group and try again.',
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
                'No posts yet. Share something, or ask a question the group can help with.',
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
              onOpen: () => onOpen(post),
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
  });

  final GroupPost post;
  final bool mine;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final time = post.createdAt == null
        ? ''
        : DateFormat('MMM d · h:mm a').format(post.createdAt!.toLocal());
    final replies = post.replyCount < 0 ? 0 : post.replyCount;
    final isQuestion = post.kind == GroupPostKind.question;
    final preview = post.text.trim();

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
              if (post.hasImage) ...[
                const SizedBox(height: 10),
                IgnorePointer(
                  child: GroupPostImageGallery(
                    imagePaths: post.imagePaths,
                    height: 160,
                    interactive: false,
                  ),
                ),
              ],
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
                        ? (isQuestion ? 'No answers yet' : 'No replies yet')
                        : '$replies ${replies == 1 ? 'reply' : 'replies'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kBrandGreen,
                    ),
                  ),
                ],
              ),
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
        kind.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isQuestion ? const Color(0xFF8A5A12) : kBrandGreen,
        ),
      ),
    );
  }
}
