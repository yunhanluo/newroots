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
    if (index < 0 || index >= CareerBridgeData.pathSlotCount) {
      throw RangeError('Invalid path index: $index');
    }
    final current = await getCareer();
    final paths = List<CareerPath>.generate(
      CareerBridgeData.pathSlotCount,
      (i) {
        if (i == index) return path;
        if (i < current.paths.length && current.paths[i].hasContent) {
          return current.paths[i];
        }
        return CareerPath.emptySlot(i);
      },
    );
    await saveCareer(current.copyWith(paths: paths));
  }

  Future<void> setChecklistItemDone({
    required int pathIndex,
    required String stepId,
    required bool isSkill,
    required int itemIndex,
    required bool done,
  }) async {
    if (pathIndex < 0 || pathIndex >= CareerBridgeData.pathSlotCount) {
      throw RangeError('Invalid path index: $pathIndex');
    }
    final current = await getCareer();
    if (pathIndex >= current.paths.length) {
      throw StateError('Career path not found.');
    }

    final path = current.paths[pathIndex];
    final stepIndex = path.steps.indexWhere((step) => step.id == stepId);
    if (stepIndex < 0) {
      throw StateError('Career step not found.');
    }

    final step = path.steps[stepIndex];
    final items = List<CareerChecklistItem>.from(
      isSkill ? step.skills : step.certifications,
    );
    if (itemIndex < 0 || itemIndex >= items.length) {
      throw RangeError('Invalid checklist item index: $itemIndex');
    }

    items[itemIndex] = items[itemIndex].copyWith(done: done);
    final updatedStep = isSkill
        ? step.copyWith(skills: items)
        : step.copyWith(certifications: items);
    final updatedSteps = [...path.steps];
    updatedSteps[stepIndex] = updatedStep;

    final updatedPaths = [...current.paths];
    updatedPaths[pathIndex] = CareerPath(
      id: path.id,
      title: path.title,
      summary: path.summary,
      steps: updatedSteps,
    );
    await saveCareer(current.copyWith(paths: updatedPaths));
  }
}

final careerServiceProvider = Provider<CareerService>(
  (ref) => CareerService(FirebaseFirestore.instance, FirebaseAuth.instance),
);

final careerProvider = StreamProvider<CareerBridgeData>((ref) {
  return ref.watch(careerServiceProvider).watchCareer();
});
