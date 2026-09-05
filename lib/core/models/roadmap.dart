/// Integration roadmap stored at `users/{uid}/roadmap/main`.
class IntegrationRoadmap {
  const IntegrationRoadmap({
    required this.firstMonth,
    required this.firstThreeMonths,
    required this.firstYear,
    this.clarifications = const [],
    this.generatedAt,
    this.updatedAt,
  });

  final RoadmapSection firstMonth;
  final RoadmapSection firstThreeMonths;
  final RoadmapSection firstYear;
  final List<ClarificationExchange> clarifications;
  final DateTime? generatedAt;
  final DateTime? updatedAt;

  bool get isEmpty =>
      firstMonth.isEmpty && firstThreeMonths.isEmpty && firstYear.isEmpty;

  IntegrationRoadmap copyWith({
    RoadmapSection? firstMonth,
    RoadmapSection? firstThreeMonths,
    RoadmapSection? firstYear,
    List<ClarificationExchange>? clarifications,
    DateTime? generatedAt,
    DateTime? updatedAt,
  }) {
    return IntegrationRoadmap(
      firstMonth: firstMonth ?? this.firstMonth,
      firstThreeMonths: firstThreeMonths ?? this.firstThreeMonths,
      firstYear: firstYear ?? this.firstYear,
      clarifications: clarifications ?? this.clarifications,
      generatedAt: generatedAt ?? this.generatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstMonth': firstMonth.toMap(),
      'firstThreeMonths': firstThreeMonths.toMap(),
      'firstYear': firstYear.toMap(),
      'clarifications': clarifications.map((c) => c.toMap()).toList(),
      if (generatedAt != null) 'generatedAt': generatedAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  factory IntegrationRoadmap.fromMap(Map<String, dynamic>? map) {
    if (map == null) return IntegrationRoadmap.empty();

    final legacyNotes = _parseList(map['notes'], RoadmapNote.fromMap);
    final legacyQa = _parseList(map['qaHistory'], RoadmapQaExchange.fromMap);

    return IntegrationRoadmap(
      firstMonth: _hydrateSection(
        RoadmapSection.fromMap(map['firstMonth']),
        map,
        'firstMonth',
        extraNotes: legacyNotes,
        extraQa: legacyQa,
      ),
      firstThreeMonths: _hydrateSection(
        RoadmapSection.fromMap(map['firstThreeMonths']),
        map,
        'firstThreeMonths',
      ),
      firstYear: _hydrateSection(
        RoadmapSection.fromMap(map['firstYear']),
        map,
        'firstYear',
      ),
      clarifications: _parseList(
        map['clarifications'],
        ClarificationExchange.fromMap,
      ),
      generatedAt: _parseDate(map['generatedAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  RoadmapSection sectionFor(RoadmapSectionKey key) {
    return switch (key) {
      RoadmapSectionKey.firstMonth => firstMonth,
      RoadmapSectionKey.firstThreeMonths => firstThreeMonths,
      RoadmapSectionKey.firstYear => firstYear,
    };
  }

  IntegrationRoadmap withSection(
    RoadmapSectionKey key,
    RoadmapSection section,
  ) {
    return switch (key) {
      RoadmapSectionKey.firstMonth => copyWith(firstMonth: section),
      RoadmapSectionKey.firstThreeMonths =>
        copyWith(firstThreeMonths: section),
      RoadmapSectionKey.firstYear => copyWith(firstYear: section),
    };
  }

  static IntegrationRoadmap empty() {
    return IntegrationRoadmap(
      firstMonth: RoadmapSection.empty(),
      firstThreeMonths: RoadmapSection.empty(),
      firstYear: RoadmapSection.empty(),
    );
  }

  /// Pulls notes/Q&A saved under dotted keys like `firstMonth.notes` (a
  /// previous `set(merge: true)` bug) back into the nested section.
  static RoadmapSection _hydrateSection(
    RoadmapSection section,
    Map<String, dynamic> map,
    String key, {
    List<RoadmapNote> extraNotes = const [],
    List<RoadmapQaExchange> extraQa = const [],
  }) {
    final dottedNotes = _parseList(map['$key.notes'], RoadmapNote.fromMap);
    final dottedQa = _parseList(map['$key.qaHistory'], RoadmapQaExchange.fromMap);
    final notes = _mergeNotes(section.notes, [...dottedNotes, ...extraNotes]);
    final qa = _mergeQa(section.qaHistory, [...dottedQa, ...extraQa]);
    if (identical(notes, section.notes) && identical(qa, section.qaHistory)) {
      return section;
    }
    return section.copyWith(notes: notes, qaHistory: qa);
  }

  static List<RoadmapNote> _mergeNotes(
    List<RoadmapNote> primary,
    List<RoadmapNote> extra,
  ) {
    if (extra.isEmpty) return primary;
    final seen = {for (final note in primary) note.id};
    final merged = [...primary];
    for (final note in extra) {
      final id = note.id.isEmpty ? '${note.text}|${note.createdAt.toIso8601String()}' : note.id;
      if (seen.add(id)) merged.add(note);
    }
    return merged;
  }

  static List<RoadmapQaExchange> _mergeQa(
    List<RoadmapQaExchange> primary,
    List<RoadmapQaExchange> extra,
  ) {
    if (extra.isEmpty) return primary;
    final seen = {
      for (final item in primary) '${item.question}\n${item.answer}',
    };
    final merged = [...primary];
    for (final item in extra) {
      if (seen.add('${item.question}\n${item.answer}')) merged.add(item);
    }
    return merged;
  }

  static List<T> _parseList<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}

class RoadmapSection {
  const RoadmapSection({
    required this.summary,
    required this.checklist,
    this.notes = const [],
    this.qaHistory = const [],
  });

  final String summary;
  final List<RoadmapChecklistItem> checklist;
  final List<RoadmapNote> notes;
  final List<RoadmapQaExchange> qaHistory;

  bool get isEmpty =>
      summary.isEmpty && checklist.isEmpty && notes.isEmpty && qaHistory.isEmpty;

  static RoadmapSection empty() =>
      const RoadmapSection(summary: '', checklist: []);

  RoadmapSection copyWith({
    String? summary,
    List<RoadmapChecklistItem>? checklist,
    List<RoadmapNote>? notes,
    List<RoadmapQaExchange>? qaHistory,
  }) {
    return RoadmapSection(
      summary: summary ?? this.summary,
      checklist: checklist ?? this.checklist,
      notes: notes ?? this.notes,
      qaHistory: qaHistory ?? this.qaHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'summary': summary,
      'checklist': checklist.map((item) => item.toMap()).toList(),
      'notes': notes.map((note) => note.toMap()).toList(),
      'qaHistory': qaHistory.map((exchange) => exchange.toMap()).toList(),
    };
  }

  factory RoadmapSection.fromMap(Object? raw) {
    if (raw is! Map) {
      return RoadmapSection.empty();
    }
    final map = Map<String, dynamic>.from(raw);
    final items = raw['checklist'];
    return RoadmapSection(
      summary: (map['summary'] as String?) ?? '',
      checklist: items is List
          ? items
              .whereType<Map>()
              .map(
                (item) => RoadmapChecklistItem.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
      notes: IntegrationRoadmap._parseList(map['notes'], RoadmapNote.fromMap),
      qaHistory: IntegrationRoadmap._parseList(
        map['qaHistory'],
        RoadmapQaExchange.fromMap,
      ),
    );
  }
}

class RoadmapChecklistItem {
  const RoadmapChecklistItem({
    required this.id,
    required this.text,
    this.done = false,
  });

  final String id;
  final String text;
  final bool done;

  RoadmapChecklistItem copyWith({String? text, bool? done}) {
    return RoadmapChecklistItem(
      id: id,
      text: text ?? this.text,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'done': done};
  }

  factory RoadmapChecklistItem.fromMap(Map<String, dynamic> map) {
    return RoadmapChecklistItem(
      id: (map['id'] as String?) ?? '',
      text: (map['text'] as String?) ?? '',
      done: (map['done'] as bool?) ?? false,
    );
  }
}

class ClarificationExchange {
  const ClarificationExchange({
    required this.question,
    required this.answer,
    this.answeredAt,
  });

  final String question;
  final String answer;
  final DateTime? answeredAt;

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      if (answeredAt != null) 'answeredAt': answeredAt!.toIso8601String(),
    };
  }

  factory ClarificationExchange.fromMap(Map<String, dynamic> map) {
    return ClarificationExchange(
      question: (map['question'] as String?) ?? '',
      answer: (map['answer'] as String?) ?? '',
      answeredAt: IntegrationRoadmap._parseDate(map['answeredAt']),
    );
  }
}

class RoadmapNote {
  const RoadmapNote({
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

  factory RoadmapNote.fromMap(Map<String, dynamic> map) {
    return RoadmapNote(
      id: (map['id'] as String?) ?? '',
      text: (map['text'] as String?) ?? '',
      createdAt:
          IntegrationRoadmap._parseDate(map['createdAt']) ?? DateTime.now(),
    );
  }
}

class RoadmapQaExchange {
  const RoadmapQaExchange({
    required this.question,
    required this.answer,
    required this.askedAt,
  });

  final String question;
  final String answer;
  final DateTime askedAt;

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'askedAt': askedAt.toIso8601String(),
    };
  }

  factory RoadmapQaExchange.fromMap(Map<String, dynamic> map) {
    return RoadmapQaExchange(
      question: (map['question'] as String?) ?? '',
      answer: (map['answer'] as String?) ?? '',
      askedAt: IntegrationRoadmap._parseDate(map['askedAt']) ?? DateTime.now(),
    );
  }
}

enum RoadmapSectionKey { firstMonth, firstThreeMonths, firstYear }

extension RoadmapSectionKeyLabel on RoadmapSectionKey {
  String get label {
    switch (this) {
      case RoadmapSectionKey.firstMonth:
        return 'First Month';
      case RoadmapSectionKey.firstThreeMonths:
        return 'First 3 Months';
      case RoadmapSectionKey.firstYear:
        return 'First Year';
    }
  }

  String get firestoreKey {
    switch (this) {
      case RoadmapSectionKey.firstMonth:
        return 'firstMonth';
      case RoadmapSectionKey.firstThreeMonths:
        return 'firstThreeMonths';
      case RoadmapSectionKey.firstYear:
        return 'firstYear';
    }
  }
}
