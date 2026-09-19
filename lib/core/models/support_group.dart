import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Shared-experience category for a local mutual support group.
enum SupportGroupCategory {
  parents,
  jobs,
  language,
  networking,
  culture,
  housing,
  other,
}

extension SupportGroupCategoryX on SupportGroupCategory {
  String get label => switch (this) {
        SupportGroupCategory.parents => 'Parents',
        SupportGroupCategory.jobs => 'Jobs',
        SupportGroupCategory.language => 'English',
        SupportGroupCategory.networking => 'Careers',
        SupportGroupCategory.culture => 'Culture',
        SupportGroupCategory.housing => 'Housing',
        SupportGroupCategory.other => 'Other',
      };

  IconData get icon => switch (this) {
        SupportGroupCategory.parents => Icons.family_restroom_outlined,
        SupportGroupCategory.jobs => Icons.work_outline,
        SupportGroupCategory.language => Icons.translate_outlined,
        SupportGroupCategory.networking => Icons.handshake_outlined,
        SupportGroupCategory.culture => Icons.public_outlined,
        SupportGroupCategory.housing => Icons.home_outlined,
        SupportGroupCategory.other => Icons.category_outlined,
      };

  static SupportGroupCategory parse(Object? raw) {
    switch ('$raw'.trim().toLowerCase()) {
      case 'parents':
        return SupportGroupCategory.parents;
      case 'jobs':
        return SupportGroupCategory.jobs;
      case 'language':
        return SupportGroupCategory.language;
      case 'networking':
        return SupportGroupCategory.networking;
      case 'culture':
        return SupportGroupCategory.culture;
      case 'housing':
        return SupportGroupCategory.housing;
      case 'other':
        return SupportGroupCategory.other;
      default:
        return SupportGroupCategory.other;
    }
  }
}

/// Maps to Firestore `groups/{id}`.
class SupportGroup {
  const SupportGroup({
    required this.id,
    required this.title,
    required this.description,
    this.category = SupportGroupCategory.culture,
    this.region = 'California',
    this.languages = const ['en'],
    this.createdAt,
    this.deleted = false,
    this.deletedReason = '',
    this.deletedAt,
    this.deletedByUid,
  });

  final String id;
  final String title;
  final String description;
  final SupportGroupCategory category;
  final String region;
  final List<String> languages;
  final DateTime? createdAt;
  final bool deleted;
  final String deletedReason;
  final DateTime? deletedAt;
  final String? deletedByUid;

  String get languageLabel {
    final labels = languages.map((code) {
      switch (code) {
        case 'es':
          return 'Spanish';
        case 'zh':
          return 'Chinese';
        case 'vi':
          return 'Vietnamese';
        case 'ko':
          return 'Korean';
        case 'hi':
          return 'Hindi';
        case 'ar':
          return 'Arabic';
        case 'en':
        default:
          return 'English';
      }
    }).toList();
    return labels.join(' · ');
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'region': region,
      'languages': languages,
    };
  }

  factory SupportGroup.fromMap(String id, Map<String, dynamic> map) {
    return SupportGroup(
      id: id,
      title: (map['title'] as String?)?.trim() ?? 'Support group',
      description: (map['description'] as String?)?.trim() ?? '',
      category: SupportGroupCategoryX.parse(map['category']),
      region: (map['region'] as String?)?.trim() ?? 'California',
      languages: _stringList(map['languages']),
      createdAt: parseFirestoreDate(map['createdAt']),
      deleted: map['deleted'] == true,
      deletedReason: (map['deletedReason'] as String?)?.trim() ?? '',
      deletedAt: parseFirestoreDate(map['deletedAt']),
      deletedByUid: (map['deletedByUid'] as String?)?.trim(),
    );
  }

  static List<String> _stringList(Object? raw) {
    if (raw is! List) return const ['en'];
    final values = raw
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return values.isEmpty ? const ['en'] : values;
  }
}

/// Maps to Firestore `users/{uid}/groupMemberships/{groupId}`.
class GroupMembership {
  const GroupMembership({
    required this.groupId,
    this.title = '',
    this.category = SupportGroupCategory.other,
    this.joinedAt,
    this.deletedNoticeSeen = false,
  });

  final String groupId;
  final String title;
  final SupportGroupCategory category;
  final DateTime? joinedAt;
  final bool deletedNoticeSeen;

  factory GroupMembership.fromMap(String id, Map<String, dynamic> map) {
    return GroupMembership(
      groupId: id,
      title: (map['title'] as String?)?.trim() ?? '',
      category: SupportGroupCategoryX.parse(map['category']),
      joinedAt: parseFirestoreDate(map['joinedAt']),
      deletedNoticeSeen: map['deletedNoticeSeen'] == true,
    );
  }
}

/// How long a hidden post is kept before it is permanently deleted.
const kPostRemovalAppealDuration = Duration(days: 7);

String postDeletionNoticeId(String groupId, String postId) =>
    '${groupId}_$postId';

enum PostAppealStatus { none, open, pending, approved, denied, expired }

extension PostAppealStatusX on PostAppealStatus {
  bool get canAppeal => this == PostAppealStatus.open;

  static PostAppealStatus parse(Object? raw) {
    switch ('$raw'.trim().toLowerCase()) {
      case 'open':
        return PostAppealStatus.open;
      case 'pending':
        return PostAppealStatus.pending;
      case 'approved':
        return PostAppealStatus.approved;
      case 'denied':
        return PostAppealStatus.denied;
      case 'expired':
        return PostAppealStatus.expired;
      default:
        return PostAppealStatus.none;
    }
  }
}

/// Maps to Firestore `users/{uid}/postDeletionNotices/{id}`.
class PostDeletionNotice {
  const PostDeletionNotice({
    required this.id,
    required this.authorUid,
    this.groupId = '',
    this.postId = '',
    this.groupTitle = '',
    this.postTitle = '',
    this.reason = '',
    this.appealMessage = '',
    this.appealStatus = PostAppealStatus.none,
    this.seen = false,
    this.createdAt,
    this.purgeAt,
  });

  final String id;
  final String authorUid;
  final String groupId;
  final String postId;
  final String groupTitle;
  final String postTitle;
  final String reason;
  final String appealMessage;
  final PostAppealStatus appealStatus;
  final bool seen;
  final DateTime? createdAt;
  final DateTime? purgeAt;

  bool get canAppeal {
    if (appealStatus != PostAppealStatus.open || postId.isEmpty) return false;
    final deadline = purgeAt;
    if (deadline == null) return true;
    return deadline.isAfter(DateTime.now());
  }

  factory PostDeletionNotice.fromMap(String id, Map<String, dynamic> map) {
    return PostDeletionNotice(
      id: id,
      authorUid: (map['authorUid'] as String?) ?? '',
      groupId: (map['groupId'] as String?)?.trim() ?? '',
      postId: (map['postId'] as String?)?.trim() ?? '',
      groupTitle: (map['groupTitle'] as String?)?.trim() ?? 'a group',
      postTitle: (map['postTitle'] as String?)?.trim() ?? 'Your post',
      reason: (map['reason'] as String?)?.trim() ?? '',
      appealMessage: (map['appealMessage'] as String?)?.trim() ?? '',
      appealStatus: PostAppealStatusX.parse(map['appealStatus']),
      seen: map['seen'] == true,
      createdAt: parseFirestoreDate(map['createdAt']),
      purgeAt: parseFirestoreDate(map['purgeAt']),
    );
  }
}

enum GroupSuggestionStatus { pending, approved, rejected }

extension GroupSuggestionStatusX on GroupSuggestionStatus {
  String get label => switch (this) {
        GroupSuggestionStatus.pending => 'Pending',
        GroupSuggestionStatus.approved => 'Approved',
        GroupSuggestionStatus.rejected => 'Declined',
      };

  static GroupSuggestionStatus parse(Object? raw) {
    switch ('$raw'.trim().toLowerCase()) {
      case 'approved':
        return GroupSuggestionStatus.approved;
      case 'rejected':
        return GroupSuggestionStatus.rejected;
      case 'pending':
      default:
        return GroupSuggestionStatus.pending;
    }
  }
}

/// Maps to Firestore `groupSuggestions/{id}`.
class GroupSuggestion {
  const GroupSuggestion({
    required this.id,
    required this.title,
    required this.description,
    this.category = SupportGroupCategory.culture,
    this.region = 'California',
    this.languages = const ['en'],
    this.status = GroupSuggestionStatus.pending,
    this.suggesterUid = '',
    this.suggesterName = 'Member',
    this.suggesterEmail = '',
    this.createdAt,
    this.reviewedAt,
    this.reviewedByUid,
    this.rejectReason,
    this.groupId,
    this.seenBySuggester = false,
  });

  final String id;
  final String title;
  final String description;
  final SupportGroupCategory category;
  final String region;
  final List<String> languages;
  final GroupSuggestionStatus status;
  final String suggesterUid;
  final String suggesterName;
  final String suggesterEmail;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final String? reviewedByUid;
  final String? rejectReason;
  final String? groupId;
  final bool seenBySuggester;

  bool get isUnseenReview =>
      !seenBySuggester &&
      (status == GroupSuggestionStatus.approved ||
          status == GroupSuggestionStatus.rejected);

  factory GroupSuggestion.fromMap(String id, Map<String, dynamic> map) {
    return GroupSuggestion(
      id: id,
      title: (map['title'] as String?)?.trim() ?? '',
      description: (map['description'] as String?)?.trim() ?? '',
      category: SupportGroupCategoryX.parse(map['category']),
      region: (map['region'] as String?)?.trim() ?? 'California',
      languages: SupportGroup._stringList(map['languages']),
      status: GroupSuggestionStatusX.parse(map['status']),
      suggesterUid: (map['suggesterUid'] as String?) ?? '',
      suggesterName: (map['suggesterName'] as String?)?.trim() ?? 'Member',
      suggesterEmail: (map['suggesterEmail'] as String?)?.trim() ?? '',
      createdAt: parseFirestoreDate(map['createdAt']),
      reviewedAt: parseFirestoreDate(map['reviewedAt']),
      reviewedByUid: map['reviewedByUid'] as String?,
      rejectReason: (map['rejectReason'] as String?)?.trim(),
      groupId: (map['groupId'] as String?)?.trim(),
      seenBySuggester: map['seenBySuggester'] == true,
    );
  }
}

/// Maps to Firestore `groups/{id}/posts/{postId}`.
class GroupPost {
  const GroupPost({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.groupId = '',
    this.title = '',
    this.text = '',
    this.kind = GroupPostKind.post,
    this.replyCount = 0,
    this.imagePaths = const [],
    this.createdAt,
    this.moderation = const GroupModeration(),
    this.removed = false,
    this.removedReason = '',
    this.removedAt,
    this.purgeAt,
    this.appealStatus = PostAppealStatus.none,
    this.appealMessage = '',
  });

  final String id;
  final String authorUid;
  final String authorName;
  final String groupId;
  final String title;
  final String text;
  final GroupPostKind kind;
  final int replyCount;
  final List<String> imagePaths;
  final DateTime? createdAt;
  final GroupModeration moderation;
  final bool removed;
  final String removedReason;
  final DateTime? removedAt;
  final DateTime? purgeAt;
  final PostAppealStatus appealStatus;
  final String appealMessage;

  bool get hasImage => imagePaths.isNotEmpty;

  bool get canAppealRemoval {
    if (!removed || appealStatus != PostAppealStatus.open) return false;
    final deadline = purgeAt;
    if (deadline == null) return true;
    return deadline.isAfter(DateTime.now());
  }

  String get displayTitle {
    if (title.isNotEmpty) return title;
    if (text.isEmpty) return 'Post';
    final first = text.split('\n').first.trim();
    if (first.length <= 80) return first;
    return '${first.substring(0, 77).trim()}…';
  }

  bool isVisibleInFeed({String? viewerUid, bool isAdmin = false}) {
    if (removed) {
      return isAdmin || (viewerUid != null && viewerUid == authorUid);
    }
    return moderation.isVisibleTo(
      authorUid: authorUid,
      viewerUid: viewerUid,
      isAdmin: isAdmin,
    );
  }

  factory GroupPost.fromMap(
    String id,
    Map<String, dynamic> map, {
    String groupId = '',
  }) {
    return GroupPost(
      id: id,
      authorUid: (map['authorUid'] as String?) ?? '',
      authorName: (map['authorName'] as String?)?.trim() ?? 'Member',
      groupId: groupId,
      title: (map['title'] as String?)?.trim() ?? '',
      text: (map['text'] as String?)?.trim() ?? '',
      kind: GroupPostKindX.parse(map['kind']),
      replyCount: (map['replyCount'] as num?)?.toInt() ?? 0,
      imagePaths: _imagePathsFromMap(map),
      createdAt: parseFirestoreDate(map['createdAt']),
      moderation: GroupModeration.fromMap(map),
      removed: map['removed'] == true,
      removedReason: (map['removedReason'] as String?)?.trim() ?? '',
      removedAt: parseFirestoreDate(map['removedAt']),
      purgeAt: parseFirestoreDate(map['purgeAt']),
      appealStatus: PostAppealStatusX.parse(map['appealStatus']),
      appealMessage: (map['appealMessage'] as String?)?.trim() ?? '',
    );
  }
}

List<String> _imagePathsFromMap(Map<String, dynamic> map) {
  final fromList = <String>[];
  final raw = map['imagePaths'];
  if (raw is List) {
    for (final item in raw) {
      final path = '$item'.trim();
      if (path.isNotEmpty) fromList.add(path);
    }
  }
  if (fromList.isNotEmpty) return fromList;
  final legacy = (map['imagePath'] as String?)?.trim() ?? '';
  return legacy.isEmpty ? const [] : [legacy];
}

enum GroupPostKind { post, question }

extension GroupPostKindX on GroupPostKind {
  String get label => switch (this) {
        GroupPostKind.post => 'Post',
        GroupPostKind.question => 'Question',
      };

  static GroupPostKind parse(Object? raw) {
    switch ('$raw'.trim().toLowerCase()) {
      case 'question':
        return GroupPostKind.question;
      case 'post':
      default:
        return GroupPostKind.post;
    }
  }
}

enum GroupModerationStatus { pending, approved, rejected }

extension GroupModerationStatusX on GroupModerationStatus {
  static GroupModerationStatus parse(Object? raw) {
    switch ('$raw'.trim().toLowerCase()) {
      case 'pending':
        return GroupModerationStatus.pending;
      case 'rejected':
        return GroupModerationStatus.rejected;
      case 'approved':
        return GroupModerationStatus.approved;
      default:
        // Older posts have no status and stay visible.
        return GroupModerationStatus.approved;
    }
  }
}

/// Server-side review result for a group post or reply.
class GroupModeration {
  const GroupModeration({
    this.status = GroupModerationStatus.approved,
    this.message = '',
    this.category = '',
  });

  final GroupModerationStatus status;
  final String message;
  final String category;

  bool get isPending => status == GroupModerationStatus.pending;
  bool get isRejected => status == GroupModerationStatus.rejected;
  bool get isApproved => status == GroupModerationStatus.approved;

  String get authorMessage {
    if (isPending) {
      return 'We are checking this before others can see it. It should appear in a moment.';
    }
    if (isRejected) {
      if (message.isNotEmpty) return message;
      return 'This was hidden because it did not meet community guidelines.';
    }
    return '';
  }

  bool isVisibleTo({
    required String authorUid,
    String? viewerUid,
    bool isAdmin = false,
  }) {
    if (isAdmin || isApproved) return true;
    return viewerUid != null && viewerUid == authorUid;
  }

  factory GroupModeration.fromMap(Map<String, dynamic> map) {
    return GroupModeration(
      status: GroupModerationStatusX.parse(map['moderationStatus']),
      message: (map['moderationMessage'] as String?)?.trim() ?? '',
      category: (map['moderationCategory'] as String?)?.trim() ?? '',
    );
  }
}

/// Maps to Firestore `groups/{id}/posts/{postId}/replies/{replyId}`.
class GroupReply {
  const GroupReply({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.text,
    this.createdAt,
    this.editedAt,
    this.moderation = const GroupModeration(),
  });

  final String id;
  final String authorUid;
  final String authorName;
  final String text;
  final DateTime? createdAt;
  final DateTime? editedAt;
  final GroupModeration moderation;

  bool isVisibleInFeed({String? viewerUid, bool isAdmin = false}) {
    return moderation.isVisibleTo(authorUid: authorUid, viewerUid: viewerUid, isAdmin: isAdmin);
  }

  factory GroupReply.fromMap(String id, Map<String, dynamic> map) {
    return GroupReply(
      id: id,
      authorUid: (map['authorUid'] as String?) ?? '',
      authorName: (map['authorName'] as String?)?.trim() ?? 'Member',
      text: (map['text'] as String?)?.trim() ?? '',
      createdAt: parseFirestoreDate(map['createdAt']),
      editedAt: parseFirestoreDate(map['editedAt']),
      moderation: GroupModeration.fromMap(map),
    );
  }
}

DateTime? parseFirestoreDate(Object? raw) {
  if (raw is Timestamp) return raw.toDate();
  if (raw is DateTime) return raw;
  if (raw is String) return DateTime.tryParse(raw);
  return null;
}

/// Official starter groups. Seeded once into Firestore (fixed ids).
const kStarterSupportGroups = <SupportGroup>[
  SupportGroup(
    id: 'ca-new-parents',
    title: 'New immigrant parents',
    description:
        'Share tips about schools, childcare, and raising kids in a new country. Meet other parents who understand the same questions.',
    category: SupportGroupCategory.parents,
    languages: ['en', 'es'],
  ),
  SupportGroup(
    id: 'ca-job-seekers',
    title: 'Job seekers',
    description:
        'Help each other with resumes, interviews, and finding a first job in the US. Celebrate small wins and share leads.',
    category: SupportGroupCategory.jobs,
    languages: ['en', 'es'],
  ),
  SupportGroup(
    id: 'ca-language-learners',
    title: 'Language learners',
    description:
        'Practice English, swap useful phrases, and find conversation partners. All levels are welcome.',
    category: SupportGroupCategory.language,
    languages: ['en', 'es'],
  ),
  SupportGroup(
    id: 'ca-professional-network',
    title: 'Professional networking',
    description:
        'Connect with others rebuilding a career. Share events, introductions, credential questions, and advice.',
    category: SupportGroupCategory.networking,
    languages: ['en'],
  ),
  SupportGroup(
    id: 'ca-cultural-community',
    title: 'Cultural community',
    description:
        'Celebrate your culture, find local events, and make friends who understand the journey of starting over.',
    category: SupportGroupCategory.culture,
    languages: ['en', 'es'],
  ),
  SupportGroup(
    id: 'ca-housing-circle',
    title: 'Housing circle',
    description:
        'Ask questions about renting, roommates, and avoiding housing scams. Support each other through the search.',
    category: SupportGroupCategory.housing,
    languages: ['en', 'es'],
  ),
];
