import 'dart:math';

/// Calcula distâncias geográficas usando a fórmula de Haversine.
class DistanceUtil {
  DistanceUtil._();

  static const double _earthRadiusKm = 6371.0;

  /// Retorna a distância em km entre dois pontos geográficos.
  static double calculateKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _toRad(double degrees) => degrees * pi / 180.0;

  /// Formata distância: mostra metros se < 1 km, km caso contrário.
  static String format(double km) {
    if (km < 1.0) {
      return '${(km * 1000).toStringAsFixed(0)} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}
