import 'package:flutter_test/flutter_test.dart';
import 'package:ews_semeru/models/sensor_data.dart';

void main() {
  group('SensorData.fromJson', () {
    test('parses valid JSON correctly', () {
      final json = {
        'gempa_total': 34,
        'updated_at': '2026-06-16T21:00:00Z',
      };

      final sensor = SensorData.fromJson(json);

      expect(sensor.gempaTotal, 34);
      expect(sensor.updatedAt.year, 2026);
    });

    test('defaults gempa_total to 0 when absent', () {
      final json = <String, dynamic>{};

      final sensor = SensorData.fromJson(json);
      expect(sensor.gempaTotal, 0);
    });
  });

  group('SensorData.toJson', () {
    test('exports to JSON correctly', () {
      final sensor = SensorData(
        gempaTotal: 12,
        updatedAt: DateTime(2026, 6, 16, 21, 0),
      );

      final json = sensor.toJson();

      expect(json['gempa_total'], 12);
      expect(json['updated_at'], isNotEmpty);
    });
  });

  group('SensorData.formattedUpdateTime', () {
    test('formats time correctly', () {
      final sensor = SensorData(
        gempaTotal: 5,
        updatedAt: DateTime(2026, 6, 16, 21, 30),
      );

      expect(sensor.formattedUpdateTime, contains('16'));
      expect(sensor.formattedUpdateTime, contains('Jun'));
      expect(sensor.formattedUpdateTime, contains('21:30'));
    });
  });
}
