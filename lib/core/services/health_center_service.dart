import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/health_center.dart';

/// Nearby HRSA community health centers via `findHealthCenters`.
class HealthCenterService {
  HealthCenterService(this._functions);

  final FirebaseFunctions _functions;

  Future<
      ({
        String locationLabel,
        double latitude,
        double longitude,
        String source,
        List<HealthCenter> centers,
      })> findNearby({
    required String location,
    double radiusKm = 40,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('findHealthCenters')
          .call<Map<String, dynamic>>({
        'location': location.trim(),
        'radiusKm': radiusKm,
      });
      final data = Map<String, dynamic>.from(result.data);
      final raw = data['centers'];
      final centers = raw is List
          ? raw
              .whereType<Map>()
              .map((item) => HealthCenter.fromMap(Map<String, dynamic>.from(item)))
              .where((c) => c.name.isNotEmpty)
              .toList()
          : <HealthCenter>[];
      return (
        locationLabel: (data['locationLabel'] as String?) ?? location.trim(),
        latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
        source: (data['source'] as String?) ?? 'hrsa',
        centers: centers,
      );
    } catch (error, stack) {
      debugPrint('findHealthCenters failed: $error\n$stack');
      rethrow;
    }
  }
}

final healthCenterServiceProvider = Provider<HealthCenterService>(
  (ref) => HealthCenterService(
    FirebaseFunctions.instanceFor(region: 'us-west1'),
  ),
);
