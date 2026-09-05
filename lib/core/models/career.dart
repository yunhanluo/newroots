/// Career Bridge data stored at `users/{uid}/career/main`.
class CareerBridgeData {
  static const pathSlotCount = 3;

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

  bool get isEmpty => paths.every((path) => !path.hasContent);

  /// Exactly [pathSlotCount] slots; missing/empty entries are null.
  List<CareerPath?> get pathSlots => List<CareerPath?>.generate(
        pathSlotCount,
        (index) {
          if (index >= paths.length) return null;
          final path = paths[index];
          return path.hasContent ? path : null;
        },
      );

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
    this.notes = const [],
  });

  final String id;
  final String title;
  final String summary;
  final List<CareerPathStep> steps;
  final List<CareerNote> notes;

  bool get hasContent => title.trim().isNotEmpty && steps.isNotEmpty;

  int get nowStepIndex => steps.indexWhere((step) => !step.isComplete);

  CareerPath withCurrentOnNextOpenStep() {
    final nowIndex = nowStepIndex;
    return copyWith(
      steps: [
        for (var i = 0; i < steps.length; i++)
          steps[i].copyWith(isCurrent: i == nowIndex),
      ],
    );
  }

  CareerPath copyWith({
    String? id,
    String? title,
    String? summary,
    List<CareerPathStep>? steps,
    List<CareerNote>? notes,
  }) {
    return CareerPath(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      steps: steps ?? this.steps,
      notes: notes ?? this.notes,
    );
  }

  factory CareerPath.emptySlot(int index) {
    return CareerPath(
      id: 'path${index + 1}',
      title: '',
      summary: '',
      steps: const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'steps': steps.map((step) => step.toMap()).toList(),
      'notes': notes.map((note) => note.toMap()).toList(),
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
      notes: _parseNotes(map['notes']),
    );
  }

  static List<CareerNote> _parseNotes(Object? raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => CareerNote.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}

class CareerNote {
  const CareerNote({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CareerNote.fromMap(Map<String, dynamic> map) {
    return CareerNote(
      id: (map['id'] as String?) ?? '',
      text: (map['text'] as String?) ?? '',
      createdAt: CareerBridgeData._parseDate(map['createdAt']) ?? DateTime.now(),
    );
  }
}

class CareerQaExchange {
  const CareerQaExchange({
    required this.question,
    required this.answer,
    required this.askedAt,
  });

  final String question;
  final String answer;
  final DateTime askedAt;
}

class CareerChecklistItem {
  const CareerChecklistItem({
    required this.label,
    this.done = false,
  });

  final String label;
  final bool done;

  CareerChecklistItem copyWith({String? label, bool? done}) {
    return CareerChecklistItem(
      label: label ?? this.label,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'done': done,
    };
  }

  factory CareerChecklistItem.fromMap(Map<String, dynamic> map) {
    return CareerChecklistItem(
      label: (map['label'] as String?)?.trim() ?? '',
      done: (map['done'] as bool?) ?? false,
    );
  }
}

class CareerPathStep {
  const CareerPathStep({
    required this.id,
    required this.title,
    required this.description,
    this.timeEstimate = '',
    this.isCurrent = false,
    this.isComplete = false,
    this.certifications = const [],
    this.skills = const [],
  });

  final String id;
  final String title;
  final String description;
  final String timeEstimate;
  final bool isCurrent;
  final bool isComplete;
  final List<CareerChecklistItem> certifications;
  final List<CareerChecklistItem> skills;

  /// Duration the AI gave for this stage, or empty when it only said Now.
  String get durationLabel {
    final value = timeEstimate.trim();
    if (value.isEmpty) return '';
    final lower = value.toLowerCase();
    if (lower == 'now' || lower == 'ongoing') return '';
    return value;
  }

  /// Bottom-left status: Completed, Now, Now (2–3 months), or the duration.
  String progressTimeLabel({required bool isNow}) {
    if (isComplete) return 'Completed';
    final duration = durationLabel;
    if (isNow) {
      return duration.isEmpty ? 'Now' : 'Now ($duration)';
    }
    return duration.isEmpty ? 'Time estimate pending' : duration;
  }

  CareerPathStep copyWith({
    String? id,
    String? title,
    String? description,
    String? timeEstimate,
    bool? isCurrent,
    bool? isComplete,
    List<CareerChecklistItem>? certifications,
    List<CareerChecklistItem>? skills,
  }) {
    return CareerPathStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeEstimate: timeEstimate ?? this.timeEstimate,
      isCurrent: isCurrent ?? this.isCurrent,
      isComplete: isComplete ?? this.isComplete,
      certifications: certifications ?? this.certifications,
      skills: skills ?? this.skills,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timeEstimate': timeEstimate,
      'isCurrent': isCurrent,
      'isComplete': isComplete,
      'certifications': certifications.map((item) => item.toMap()).toList(),
      'skills': skills.map((item) => item.toMap()).toList(),
    };
  }

  factory CareerPathStep.fromMap(Map<String, dynamic> map) {
    return CareerPathStep(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      timeEstimate: (map['timeEstimate'] as String?) ?? '',
      isCurrent: (map['isCurrent'] as bool?) ?? false,
      isComplete: (map['isComplete'] as bool?) ?? false,
      certifications: _parseChecklist(map['certifications']),
      skills: _parseChecklist(map['skills']),
    );
  }

  static List<CareerChecklistItem> _parseChecklist(Object? raw) {
    if (raw is! List) return [];
    final items = <CareerChecklistItem>[];
    for (final entry in raw) {
      if (entry is String) {
        final label = entry.trim();
        if (label.isNotEmpty) {
          items.add(CareerChecklistItem(label: label));
        }
      } else if (entry is Map) {
        final item = CareerChecklistItem.fromMap(
          Map<String, dynamic>.from(entry),
        );
        if (item.label.isNotEmpty) items.add(item);
      }
    }
    return items;
  }
}
