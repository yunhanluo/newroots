/// Maps to Firestore `resources/{id}` (public-read; see DESIGN_PLAN.md §5).
///
/// Used by Housing, English, Education, and Healthcare navigators.
class Resource {
  const Resource({
    required this.id,
    required this.type,
    required this.title,
    this.description = '',
    this.address = '',
    this.city = '',
    this.geohash,
    this.latitude,
    this.longitude,
    this.languages = const [],
    this.sourceUrl,
    this.verified = false,
    this.distanceKm,
  });

  final String id;
  final String type; // housing | english | education | healthcare
  final String title;
  final String description;
  final String address;
  final String city;
  final String? geohash;
  final double? latitude;
  final double? longitude;
  final List<String> languages;
  final String? sourceUrl;
  final bool verified;
  final double? distanceKm;

  Resource copyWith({double? distanceKm}) {
    return Resource(
      id: id,
      type: type,
      title: title,
      description: description,
      address: address,
      city: city,
      geohash: geohash,
      latitude: latitude,
      longitude: longitude,
      languages: languages,
      sourceUrl: sourceUrl,
      verified: verified,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'address': address,
      'city': city,
      if (geohash != null) 'geohash': geohash,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'languages': languages,
      if (sourceUrl != null) 'sourceUrl': sourceUrl,
      'verified': verified,
    };
  }

  factory Resource.fromMap(String id, Map<String, dynamic> map) {
    return Resource(
      id: id,
      type: (map['type'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      address: (map['address'] as String?) ?? '',
      city: (map['city'] as String?) ?? '',
      geohash: map['geohash'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      languages: (map['languages'] is List)
          ? (map['languages'] as List)
              .whereType<String>()
              .where((value) => value.trim().isNotEmpty)
              .toList()
          : const [],
      sourceUrl: map['sourceUrl'] as String?,
      verified: (map['verified'] as bool?) ?? false,
    );
  }
}

class GeoPointLocation {
  const GeoPointLocation({
    required this.latitude,
    required this.longitude,
    this.label = '',
  });

  final double latitude;
  final double longitude;
  final String label;
}
