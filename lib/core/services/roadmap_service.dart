import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/roadmap.dart';

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

  Stream<IntegrationRoadmap> watchRoadmap() {
    final ref = _docRef();
    if (ref == null) return Stream.value(IntegrationRoadmap.empty());
    return ref.snapshots().map((snap) {
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
    await ref.set({
      '${key.firestoreKey}.notes': FieldValue.arrayUnion([note.toMap()]),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
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

  Future<void> addQaExchange(
    RoadmapSectionKey key,
    RoadmapQaExchange exchange,
  ) async {
    final ref = _docRef();
    if (ref == null) throw StateError('No signed-in user.');
    await ref.set({
      '${key.firestoreKey}.qaHistory':
          FieldValue.arrayUnion([exchange.toMap()]),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
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
  return ref.watch(roadmapServiceProvider).watchRoadmap();
});
