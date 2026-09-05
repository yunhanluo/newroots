import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/career.dart';
import '../models/roadmap.dart';
import '../models/scam_report.dart';
import 'roadmap_ai_local.dart';
import 'user_profile_service.dart';

/// Client for the AI backend.
///
/// Roadmap AI calls the `roadmapAi` Cloud Function (OpenAI on the server).
class AiService {
  AiService(this._functions);

  final FirebaseFunctions _functions;

  static const _aiTimeout = Duration(seconds: 180);

  HttpsCallable _callable(String name) => _functions.httpsCallable(
        name,
        options: HttpsCallableOptions(timeout: _aiTimeout),
      );

  String _replyLanguage(UserProfileData profile, String? language) {
    final code = language?.trim() ?? '';
    if (code.isNotEmpty) return code;
    return profile.languageCode;
  }

  /// Calls the `analyzeScam` Cloud Function.
  Future<ScamReport> analyzeScam({
    String? text,
    String? contentRef,
    required ScamCategory category,
    required String language,
    String? priorThread,
    RiskLevel? priorRiskLevel,
    String? reportId,
  }) async {
    try {
      final result = await _callable('analyzeScam').call<Map<String, dynamic>>({
        if (text != null && text.trim().isNotEmpty) 'text': text.trim(),
        if (contentRef != null && contentRef.trim().isNotEmpty)
          'contentRef': contentRef.trim(),
        'category': category.apiValue,
        'language': language,
        if (priorThread != null && priorThread.trim().isNotEmpty)
          'priorThread': priorThread.trim(),
        if (priorRiskLevel != null) 'priorRiskLevel': priorRiskLevel.name,
        if (reportId != null && reportId.trim().isNotEmpty)
          'reportId': reportId.trim(),
      });
      final data = Map<String, dynamic>.from(result.data);
      final id = (data['id'] as String?)?.trim().isNotEmpty == true
          ? data['id'] as String
          : (reportId?.trim().isNotEmpty == true
              ? reportId!.trim()
              : 'scam_${DateTime.now().millisecondsSinceEpoch}');
      return ScamReport.fromMap(id, data);
    } catch (error, stack) {
      debugPrint('analyzeScam Cloud Function failed: $error\n$stack');
      rethrow;
    }
  }

  /// Calls the `careerMap` Cloud Function to generate career pathways.
  Future<List<CareerPath>> generateCareerPaths({
    required UserProfileData profile,
    required String additionalNotes,
    String? language,
  }) async {
    return _callCareerMap(
      profile: profile,
      additionalNotes: additionalNotes,
      action: 'generate',
      language: language,
    );
  }

  Future<CareerPath> regenerateCareerPath({
    required UserProfileData profile,
    required String additionalNotes,
    required List<CareerPath?> existingPaths,
    required int pathIndex,
    String? language,
  }) async {
    final path = pathIndex < existingPaths.length
        ? existingPaths[pathIndex]
        : null;
    final replyLanguage = _replyLanguage(profile, language);
    final result = await _callable('careerMap').call<Map<String, dynamic>>({
      'action': 'regenerate_path',
      'profile': _careerProfilePayload(profile, replyLanguage),
      'additionalNotes': additionalNotes.trim(),
      'language': replyLanguage,
      'languageCode': replyLanguage,
      'pathIndex': pathIndex,
      'pathId': path?.id.isNotEmpty == true
          ? path!.id
          : 'path${pathIndex + 1}',
      'replacePathTitle':
          path?.title.isNotEmpty == true ? path!.title : 'this path',
      'existingPaths': List.generate(
        CareerBridgeData.pathSlotCount,
        (index) {
          final item =
              index < existingPaths.length ? existingPaths[index] : null;
          return {
            'title': item?.title ?? '',
            'summary': item?.summary ?? '',
          };
        },
      ),
    });
    final data = Map<String, dynamic>.from(result.data);
    final rawPath = data['path'];
    if (rawPath is! Map) {
      throw StateError('No career path returned.');
    }
    return CareerPath.fromMap(Map<String, dynamic>.from(rawPath));
  }

  Future<String> askCareerQuestion({
    required UserProfileData profile,
    required String additionalNotes,
    required CareerPath path,
    required List<CareerQaExchange> qaHistory,
    required List<CareerPath?> existingPaths,
    required String question,
    String? language,
  }) async {
    try {
      final replyLanguage = _replyLanguage(profile, language);
      final result = await _callable('careerMap').call<Map<String, dynamic>>({
        'action': 'ask',
        'profile': _careerProfilePayload(profile, replyLanguage),
        'additionalNotes': additionalNotes.trim(),
        'language': replyLanguage,
        'languageCode': replyLanguage,
        'question': question.trim(),
        'path': path.toMap(),
        'qaHistory': [
          for (final item in qaHistory)
            {'question': item.question, 'answer': item.answer},
        ],
        'existingPaths': List.generate(
          CareerBridgeData.pathSlotCount,
          (index) {
            final item =
                index < existingPaths.length ? existingPaths[index] : null;
            return {
              'title': item?.title ?? '',
              'summary': item?.summary ?? '',
            };
          },
        ),
      });
      final data = Map<String, dynamic>.from(result.data);
      final answer = (data['answer'] as String?)?.trim() ?? '';
      if (answer.isEmpty) {
        throw StateError('No answer returned.');
      }
      return answer;
    } catch (error, stack) {
      debugPrint('careerMap ask failed: $error\n$stack');
      rethrow;
    }
  }

  Future<List<CareerPath>> _callCareerMap({
    required UserProfileData profile,
    required String additionalNotes,
    required String action,
    String? language,
  }) async {
    try {
      final replyLanguage = _replyLanguage(profile, language);
      final result = await _callable('careerMap').call<Map<String, dynamic>>({
        'action': action,
        'profile': _careerProfilePayload(profile, replyLanguage),
        'additionalNotes': additionalNotes.trim(),
        'language': replyLanguage,
        'languageCode': replyLanguage,
      });
      final data = Map<String, dynamic>.from(result.data);
      final rawPaths = data['paths'];
      if (rawPaths is! List) return [];
      return rawPaths
          .whereType<Map>()
          .map((item) => CareerPath.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error, stack) {
      debugPrint('careerMap Cloud Function failed: $error\n$stack');
      rethrow;
    }
  }

  /// Asks the `housingAi` Cloud Function a question about the current section.
  ///
  /// [history] is prior turns in this temporary session (`role` + `content`),
  /// excluding the latest [question].
  Future<String> askHousingQuestion({
    required String question,
    required String sectionTitle,
    required String sectionSummary,
    List<Map<String, String>> history = const [],
    String language = 'en',
  }) async {
    try {
      final result = await _callable('housingAi').call<Map<String, dynamic>>({
        'question': question.trim(),
        'sectionTitle': sectionTitle,
        'sectionSummary': sectionSummary,
        'language': language,
        if (history.isNotEmpty) 'history': history,
      });
      final data = Map<String, dynamic>.from(result.data);
      final answer = (data['answer'] as String?)?.trim() ?? '';
      if (answer.isEmpty) {
        throw StateError('No answer returned.');
      }
      return answer;
    } catch (error, stack) {
      debugPrint('housingAi Cloud Function failed: $error\n$stack');
      rethrow;
    }
  }

  Future<RoadmapAiResponse> _callRoadmapAi(
    Map<String, dynamic> payload,
  ) async {
    try {
      final result =
          await _callable('roadmapAi').call<Map<String, dynamic>>(payload);
      final data = result.data;
      return RoadmapAiResponse.fromMap(Map<String, dynamic>.from(data));
    } catch (error, stack) {
      debugPrint('roadmapAi Cloud Function failed: $error\n$stack');
      rethrow;
    }
  }

  Future<RoadmapAiResponse> generateRoadmap({
    required UserProfileData profile,
    required List<ClarificationExchange> clarifications,
    IntegrationRoadmap? existing,
    String? language,
  }) async {
    final payload = _basePayload(
      action: 'generate',
      profile: profile,
      clarifications: clarifications,
      roadmap: existing,
      language: language,
    );
    return _callRoadmapAi(payload);
  }

  Future<RoadmapAiResponse> submitClarification({
    required UserProfileData profile,
    required List<ClarificationExchange> clarifications,
    required String question,
    required String answer,
    IntegrationRoadmap? existing,
    String? language,
  }) async {
    final updated = [
      ...clarifications,
      ClarificationExchange(
        question: question,
        answer: answer,
        answeredAt: DateTime.now(),
      ),
    ];
    final payload = _basePayload(
      action: 'clarify',
      profile: profile,
      clarifications: updated,
      roadmap: existing,
      language: language,
    );
    return _callRoadmapAi(payload);
  }

  Future<RoadmapAiResponse> askRoadmapQuestion({
    required UserProfileData profile,
    required IntegrationRoadmap roadmap,
    required RoadmapSectionKey section,
    required String question,
    String? language,
  }) async {
    final payload = _basePayload(
      action: 'ask',
      profile: profile,
      roadmap: roadmap,
      userMessage: question,
      section: section.firestoreKey,
      language: language,
    );
    try {
      return await _callRoadmapAi(payload);
    } catch (_) {
      return RoadmapAiLocal.askQuestion(
        profile: profile,
        roadmap: roadmap,
        section: section,
        question: question,
      );
    }
  }

  Future<RoadmapAiResponse> regenerateRoadmap({
    required UserProfileData profile,
    required List<ClarificationExchange> clarifications,
    IntegrationRoadmap? existing,
    String? language,
  }) async {
    final payload = _basePayload(
      action: 'regenerate_all',
      profile: profile,
      clarifications: clarifications,
      roadmap: existing,
      language: language,
    );
    return _callRoadmapAi(payload);
  }

  Future<RoadmapAiResponse> regenerateSection({
    required UserProfileData profile,
    required RoadmapSectionKey section,
    required List<ClarificationExchange> clarifications,
    IntegrationRoadmap? existing,
    String? language,
  }) async {
    final payload = _basePayload(
      action: 'regenerate_section',
      profile: profile,
      clarifications: clarifications,
      roadmap: existing,
      section: section.firestoreKey,
      language: language,
    );
    return _callRoadmapAi(payload);
  }

  /// Debug-only: checks server AI configuration and OpenAI connectivity.
  Future<RoadmapAiDebugStatus?> fetchDebugStatus() async {
    try {
      final result = await _callable('roadmapAi')
          .call<Map<String, dynamic>>({'action': 'debug'});
      final data = Map<String, dynamic>.from(result.data);
      return RoadmapAiDebugStatus(
        apiKeyConfigured: data['apiKeyConfigured'] as bool? ?? false,
        openAiReachable: data['openAiReachable'] as bool?,
        detail: data['detail'] as String?,
      );
    } catch (error, stack) {
      debugPrint('roadmapAi debug check failed: $error\n$stack');
      return null;
    }
  }

  Map<String, dynamic> _basePayload({
    required String action,
    required UserProfileData profile,
    List<ClarificationExchange> clarifications = const [],
    IntegrationRoadmap? roadmap,
    String? userMessage,
    String? section,
    String? language,
  }) {
    final replyLanguage = _replyLanguage(profile, language);
    return {
      'action': action,
      'profile': _profilePayload(profile, replyLanguage),
      'language': replyLanguage,
      'languageCode': replyLanguage,
      if (clarifications.isNotEmpty)
        'clarifications': clarifications.map((c) => c.toMap()).toList(),
      if (roadmap != null &&
          (!roadmap.isEmpty || action == 'ask'))
        'roadmap': roadmap.toMap(),
      if (userMessage != null) 'userMessage': userMessage,
      if (section != null) 'section': section,
    };
  }

  Map<String, dynamic> _profilePayload(
    UserProfileData profile,
    String replyLanguage,
  ) {
    return {
      'languageCode': replyLanguage,
      'location': profile.location,
      'familySize': profile.familySize,
      'topPriorities': profile.topPriorities,
      'employmentBackground': profile.employmentBackground,
      'childrenInfo': profile.childrenInfo,
      'skippedQuestions': profile.skippedQuestions,
      'onboardingComplete': profile.onboardingComplete,
    };
  }

  Map<String, dynamic> _careerProfilePayload(
    UserProfileData profile,
    String replyLanguage,
  ) {
    return {
      'languageCode': replyLanguage,
      'location': profile.location,
      'employmentBackground': profile.employmentBackground,
      'topPriorities': profile.topPriorities,
    };
  }
}

/// Debug status from the `roadmapAi` `debug` action.
class RoadmapAiDebugStatus {
  const RoadmapAiDebugStatus({
    required this.apiKeyConfigured,
    this.openAiReachable,
    this.detail,
  });

  final bool apiKeyConfigured;
  final bool? openAiReachable;
  final String? detail;

  bool get hasProblem =>
      !apiKeyConfigured || openAiReachable == false;
}

/// User-facing message for AI Cloud Function failures.
String describeAiServiceError(Object error) {
  if (error is FirebaseFunctionsException) {
    return error.message ?? 'AI service error. Try again shortly.';
  }
  return 'Could not reach the AI service. Try again shortly.';
}

@Deprecated('Use describeAiServiceError')
String describeRoadmapAiError(Object error) => describeAiServiceError(error);

final aiServiceProvider = Provider<AiService>(
  (ref) => AiService(FirebaseFunctions.instanceFor(region: 'us-west1')),
);
