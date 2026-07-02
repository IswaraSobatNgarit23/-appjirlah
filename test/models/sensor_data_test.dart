import 'package:flutter_test/flutter_test.dart';
import 'package:ews_semeru/models/sensor_data.dart';

void main() {
  group('SensorData.fromJson', () {
    test('parses valid JSON correctly', () {
      final json = {
        'amplitudo': 20.0,
        'suhu': 78.5,
        'gempa_count': 34,
        'updated_at': '2026-06-16T21:00:00Z',
      };

      final sensor = SensorData.fromJson(json);

      expect(sensor.amplitudo, 20.0);
      expect(sensor.suhu, 78.5);
      expect(sensor.gempaCount, 34);
      expect(sensor.updatedAt.year, 2026);
    });

    test('handles integer values for amplitudo and suhu', () {
      final json = {
        'amplitudo': 20,
        'suhu': 78,
        'gempa_count': 10,
      };

      final sensor = SensorData.fromJson(json);

      expect(sensor.amplitudo, 20.0);
      expect(sensor.suhu, 78.0);
    });

    test('defaults gempa_count to 0 when absent', () {
      final json = {
        'amplitudo': 5.0,
        'suhu': 50.0,
      };

      final sensor = SensorData.fromJson(json);
      expect(sensor.gempaCount, 0);
    });

    test('throws FormatException when amplitudo is missing', () {
      final json = {
        'suhu': 78.5,
        'gempa_count': 34,
      };

      expect(
        () => SensorData.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when suhu is missing', () {
      final json = {
        'amplitudo': 20.0,
        'gempa_count': 34,
      };

      expect(
        () => SensorData.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('SensorData.toJson', () {
    test('exports to JSON correctly', () {
      final sensor = SensorData(
        amplitudo: 15.5,
        suhu: 100.0,
        gempaCount: 12,
        updatedAt: DateTime(2026, 6, 16, 21, 0),
      );

      final json = sensor.toJson();

      expect(json['amplitudo'], 15.5);
      expect(json['suhu'], 100.0);
      expect(json['gempa_count'], 12);
      expect(json['updated_at'], isNotEmpty);
    });
  });

  group('SensorData.formattedUpdateTime', () {
    test('formats time correctly', () {
      final sensor = SensorData(
        amplitudo: 10.0,
        suhu: 50.0,
        gempaCount: 5,
        updatedAt: DateTime(2026, 6, 16, 21, 30),
      );

      expect(sensor.formattedUpdateTime, contains('16'));
      expect(sensor.formattedUpdateTime, contains('Jun'));
      expect(sensor.formattedUpdateTime, contains('21:30'));
    });
  });
}
