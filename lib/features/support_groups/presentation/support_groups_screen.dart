import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/support_group.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/support_group_service.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_scaffold.dart';
import 'widgets/deleted_group_notice.dart';
import 'widgets/deleted_post_notice.dart';
import 'widgets/suggestion_review_notice.dart';

/// Feature 8: Mutual Support Groups — discover and join.
class SupportGroupsScreen extends ConsumerStatefulWidget {
  const SupportGroupsScreen({super.key});

  @override
  ConsumerState<SupportGroupsScreen> createState() =>
      _SupportGroupsScreenState();
}

class _SupportGroupsScreenState extends ConsumerState<SupportGroupsScreen> {
  SupportGroupCategory? _filter;
  bool _mineOnly = false;
  bool _seeding = false;
  bool _deleting = false;
  String? _banner;
  String? _confirmDeleteId;
  final _deleteReasonController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _deleteReasonController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(SupportGroup group) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return group.title.toLowerCase().contains(query) ||
        group.description.toLowerCase().contains(query) ||
        group.region.toLowerCase().contains(query) ||
        group.category.label.toLowerCase().contains(query) ||
        group.languageLabel.toLowerCase().contains(query);
  }

  Future<void> _seed() async {
    setState(() {
      _seeding = true;
      _banner = null;
    });
    try {
      final written =
          await ref.read(supportGroupServiceProvider).seedStarterGroups();
      if (!mounted) return;
      setState(() {
        _banner = written == 0
            ? 'Starter groups are already loaded.'
            : 'Loaded $written starter groups. Join one to start posting.';
      });
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _banner = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _banner =
            'Could not load starter groups. Deploy Firestore rules, then try again.',
      );
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  void _startDelete(SupportGroup group) {
    setState(() {
      _confirmDeleteId = group.id;
      _deleteReasonController.clear();
      _banner = null;
    });
  }

  void _cancelDelete() {
    setState(() {
      _confirmDeleteId = null;
      _deleteReasonController.clear();
    });
  }

  Future<void> _confirmDelete(SupportGroup group) async {
    if (_deleting) return;
    setState(() => _deleting = true);
    try {
      await ref.read(supportGroupServiceProvider).deleteGroup(
            group.id,
            reason: _deleteReasonController.text,
          );
      if (!mounted) return;
      setState(() {
        _confirmDeleteId = null;
        _deleteReasonController.clear();
      });
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _banner = e.message);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _removeDeadGroup(SupportGroup group) async {
    try {
      await ref.read(supportGroupServiceProvider).leaveGroup(group.id);
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _banner = e.message);
    }
  }

  Future<void> _leave(SupportGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave this group?'),
        content: Text(
          'You will stop seeing posts in "${group.title}". You can join again later.',
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
      await ref.read(supportGroupServiceProvider).leaveGroup(group.id);
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _banner = e.message);
    }
  }

  Future<void> _join(SupportGroup group) async {
    try {
      await ref.read(supportGroupServiceProvider).joinGroup(group);
      if (!mounted) return;
      context.pushNamed(
        Routes.supportGroupDetail,
        pathParameters: {'groupId': group.id},
      );
    } on SupportGroupException catch (e) {
      if (!mounted) return;
      setState(() => _banner = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(adminSyncProvider);
    final groupsAsync = ref.watch(supportGroupsProvider);
    final myIds = ref.watch(myGroupIdsProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final pendingSuggestions = isAdmin
        ? (ref.watch(groupSuggestionsProvider).value ?? const [])
            .where((s) => s.status == GroupSuggestionStatus.pending)
            .length
        : 0;
    final pendingAppeals = isAdmin
        ? (ref.watch(pendingPostAppealsProvider).value ?? const []).length
        : 0;
    final pendingCount = pendingSuggestions + pendingAppeals;
    final mySuggestions =
        (ref.watch(myGroupSuggestionsProvider).value ?? const <GroupSuggestion>[])
            .where((s) => s.status == GroupSuggestionStatus.pending)
            .toList();
    final reviews = ref.watch(unseenSuggestionReviewsProvider);
    final deletedNotices = ref.watch(deletedGroupNoticesProvider);
    final deletedPosts =
        ref.watch(unseenPostDeletionNoticesProvider).value ?? const [];

    return BrandScaffold(
      title: 'Support Groups',
      actions: [
        if (isAdmin)
          IconButton(
            tooltip: pendingCount == 0
                ? 'Review groups'
                : 'Review groups ($pendingCount pending)',
            onPressed: () => context.pushNamed(Routes.groupAdmin),
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.admin_panel_settings_outlined),
            ),
          ),
      ],
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBody(
          message:
              'Could not load groups. Deploy Firestore rules '
              '(firebase deploy --only firestore:rules), then try again.',
          onRetry: () => ref.invalidate(supportGroupsProvider),
        ),
        data: (groups) {
          final visible = groups.where((group) {
            if (group.deleted) {
              return _mineOnly &&
                  myIds.contains(group.id) &&
                  _matchesSearch(group);
            }
            if (_mineOnly && !myIds.contains(group.id)) return false;
            if (_filter != null && group.category != _filter) return false;
            if (!_matchesSearch(group)) return false;
            return true;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Text(
                'Join a group to post, ask questions, and help other newcomers in California.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Colors.black87.withValues(alpha: 0.75),
                ),
              ),
              if (reviews.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final suggestion in reviews) ...[
                  SuggestionReviewNotice(suggestion: suggestion),
                  const SizedBox(height: 8),
                ],
              ],
              if (deletedNotices.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final group in deletedNotices) ...[
                  DeletedGroupNotice(group: group),
                  const SizedBox(height: 8),
                ],
              ],
              if (deletedPosts.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final notice in deletedPosts) ...[
                  DeletedPostNotice(notice: notice),
                  const SizedBox(height: 8),
                ],
              ],
              if (_banner != null) ...[
                const SizedBox(height: 12),
                _BannerNote(
                  message: _banner!,
                  onDismiss: () => setState(() => _banner = null),
                ),
              ],
              const SizedBox(height: 32),
              _ScopeToggle(
                mineOnly: _mineOnly,
                myCount: myIds.length,
                onChanged: (mineOnly) => setState(() => _mineOnly = mineOnly),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 168,
                    child: _GroupSearchField(
                      controller: _searchController,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _filter == null,
                            onTap: () => setState(() => _filter = null),
                          ),
                          for (final category
                              in SupportGroupCategory.values) ...[
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: category.label,
                              selected: _filter == category,
                              onTap: () =>
                                  setState(() => _filter = category),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (groups.isEmpty)
                _EmptyGroups(
                  seeding: _seeding,
                  onSeed: _seed,
                )
              else if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Text(
                    _searchController.text.trim().isNotEmpty
                        ? 'No groups match your search.'
                        : _mineOnly
                            ? 'You have not joined a group yet. Switch to Discover to find one.'
                            : 'No groups in this category yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.black87.withValues(alpha: 0.65),
                    ),
                  ),
                )
              else
                for (final group in visible) ...[
                  _GroupCard(
                    group: group,
                    joined: myIds.contains(group.id),
                    isAdmin: isAdmin,
                    onOpen: group.deleted
                        ? null
                        : () => context.pushNamed(
                              Routes.supportGroupDetail,
                              pathParameters: {'groupId': group.id},
                            ),
                    onJoin: () => _join(group),
                    onLeave: () => _leave(group),
                    onDelete: () => _startDelete(group),
                    onCancelDelete: _cancelDelete,
                    onConfirmDelete: () => _confirmDelete(group),
                    confirmingDelete: _confirmDeleteId == group.id,
                    deleteReasonController: _deleteReasonController,
                    deleting: _deleting,
                    onRemoveDead: () => _removeDeadGroup(group),
                  ),
                  const SizedBox(height: 12),
                ],
              const SizedBox(height: 8),
              if (mySuggestions.isNotEmpty) ...[
                _MySuggestionsList(suggestions: mySuggestions),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: () => context.pushNamed(Routes.suggestGroup),
                icon: const Icon(Icons.add),
                label: const Text('Suggest a new group'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MySuggestionsList extends StatefulWidget {
  const _MySuggestionsList({required this.suggestions});

  final List<GroupSuggestion> suggestions;

  @override
  State<_MySuggestionsList> createState() => _MySuggestionsListState();
}

class _MySuggestionsListState extends State<_MySuggestionsList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final count = widget.suggestions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _expanded
                          ? 'Your suggestions'
                          : 'Your suggestions ($count)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: kBrandGreen,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          for (final suggestion in widget.suggestions) ...[
            _MySuggestionTile(suggestion: suggestion),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _MySuggestionTile extends StatelessWidget {
  const _MySuggestionTile({required this.suggestion});

  final GroupSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kBrandGreen.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Waiting for an admin to review.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopeToggle extends StatelessWidget {
  const _ScopeToggle({
    required this.mineOnly,
    required this.myCount,
    required this.onChanged,
  });

  final bool mineOnly;
  final int myCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          _ScopeButton(
            label: 'Discover',
            selected: !mineOnly,
            onTap: () => onChanged(false),
          ),
          _ScopeButton(
            label: myCount == 0 ? 'My groups' : 'My groups ($myCount)',
            selected: mineOnly,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ScopeButton extends StatelessWidget {
  const _ScopeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? kBrandGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : kBrandGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupSearchField extends StatelessWidget {
  const _GroupSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final hasQuery = controller.text.trim().isNotEmpty;
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search',
        hintStyle: TextStyle(
          color: Colors.black87.withValues(alpha: 0.45),
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.search, size: 20, color: kBrandGreen),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 40,
        ),
        suffixIcon: hasQuery
            ? IconButton(
                tooltip: 'Clear search',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 40,
                ),
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged();
                },
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 40,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kBrandGreen.withValues(alpha: 0.22)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kBrandGreen.withValues(alpha: 0.22)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: kBrandGreen),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: kBrandGreen.withValues(alpha: 0.16),
      checkmarkColor: kBrandGreen,
      side: BorderSide(
        color: selected
            ? kBrandGreen
            : kBrandGreen.withValues(alpha: 0.22),
      ),
      labelStyle: TextStyle(
        color: kBrandGreen,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor: Colors.white,
      showCheckmark: false,
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.joined,
    required this.isAdmin,
    required this.onOpen,
    required this.onJoin,
    required this.onLeave,
    required this.onDelete,
    required this.onCancelDelete,
    required this.onConfirmDelete,
    required this.confirmingDelete,
    required this.deleteReasonController,
    required this.deleting,
    required this.onRemoveDead,
  });

  final SupportGroup group;
  final bool joined;
  final bool isAdmin;
  final VoidCallback? onOpen;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onDelete;
  final VoidCallback onCancelDelete;
  final VoidCallback onConfirmDelete;
  final bool confirmingDelete;
  final TextEditingController deleteReasonController;
  final bool deleting;
  final VoidCallback onRemoveDead;

  @override
  Widget build(BuildContext context) {
    if (group.deleted) {
      return _DeletedGroupCard(
        group: group,
        onRemove: onRemoveDead,
      );
    }

    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBrandGreen.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: confirmingDelete ? null : onOpen,
        splashColor: kBrandGreen.withValues(alpha: 0.08),
        highlightColor: kBrandGreen.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(group.category.icon, size: 32, color: kBrandGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${group.region} · ${group.languageLabel}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAdmin)
                    PopupMenuButton<String>(
                      tooltip: 'Group options',
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert, color: Colors.black54),
                      onSelected: (value) {
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete group'),
                        ),
                      ],
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      color: kBrandGreen.withValues(alpha: 0.7),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                group.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87.withValues(alpha: 0.75),
                ),
              ),
              if (confirmingDelete) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: deleteReasonController,
                  enabled: !deleting,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Why is this group being removed?',
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
                      onPressed: deleting ? null : onCancelDelete,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: deleting ? null : onConfirmDelete,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: deleting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Delete'),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (joined)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          foregroundColor: Colors.black54,
                          side: BorderSide(
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ),
                        onPressed: onLeave,
                        child: const Text('Leave group'),
                      ),
                    const Spacer(),
                    joined
                        ? const _JoinedChip()
                        : FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(96, 44),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                            ),
                            onPressed: onJoin,
                            child: const Text('Join'),
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

class _DeletedGroupCard extends StatelessWidget {
  const _DeletedGroupCard({
    required this.group,
    required this.onRemove,
  });

  final SupportGroup group;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8E8E8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  group.category.icon,
                  size: 32,
                  color: Colors.black45,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'This group was removed',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (group.deletedReason.isNotEmpty)
              Text(
                'Reason: ${group.deletedReason}',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black54,
                ),
              )
            else
              const Text(
                'An admin removed this group.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  foregroundColor: Colors.black54,
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.25)),
                ),
                onPressed: onRemove,
                child: const Text('Remove from my groups'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinedChip extends StatelessWidget {
  const _JoinedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kBrandGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Joined',
        style: TextStyle(
          color: kBrandGreen,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyGroups extends StatelessWidget {
  const _EmptyGroups({required this.seeding, required this.onSeed});

  final bool seeding;
  final VoidCallback onSeed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Icon(
            Icons.diversity_3_outlined,
            size: 56,
            color: kBrandGreen.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          const Text(
            'No groups yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Load the starter groups for new parents, job seekers, language learners, and more.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.black87.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: seeding ? null : onSeed,
            child: seeding
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Load starter groups'),
          ),
        ],
      ),
    );
  }
}

class _BannerNote extends StatelessWidget {
  const _BannerNote({required this.message, this.onDismiss});

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBrandGreen.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, height: 1.35),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Dismiss',
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
