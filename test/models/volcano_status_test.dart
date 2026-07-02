import 'package:flutter_test/flutter_test.dart';
import 'package:ews_semeru/models/volcano_status.dart';

void main() {
  group('VolcanoStatus.fromJson', () {
    test('parses valid JSON correctly', () {
      final json = {
        'level': 'SIAGA',
        'message': 'Jauhi radius 13 KM',
        'updated_at': '2026-06-16T21:00:00Z',
      };

      final status = VolcanoStatus.fromJson(json);

      expect(status.level, StatusLevel.siaga);
      expect(status.message, 'Jauhi radius 13 KM');
      expect(status.updatedAt.year, 2026);
    });

    test('parses all valid level strings', () {
      for (final entry in {
        'NORMAL': StatusLevel.normal,
        'WASPADA': StatusLevel.waspada,
        'SIAGA': StatusLevel.siaga,
        'AWAS': StatusLevel.awas,
      }.entries) {
        final json = {
          'level': entry.key,
          'message': 'test',
          'updated_at': '2026-01-01T00:00:00Z',
        };
        final status = VolcanoStatus.fromJson(json);
        expect(
          status.level,
          entry.value,
          reason: 'Level ${entry.key} should parse correctly',
        );
      }
    });

    test('parses level case-insensitively', () {
      final json = {'level': 'siaga', 'message': 'test'};
      final status = VolcanoStatus.fromJson(json);
      expect(status.level, StatusLevel.siaga);
    });

    test('throws FormatException for missing level key', () {
      final json = {'message': 'some message'};
      expect(
        () => VolcanoStatus.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for empty level string', () {
      final json = {'level': '', 'message': 'some message'};
      expect(
        () => VolcanoStatus.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for invalid level string', () {
      final json = {'level': 'INVALID_LEVEL', 'message': 'some message'};
      expect(
        () => VolcanoStatus.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('defaults message to empty string when absent', () {
      final json = {'level': 'NORMAL'};
      final status = VolcanoStatus.fromJson(json);
      expect(status.message, '');
    });
  });

  group('VolcanoStatus.toJson', () {
    test('round-trip fromJson -> toJson preserves data', () {
      final original = {
        'level': 'AWAS',
        'message': 'Evakuasi segera',
        'updated_at': '2026-06-16T21:00:00.000Z',
      };

      final status = VolcanoStatus.fromJson(original);
      final exported = status.toJson();

      expect(exported['level'], 'AWAS');
      expect(exported['message'], 'Evakuasi segera');
      expect(exported['updated_at'], isNotEmpty);
    });
  });

  group('VolcanoStatus properties', () {
    test('levelLabel returns correct string', () {
      final status = VolcanoStatus(
        level: StatusLevel.awas,
        message: 'test',
        updatedAt: DateTime(2026, 1, 1),
      );
      expect(status.levelLabel, 'AWAS');
    });
  });
}
