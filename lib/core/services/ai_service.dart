import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/roadmap.dart';
import '../models/scam_report.dart';

/// Client for the AI backend.
///
/// IMPORTANT (see DESIGN_PLAN.md §6): the app NEVER holds LLM API keys.
/// All AI runs in Cloud Functions, invoked here as callable functions and
/// protected by App Check. These are placeholders.
class AiService {
  // TODO: inject FirebaseFunctions.instance (correct region).

  /// Calls the `generateRoadmap` Cloud Function.
  Future<Roadmap> generateRoadmap({
    required String language,
    required Map<String, dynamic> profile,
  }) async {
    // TODO: final result = await functions.httpsCallable('generateRoadmap').call({...});
    throw UnimplementedError('generateRoadmap Cloud Function not wired yet');
  }

  /// Calls the `analyzeScam` Cloud Function.
  ///
  /// [contentRef] is a Cloud Storage path (for uploaded screenshots) or null
  /// when [text] is provided directly.
  Future<ScamReport> analyzeScam({
    String? text,
    String? contentRef,
    required String language,
  }) async {
    // TODO: final result = await functions.httpsCallable('analyzeScam').call({...});
    throw UnimplementedError('analyzeScam Cloud Function not wired yet');
  }

  /// Calls the `careerMap` Cloud Function.
  Future<List<String>> mapCareer({
    required String priorRole,
    required String language,
  }) async {
    // TODO: functions.httpsCallable('careerMap')
    throw UnimplementedError('careerMap Cloud Function not wired yet');
  }
}

final aiServiceProvider = Provider<AiService>((ref) => AiService());
