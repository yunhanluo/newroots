/// Career Bridge data stored at `users/{uid}/career/main`.
class CareerBridgeData {
  const CareerBridgeData({
    required this.paths,
    this.additionalNotes = '',
    this.generatedAt,
    this.updatedAt,
  });

  final List<CareerPath> paths;
  final String additionalNotes;
  final DateTime? generatedAt;
  final DateTime? updatedAt;

  bool get isEmpty => paths.isEmpty;

  CareerBridgeData copyWith({
    List<CareerPath>? paths,
    String? additionalNotes,
    DateTime? generatedAt,
    DateTime? updatedAt,
  }) {
    return CareerBridgeData(
      paths: paths ?? this.paths,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      generatedAt: generatedAt ?? this.generatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paths': paths.map((path) => path.toMap()).toList(),
      'additionalNotes': additionalNotes,
      if (generatedAt != null) 'generatedAt': generatedAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  factory CareerBridgeData.fromMap(Map<String, dynamic>? map) {
    if (map == null) return CareerBridgeData.empty();
    final rawPaths = map['paths'];
    return CareerBridgeData(
      paths: rawPaths is List
          ? rawPaths
              .whereType<Map>()
              .map(
                (item) => CareerPath.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList()
          : [],
      additionalNotes: (map['additionalNotes'] as String?) ?? '',
      generatedAt: _parseDate(map['generatedAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  static CareerBridgeData empty() => const CareerBridgeData(paths: []);

  static DateTime? _parseDate(Object? raw) {
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}

class CareerPath {
  const CareerPath({
    required this.id,
    required this.title,
    required this.summary,
    required this.steps,
  });

  final String id;
  final String title;
  final String summary;
  final List<CareerPathStep> steps;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'steps': steps.map((step) => step.toMap()).toList(),
    };
  }

  factory CareerPath.fromMap(Map<String, dynamic> map) {
    final rawSteps = map['steps'];
    return CareerPath(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      summary: (map['summary'] as String?) ?? '',
      steps: rawSteps is List
          ? rawSteps
              .whereType<Map>()
              .map(
                (item) =>
                    CareerPathStep.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList()
          : [],
    );
  }
}

class CareerPathStep {
  const CareerPathStep({
    required this.id,
    required this.title,
    required this.description,
    this.isCurrent = false,
    this.certifications = const [],
    this.skills = const [],
  });

  final String id;
  final String title;
  final String description;
  final bool isCurrent;
  final List<String> certifications;
  final List<String> skills;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCurrent': isCurrent,
      'certifications': certifications,
      'skills': skills,
    };
  }

  factory CareerPathStep.fromMap(Map<String, dynamic> map) {
    return CareerPathStep(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      isCurrent: (map['isCurrent'] as bool?) ?? false,
      certifications: _parseStringList(map['certifications']),
      skills: _parseStringList(map['skills']),
    );
  }

  static List<String> _parseStringList(Object? raw) {
    if (raw is! List) return [];
    return raw.whereType<String>().where((value) => value.trim().isNotEmpty).toList();
  }
}
