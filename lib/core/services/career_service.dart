import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/career.dart';

/// Persists career bridge state under `users/{uid}/career/main`.
class CareerService {
  CareerService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>>? _docRef() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('career').doc('main');
  }

  Stream<CareerBridgeData> watchCareer() {
    final ref = _docRef();
    if (ref == null) return Stream.value(CareerBridgeData.empty());
    return ref.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return CareerBridgeData.empty();
      }
      return CareerBridgeData.fromMap(snap.data());
    });
  }

  Future<CareerBridgeData> getCareer() async {
    final ref = _docRef();
    if (ref == null) return CareerBridgeData.empty();
    final snap = await ref.get();
    if (!snap.exists || snap.data() == null) {
      return CareerBridgeData.empty();
    }
    return CareerBridgeData.fromMap(snap.data());
  }

  Future<void> saveCareer(CareerBridgeData career) async {
    final ref = _docRef();
    if (ref == null) throw StateError('No signed-in user.');
    final now = DateTime.now();
    final data = career.toMap()
      ..['updatedAt'] = now.toIso8601String()
      ..putIfAbsent(
        'generatedAt',
        () => (career.generatedAt ?? now).toIso8601String(),
      );
    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> saveAdditionalNotes(String notes) async {
    final ref = _docRef();
    if (ref == null) throw StateError('No signed-in user.');
    await ref.set({
      'additionalNotes': notes.trim(),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> replacePath(int index, CareerPath path) async {
    final current = await getCareer();
    if (index < 0 || index >= current.paths.length) {
      throw RangeError('Invalid path index: $index');
    }
    final paths = [...current.paths];
    paths[index] = path;
    await saveCareer(current.copyWith(paths: paths));
  }
}

final careerServiceProvider = Provider<CareerService>(
  (ref) => CareerService(FirebaseFirestore.instance, FirebaseAuth.instance),
);

final careerProvider = StreamProvider<CareerBridgeData>((ref) {
  return ref.watch(careerServiceProvider).watchCareer();
});
