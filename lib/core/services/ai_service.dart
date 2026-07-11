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

  /// Calls the `analyzeScam` Cloud Function.
  Future<ScamReport> analyzeScam({
    String? text,
    String? contentRef,
    required String language,
  }) async {
    throw UnimplementedError('analyzeScam Cloud Function not wired yet');
  }

  /// Calls the `careerMap` Cloud Function to generate career pathways.
  Future<List<CareerPath>> generateCareerPaths({
    required UserProfileData profile,
    required String additionalNotes,
  }) async {
    return _callCareerMap(
      profile: profile,
      additionalNotes: additionalNotes,
      action: 'generate',
    );
  }

  Future<CareerPath> regenerateCareerPath({
    required UserProfileData profile,
    required String additionalNotes,
    required List<CareerPath> existingPaths,
    required int pathIndex,
  }) async {
    final path = existingPaths[pathIndex];
    final result = await _functions
        .httpsCallable('careerMap')
        .call<Map<String, dynamic>>({
      'action': 'regenerate_path',
      'profile': _careerProfilePayload(profile),
      'additionalNotes': additionalNotes.trim(),
      'language': profile.languageCode,
      'pathIndex': pathIndex,
      'pathId': path.id,
      'replacePathTitle': path.title,
      'existingPaths': existingPaths
          .map((p) => {'title': p.title, 'summary': p.summary})
          .toList(),
    });
    final data = Map<String, dynamic>.from(result.data);
    final rawPath = data['path'];
    if (rawPath is! Map) {
      throw StateError('No career path returned.');
    }
    return CareerPath.fromMap(Map<String, dynamic>.from(rawPath));
  }

  Future<List<CareerPath>> _callCareerMap({
    required UserProfileData profile,
    required String additionalNotes,
    required String action,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('careerMap')
          .call<Map<String, dynamic>>({
        'action': action,
        'profile': _careerProfilePayload(profile),
        'additionalNotes': additionalNotes.trim(),
        'language': profile.languageCode,
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

  Future<RoadmapAiResponse> _callRoadmapAi(
    Map<String, dynamic> payload,
  ) async {
    try {
      final result = await _functions
          .httpsCallable('roadmapAi')
          .call<Map<String, dynamic>>(payload);
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
  }) async {
    final payload = _basePayload(
      action: 'generate',
      profile: profile,
      clarifications: clarifications,
      roadmap: existing,
    );
    return _callRoadmapAi(payload);
  }

  Future<RoadmapAiResponse> submitClarification({
    required UserProfileData profile,
    required List<ClarificationExchange> clarifications,
    required String question,
    required String answer,
    IntegrationRoadmap? existing,
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
    );
    return _callRoadmapAi(payload);
  }

  Future<RoadmapAiResponse> askRoadmapQuestion({
    required UserProfileData profile,
    required IntegrationRoadmap roadmap,
    required RoadmapSectionKey section,
    required String question,
  }) async {
    final payload = _basePayload(
      action: 'ask',
      profile: profile,
      roadmap: roadmap,
      userMessage: question,
      section: section.firestoreKey,
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
  }) async {
    final payload = _basePayload(
      action: 'regenerate_all',
      profile: profile,
      clarifications: clarifications,
      roadmap: existing,
    );
    return _callRoadmapAi(payload);
  }

  Future<RoadmapAiResponse> regenerateSection({
    required UserProfileData profile,
    required RoadmapSectionKey section,
    required List<ClarificationExchange> clarifications,
    IntegrationRoadmap? existing,
  }) async {
    final payload = _basePayload(
      action: 'regenerate_section',
      profile: profile,
      clarifications: clarifications,
      roadmap: existing,
      section: section.firestoreKey,
    );
    return _callRoadmapAi(payload);
  }

  /// Debug-only: checks server AI configuration and OpenAI connectivity.
  Future<RoadmapAiDebugStatus?> fetchDebugStatus() async {
    try {
      final result = await _functions
          .httpsCallable('roadmapAi')
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
  }) {
    return {
      'action': action,
      'profile': _profilePayload(profile),
      if (clarifications.isNotEmpty)
        'clarifications': clarifications.map((c) => c.toMap()).toList(),
      if (roadmap != null &&
          (!roadmap.isEmpty || action == 'ask'))
        'roadmap': roadmap.toMap(),
      if (userMessage != null) 'userMessage': userMessage,
      if (section != null) 'section': section,
    };
  }

  Map<String, dynamic> _profilePayload(UserProfileData profile) {
    return {
      'languageCode': profile.languageCode,
      'location': profile.location,
      'familySize': profile.familySize,
      'topPriorities': profile.topPriorities,
      'employmentBackground': profile.employmentBackground,
      'childrenInfo': profile.childrenInfo,
      'skippedQuestions': profile.skippedQuestions,
      'onboardingComplete': profile.onboardingComplete,
    };
  }

  Map<String, dynamic> _careerProfilePayload(UserProfileData profile) {
    return {
      'languageCode': profile.languageCode,
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
