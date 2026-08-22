import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scam_report.dart';

/// Persists ScamShield reports and uploads screenshots.
class ScamService {
  ScamService(this._firestore, this._auth, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? _reportsCol() {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('scamReports');
  }

  /// Uploads a screenshot and returns the Storage object path (`contentRef`).
  Future<String> uploadScreenshot({
    required Uint8List bytes,
    required String contentType,
    String extension = 'jpg',
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('No signed-in user.');
    final safeExt = extension.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final path =
        'scamshield-uploads/$uid/${DateTime.now().millisecondsSinceEpoch}.$safeExt';
    final ref = _storage.ref(path);
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    return path;
  }

  Future<ScamReport> saveReport(ScamReport report) async {
    final col = _reportsCol();
    if (col == null) throw StateError('No signed-in user.');
    final data = report.toMap();
    if (report.id.isNotEmpty && report.id != 'placeholder') {
      await col.doc(report.id).set(data, SetOptions(merge: true));
      return report;
    }
    final doc = await col.add(data);
    return ScamReport.fromMap(doc.id, {...data, 'id': doc.id});
  }

  Future<void> deleteReport(ScamReport report) async {
    final col = _reportsCol();
    if (col == null) throw StateError('No signed-in user.');
    if (report.id.isEmpty) return;
    await col.doc(report.id).delete();

    final contentRef = report.contentRef?.trim() ?? '';
    if (contentRef.isEmpty) return;
    final uid = _uid;
    if (uid == null) return;
    final path = contentRef.replaceFirst(RegExp(r'^/+'), '');
    final prefix = 'scamshield-uploads/$uid/';
    if (!path.startsWith(prefix) || path.contains('..')) return;
    try {
      await _storage.ref(path).delete();
    } catch (_) {
      // Report is already gone; ignore storage cleanup failures.
    }
  }

  /// Downloads a previously uploaded screenshot for a past report.
  Future<Uint8List?> downloadScreenshot(String contentRef) async {
    final uid = _uid;
    if (uid == null) return null;
    final path = contentRef.trim().replaceFirst(RegExp(r'^/+'), '');
    final prefix = 'scamshield-uploads/$uid/';
    if (!path.startsWith(prefix) || path.contains('..')) return null;
    try {
      return await _storage.ref(path).getData(8 * 1024 * 1024);
    } catch (_) {
      return null;
    }
  }

  Stream<List<ScamReport>> watchRecentReports({int limit = 10}) {
    final col = _reportsCol();
    if (col == null) return Stream.value(const []);
    return col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ScamReport.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}

final scamServiceProvider = Provider<ScamService>(
  (ref) => ScamService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
    FirebaseStorage.instance,
  ),
);

final recentScamReportsProvider = StreamProvider<List<ScamReport>>((ref) {
  return ref.watch(scamServiceProvider).watchRecentReports(limit: 20);
});
