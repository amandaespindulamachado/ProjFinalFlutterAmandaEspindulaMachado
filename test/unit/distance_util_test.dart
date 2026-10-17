import 'package:flutter_test/flutter_test.dart';
import 'package:isp_tech_app/core/utils/distance_util.dart';

void main() {
  group('DistanceUtil', () {
    test('distância entre o mesmo ponto deve ser 0', () {
      final d = DistanceUtil.calculateKm(
        lat1: -27.5945,
        lon1: -48.5477,
        lat2: -27.5945,
        lon2: -48.5477,
      );
      expect(d, closeTo(0.0, 0.01));
    });

    test('distância Florianópolis a São Paulo deve ser ~ 490 km', () {
      // Florianópolis: -27.5945, -48.5477
      // São Paulo: -23.5505, -46.6333
      final d = DistanceUtil.calculateKm(
        lat1: -27.5945,
        lon1: -48.5477,
        lat2: -23.5505,
        lon2: -46.6333,
      );
      expect(d, closeTo(489, 30)); // ~489km com tolerância
    });

    test('format deve exibir metros quando distância < 1 km', () {
      expect(DistanceUtil.format(0.500), '500 m');
      expect(DistanceUtil.format(0.123), '123 m');
      expect(DistanceUtil.format(0.05), '50 m');
    });

    test('format deve exibir km quando distância >= 1 km', () {
      expect(DistanceUtil.format(1.0), '1.0 km');
      expect(DistanceUtil.format(15.4), '15.4 km');
      expect(DistanceUtil.format(100.0), '100.0 km');
    });
  });
}
