import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/support_group.dart';
import 'auth_service.dart';
import 'group_content_policy.dart';
import 'admin_service.dart';

const _maxPostLength = 2000;
const _maxImageBytes = 8 * 1024 * 1024;
const kMaxGroupPostImages = 6;

/// Local mutual support groups: discover, join, and post in real time.
class SupportGroupService {
  SupportGroupService(this._firestore, this._auth, this._functions, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection('groups');

  CollectionReference<Map<String, dynamic>> get _suggestions =>
      _firestore.collection('groupSuggestions');

  /// Short name shown to other members. Never the full email address.
  String get currentDisplayName {
    final email = _auth.currentUser?.email?.trim() ?? '';
    if (email.contains('@')) {
      final local = email.split('@').first.trim();
      if (local.isNotEmpty) return local;
    }
    return 'Member';
  }

  Stream<List<SupportGroup>> watchGroups() {
    return _groups.orderBy('title').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SupportGroup.fromMap(doc.id, doc.data()))
          .where((group) => group.title.isNotEmpty)
          .toList();
    });
  }

  Stream<SupportGroup?> watchGroup(String groupId) {
    return _groups.doc(groupId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return SupportGroup.fromMap(doc.id, doc.data()!);
    });
  }

  Stream<List<GroupMembership>> watchMyMemberships(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('groupMemberships')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GroupMembership.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<int> watchMemberCount(String groupId) {
    return _groups.doc(groupId).collection('members').snapshots().map(
          (snapshot) => snapshot.docs.length,
        );
  }

  Stream<List<GroupPost>> watchPosts(String groupId) {
    return _groups
        .doc(groupId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GroupPost.fromMap(doc.id, doc.data(), groupId: groupId))
          .where((post) => post.title.isNotEmpty || post.text.isNotEmpty)
          .toList();
    });
  }

  Future<void> joinGroup(SupportGroup group) async {
    final uid = _uid;
    if (uid == null) {
      throw const SupportGroupException('Sign in to join a group.');
    }
    if (group.deleted) {
      throw const SupportGroupException('This group is no longer available.');
    }
    final memberRef = _groups.doc(group.id).collection('members').doc(uid);
    final membershipRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('groupMemberships')
        .doc(group.id);

    try {
      final batch = _firestore.batch();
      batch.set(memberRef, {
        'uid': uid,
        'displayName': currentDisplayName,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      batch.set(membershipRef, {
        'groupId': group.id,
        'title': group.title,
        'category': group.category.name,
        'joinedAt': FieldValue.serverTimestamp(),
        'deletedNoticeSeen': false,
      });
      await batch.commit();
    } on FirebaseException catch (e) {
      throw SupportGroupException(_friendly(e, 'Could not join that group.'));
    }
  }

  Future<void> leaveGroup(String groupId) async {
    final uid = _uid;
    if (uid == null) {
      throw const SupportGroupException('Sign in to leave a group.');
    }
    try {
      final batch = _firestore.batch();
      batch.delete(_groups.doc(groupId).collection('members').doc(uid));
      batch.delete(
        _firestore
            .collection('users')
            .doc(uid)
            .collection('groupMemberships')
            .doc(groupId),
      );
      await batch.commit();
    } on FirebaseException catch (e) {
      throw SupportGroupException(_friendly(e, 'Could not leave that group.'));
    }
  }

  Future<void> deleteGroup(String groupId, {required String reason}) async {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) {
      throw const SupportGroupException(
        'Add a short message so members know why the group was removed.',
      );
    }
    if (trimmed.length > 300) {
      throw const SupportGroupException(
        'Keep the message under 300 characters.',
      );
    }
    try {
      final groupRef = _groups.doc(groupId);
      final posts = await groupRef.collection('posts').get();
      final batch = _firestore.batch();
      for (final doc in posts.docs) {
        batch.delete(doc.reference);
      }
      batch.update(groupRef, {
        'deleted': true,
        'deletedReason': trimmed,
        'deletedAt': FieldValue.serverTimestamp(),
        if (_uid != null) 'deletedByUid': _uid,
      });
      await batch.commit();
    } on FirebaseException catch (e) {
      throw SupportGroupException(_friendly(e, 'Could not delete that group.'));
    }
  }

  Stream<GroupPost?> watchPost(String groupId, String postId) {
    return _groups.doc(groupId).collection('posts').doc(postId).snapshots().map(
      (doc) {
        if (!doc.exists || doc.data() == null) return null;
        return GroupPost.fromMap(doc.id, doc.data()!, groupId: groupId);
      },
    );
  }

  Stream<List<GroupReply>> watchReplies(String groupId, String postId) {
    return _groups
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .collection('replies')
        .orderBy('createdAt')
        .limit(200)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GroupReply.fromMap(doc.id, doc.data()))
          .where((reply) => reply.text.isNotEmpty)
          .toList();
    });
  }

  Future<void> createPost({
    required String groupId,
    required String title,
    required String text,
    GroupPostKind kind = GroupPostKind.post,
    List<GroupPostImageUpload> images = const [],
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const SupportGroupException('Sign in to post.');
    }
    final trimmedTitle = title.trim();
    final trimmed = text.trim();
    if (trimmedTitle.isEmpty) {
      throw const SupportGroupException('Give this post a title.');
    }
    if (trimmedTitle.length > 120) {
      throw const SupportGroupException('Keep the title under 120 characters.');
    }
    if (trimmed.length > _maxPostLength) {
      throw const SupportGroupException(
        'Please keep posts under 2,000 characters.',
      );
    }
    final blocked = GroupContentPolicy.blockedReason(
      title: trimmedTitle,
      text: trimmed,
    );
    if (blocked != null) {
      throw SupportGroupException(blocked);
    }
    if (images.length > kMaxGroupPostImages) {
      throw const SupportGroupException(
        'You can add up to 6 photos.',
      );
    }
    for (final image in images) {
      if (image.bytes.length > _maxImageBytes) {
        throw const SupportGroupException(
          'Please choose smaller photos (each under 8 MB).',
        );
      }
    }
    try {
      final group = await _groups.doc(groupId).get();
      if (group.data()?['deleted'] == true) {
        throw const SupportGroupException('This group is no longer available.');
      }
    } on SupportGroupException {
      rethrow;
    } catch (_) {}

    final imagePaths = <String>[];
    try {
      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        imagePaths.add(
          await _uploadPostImage(
            groupId: groupId,
            uid: uid,
            bytes: image.bytes,
            contentType: image.contentType,
            extension: image.extension,
            index: i,
          ),
        );
      }
      final data = <String, dynamic>{
        'authorUid': uid,
        'authorName': currentDisplayName,
        'title': trimmedTitle,
        'text': trimmed,
        'kind': kind.name,
        'replyCount': 0,
        'moderationStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (imagePaths.isNotEmpty) {
        data['imagePaths'] = imagePaths;
      }
      await _groups.doc(groupId).collection('posts').add(data);
    } on SupportGroupException {
      await _deleteUploadedImages(imagePaths);
      rethrow;
    } on FirebaseException catch (e) {
      await _deleteUploadedImages(imagePaths);
      throw SupportGroupException(_friendly(e, 'Could not publish that post.'));
    }
  }

  Future<void> _deleteUploadedImages(List<String> paths) async {
    for (final path in paths) {
      try {
        await _storage.ref(path).delete();
      } catch (_) {}
    }
  }

  Future<String> _uploadPostImage({
    required String groupId,
    required String uid,
    required Uint8List bytes,
    required String contentType,
    required String extension,
    int index = 0,
  }) async {
    final safeExt = extension.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final ext = safeExt.isEmpty ? 'jpg' : safeExt;
    final path =
        'group-posts/$groupId/$uid/${DateTime.now().microsecondsSinceEpoch}_$index.$ext';
    try {
      await _storage.ref(path).putData(
            bytes,
            SettableMetadata(contentType: contentType),
          );
      return path;
    } on FirebaseException catch (e) {
      throw SupportGroupException(
        _friendly(e, 'Could not upload that photo.'),
      );
    }
  }

  Future<Uint8List?> downloadPostImage(String imagePath) async {
    final path = imagePath.trim().replaceFirst(RegExp(r'^/+'), '');
    if (!path.startsWith('group-posts/') || path.contains('..')) return null;
    try {
      return await _storage.ref(path).getData(_maxImageBytes);
    } catch (_) {
      return null;
    }
  }

  Future<void> createReply({
    required String groupId,
    required String postId,
    required String text,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const SupportGroupException('Sign in to reply.');
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const SupportGroupException('Write a reply first.');
    }
    if (trimmed.length > _maxPostLength) {
      throw const SupportGroupException(
        'Please keep replies under 2,000 characters.',
      );
    }
    final blocked = GroupContentPolicy.blockedReason(text: trimmed);
    if (blocked != null) {
      throw SupportGroupException(blocked);
    }
    try {
      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final batch = _firestore.batch();
      batch.set(postRef.collection('replies').doc(), {
        'authorUid': uid,
        'authorName': currentDisplayName,
        'text': trimmed,
        'moderationStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(postRef, {
        'replyCount': FieldValue.increment(1),
      });
      await batch.commit();
    } on FirebaseException catch (e) {
      throw SupportGroupException(_friendly(e, 'Could not send that reply.'));
    }
  }

  Future<void> deletePost({
    required String groupId,
    required String postId,
    String? removalReason,
  }) async {
    try {
      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final snap = await postRef.get();
      final data = snap.data();
      if (data == null) {
        throw const SupportGroupException('This post was already removed.');
      }
      if (data['removed'] == true) {
        throw const SupportGroupException(
          'This post is already hidden from the group.',
        );
      }
      final authorUid = (data['authorUid'] as String?) ?? '';
      final imagePaths = _storagePathsFromPost(data);
      final ownPost = authorUid.isNotEmpty && authorUid == _uid;
      final reason = removalReason?.trim() ?? '';

      if (ownPost) {
        await _hardDeletePost(postRef: postRef, imagePaths: imagePaths);
        return;
      }

      if (reason.isEmpty) {
        throw const SupportGroupException(
          'Please say why this post is being removed.',
        );
      }
      if (reason.length > 400) {
        throw const SupportGroupException(
          'Keep the reason under 400 characters.',
        );
      }
      if (authorUid.isEmpty) {
        throw const SupportGroupException('Could not find who wrote that post.');
      }

      final groupSnap = await _groups.doc(groupId).get();
      final groupTitle =
          (groupSnap.data()?['title'] as String?)?.trim() ?? 'a group';
      final postTitle = _postTitleFromMap(data);
      final purgeAt = Timestamp.fromDate(
        DateTime.now().toUtc().add(kPostRemovalAppealDuration),
      );
      final noticeRef = _firestore
          .collection('users')
          .doc(authorUid)
          .collection('postDeletionNotices')
          .doc(postDeletionNoticeId(groupId, postId));

      final batch = _firestore.batch();
      batch.update(postRef, {
        'removed': true,
        'removedReason': reason,
        'removedAt': FieldValue.serverTimestamp(),
        'removedByUid': _uid,
        'purgeAt': purgeAt,
        'appealStatus': 'open',
        'appealMessage': '',
      });
      batch.set(noticeRef, {
        'authorUid': authorUid,
        'groupId': groupId,
        'postId': postId,
        'groupTitle': groupTitle,
        'postTitle': postTitle,
        'reason': reason,
        'appealStatus': 'open',
        'appealMessage': '',
        'seen': false,
        'purgeAt': purgeAt,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } on SupportGroupException {
      rethrow;
    } on FirebaseException catch (e) {
      throw SupportGroupException(_friendly(e, 'Could not delete that post.'));
    }
  }

  Future<void> appealPostRemoval({
    required String groupId,
    required String postId,
    String? message,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const SupportGroupException('Sign in to appeal.');
    }
    final trimmed = (message ?? '').trim();
    if (trimmed.length > 400) {
      throw const SupportGroupException(
        'Keep the appeal under 400 characters.',
      );
    }
    try {
      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final snap = await postRef.get();
      final data = snap.data();
      if (data == null || data['removed'] != true) {
        throw const SupportGroupException('That post is not waiting for an appeal.');
      }
      if (data['authorUid'] != uid) {
        throw const SupportGroupException('Only the author can appeal.');
      }
      if ('${data['appealStatus'] ?? ''}' != 'open') {
        throw const SupportGroupException('This post was already appealed.');
      }
      final purgeAt = parseFirestoreDate(data['purgeAt']);
      if (purgeAt != null && !purgeAt.isAfter(DateTime.now())) {
        throw const SupportGroupException(
          'The window to appeal this post has ended.',
        );
      }
      final noticeRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('postDeletionNotices')
          .doc(postDeletionNoticeId(groupId, postId));
      final batch = _firestore.batch();
      batch.update(postRef, {
        'appealStatus': 'pending',
        'appealMessage': trimmed,
        'appealedAt': FieldValue.serverTimestamp(),
      });
      batch.update(noticeRef, {
        'appealStatus': 'pending',
        'appealMessage': trimmed,
        'appealedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } on SupportGroupException {
      rethrow;
    } on FirebaseException catch (e) {
      throw SupportGroupException(_friendly(e, 'Could not send that appeal.'));
    }
  }

  Future<void> restoreRemovedPost({
    required String groupId,
    required String postId,
  }) async {
    try {
      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final snap = await postRef.get();
      final data = snap.data();
      if (data == null) {
        throw const SupportGroupException('This post was already removed.');
      }
      final authorUid = (data['authorUid'] as String?) ?? '';
      await postRef.update({
        'removed': FieldValue.delete(),
        'removedReason': FieldValue.delete(),
        'removedAt': FieldValue.delete(),
        'removedByUid': FieldValue.delete(),
        'purgeAt': FieldValue.delete(),
        'appealStatus': FieldValue.delete(),
        'appealMessage': FieldValue.delete(),
        'appealedAt': FieldValue.delete(),
      });
      if (authorUid.isEmpty) return;
      try {
        await _firestore
            .collection('users')
            .doc(authorUid)
            .collection('postDeletionNotices')
            .doc(postDeletionNoticeId(groupId, postId))
            .update({
          'appealStatus': 'approved',
          'seen': false,
          'decidedAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException {
        // Notice may already be gone.
      }
    } on SupportGroupException {
      rethrow;
    } on FirebaseException catch (e) {
      throw SupportGroupException(
        _friendly(e, 'Could not restore that post.'),
      );
    }
  }

  Future<void> denyPostAppeal({
    required String groupId,
    required String postId,
  }) async {
    try {
      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final snap = await postRef.get();
      final data = snap.data();
      if (data == null) {
        throw const SupportGroupException('This post was already removed.');
      }
      final authorUid = (data['authorUid'] as String?) ?? '';
      final imagePaths = _storagePathsFromPost(data);
      await _hardDeletePost(postRef: postRef, imagePaths: imagePaths);
      if (authorUid.isEmpty) return;
      try {
        await _firestore
            .collection('users')
            .doc(authorUid)
            .collection('postDeletionNotices')
            .doc(postDeletionNoticeId(groupId, postId))
            .update({
          'appealStatus': 'denied',
          'seen': false,
          'decidedAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException {
        // Notice may already be gone.
      }
    } on SupportGroupException {
      rethrow;
    } on FirebaseException catch (e) {
      throw SupportGroupException(
        _friendly(e, 'Could not finish removing that post.'),
      );
    }
  }

  Future<void> _hardDeletePost({
    required DocumentReference<Map<String, dynamic>> postRef,
    required List<String> imagePaths,
  }) async {
    final replies = await postRef.collection('replies').get();
    final batch = _firestore.batch();
    for (final doc in replies.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(postRef);
    await batch.commit();
    await _deleteUploadedImages(imagePaths);
  }

  Stream<List<GroupPost>> watchPendingPostAppeals() {
    return _firestore
        .collectionGroup('posts')
        .where('appealStatus', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final groupId = doc.reference.parent.parent?.id ?? '';
        return GroupPost.fromMap(doc.id, doc.data(), groupId: groupId);
      }).toList()
        ..sort(
          (a, b) => (b.removedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.removedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );
      return items;
    });
  }

  String _postTitleFromMap(Map<String, dynamic> map) {
    final title = (map['title'] as String?)?.trim() ?? '';
    if (title.isNotEmpty) return title;
    final text = (map['text'] as String?)?.trim() ?? '';
    if (text.isEmpty) return 'Your post';
    final first = text.split('\n').first.trim();
    if (first.length <= 80) return first;
    return '${first.substring(0, 77).trim()}…';
  }

  Future<void> updateReply({
    required String groupId,
    required String postId,
    required String replyId,
    required String text,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const SupportGroupException('Sign in to edit.');
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const SupportGroupException('Write a reply first.');
    }
    if (trimmed.length > _maxPostLength) {
      throw const SupportGroupException(
        'Please keep replies under 2,000 characters.',
      );
    }
    final blocked = GroupContentPolicy.blockedReason(text: trimmed);
    if (blocked != null) {
      throw SupportGroupException(blocked);
    }
    try {
      await _groups
          .doc(groupId)
          .collection('posts')
          .doc(postId)
          .collection('replies')
          .doc(replyId)
          .update({
        'text': trimmed,
        'editedAt': FieldValue.serverTimestamp(),
        'moderationStatus': 'pending',
      });
    } on FirebaseException catch (e) {
      throw SupportGroupException(_friendly(e, 'Could not save that edit.'));
    }
  }

  Future<void> deleteReply({
    required String groupId,
    required String postId,
    required String replyId,
  }) async {
    try {
      final postRef = _groups.doc(groupId).collection('posts').doc(postId);
      final batch = _firestore.batch();
      batch.delete(postRef.collection('replies').doc(replyId));
      batch.update(postRef, {
        'replyCount': FieldValue.increment(-1),
      });
      await batch.commit();
    } on FirebaseException catch (e) {
      throw SupportGroupException(_friendly(e, 'Could not delete that reply.'));
    }
  }

  Future<void> suggestGroup({
    required String title,
    required String description,
    required SupportGroupCategory category,
    String region = 'California',
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const SupportGroupException('Sign in to suggest a group.');
    }
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();
    if (trimmedTitle.isEmpty) {
      throw const SupportGroupException('Give the group a name.');
    }
    if (trimmedTitle.length > 80) {
      throw const SupportGroupException('Keep the name under 80 characters.');
    }
    if (trimmedDescription.isEmpty) {
      throw const SupportGroupException('Add a short description.');
    }
    if (trimmedDescription.length > 600) {
      throw const SupportGroupException(
        'Keep the description under 600 characters.',
      );
    }
    try {
      await _suggestions.add({
        'title': trimmedTitle,
        'description': trimmedDescription,
        'category': category.name,
        'region': region.trim().isEmpty ? 'California' : region.trim(),
        'languages': const ['en'],
        'status': 'pending',
        'suggesterUid': uid,
        'suggesterName': currentDisplayName,
        'suggesterEmail': _auth.currentUser?.email?.trim() ?? '',
        'seenBySuggester': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw SupportGroupException(
        _friendly(e, 'Could not send that suggestion.'),
      );
    }
  }

  Stream<List<GroupSuggestion>> watchSuggestions() {
    return _suggestions
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GroupSuggestion.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<GroupSuggestion>> watchMySuggestions(String uid) {
    return _suggestions
        .where('suggesterUid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => GroupSuggestion.fromMap(doc.id, doc.data()))
          .toList()
        ..sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      return items;
    });
  }

  Future<void> approveSuggestion(GroupSuggestion suggestion) async {
    final uid = _uid;
    if (uid == null) {
      throw const SupportGroupException('Sign in as an admin to approve.');
    }
    if (suggestion.status != GroupSuggestionStatus.pending) {
      throw const SupportGroupException('That suggestion was already reviewed.');
    }
    final groupRef = _groups.doc();
    final suggesterUid = suggestion.suggesterUid.trim();
    try {
      final batch = _firestore.batch();
      batch.set(groupRef, {
        'title': suggestion.title,
        'description': suggestion.description,
        'category': suggestion.category.name,
        'region': suggestion.region,
        'languages': suggestion.languages,
        'createdAt': FieldValue.serverTimestamp(),
        'fromSuggestionId': suggestion.id,
      });
      batch.update(_suggestions.doc(suggestion.id), {
        'status': 'approved',
        'groupId': groupRef.id,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedByUid': uid,
        'seenBySuggester': false,
      });
      if (suggesterUid.isNotEmpty) {
        final displayName = suggestion.suggesterName.trim().isEmpty
            ? 'Member'
            : suggestion.suggesterName.trim();
        batch.set(groupRef.collection('members').doc(suggesterUid), {
          'uid': suggesterUid,
          'displayName': displayName,
          'joinedAt': FieldValue.serverTimestamp(),
        });
        batch.set(
          _firestore
              .collection('users')
              .doc(suggesterUid)
              .collection('groupMemberships')
              .doc(groupRef.id),
          {
            'groupId': groupRef.id,
            'title': suggestion.title,
            'category': suggestion.category.name,
            'joinedAt': FieldValue.serverTimestamp(),
            'deletedNoticeSeen': false,
          },
        );
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw SupportGroupException(
        _friendly(e, 'Could not approve that suggestion.'),
      );
    }
  }

  Future<void> rejectSuggestion(
    GroupSuggestion suggestion, {
    String? reason,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const SupportGroupException('Sign in as an admin to decline.');
    }
    if (suggestion.status != GroupSuggestionStatus.pending) {
      throw const SupportGroupException('That suggestion was already reviewed.');
    }
    try {
      await _suggestions.doc(suggestion.id).update({
        'status': 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedByUid': uid,
        'seenBySuggester': false,
        if (reason != null && reason.trim().isNotEmpty)
          'rejectReason': reason.trim(),
      });
    } on FirebaseException catch (e) {
      throw SupportGroupException(
        _friendly(e, 'Could not decline that suggestion.'),
      );
    }
  }

  Future<void> markDeletedNoticeSeen(String groupId) async {
    final uid = _uid;
    if (uid == null) {
      throw const SupportGroupException('Sign in to dismiss that notice.');
    }
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groupMemberships')
          .doc(groupId)
          .update({'deletedNoticeSeen': true});
    } on FirebaseException catch (e) {
      throw SupportGroupException(
        _friendly(e, 'Could not dismiss that notice.'),
      );
    }
  }

  Future<void> markPostDeletionNoticeSeen(String noticeId) async {
    final uid = _uid;
    if (uid == null) {
      throw const SupportGroupException('Sign in to dismiss that notice.');
    }
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('postDeletionNotices')
          .doc(noticeId)
          .update({'seen': true});
    } on FirebaseException catch (e) {
      throw SupportGroupException(
        _friendly(e, 'Could not dismiss that notice.'),
      );
    }
  }

  Stream<List<PostDeletionNotice>> watchPostDeletionNotices(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('postDeletionNotices')
        .where('seen', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => PostDeletionNotice.fromMap(doc.id, doc.data()))
          .toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );
      return items;
    });
  }

  Future<void> markSuggestionSeen(String suggestionId) async {
    try {
      await _suggestions.doc(suggestionId).update({
        'seenBySuggester': true,
      });
    } on FirebaseException catch (e) {
      throw SupportGroupException(
        _friendly(e, 'Could not dismiss that notice.'),
      );
    }
  }

  /// Writes the official starter groups if they are missing.
  ///
  /// Tries a client write first (signed-in create). If rules still require
  /// admin, falls back to the `seedSupportGroups` Cloud Function.
  Future<int> seedStarterGroups() async {
    final existing = await _groups.limit(1).get();
    var written = 0;
    for (final group in kStarterSupportGroups) {
      final ref = _groups.doc(group.id);
      try {
        final doc = await ref.get();
        if (doc.exists) continue;
        await ref.set({
          ...group.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        written += 1;
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          continue;
        }
        throw SupportGroupException(
          _friendly(e, 'Could not load starter groups.'),
        );
      }
    }
    if (written > 0 || existing.docs.isNotEmpty) return written;

    try {
      final result = await _functions
          .httpsCallable('seedSupportGroups')
          .call<Map<String, dynamic>>();
      final data = Map<String, dynamic>.from(result.data);
      return (data['written'] as num?)?.toInt() ?? 0;
    } on FirebaseFunctionsException catch (e) {
      throw SupportGroupException(
        e.message ??
            'Could not load starter groups. Deploy Firestore rules, then try again.',
      );
    } catch (_) {
      throw const SupportGroupException(
        'Could not load starter groups. Deploy Firestore rules '
        '(firebase deploy --only firestore:rules), then try again.',
      );
    }
  }

  String _friendly(FirebaseException e, String fallback) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have access to do that.';
      case 'unavailable':
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return fallback;
    }
  }
}

class SupportGroupException implements Exception {
  const SupportGroupException(this.message);
  final String message;

  @override
  String toString() => message;
}

class GroupPostImageUpload {
  const GroupPostImageUpload({
    required this.bytes,
    this.contentType = 'image/jpeg',
    this.extension = 'jpg',
  });

  final Uint8List bytes;
  final String contentType;
  final String extension;
}

List<String> _storagePathsFromPost(Map<String, dynamic>? data) {
  if (data == null) return const [];
  final paths = <String>[];
  final raw = data['imagePaths'];
  if (raw is List) {
    for (final item in raw) {
      final path = '$item'.trim();
      if (path.startsWith('group-posts/') && !path.contains('..')) {
        paths.add(path);
      }
    }
  }
  if (paths.isEmpty) {
    final legacy = (data['imagePath'] as String?)?.trim() ?? '';
    if (legacy.startsWith('group-posts/') && !legacy.contains('..')) {
      paths.add(legacy);
    }
  }
  return paths;
}

final supportGroupServiceProvider = Provider<SupportGroupService>(
  (ref) => SupportGroupService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
    FirebaseFunctions.instanceFor(region: 'us-west1'),
    FirebaseStorage.instance,
  ),
);

final supportGroupsProvider = StreamProvider<List<SupportGroup>>((ref) {
  return ref.watch(supportGroupServiceProvider).watchGroups();
});

final myMembershipsProvider = StreamProvider<List<GroupMembership>>((ref) {
  return watchForSignedInUser(
    ref: ref,
    whenSignedOut: const <GroupMembership>[],
    watch: (uid) =>
        ref.watch(supportGroupServiceProvider).watchMyMemberships(uid),
  );
});

final myGroupIdsProvider = Provider<Set<String>>((ref) {
  final memberships = ref.watch(myMembershipsProvider).value ?? const [];
  return {for (final m in memberships) m.groupId};
});

/// Groups the signed-in user belongs to that an admin has removed, and the
/// member has not dismissed the notice yet. The admin who deleted the group
/// is skipped — they already know.
final deletedGroupNoticesProvider = Provider<List<SupportGroup>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  final groups = ref.watch(supportGroupsProvider).value ?? const <SupportGroup>[];
  final memberships =
      ref.watch(myMembershipsProvider).value ?? const <GroupMembership>[];
  final unseenIds = {
    for (final m in memberships)
      if (!m.deletedNoticeSeen) m.groupId,
  };
  return groups.where((group) {
    if (!group.deleted) return false;
    if (!unseenIds.contains(group.id)) return false;
    if (uid != null && group.deletedByUid == uid) return false;
    return true;
  }).toList();
});

final supportGroupProvider =
    StreamProvider.family<SupportGroup?, String>((ref, groupId) {
  return ref.watch(supportGroupServiceProvider).watchGroup(groupId);
});

final groupPostsProvider =
    StreamProvider.family<List<GroupPost>, String>((ref, groupId) {
  final uid = ref.watch(authStateProvider).value?.uid;
  final isAdmin = ref.watch(isAdminProvider);
  return ref.watch(supportGroupServiceProvider).watchPosts(groupId).map(
        (posts) => posts
            .where(
              (post) => post.isVisibleInFeed(viewerUid: uid, isAdmin: isAdmin),
            )
            .toList(),
      );
});

final groupPostProvider =
    StreamProvider.family<GroupPost?, (String, String)>((ref, key) {
  return ref.watch(supportGroupServiceProvider).watchPost(key.$1, key.$2);
});

final groupRepliesProvider =
    StreamProvider.family<List<GroupReply>, (String, String)>((ref, key) {
  final uid = ref.watch(authStateProvider).value?.uid;
  final isAdmin = ref.watch(isAdminProvider);
  return ref.watch(supportGroupServiceProvider).watchReplies(key.$1, key.$2).map(
        (replies) => replies
            .where(
              (reply) => reply.isVisibleInFeed(viewerUid: uid, isAdmin: isAdmin),
            )
            .toList(),
      );
});

final groupMemberCountProvider =
    StreamProvider.family<int, String>((ref, groupId) {
  return ref.watch(supportGroupServiceProvider).watchMemberCount(groupId);
});

final groupSuggestionsProvider = StreamProvider<List<GroupSuggestion>>((ref) {
  return ref.watch(supportGroupServiceProvider).watchSuggestions();
});

final myGroupSuggestionsProvider =
    StreamProvider<List<GroupSuggestion>>((ref) {
  return watchForSignedInUser(
    ref: ref,
    whenSignedOut: const <GroupSuggestion>[],
    watch: (uid) =>
        ref.watch(supportGroupServiceProvider).watchMySuggestions(uid),
  );
});

final unseenPostDeletionNoticesProvider =
    StreamProvider<List<PostDeletionNotice>>((ref) {
  return watchForSignedInUser(
    ref: ref,
    whenSignedOut: const <PostDeletionNotice>[],
    watch: (uid) =>
        ref.watch(supportGroupServiceProvider).watchPostDeletionNotices(uid),
  );
});

final pendingPostAppealsProvider = StreamProvider<List<GroupPost>>((ref) {
  if (!ref.watch(isAdminProvider)) {
    return Stream.value(const <GroupPost>[]);
  }
  return ref.watch(supportGroupServiceProvider).watchPendingPostAppeals();
});

final unseenSuggestionReviewsProvider = Provider<List<GroupSuggestion>>((ref) {
  final items = ref.watch(myGroupSuggestionsProvider).value ?? const [];
  return items.where((s) => s.isUnseenReview).toList();
});
