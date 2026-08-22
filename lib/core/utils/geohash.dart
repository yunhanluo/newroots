import 'dart:math' as math;

/// Minimal geohash helpers for nearby Firestore queries.
///
/// Precision guide (approx):
/// - 4 ≈ 20–40 km (good for city / metro ESL search)
/// - 5 ≈ 5 km
class GeoHash {
  GeoHash._();

  static const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Encodes [latitude], [longitude] to a geohash of [precision] characters.
  static String encode(
    double latitude,
    double longitude, {
    int precision = 4,
  }) {
    var latMin = -90.0;
    var latMax = 90.0;
    var lngMin = -180.0;
    var lngMax = 180.0;
    final buffer = StringBuffer();
    var bit = 0;
    var ch = 0;
    var even = true;

    while (buffer.length < precision) {
      if (even) {
        final mid = (lngMin + lngMax) / 2;
        if (longitude >= mid) {
          ch |= 1 << (4 - bit);
          lngMin = mid;
        } else {
          lngMax = mid;
        }
      } else {
        final mid = (latMin + latMax) / 2;
        if (latitude >= mid) {
          ch |= 1 << (4 - bit);
          latMin = mid;
        } else {
          latMax = mid;
        }
      }
      even = !even;
      if (bit < 4) {
        bit += 1;
      } else {
        buffer.write(_base32[ch]);
        bit = 0;
        ch = 0;
      }
    }
    return buffer.toString();
  }

  /// Center cell plus 8 neighbors (for boundary-safe nearby queries).
  static Set<String> queryPrefixes(String hash) {
    return {hash, ...neighbors(hash)};
  }

  static Set<String> neighbors(String hash) {
    if (hash.isEmpty) return {};
    final adjacent = <String>{
      _adjacent(hash, _Direction.top),
      _adjacent(hash, _Direction.bottom),
      _adjacent(hash, _Direction.left),
      _adjacent(hash, _Direction.right),
    };
    final top = _adjacent(hash, _Direction.top);
    final bottom = _adjacent(hash, _Direction.bottom);
    adjacent.add(_adjacent(top, _Direction.left));
    adjacent.add(_adjacent(top, _Direction.right));
    adjacent.add(_adjacent(bottom, _Direction.left));
    adjacent.add(_adjacent(bottom, _Direction.right));
    return adjacent.where((value) => value.isNotEmpty).toSet();
  }

  static String _adjacent(String hash, _Direction direction) {
    if (hash.isEmpty) return '';
    const neighbor = {
      _Direction.right: [
        'bc01fg45238967deuvhjyznpkmstqrwx',
        'p0r21436x8zb9dcf5h7kjnmqesgutwvy',
      ],
      _Direction.left: [
        '238967debc01fg45kmstqrwxuvhjyznp',
        '14365h7k9dcfesgujnmqp0r2twvyx8zb',
      ],
      _Direction.top: [
        'p0r21436x8zb9dcf5h7kjnmqesgutwvy',
        'bc01fg45238967deuvhjyznpkmstqrwx',
      ],
      _Direction.bottom: [
        '14365h7k9dcfesgujnmqp0r2twvyx8zb',
        '238967debc01fg45kmstqrwxuvhjyznp',
      ],
    };
    const border = {
      _Direction.right: ['bcfguvyz', 'prxz'],
      _Direction.left: ['0145hjnp', '028b'],
      _Direction.top: ['prxz', 'bcfguvyz'],
      _Direction.bottom: ['028b', '0145hjnp'],
    };

    final last = hash[hash.length - 1];
    var parent = hash.substring(0, hash.length - 1);
    final type = hash.length.isOdd ? 0 : 1;
    if (border[direction]![type].contains(last) && parent.isNotEmpty) {
      parent = _adjacent(parent, direction);
    }
    if (parent.isEmpty && border[direction]![type].contains(last)) {
      return '';
    }
    final neighborMap = neighbor[direction]![type];
    final idx = _base32.indexOf(last);
    return parent + neighborMap[idx];
  }

  /// Great-circle distance in kilometers.
  static double distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}

enum _Direction { top, bottom, left, right }
