import 'package:flutter_test/flutter_test.dart';
import 'package:ews_semeru/services/dummy_data_service.dart';

void main() {
  late DummyDataService service;

  setUp(() {
    service = DummyDataService();
  });

  group('DummyDataService', () {
    test('getVolcanoStatus returns valid status', () async {
      final status = await service.getVolcanoStatus();

      expect(status.level, isNotNull);
      expect(status.message, isNotEmpty);
      expect(status.updatedAt, isNotNull);
    });

    test('getSensorData returns valid sensor data', () async {
      final sensor = await service.getSensorData();

      expect(sensor.amplitudo, greaterThan(0));
      expect(sensor.suhu, greaterThan(0));
      expect(sensor.gempaCount, greaterThanOrEqualTo(0));
      expect(sensor.updatedAt, isNotNull);
    });

    test('getEvacuationRoutes returns at least 1 route', () async {
      final routes = await service.getEvacuationRoutes();

      expect(routes, isNotEmpty);
      expect(routes.length, greaterThanOrEqualTo(1));

      for (final route in routes) {
        expect(route.id, isNotEmpty);
        expect(route.destination, isNotEmpty);
        expect(route.routeCoordinates, isNotEmpty);
        expect(route.emergencyContacts, isNotEmpty);
      }
    });

    test('getEvacuationRoute returns first route', () async {
      final route = await service.getEvacuationRoute();
      final routes = await service.getEvacuationRoutes();

      expect(route.id, routes.first.id);
    });

    test('getActivityLogs returns at least 1 log', () async {
      final logs = await service.getActivityLogs();

      expect(logs, isNotEmpty);
      expect(logs.length, greaterThanOrEqualTo(1));

      for (final log in logs) {
        expect(log.description, isNotEmpty);
        expect(log.timestamp, isNotNull);
      }
    });

    test('isSystemOnline returns true', () async {
      final online = await service.isSystemOnline();
      expect(online, isTrue);
    });

    test('statusStream returns null (not implemented)', () {
      expect(service.statusStream, isNull);
    });

    test('sensorStream returns null (not implemented)', () {
      expect(service.sensorStream, isNull);
    });
  });
}
