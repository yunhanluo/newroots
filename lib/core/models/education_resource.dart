/// A California public school or education support program pin.
class EducationResource {
  const EducationResource({
    required this.id,
    required this.title,
    required this.kind,
    this.category = '',
    this.description = '',
    this.address = '',
    this.city = '',
    this.zip = '',
    this.district = '',
    this.website = '',
    this.phone = '',
    this.gradeLow,
    this.gradeHigh,
    this.gradeBands = const [],
    required this.latitude,
    required this.longitude,
    this.verified = true,
    this.source = '',
    this.distanceKm,
  });

  final String id;
  final String title;

  /// `school` | `private_school` | `enrollment_help` | `library` | `tutoring`
  /// | `stem`
  final String kind;
  final String category;
  final String description;
  final String address;
  final String city;
  final String zip;
  final String district;
  final String website;
  final String phone;
  final int? gradeLow;
  final int? gradeHigh;
  final List<String> gradeBands;
  final double latitude;
  final double longitude;
  final bool verified;
  final String source;
  final double? distanceKm;

  String get cityLine {
    final parts = <String>[
      if (city.isNotEmpty) city,
      if (zip.isNotEmpty) zip,
    ];
    return parts.join(' ');
  }

  String get gradeLabel {
    if (gradeLow == null && gradeHigh == null) {
      if (gradeBands.isEmpty) return '';
      return gradeBands.map(_bandLabel).join(', ');
    }
    return '${_gradeName(gradeLow)}–${_gradeName(gradeHigh)}';
  }

  String get kindLabel {
    switch (kind) {
      case 'school':
        return 'Public school';
      case 'private_school':
        return 'Private school';
      case 'enrollment_help':
        return 'Enrollment help';
      case 'library':
        return 'Public library';
      case 'tutoring':
        return 'Tutoring';
      case 'stem':
        return 'STEM / enrichment';
      default:
        return 'Education resource';
    }
  }

  static String _bandLabel(String band) {
    switch (band) {
      case 'elementary':
        return 'Elementary';
      case 'middle':
        return 'Middle';
      case 'high':
        return 'High';
      default:
        return band;
    }
  }

  static String _gradeName(int? grade) {
    if (grade == null) return '?';
    if (grade == 0) return 'K';
    if (grade < 0) return 'PK';
    return '$grade';
  }

  factory EducationResource.fromMap(Map<String, dynamic> map) {
    return EducationResource(
      id: '${map['id'] ?? ''}',
      title: (map['title'] as String?)?.trim() ?? '',
      kind: (map['kind'] as String?)?.trim() ?? '',
      category: (map['category'] as String?)?.trim() ?? '',
      description: (map['description'] as String?)?.trim() ?? '',
      address: (map['address'] as String?)?.trim() ?? '',
      city: (map['city'] as String?)?.trim() ?? '',
      zip: (map['zip'] as String?)?.trim() ?? '',
      district: (map['district'] as String?)?.trim() ?? '',
      website: (map['website'] as String?)?.trim() ?? '',
      phone: (map['phone'] as String?)?.trim() ?? '',
      gradeLow: (map['gradeLow'] as num?)?.toInt(),
      gradeHigh: (map['gradeHigh'] as num?)?.toInt(),
      gradeBands: (map['gradeBands'] is List)
          ? (map['gradeBands'] as List)
              .whereType<String>()
              .where((value) => value.trim().isNotEmpty)
              .toList()
          : const [],
      latitude: (map['lat'] as num?)?.toDouble() ??
          (map['latitude'] as num?)?.toDouble() ??
          0,
      longitude: (map['lng'] as num?)?.toDouble() ??
          (map['longitude'] as num?)?.toDouble() ??
          0,
      verified: (map['verified'] as bool?) ?? true,
      source: (map['source'] as String?)?.trim() ?? '',
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
    );
  }
}

class SchoolSummarySource {
  const SchoolSummarySource({required this.title, required this.url});

  final String title;
  final String url;

  factory SchoolSummarySource.fromMap(Map<String, dynamic> map) {
    return SchoolSummarySource(
      title: (map['title'] as String?)?.trim() ?? '',
      url: (map['url'] as String?)?.trim() ?? '',
    );
  }
}

/// A grounded, AI-generated summary of official school information.
class SchoolAiSummary {
  const SchoolAiSummary({
    required this.overview,
    this.highlights = const [],
    this.questionsToAsk = const [],
    this.sources = const [],
    this.generatedAt,
  });

  final String overview;
  final List<String> highlights;
  final List<String> questionsToAsk;
  final List<SchoolSummarySource> sources;
  final DateTime? generatedAt;

  factory SchoolAiSummary.fromMap(Map<String, dynamic> map) {
    List<String> stringList(String key) {
      final value = map[key];
      return value is List
          ? value
              .whereType<String>()
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList()
          : const [];
    }

    final rawSources = map['sources'];
    return SchoolAiSummary(
      overview: (map['overview'] as String?)?.trim() ?? '',
      highlights: stringList('highlights'),
      questionsToAsk: stringList('questionsToAsk'),
      sources: rawSources is List
          ? rawSources
              .whereType<Map>()
              .map(
                (item) => SchoolSummarySource.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .where((source) => source.url.isNotEmpty)
              .toList()
          : const [],
      generatedAt: DateTime.tryParse(
        (map['generatedAt'] as String?)?.trim() ?? '',
      ),
    );
  }
}
