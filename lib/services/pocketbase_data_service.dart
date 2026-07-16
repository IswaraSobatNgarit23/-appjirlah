import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/material.dart';

import '../models/volcano_status.dart';
import '../models/sensor_data.dart';
import '../models/evacuation_route.dart';
import '../models/activity_log.dart';
import 'data_service.dart';

class PocketbaseDataService implements DataService {
  late final PocketBase pb;
  
  // Cache data terakhir untuk fallback saat offline
  VolcanoStatus? _lastStatus;
  SensorData? _lastSensor;

  PocketbaseDataService() {
    final url = dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090';
    pb = PocketBase(url);
    debugPrint('PocketBase Service diinisialisasi dengan URL: $url');
  }

  @override
  Future<VolcanoStatus> getVolcanoStatus() async {
    try {
      // Ambil 1 record terakhir dari tabel volcano_status
      final records = await pb.collection('volcano_status').getList(
        page: 1,
        perPage: 1,
        sort: '-created',
      );

      if (records.items.isNotEmpty) {
        final data = records.items.first.data;
        
        StatusLevel level = StatusLevel.normal;
        final levelInt = data['level'] as int? ?? 1;
        if (levelInt == 2) level = StatusLevel.waspada;
        if (levelInt == 3) level = StatusLevel.siaga;
        if (levelInt == 4) level = StatusLevel.awas;

        _lastStatus = VolcanoStatus(
          level: level,
          message: data['message']?.toString() ?? 'Tidak ada pesan',
          updatedAt: DateTime.parse(records.items.first.created),
        );
        return _lastStatus!;
      }
    } catch (e) {
      debugPrint('Error getVolcanoStatus: $e');
    }
    
    // Fallback jika gagal atau kosong
    return _lastStatus ?? VolcanoStatus.fallback();
  }

  @override
  Stream<VolcanoStatus> watchVolcanoStatus() async* {
    // Berikan data awal
    yield await getVolcanoStatus();
    
    // Subscribe ke realtime changes
    final controller = StreamController<VolcanoStatus>();
    
    pb.collection('volcano_status').subscribe('*', (e) {
      if (e.record != null) {
        final data = e.record!.data;
        StatusLevel level = StatusLevel.normal;
        final levelInt = data['level'] as int? ?? 1;
        if (levelInt == 2) level = StatusLevel.waspada;
        if (levelInt == 3) level = StatusLevel.siaga;
        if (levelInt == 4) level = StatusLevel.awas;

        _lastStatus = VolcanoStatus(
          level: level,
          message: data['message']?.toString() ?? 'Tidak ada pesan',
          updatedAt: DateTime.parse(e.record!.updated),
        );
        controller.add(_lastStatus!);
      }
    }).catchError((err) {
      debugPrint('Subscribe error volcano_status: $err');
    });

    yield* controller.stream;
  }

  @override
  Future<SensorData> getSensorData() async {
    try {
      final records = await pb.collection('sensor_data').getList(
        page: 1,
        perPage: 1,
        sort: '-created',
      );

      if (records.items.isNotEmpty) {
        final data = records.items.first.data;
        _lastSensor = SensorData(
          amplitudo: (data['amplitudo'] as num?)?.toDouble() ?? 0.0,
          suhu: (data['suhu'] as num?)?.toDouble() ?? 0.0,
          gempaCount: (data['gempa_count'] as num?)?.toInt() ?? 0,
          timestamp: DateTime.parse(records.items.first.created),
        );
        return _lastSensor!;
      }
    } catch (e) {
      debugPrint('Error getSensorData: $e');
    }
    
    return _lastSensor ?? SensorData.fallback();
  }

  @override
  Stream<SensorData> watchSensorData() async* {
    yield await getSensorData();
    
    final controller = StreamController<SensorData>();
    
    pb.collection('sensor_data').subscribe('*', (e) {
      if (e.record != null) {
        final data = e.record!.data;
        _lastSensor = SensorData(
          amplitudo: (data['amplitudo'] as num?)?.toDouble() ?? 0.0,
          suhu: (data['suhu'] as num?)?.toDouble() ?? 0.0,
          gempaCount: (data['gempa_count'] as num?)?.toInt() ?? 0,
          timestamp: DateTime.parse(e.record!.updated),
        );
        controller.add(_lastSensor!);
      }
    }).catchError((err) {
      debugPrint('Subscribe error sensor_data: $err');
    });

    yield* controller.stream;
  }

  @override
  Future<List<ActivityLog>> getActivityLogs() async {
    // TODO: Implementasi dari tabel activity_logs. Menggunakan dummy sementara.
    return [
      ActivityLog(
        id: '1',
        title: 'Status Realtime Tersambung',
        description: 'Menunggu pembaruan data sensor dari PocketBase...',
        timestamp: DateTime.now(),
        type: LogType.info,
      ),
    ];
  }

  @override
  Future<EvacuationRoute> getEvacuationRoute() async {
    // Fallback dummy route
    return EvacuationRoute(
      id: 'dummy',
      name: 'Rute Evakuasi Pronojiwo',
      description: 'Menuju Balai Desa Pronojiwo',
      destinationCoordinate: const [
        -8.2131,
        112.9806
      ], // Sekitar Pronojiwo
      waypoints: const [
        [-8.1064, 112.9221], // Curah Kobokan (Start/Bahaya)
        [-8.1500, 112.9500], // Titik tengah
        [-8.2131, 112.9806]  // Pronojiwo (End/Aman)
      ],
      estimatedTimeMinutes: 45,
      isSafe: true,
    );
  }

  @override
  Future<List<EvacuationRoute>> getEvacuationRoutes() async {
    return [await getEvacuationRoute()];
  }

  @override
  Future<bool> isSystemOnline() async {
    try {
      // Hit health API
      await pb.health.check();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    pb.collection('volcano_status').unsubscribe('*');
    pb.collection('sensor_data').unsubscribe('*');
  }
}
