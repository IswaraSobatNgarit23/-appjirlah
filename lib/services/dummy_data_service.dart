import '../models/volcano_status.dart';
import '../models/sensor_data.dart';
import '../models/evacuation_route.dart';
import '../models/activity_log.dart';
import '../data/fixtures/dummy_routes.dart';
import '../data/fixtures/dummy_logs.dart';
import 'data_service.dart';

/// Implementasi DataService dengan data dummy (simulasi).
///
/// Gunakan class ini untuk development dan testing.
/// Saat backend sudah siap, buat implementasi baru (misal: `ApiDataService`)
/// yang mengimplementasikan [DataService], lalu ganti di `data_providers.dart`.
class DummyDataService implements DataService {
  @override
  Future<VolcanoStatus> getVolcanoStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return VolcanoStatus(
      level: StatusLevel.siaga,
      message: 'Jauhi radius 13 KM',
      updatedAt: DateTime(2026, 6, 16, 21, 0),
    );
  }

  @override
  Future<SensorData> getSensorData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return SensorData(
      amplitudo: 20.0,
      suhu: 78.5,
      gempaCount: 34,
      updatedAt: DateTime(2026, 6, 16, 21, 0),
    );
  }

  @override
  Future<EvacuationRoute> getEvacuationRoute() async {
    final routes = await getEvacuationRoutes();
    return routes.first;
  }

  @override
  Future<List<EvacuationRoute>> getEvacuationRoutes() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return getDummyRoutes();
  }

  @override
  Future<List<ActivityLog>> getActivityLogs() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return getDummyLogs();
  }

  @override
  Future<bool> isSystemOnline() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Stream<VolcanoStatus>? get statusStream => null;

  @override
  Stream<SensorData>? get sensorStream => null;

  @override
  Future<void> dispose() async {}
}
