import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/education_resource.dart';

/// Nearby California schools and education programs via `findEducationResources`.
class EducationResourceService {
  EducationResourceService(this._functions);

  final FirebaseFunctions _functions;

  Future<SchoolAiSummary> summarizeSchool({
    required String resourceId,
    String language = 'en',
  }) async {
    try {
      final result = await _functions
          .httpsCallable('educationSchoolSummary')
          .call<Map<String, dynamic>>({
            'resourceId': resourceId,
            'language': language,
          });
      final summary = SchoolAiSummary.fromMap(
        Map<String, dynamic>.from(result.data),
      );
      if (summary.overview.isEmpty) {
        throw StateError('No school summary returned.');
      }
      return summary;
    } catch (error, stack) {
      debugPrint('educationSchoolSummary failed: $error\n$stack');
      rethrow;
    }
  }

  Future<
    ({
      String locationLabel,
      double latitude,
      double longitude,
      String source,
      List<EducationResource> resources,
    })
  >
  findNearby({
    required String location,
    String gradeBand = 'all',
    int? gradeMin,
    int? gradeMax,
    String kind = 'all',
    double radiusKm = 25,
    String language = 'en',
  }) async {
    try {
      final result = await _functions
          .httpsCallable('findEducationResources')
          .call<Map<String, dynamic>>({
            'location': location.trim(),
            'gradeBand': gradeBand,
            if (gradeMin != null && gradeMax != null) 'gradeMin': gradeMin,
            if (gradeMin != null && gradeMax != null) 'gradeMax': gradeMax,
            'kind': kind,
            'radiusKm': radiusKm,
            'language': language,
          });
      final data = Map<String, dynamic>.from(result.data);
      final raw = data['resources'];
      final resources = raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (item) => EducationResource.fromMap(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((r) => r.title.isNotEmpty)
                .toList()
          : <EducationResource>[];
      return (
        locationLabel: (data['locationLabel'] as String?) ?? location.trim(),
        latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
        source: (data['source'] as String?) ?? 'cde+curated',
        resources: resources,
      );
    } catch (error, stack) {
      debugPrint('findEducationResources failed: $error\n$stack');
      rethrow;
    }
  }
}

final educationResourceServiceProvider = Provider<EducationResourceService>(
  (ref) => EducationResourceService(
    FirebaseFunctions.instanceFor(region: 'us-west1'),
  ),
);
