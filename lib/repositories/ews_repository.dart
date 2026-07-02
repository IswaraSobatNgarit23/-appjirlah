import 'dart:async';
import 'dart:io';

import '../core/failures.dart';
import '../models/volcano_status.dart';
import '../models/sensor_data.dart';
import '../models/evacuation_route.dart';
import '../models/activity_log.dart';
import '../services/data_service.dart';

/// Repository layer antara Provider dan DataService.
///
/// Alur arsitektur:
/// ```
/// UI (Widget) -> Provider (Riverpod) -> Repository -> DataService
/// ```
///
/// Tanggung jawab repository:
/// - Memetakan error dari DataService ke [AppFailure] yang terstruktur.
/// - Titik masuk untuk cache/offline di masa depan.
/// - Fallback logic (misal: jika stream null, gunakan Future).
///
/// Repository TIDAK mengetahui implementasi DataService mana yang digunakan.
/// Ia hanya bergantung pada kontrak abstrak [DataService].
class EwsRepository {
  final DataService _dataService;

  EwsRepository(this._dataService);

  /// Mengambil status gunung api terkini.
  Future<VolcanoStatus> getVolcanoStatus() async {
    try {
      return await _dataService.getVolcanoStatus();
    } catch (e) {
      throw _mapError(e, 'Gagal mengambil status gunung.');
    }
  }

  /// Mengambil data sensor terkini.
  Future<SensorData> getSensorData() async {
    try {
      return await _dataService.getSensorData();
    } catch (e) {
      throw _mapError(e, 'Gagal mengambil data sensor.');
    }
  }

  /// Mengambil semua rute evakuasi yang tersedia.
  Future<List<EvacuationRoute>> getEvacuationRoutes() async {
    try {
      return await _dataService.getEvacuationRoutes();
    } catch (e) {
      throw _mapError(e, 'Gagal mengambil daftar rute evakuasi.');
    }
  }

  /// Mengambil rute evakuasi pertama (backward compatible).
  Future<EvacuationRoute> getEvacuationRoute() async {
    try {
      return await _dataService.getEvacuationRoute();
    } catch (e) {
      throw _mapError(e, 'Gagal mengambil rute evakuasi.');
    }
  }

  /// Mengambil daftar log aktivitas/kejadian.
  Future<List<ActivityLog>> getActivityLogs() async {
    try {
      return await _dataService.getActivityLogs();
    } catch (e) {
      throw _mapError(e, 'Gagal mengambil log aktivitas.');
    }
  }

  /// Mengecek apakah sistem (sensor/server) sedang online.
  Future<bool> isSystemOnline() async {
    try {
      return await _dataService.isSystemOnline();
    } catch (e) {
      throw _mapError(e, 'Gagal mengecek status sistem.');
    }
  }

  // ---------------------------------------------------------------------------
  // STREAM (Real-time)
  //
  // Jika DataService menyediakan stream, gunakan langsung.
  // Jika tidak (null), fallback ke single-emit stream dari Future.
  // ---------------------------------------------------------------------------

  /// Stream status gunung api secara real-time.
  /// Fallback ke single-emit jika DataService belum mendukung stream.
  Stream<VolcanoStatus> watchVolcanoStatus() {
    final stream = _dataService.statusStream;
    if (stream != null) return stream;
    return Stream.fromFuture(getVolcanoStatus());
  }

  /// Stream data sensor secara real-time.
  /// Fallback ke single-emit jika DataService belum mendukung stream.
  Stream<SensorData> watchSensorData() {
    final stream = _dataService.sensorStream;
    if (stream != null) return stream;
    return Stream.fromFuture(getSensorData());
  }

  /// Menutup koneksi dan membersihkan resource.
  Future<void> dispose() {
    return _dataService.dispose();
  }

  // ---------------------------------------------------------------------------
  // ERROR MAPPING
  // ---------------------------------------------------------------------------

  /// Memetakan error dari DataService ke [AppFailure] yang terstruktur.
  ///
  /// - [FormatException] -> [DataParsingFailure]
  /// - [SocketException], [HttpException] -> [NetworkFailure]
  /// - [AppFailure] (sudah terstruktur) -> diteruskan langsung
  /// - Lainnya -> [UnknownFailure]
  AppFailure _mapError(Object error, String context) {
    if (error is AppFailure) return error;

    if (error is FormatException) {
      return DataParsingFailure(
        '$context Format data tidak valid.',
        originalError: error,
      );
    }

    if (error is SocketException || error is HttpException) {
      return NetworkFailure(
        '$context Periksa koneksi internet Anda.',
        originalError: error,
      );
    }

    return UnknownFailure(
      '$context ${error.toString()}',
      originalError: error,
    );
  }
}
