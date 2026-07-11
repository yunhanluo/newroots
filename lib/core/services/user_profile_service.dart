import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const surveyPriorityOptions = <(String, String)>[
  ('Housing', 'Housing'),
  ('Employment', 'Employment'),
  ('Education', 'Education'),
  ('Healthcare', 'Healthcare'),
  ('English', 'English learning'),
  ('Safety', 'Safety'),
];

const surveyPriorityPresets = {
  'Housing',
  'Employment',
  'Education',
  'Healthcare',
  'English',
  'Safety',
};

String surveyPriorityDisplayLabel(String value) {
  for (final option in surveyPriorityOptions) {
    if (option.$1 == value) return option.$2;
  }
  return value;
}

String formatSurveyPriorities(List<String> priorities) {
  if (priorities.isEmpty) return '';
  return priorities.map(surveyPriorityDisplayLabel).join(', ');
}

/// Handles saving lightweight onboarding/profile information.
class UserProfileService {
  UserProfileService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<UserProfileData?> watchCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return const Stream<UserProfileData?>.empty();
    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfileData.fromMap(doc.data()!) : null);
  }

  Future<UserProfileData?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfileData.fromMap(doc.data()!);
  }

  Future<void> saveOnboarding({
    required String languageCode,
    required String location,
    required int familySize,
    required List<String> topPriorities,
    required String employmentBackground,
    required String childrenInfo,
    required List<int> skippedQuestions,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user.');
    }

    // Refresh the auth token before writing (helps on web after long sessions).
    await user.getIdToken(true);

    await _firestore.collection('users').doc(user.uid).set({
      'languageCode': languageCode,
      'location': location.trim(),
      'familySize': familySize,
      'topPriorities': topPriorities,
      'employmentBackground': employmentBackground.trim(),
      'childrenInfo': childrenInfo.trim(),
      'skippedQuestions': skippedQuestions,
      'onboardingComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static const _fieldQuestionSteps = {
    'languageCode': 1,
    'location': 2,
    'familySize': 3,
    'topPriorities': 4,
    'employmentBackground': 5,
    'childrenInfo': 6,
  };

  Future<void> updateField(String key, dynamic value) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user.');
    }

    final normalized = value is String ? value.trim() : value;
    final updates = <String, dynamic>{
      key: normalized,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final step = _fieldQuestionSteps[key];
    if (step != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final skipped = UserProfileData._parseSkippedQuestions(
        doc.data()?['skippedQuestions'],
      );
      if (skipped.contains(step)) {
        updates['skippedQuestions'] =
            skipped.where((question) => question != step).toList();
      }
    }

    await _firestore.collection('users').doc(user.uid).set(
          updates,
          SetOptions(merge: true),
        );
  }
}

final userProfileServiceProvider = Provider<UserProfileService>(
  (ref) => UserProfileService(FirebaseFirestore.instance, FirebaseAuth.instance),
);

final userProfileProvider = StreamProvider<UserProfileData?>((ref) {
  return ref.watch(userProfileServiceProvider).watchCurrentUserProfile();
});

class UserProfileData {
  const UserProfileData({
    required this.languageCode,
    required this.location,
    required this.familySize,
    required this.topPriorities,
    required this.employmentBackground,
    required this.childrenInfo,
    required this.onboardingComplete,
    required this.skippedQuestions,
  });

  final String languageCode;
  final String location;
  final int familySize;
  final List<String> topPriorities;
  final String employmentBackground;
  final String childrenInfo;
  final bool onboardingComplete;
  final List<int> skippedQuestions;

  bool get hasSurveyData =>
      onboardingComplete ||
      location.isNotEmpty ||
      topPriorities.isNotEmpty ||
      employmentBackground.isNotEmpty ||
      childrenInfo.isNotEmpty;

  factory UserProfileData.fromMap(Map<String, dynamic> map) {
    return UserProfileData(
      languageCode: (map['languageCode'] as String?) ?? 'en',
      location: (map['location'] as String?) ?? '',
      familySize: (map['familySize'] as num?)?.toInt() ?? 0,
      topPriorities: _parseTopPriorities(map),
      employmentBackground: (map['employmentBackground'] as String?) ?? '',
      childrenInfo: (map['childrenInfo'] as String?) ?? '',
      onboardingComplete: (map['onboardingComplete'] as bool?) ?? false,
      skippedQuestions: _parseSkippedQuestions(map['skippedQuestions']),
    );
  }

  static List<String> _parseTopPriorities(Map<String, dynamic> map) {
    final raw = map['topPriorities'];
    if (raw is List) {
      return raw.whereType<String>().where((value) => value.isNotEmpty).toList();
    }
    final legacy = (map['topPriority'] as String?) ?? '';
    if (legacy.isEmpty) return const [];
    return [legacy];
  }

  static List<int> _parseSkippedQuestions(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<num>()
        .map((n) => n.toInt())
        .where((step) => step >= 1 && step <= 6)
        .toList()
      ..sort();
  }
}
