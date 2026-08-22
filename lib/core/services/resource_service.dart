import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/resource.dart';

/// English / resource finder client.
///
/// Nearby ESL discovery goes through `findEnglishResources` (curated CA
/// adult schools, community colleges, and libraries).
class ResourceService {
  ResourceService(this._functions);

  final FirebaseFunctions _functions;

  /// Finds nearby English resources via the `findEnglishResources` function.
  Future<
      ({
        String locationLabel,
        double latitude,
        double longitude,
        String source,
        List<Resource> resources,
      })> findEnglishNearby({
    required String location,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('findEnglishResources')
          .call<Map<String, dynamic>>({
        'location': location.trim(),
      });
      final data = Map<String, dynamic>.from(result.data);
      final raw = data['resources'];
      final resources = raw is List
          ? raw
              .whereType<Map>()
              .map((item) {
                final map = Map<String, dynamic>.from(item);
                return Resource.fromMap(
                  '${map['id'] ?? ''}',
                  map,
                ).copyWith(
                  distanceKm: (map['distanceKm'] as num?)?.toDouble(),
                );
              })
              .toList()
          : <Resource>[];
      return (
        locationLabel: (data['locationLabel'] as String?) ?? location.trim(),
        latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
        source: (data['source'] as String?) ?? 'curated',
        resources: resources,
      );
    } catch (error, stack) {
      debugPrint('findEnglishResources failed: $error\n$stack');
      rethrow;
    }
  }
}

final resourceServiceProvider = Provider<ResourceService>(
  (ref) => ResourceService(
    FirebaseFunctions.instanceFor(region: 'us-west1'),
  ),
);
