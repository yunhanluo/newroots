/// Maps to Firestore `resources/{id}` (public-read; see DESIGN_PLAN.md §5).
///
/// Used by Housing, English, Education, Healthcare, and Community navigators.
/// PLACEHOLDER model.
class Resource {
  const Resource({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.geohash,
    this.languages = const [],
    this.sourceUrl,
    this.verified = false,
  });

  final String id;
  final String type; // housing | english | education | healthcare | community
  final String title;
  final String? description;
  final String? geohash;
  final List<String> languages;
  final String? sourceUrl;
  final bool verified;

  factory Resource.fromMap(String id, Map<String, dynamic> map) {
    // TODO: parse fields.
    return Resource(id: id, type: map['type'] as String? ?? '', title: map['title'] as String? ?? '');
  }
}
