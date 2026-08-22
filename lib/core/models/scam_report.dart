/// Risk levels returned by the ScamShield AI.
enum RiskLevel { low, moderate, high }

/// Content category selected by the user before analysis.
enum ScamCategory {
  sms,
  email,
  job,
  rental,
  government,
}

extension ScamCategoryX on ScamCategory {
  String get apiValue => name;

  String get label => switch (this) {
        ScamCategory.sms => 'Text message',
        ScamCategory.email => 'Email',
        ScamCategory.job => 'Job offer',
        ScamCategory.rental => 'Rental ad',
        ScamCategory.government => 'Government',
      };
}

/// One message (or screenshot) in a ScamShield conversation thread.
class ScamThreadMessage {
  const ScamThreadMessage({
    this.text = '',
    this.contentRef,
    this.createdAt,
  });

  final String text;
  final String? contentRef;
  final DateTime? createdAt;

  bool get hasScreenshot => contentRef != null && contentRef!.isNotEmpty;
  bool get isEmpty => text.trim().isEmpty && !hasScreenshot;

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      if (contentRef != null && contentRef!.isNotEmpty) 'contentRef': contentRef,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory ScamThreadMessage.fromMap(Map<String, dynamic> map) {
    DateTime? createdAt;
    final raw = map['createdAt'];
    if (raw is String) createdAt = DateTime.tryParse(raw);
    return ScamThreadMessage(
      text: (map['text'] as String?)?.trim() ?? '',
      contentRef: (map['contentRef'] as String?)?.trim(),
      createdAt: createdAt,
    );
  }
}

/// Maps to Firestore `users/{uid}/scamReports/{id}`.
class ScamReport {
  const ScamReport({
    required this.id,
    required this.riskLevel,
    this.summary = '',
    this.reasons = const [],
    this.recommendedActions = const [],
    this.category = ScamCategory.sms,
    this.inputText = '',
    this.messages = const [],
    this.contentRef,
    this.previousRiskLevel,
    this.isPublic = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final RiskLevel riskLevel;
  final String summary;
  final List<String> reasons;
  final List<String> recommendedActions;
  final ScamCategory category;
  /// Flattened thread text (kept for older reports and quick display).
  final String inputText;
  /// Ordered conversation thread (original + follow-ups).
  final List<ScamThreadMessage> messages;
  final String? contentRef;
  /// Risk level before the latest reevaluation, if any.
  final RiskLevel? previousRiskLevel;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasScreenshot =>
      (contentRef != null && contentRef!.isNotEmpty) ||
      messages.any((m) => m.hasScreenshot);

  List<ScamThreadMessage> get thread {
    if (messages.isNotEmpty) return messages;
    if (inputText.trim().isEmpty && !hasScreenshot) return const [];
    return [
      ScamThreadMessage(
        text: inputText,
        contentRef: contentRef,
        createdAt: createdAt,
      ),
    ];
  }

  String get threadDisplayText {
    final parts = <String>[];
    for (var i = 0; i < thread.length; i++) {
      final message = thread[i];
      final label = thread.length == 1 ? 'Message' : 'Message ${i + 1}';
      final body = message.text.trim().isNotEmpty
          ? message.text.trim()
          : (message.hasScreenshot ? '[Screenshot]' : '');
      if (body.isEmpty) continue;
      parts.add('$label:\n$body');
    }
    return parts.join('\n\n');
  }

  bool get riskChanged =>
      previousRiskLevel != null && previousRiskLevel != riskLevel;

  ScamReport copyWith({
    String? id,
    RiskLevel? riskLevel,
    String? summary,
    List<String>? reasons,
    List<String>? recommendedActions,
    ScamCategory? category,
    String? inputText,
    List<ScamThreadMessage>? messages,
    String? contentRef,
    RiskLevel? previousRiskLevel,
    bool clearPreviousRiskLevel = false,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScamReport(
      id: id ?? this.id,
      riskLevel: riskLevel ?? this.riskLevel,
      summary: summary ?? this.summary,
      reasons: reasons ?? this.reasons,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      category: category ?? this.category,
      inputText: inputText ?? this.inputText,
      messages: messages ?? this.messages,
      contentRef: contentRef ?? this.contentRef,
      previousRiskLevel: clearPreviousRiskLevel
          ? null
          : (previousRiskLevel ?? this.previousRiskLevel),
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static RiskLevel parseRiskLevel(Object? raw) {
    switch ('$raw'.trim().toLowerCase()) {
      case 'low':
        return RiskLevel.low;
      case 'high':
        return RiskLevel.high;
      case 'moderate':
      default:
        return RiskLevel.moderate;
    }
  }

  static RiskLevel? parseOptionalRiskLevel(Object? raw) {
    if (raw == null) return null;
    final value = '$raw'.trim();
    if (value.isEmpty) return null;
    return parseRiskLevel(value);
  }

  static ScamCategory parseCategory(Object? raw) {
    switch ('$raw'.trim().toLowerCase()) {
      case 'email':
        return ScamCategory.email;
      case 'job':
        return ScamCategory.job;
      case 'rental':
        return ScamCategory.rental;
      case 'government':
        return ScamCategory.government;
      case 'sms':
      default:
        return ScamCategory.sms;
    }
  }

  static List<String> _stringList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static List<ScamThreadMessage> _parseMessages(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => ScamThreadMessage.fromMap(Map<String, dynamic>.from(item)))
        .where((m) => !m.isEmpty)
        .toList();
  }

  factory ScamReport.fromMap(String id, Map<String, dynamic> map) {
    DateTime? createdAt;
    final rawCreated = map['createdAt'];
    if (rawCreated is String) {
      createdAt = DateTime.tryParse(rawCreated);
    }
    DateTime? updatedAt;
    final rawUpdated = map['updatedAt'];
    if (rawUpdated is String) {
      updatedAt = DateTime.tryParse(rawUpdated);
    }

    final inputText = (map['inputText'] as String?)?.trim() ?? '';
    var messages = _parseMessages(map['messages']);
    final contentRef = (map['contentRef'] as String?)?.trim();
    if (messages.isEmpty && (inputText.isNotEmpty || (contentRef?.isNotEmpty ?? false))) {
      messages = [
        ScamThreadMessage(
          text: inputText,
          contentRef: contentRef,
          createdAt: createdAt,
        ),
      ];
    }

    return ScamReport(
      id: id,
      riskLevel: parseRiskLevel(map['riskLevel']),
      summary: (map['summary'] as String?)?.trim() ?? '',
      reasons: _stringList(map['reasons']),
      recommendedActions: _stringList(map['recommendedActions']),
      category: parseCategory(map['category']),
      inputText: inputText.isNotEmpty
          ? inputText
          : messages.map((m) => m.text).where((t) => t.isNotEmpty).join('\n\n'),
      messages: messages,
      contentRef: contentRef,
      previousRiskLevel: parseOptionalRiskLevel(map['previousRiskLevel']),
      isPublic: map['isPublic'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'riskLevel': riskLevel.name,
      'summary': summary,
      'reasons': reasons,
      'recommendedActions': recommendedActions,
      'category': category.apiValue,
      'inputText': inputText,
      'messages': thread.map((m) => m.toMap()).toList(),
      if (contentRef != null && contentRef!.isNotEmpty) 'contentRef': contentRef,
      if (previousRiskLevel != null) 'previousRiskLevel': previousRiskLevel!.name,
      'isPublic': isPublic,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
