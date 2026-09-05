import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/roadmap.dart';
import 'auth_service.dart';

/// Persists roadmap state under `users/{uid}/roadmap/main`.
class RoadmapService {
  RoadmapService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>>? _docRef() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('roadmap').doc('main');
  }

  Stream<IntegrationRoadmap> watchRoadmap(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('roadmap')
        .doc('main')
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) {
        return IntegrationRoadmap.empty();
      }
      return IntegrationRoadmap.fromMap(snap.data());
    });
  }

  Future<IntegrationRoadmap> getRoadmap() async {
    final ref = _docRef();
    if (ref == null) return IntegrationRoadmap.empty();
    final snap = await ref.get();
    if (!snap.exists || snap.data() == null) {
      return IntegrationRoadmap.empty();
    }
    return IntegrationRoadmap.fromMap(snap.data());
  }

  Future<void> saveRoadmap(IntegrationRoadmap roadmap) async {
    final ref = _docRef();
    if (ref == null) throw StateError('No signed-in user.');
    final now = DateTime.now();
    final data = roadmap.toMap()
      ..['updatedAt'] = now.toIso8601String()
      ..putIfAbsent(
        'generatedAt',
        () => (roadmap.generatedAt ?? now).toIso8601String(),
      );
    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> addNote(RoadmapSectionKey key, String text) async {
    final ref = _docRef();
    if (ref == null) throw StateError('No signed-in user.');
    final note = RoadmapNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    await _appendToSectionList(ref, key, 'notes', note.toMap());
  }

  Future<void> deleteNote(RoadmapSectionKey key, RoadmapNote note) async {
    final ref = _docRef();
    if (ref == null) throw StateError('No signed-in user.');
    final current = await getRoadmap();
    final remaining = current
        .sectionFor(key)
        .notes
        .where((item) => !_sameNote(item, note))
        .map((item) => item.toMap())
        .toList();
    await ref.update({
      '${key.firestoreKey}.notes': remaining,
      FieldPath(['${key.firestoreKey}.notes']): FieldValue.delete(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  bool _sameNote(RoadmapNote left, RoadmapNote right) {
    if (left.id.isNotEmpty && right.id.isNotEmpty) return left.id == right.id;
    return left.text == right.text &&
        left.createdAt.toIso8601String() == right.createdAt.toIso8601String();
  }

  Future<void> updateSection(
    RoadmapSectionKey key,
    RoadmapSection section,
  ) async {
    final ref = _docRef();
    if (ref == null) throw StateError('No signed-in user.');
    await ref.set({
      key.firestoreKey: section.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  /// `set(merge: true)` treats `'firstMonth.notes'` as a literal field name.
  /// `update()` is required so dotted paths write into the nested section map.
  Future<void> _appendToSectionList(
    DocumentReference<Map<String, dynamic>> ref,
    RoadmapSectionKey key,
    String listField,
    Map<String, dynamic> item,
  ) async {
    final path = '${key.firestoreKey}.$listField';
    final payload = {
      path: FieldValue.arrayUnion([item]),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    try {
      await ref.update(payload);
    } on FirebaseException catch (error) {
      if (error.code != 'not-found') rethrow;
      await ref.set({
        key.firestoreKey: {
          listField: [item],
        },
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> addClarification(ClarificationExchange exchange) async {
    final ref = _docRef();
    if (ref == null) throw StateError('No signed-in user.');
    await ref.set({
      'clarifications': FieldValue.arrayUnion([exchange.toMap()]),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}

final roadmapServiceProvider = Provider<RoadmapService>(
  (ref) => RoadmapService(FirebaseFirestore.instance, FirebaseAuth.instance),
);

final roadmapProvider = StreamProvider<IntegrationRoadmap>((ref) {
  return watchForSignedInUser(
    ref: ref,
    whenSignedOut: IntegrationRoadmap.empty(),
    watch: (uid) => ref.watch(roadmapServiceProvider).watchRoadmap(uid),
  );
});
