import '../models/volcano_status.dart';
import '../models/sensor_data.dart';
import '../models/evacuation_route.dart';
import '../models/activity_log.dart';

/// Kontrak (interface) untuk semua operasi data.
///
/// ## Cara Integrasi Database / API / MQTT
///
/// 1. Buat file baru, misal: `firebase_data_service.dart`
/// 2. Implement class ini:
///    ```dart
///    class FirebaseDataService implements DataService {
///      @override
///      Future<VolcanoStatus> getVolcanoStatus() async {
///        final doc = await FirebaseFirestore.instance
///            .collection('status').doc('current').get();
///        return VolcanoStatus.fromJson(doc.data()!);
///      }
///      // ... implement method lainnya
///    }
///    ```
/// 3. Di `lib/providers/data_providers.dart`, ubah `dataServiceProvider`
///    agar menggunakan service baru Anda.
/// 4. Selesai! Seluruh UI otomatis menggunakan data dari Firebase.
abstract class DataService {
  /// Mengambil status gunung saat ini.
  Future<VolcanoStatus> getVolcanoStatus();

  /// Mengambil data sensor terkini.
  Future<SensorData> getSensorData();

  /// Mengambil info rute evakuasi terdekat.
  Future<EvacuationRoute> getEvacuationRoute();

  /// Mengambil semua lokasi evakuasi yang tersedia.
  Future<List<EvacuationRoute>> getEvacuationRoutes();

  /// Mengambil daftar log kejadian/aktivitas.
  Future<List<ActivityLog>> getActivityLogs();

  /// Mengecek apakah sistem (sensor/server) sedang online.
  Future<bool> isSystemOnline();

  // ---------------------------------------------------------------------------
  // STREAM REAL-TIME (Opsional)
  // Override method ini jika backend mendukung real-time updates (MQTT, WebSocket, Firestore).
  // ---------------------------------------------------------------------------

  /// Stream perubahan status secara real-time.
  /// Return null jika tidak mendukung real-time.
  Stream<VolcanoStatus>? get statusStream => null;

  /// Stream data sensor secara real-time.
  /// Return null jika tidak mendukung real-time.
  Stream<SensorData>? get sensorStream => null;

  /// Menutup koneksi dan membersihkan resource.
  /// Panggil saat aplikasi ditutup.
  Future<void> dispose() async {}
}
