import 'package:flutter_test/flutter_test.dart';
import 'package:ews_semeru/repositories/ews_repository.dart';
import 'package:ews_semeru/services/dummy_data_service.dart';
import 'package:ews_semeru/models/volcano_status.dart';
import 'package:ews_semeru/models/sensor_data.dart';

void main() {
  late EwsRepository repository;

  setUp(() {
    repository = EwsRepository(DummyDataService());
  });

  group('EwsRepository', () {
    test('getVolcanoStatus delegates to DataService', () async {
      final status = await repository.getVolcanoStatus();

      expect(status, isA<VolcanoStatus>());
      expect(status.level, isNotNull);
      expect(status.message, isNotEmpty);
    });

    test('getSensorData delegates to DataService', () async {
      final sensor = await repository.getSensorData();

      expect(sensor, isA<SensorData>());
      expect(sensor.gempaTotal, greaterThanOrEqualTo(0));
    });

    test('getEvacuationRoutes delegates to DataService', () async {
      final routes = await repository.getEvacuationRoutes();

      expect(routes, isNotEmpty);
    });

    test('getEvacuationRoute returns first route', () async {
      final route = await repository.getEvacuationRoute();
      final routes = await repository.getEvacuationRoutes();

      expect(route.id, routes.first.id);
    });

    test('getActivityLogs delegates to DataService', () async {
      final logs = await repository.getActivityLogs();

      expect(logs, isNotEmpty);
    });

    test('isSystemOnline delegates to DataService', () async {
      final online = await repository.isSystemOnline();
      expect(online, isTrue);
    });

    test('watchVolcanoStatus emits at least one value (fallback mode)', () async {
      final stream = repository.watchVolcanoStatus();
      final status = await stream.first;

      expect(status, isA<VolcanoStatus>());
      expect(status.level, isNotNull);
    });

    test('watchSensorData emits at least one value (fallback mode)', () async {
      final stream = repository.watchSensorData();
      final sensor = await stream.first;

      expect(sensor, isA<SensorData>());
      expect(sensor.gempaTotal, greaterThanOrEqualTo(0));
    });
  });
}
