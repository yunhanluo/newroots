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
    this.title = '',
    this.text = '',
    this.kind = GroupPostKind.post,
    this.replyCount = 0,
    this.imagePaths = const [],
    this.createdAt,
  });

  final String id;
  final String authorUid;
  final String authorName;
  final String title;
  final String text;
  final GroupPostKind kind;
  final int replyCount;
  final List<String> imagePaths;
  final DateTime? createdAt;

  bool get hasImage => imagePaths.isNotEmpty;

  String get displayTitle {
    if (title.isNotEmpty) return title;
    if (text.isEmpty) return 'Post';
    final first = text.split('\n').first.trim();
    if (first.length <= 80) return first;
    return '${first.substring(0, 77).trim()}…';
  }

  factory GroupPost.fromMap(String id, Map<String, dynamic> map) {
    return GroupPost(
      id: id,
      authorUid: (map['authorUid'] as String?) ?? '',
      authorName: (map['authorName'] as String?)?.trim() ?? 'Member',
      title: (map['title'] as String?)?.trim() ?? '',
      text: (map['text'] as String?)?.trim() ?? '',
      kind: GroupPostKindX.parse(map['kind']),
      replyCount: (map['replyCount'] as num?)?.toInt() ?? 0,
      imagePaths: _imagePathsFromMap(map),
      createdAt: parseFirestoreDate(map['createdAt']),
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

/// Maps to Firestore `groups/{id}/posts/{postId}/replies/{replyId}`.
class GroupReply {
  const GroupReply({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.text,
    this.createdAt,
  });

  final String id;
  final String authorUid;
  final String authorName;
  final String text;
  final DateTime? createdAt;

  factory GroupReply.fromMap(String id, Map<String, dynamic> map) {
    return GroupReply(
      id: id,
      authorUid: (map['authorUid'] as String?) ?? '',
      authorName: (map['authorName'] as String?)?.trim() ?? 'Member',
      text: (map['text'] as String?)?.trim() ?? '',
      createdAt: parseFirestoreDate(map['createdAt']),
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
