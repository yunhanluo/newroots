import '../models/roadmap.dart';
import 'user_profile_service.dart';

/// Response from the roadmap AI backend.
class RoadmapAiResponse {
  const RoadmapAiResponse({
    required this.status,
    this.question,
    this.questions = const [],
    this.answer,
    this.roadmap,
    this.section,
    this.sectionData,
    this.errorMessage,
  });

  final RoadmapAiStatus status;
  /// First question in the queue (kept for backward compatibility).
  final String? question;
  /// Clarification questions returned by the AI, in order.
  final List<String> questions;
  final String? answer;
  final IntegrationRoadmap? roadmap;
  final RoadmapSectionKey? section;
  final RoadmapSection? sectionData;
  final String? errorMessage;

  List<String> get clarificationQueue {
    if (questions.isNotEmpty) return questions;
    if (question != null && question!.isNotEmpty) return [question!];
    return const [];
  }

  factory RoadmapAiResponse.fromMap(Map<String, dynamic> map) {
    final statusName = map['status'] as String? ?? 'complete';
    final status = switch (statusName) {
      'needs_clarification' => RoadmapAiStatus.needsClarification,
      'answer' => RoadmapAiStatus.answer,
      'error' => RoadmapAiStatus.error,
      'complete' => RoadmapAiStatus.complete,
      _ => RoadmapAiStatus.complete,
    };

    final parsedQuestions = _parseQuestions(map['questions']);
    final singleQuestion = map['question'] as String?;
    final questions = parsedQuestions.isNotEmpty
        ? parsedQuestions
        : (singleQuestion != null && singleQuestion.isNotEmpty
            ? [singleQuestion]
            : <String>[]);

    IntegrationRoadmap? roadmap;
    final rawRoadmap = map['roadmap'];
    if (rawRoadmap is Map) {
      roadmap = IntegrationRoadmap.fromMap(Map<String, dynamic>.from(rawRoadmap));
    }

    RoadmapSectionKey? section;
    final sectionName = map['section'] as String?;
    if (sectionName != null) {
      section = RoadmapSectionKey.values.firstWhere(
        (value) => value.firestoreKey == sectionName,
        orElse: () => RoadmapSectionKey.firstMonth,
      );
    }

    RoadmapSection? sectionData;
    final rawSection = map['sectionData'];
    if (rawSection is Map) {
      sectionData = RoadmapSection.fromMap(rawSection);
    }

    return RoadmapAiResponse(
      status: status,
      question: questions.isNotEmpty ? questions.first : singleQuestion,
      questions: questions,
      answer: map['answer'] as String?,
      roadmap: roadmap,
      section: section,
      sectionData: sectionData,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  static List<String> _parseQuestions(Object? raw) {
    if (raw is! List) return [];
    return raw.whereType<String>().where((q) => q.trim().isNotEmpty).toList();
  }
}

enum RoadmapAiStatus {
  needsClarification,
  complete,
  answer,
  error,
}

/// Offline fallback — clarifications and generation require the Cloud Function.
class RoadmapAiLocal {
  static const _unavailableMessage =
      'AI service is unavailable. Ensure the roadmapAi Cloud Function is deployed '
      'and OPENAI_API_KEY is configured.';

  static RoadmapAiResponse unavailable() {
    return const RoadmapAiResponse(
      status: RoadmapAiStatus.error,
      errorMessage: _unavailableMessage,
    );
  }

  static RoadmapAiResponse askQuestion({
    required UserProfileData profile,
    required IntegrationRoadmap roadmap,
    required RoadmapSectionKey section,
    required String question,
  }) {
    return unavailable();
  }

  static RoadmapAiResponse regenerateSection({
    required UserProfileData profile,
    required RoadmapSectionKey section,
    required List<ClarificationExchange> clarifications,
  }) {
    return unavailable();
  }
}
