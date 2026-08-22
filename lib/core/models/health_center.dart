/// A California HRSA community health center / look-alike site.
class HealthCenter {
  const HealthCenter({
    required this.id,
    required this.name,
    this.org = '',
    this.address = '',
    this.city = '',
    this.zip = '',
    this.phone = '',
    this.website = '',
    this.type = '',
    required this.latitude,
    required this.longitude,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String org;
  final String address;
  final String city;
  final String zip;
  final String phone;
  final String website;
  final String type;
  final double latitude;
  final double longitude;
  final double? distanceKm;

  String get cityLine {
    final parts = <String>[
      if (city.isNotEmpty) city,
      if (zip.isNotEmpty) zip,
    ];
    return parts.join(' ');
  }

  factory HealthCenter.fromMap(Map<String, dynamic> map) {
    return HealthCenter(
      id: '${map['id'] ?? ''}',
      name: (map['name'] as String?)?.trim() ?? '',
      org: (map['org'] as String?)?.trim() ?? '',
      address: (map['address'] as String?)?.trim() ?? '',
      city: (map['city'] as String?)?.trim() ?? '',
      zip: (map['zip'] as String?)?.trim() ?? '',
      phone: (map['phone'] as String?)?.trim() ?? '',
      website: (map['website'] as String?)?.trim() ?? '',
      type: (map['type'] as String?)?.trim() ?? '',
      latitude: (map['lat'] as num?)?.toDouble() ?? 0,
      longitude: (map['lng'] as num?)?.toDouble() ?? 0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
    );
  }
}
