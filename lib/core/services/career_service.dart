import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/career.dart';
import 'auth_service.dart';

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

  Stream<CareerBridgeData> watchCareer(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('career')
        .doc('main')
        .snapshots()
        .map((snap) {
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
    final existingNotes =
        index < current.paths.length ? current.paths[index].notes : const <CareerNote>[];
    final paths = List<CareerPath>.generate(
      CareerBridgeData.pathSlotCount,
      (i) {
        if (i == index) {
          return path.copyWith(
            notes: path.notes.isNotEmpty ? path.notes : existingNotes,
          );
        }
        if (i < current.paths.length && current.paths[i].hasContent) {
          return current.paths[i];
        }
        return CareerPath.emptySlot(i);
      },
    );
    await saveCareer(current.copyWith(paths: paths));
  }

  Future<void> addNote(int pathIndex, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final current = await _requirePath(pathIndex);
    final path = current.paths[pathIndex];
    final note = CareerNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      createdAt: DateTime.now(),
    );
    final paths = [...current.paths];
    paths[pathIndex] = path.copyWith(notes: [...path.notes, note]);
    await saveCareer(current.copyWith(paths: paths));
  }

  Future<void> deleteNote(int pathIndex, CareerNote note) async {
    final current = await _requirePath(pathIndex);
    final path = current.paths[pathIndex];
    final remaining = path.notes.where((item) {
      if (note.id.isNotEmpty && item.id.isNotEmpty) return item.id != note.id;
      return !(item.text == note.text &&
          item.createdAt.toIso8601String() == note.createdAt.toIso8601String());
    }).toList();
    final paths = [...current.paths];
    paths[pathIndex] = path.copyWith(notes: remaining);
    await saveCareer(current.copyWith(paths: paths));
  }

  Future<CareerBridgeData> _requirePath(int pathIndex) async {
    if (pathIndex < 0 || pathIndex >= CareerBridgeData.pathSlotCount) {
      throw RangeError('Invalid path index: $pathIndex');
    }
    final current = await getCareer();
    if (pathIndex >= current.paths.length ||
        !current.paths[pathIndex].hasContent) {
      throw StateError('Career path not found.');
    }
    return current;
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
    updatedPaths[pathIndex] = path.copyWith(steps: updatedSteps);
    await saveCareer(current.copyWith(paths: updatedPaths));
  }

  Future<void> setStepComplete({
    required int pathIndex,
    required String stepId,
    required bool complete,
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

    if (complete) {
      final blocked = path.steps.take(stepIndex).any((step) => !step.isComplete);
      if (blocked) {
        throw const CareerStepOrderException(CareerStepOrderIssue.finishAbove);
      }
    } else {
      final blocked = path.steps.skip(stepIndex + 1).any((step) => step.isComplete);
      if (blocked) {
        throw const CareerStepOrderException(CareerStepOrderIssue.undoLater);
      }
    }

    final updatedSteps = [...path.steps];
    updatedSteps[stepIndex] = updatedSteps[stepIndex].copyWith(
      isComplete: complete,
    );
    final updatedPaths = [...current.paths];
    updatedPaths[pathIndex] = path
        .copyWith(steps: updatedSteps)
        .withCurrentOnNextOpenStep();
    await saveCareer(current.copyWith(paths: updatedPaths));
  }
}

class CareerStepOrderException implements Exception {
  const CareerStepOrderException(this.issue);

  final CareerStepOrderIssue issue;

  @override
  String toString() => issue.name;
}

enum CareerStepOrderIssue { finishAbove, undoLater }

final careerServiceProvider = Provider<CareerService>(
  (ref) => CareerService(FirebaseFirestore.instance, FirebaseAuth.instance),
);

final careerProvider = StreamProvider<CareerBridgeData>((ref) {
  return watchForSignedInUser(
    ref: ref,
    whenSignedOut: CareerBridgeData.empty(),
    watch: (uid) => ref.watch(careerServiceProvider).watchCareer(uid),
  );
});
