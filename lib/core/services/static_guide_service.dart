import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/static_guide.dart';

/// Loads static guides from bundled assets, a disk cache, and Firestore.
///
/// Order:
/// 1. Bundled JSON (`assets/guides/{id}.json`) — always available offline.
/// 2. SharedPreferences — last copy the user actually opened or prefetched.
/// 3. Firestore `guides/{id}` — optional newer copy; persisted by Firestore
///    offline cache after the first successful fetch.
class StaticGuideService {
  StaticGuideService(this._db);

  static const _assetPrefix = 'assets/guides';
  static const _prefPrefix = 'static_guide_cache_v1_';

  final FirebaseFirestore _db;
  final Map<String, StaticGuide> _bundledMemory = {};
  SharedPreferences? _prefs;

  Stream<StaticGuide> watchGuide(String id) async* {
    var current = await _bestLocal(id);
    yield current;

    try {
      await for (final snap in _db.collection('guides').doc(id).snapshots()) {
        final remote = _parseRemote(id, snap);
        if (remote == null || remote.sections.isEmpty) continue;
        if (!_shouldReplace(current, remote)) continue;
        current = remote;
        await _writeDisk(current);
        yield current;
      }
    } catch (error, stack) {
      debugPrint('static guide "$id" Firestore watch failed: $error\n$stack');
    }
  }

  /// Seeds the disk cache from bundled assets and pulls Firestore if online.
  Future<void> prefetchAll() async {
    await Future.wait(StaticGuideIds.all.map(_warm));
  }

  Future<void> _warm(String id) async {
    try {
      await _bestLocal(id);
      final snap = await _db.collection('guides').doc(id).get();
      final remote = _parseRemote(id, snap);
      if (remote == null || remote.sections.isEmpty) return;
      final local = await _bestLocal(id);
      if (!_shouldReplace(local, remote)) return;
      await _writeDisk(remote);
    } catch (error, stack) {
      debugPrint('static guide "$id" prefetch failed: $error\n$stack');
    }
  }

  Future<StaticGuide> _bestLocal(String id) async {
    final bundled = await _loadBundled(id);
    final disk = await _loadDisk(id);
    if (disk == null || disk.sections.isEmpty) {
      await _writeDisk(bundled);
      return bundled;
    }
    if (disk.version >= bundled.version) return disk;
    await _writeDisk(bundled);
    return bundled;
  }

  Future<StaticGuide> _loadBundled(String id) async {
    final cached = _bundledMemory[id];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('$_assetPrefix/$id.json');
    final map = jsonDecode(raw);
    if (map is! Map) {
      throw StateError('Guide "$id" asset is not a JSON object.');
    }
    final guide = StaticGuide.fromMap(id, Map<String, dynamic>.from(map));
    if (guide.sections.isEmpty) {
      throw StateError('Guide "$id" asset has no sections.');
    }
    _bundledMemory[id] = guide;
    return guide;
  }

  Future<StaticGuide?> _loadDisk(String id) async {
    try {
      final prefs = await _preferences();
      final raw = prefs.getString('$_prefPrefix$id');
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      final guide = StaticGuide.fromMap(id, Map<String, dynamic>.from(map));
      if (guide.sections.isEmpty) return null;
      return guide;
    } catch (error, stack) {
      debugPrint('static guide "$id" disk cache failed: $error\n$stack');
      return null;
    }
  }

  Future<void> _writeDisk(StaticGuide guide) async {
    try {
      final prefs = await _preferences();
      await prefs.setString('$_prefPrefix${guide.id}', guide.toJsonString());
    } catch (error, stack) {
      debugPrint(
        'static guide "${guide.id}" disk write failed: $error\n$stack',
      );
    }
  }

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  StaticGuide? _parseRemote(String id, DocumentSnapshot snap) {
    if (!snap.exists) return null;
    final data = snap.data();
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    if (map.isEmpty) return null;
    try {
      return StaticGuide.fromMap(id, map);
    } catch (error, stack) {
      debugPrint('static guide "$id" remote parse failed: $error\n$stack');
      return null;
    }
  }

  bool _shouldReplace(StaticGuide current, StaticGuide candidate) {
    if (candidate.version > current.version) return true;
    if (candidate.version < current.version) return false;
    return candidate.toJsonString() != current.toJsonString();
  }
}

final staticGuideServiceProvider = Provider<StaticGuideService>(
  (ref) => StaticGuideService(FirebaseFirestore.instance),
);

final staticGuideProvider = StreamProvider.family<StaticGuide, String>((
  ref,
  id,
) {
  return ref.watch(staticGuideServiceProvider).watchGuide(id);
});
