import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_locale.dart';
import '../models/static_guide.dart';

/// Loads static guides from bundled assets, a disk cache, and Firestore.
///
/// Order:
/// 1. Bundled JSON (`assets/guides/{id}.{lang}.json`, then `{id}.json`) —
///    always available offline.
/// 2. SharedPreferences — last copy the user actually opened or prefetched.
/// 3. Firestore `guides/{id}` — optional newer copy for the same language;
///    persisted by Firestore offline cache after the first successful fetch.
class StaticGuideService {
  StaticGuideService(this._db);

  static const _assetPrefix = 'assets/guides';
  static const _prefPrefix = 'static_guide_cache_v2_';
  static const _localizedLanguages = {'es', 'zh', 'vi', 'ko', 'tl', 'hi', 'ar'};
  static const _localizedGuides = <String, Set<String>>{
    StaticGuideIds.housing: _localizedLanguages,
    StaticGuideIds.safety: _localizedLanguages,
    StaticGuideIds.education: _localizedLanguages,
    StaticGuideIds.healthcare: _localizedLanguages,
  };

  final FirebaseFirestore _db;
  final Map<String, StaticGuide> _bundledMemory = {};
  SharedPreferences? _prefs;

  Stream<StaticGuide> watchGuide(
    String id, {
    String languageCode = 'en',
  }) async* {
    var current = await _bestLocal(id, languageCode);
    yield current;

    try {
      await for (final snap in _db.collection('guides').doc(id).snapshots()) {
        final remote = _parseRemote(id, languageCode, snap);
        if (remote == null || remote.sections.isEmpty) continue;
        if (!_shouldReplace(current, remote)) continue;
        current = remote;
        await _writeDisk(current, languageCode);
        yield current;
      }
    } catch (error, stack) {
      debugPrint('static guide "$id" Firestore watch failed: $error\n$stack');
    }
  }

  /// Seeds the disk cache from bundled assets and pulls Firestore if online.
  Future<void> prefetchAll({String languageCode = 'en'}) async {
    await Future.wait(
      StaticGuideIds.all.map((id) => _warm(id, languageCode)),
    );
  }

  Future<void> _warm(String id, String languageCode) async {
    try {
      await _bestLocal(id, languageCode);
      final snap = await _db.collection('guides').doc(id).get();
      final remote = _parseRemote(id, languageCode, snap);
      if (remote == null || remote.sections.isEmpty) return;
      final local = await _bestLocal(id, languageCode);
      if (!_shouldReplace(local, remote)) return;
      await _writeDisk(remote, languageCode);
    } catch (error, stack) {
      debugPrint('static guide "$id" prefetch failed: $error\n$stack');
    }
  }

  Future<StaticGuide> _bestLocal(String id, String languageCode) async {
    final bundled = await _loadBundled(id, languageCode);
    final disk = await _loadDisk(id, languageCode);
    if (disk == null || disk.sections.isEmpty) {
      await _writeDisk(bundled, languageCode);
      return bundled;
    }
    if (disk.version >= bundled.version) return disk;
    await _writeDisk(bundled, languageCode);
    return bundled;
  }

  Future<StaticGuide> _loadBundled(String id, String languageCode) async {
    final memKey = _cacheKey(id, languageCode);
    final cached = _bundledMemory[memKey];
    if (cached != null) return cached;

    Object? lastError;
    for (final path in _assetCandidates(id, languageCode)) {
      try {
        final raw = await rootBundle.loadString(path);
        final map = jsonDecode(raw);
        if (map is! Map) {
          throw StateError('Guide "$id" asset is not a JSON object.');
        }
        final guide = StaticGuide.fromMap(id, Map<String, dynamic>.from(map));
        if (guide.sections.isEmpty) {
          throw StateError('Guide "$id" asset has no sections.');
        }
        _bundledMemory[memKey] = guide;
        return guide;
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError ?? StateError('Guide "$id" asset not found.');
  }

  Future<StaticGuide?> _loadDisk(String id, String languageCode) async {
    try {
      final prefs = await _preferences();
      final raw = prefs.getString('$_prefPrefix${_cacheKey(id, languageCode)}');
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

  Future<void> _writeDisk(StaticGuide guide, String languageCode) async {
    try {
      final prefs = await _preferences();
      await prefs.setString(
        '$_prefPrefix${_cacheKey(guide.id, languageCode)}',
        guide.toJsonString(),
      );
    } catch (error, stack) {
      debugPrint(
        'static guide "${guide.id}" disk write failed: $error\n$stack',
      );
    }
  }

  List<String> _assetCandidates(String id, String languageCode) {
    final code = languageCode.trim().toLowerCase();
    final fallback = '$_assetPrefix/$id.json';
    if (code.isEmpty || code == 'en') return [fallback];
    final localized = _localizedGuides[id];
    if (localized == null || !localized.contains(code)) return [fallback];
    return ['$_assetPrefix/$id.$code.json', fallback];
  }

  String _cacheKey(String id, String languageCode) {
    final code = languageCode.trim().toLowerCase();
    return '${id}_${code.isEmpty ? 'en' : code}';
  }

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  StaticGuide? _parseRemote(
    String id,
    String languageCode,
    DocumentSnapshot snap,
  ) {
    if (!snap.exists) return null;
    final data = snap.data();
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    if (map.isEmpty) return null;
    try {
      final locales = map['locales'];
      if (locales is Map) {
        final localized = locales[languageCode];
        if (localized is Map) {
          final merged = Map<String, dynamic>.from(map)..remove('locales');
          merged.addAll(Map<String, dynamic>.from(localized));
          return StaticGuide.fromMap(id, merged);
        }
      }
      final requested = languageCode.trim().toLowerCase();
      final docLanguage =
          (map['language'] as String?)?.trim().toLowerCase() ?? 'en';
      if (docLanguage != requested) return null;
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
  final languageCode = ref.watch(appLocaleProvider).languageCode;
  return ref.watch(staticGuideServiceProvider).watchGuide(
    id,
    languageCode: languageCode,
  );
});
