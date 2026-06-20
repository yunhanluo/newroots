/// Maps to Firestore `users/{uid}` (see DESIGN_PLAN.md §5).
///
/// PLACEHOLDER model — fromMap/toMap stubbed.
class UserProfile {
  const UserProfile({
    required this.uid,
    this.languageCode = 'en',
    this.familySize,
    this.location,
    this.geohash,
    this.employmentBackground,
    this.childrenAges = const [],
  });

  final String uid;
  final String languageCode;
  final int? familySize;
  final String? location;
  final String? geohash;
  final String? employmentBackground;
  final List<int> childrenAges;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    // TODO: parse fields safely.
    return UserProfile(uid: uid, languageCode: map['languageCode'] as String? ?? 'en');
  }

  Map<String, dynamic> toMap() {
    // TODO: serialize all fields.
    return {'languageCode': languageCode};
  }
}
