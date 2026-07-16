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
  
  VolcanoStatus? _lastStatus;
  SensorData? _lastSensor;

  final _statusController = StreamController<VolcanoStatus>.broadcast();
  final _sensorController = StreamController<SensorData>.broadcast();

  PocketbaseDataService() {
    final url = dotenv.env['POCKETBASE_URL'] ?? 'https://db-ews.sagamuda.id';
    pb = PocketBase(url);
    debugPrint('PocketBase Service diinisialisasi dengan URL: $url');
    _initRealtime();
  }

  void _initRealtime() {
    getVolcanoStatus().then((val) => _statusController.add(val));
    getSensorData().then((val) => _sensorController.add(val));

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
          visual: data['visual']?.toString() ?? '',
          klimatologi: data['klimatologi']?.toString() ?? '',
          kegempaan: data['kegempaan']?.toString() ?? '',
          rekomendasi: data['rekomendasi']?.toString() ?? '',
          author: data['author']?.toString() ?? '',
          updatedAt: DateTime.tryParse(e.record!.updated) ?? DateTime.now(),
        );
        _statusController.add(_lastStatus!);
      }
    }).catchError((err) {
      debugPrint('Subscribe error volcano_status: $err');
    });

    pb.collection('sensor_data').subscribe('*', (e) {
      if (e.record != null) {
        final data = e.record!.data;
        _lastSensor = SensorData(
          amplitudo: (data['amplitudo'] as num?)?.toDouble() ?? 0.0,
          suhuMin: (data['suhu_min'] as num?)?.toDouble() ?? 0.0,
          suhuMax: (data['suhu_max'] as num?)?.toDouble() ?? (data['suhu_min'] as num?)?.toDouble() ?? 0.0,
          gempaCount: (data['gempa_count'] as num?)?.toInt() ?? 0,
          updatedAt: DateTime.tryParse(e.record!.updated) ?? DateTime.now(),
        );
        _sensorController.add(_lastSensor!);
      }
    }).catchError((err) {
      debugPrint('Subscribe error sensor_data: $err');
    });
  }

  @override
  Stream<VolcanoStatus>? get statusStream => _statusController.stream;

  @override
  Stream<SensorData>? get sensorStream => _sensorController.stream;

  @override
  Future<VolcanoStatus> getVolcanoStatus() async {
    try {
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
          visual: data['visual']?.toString() ?? '',
          klimatologi: data['klimatologi']?.toString() ?? '',
          kegempaan: data['kegempaan']?.toString() ?? '',
          rekomendasi: data['rekomendasi']?.toString() ?? '',
          author: data['author']?.toString() ?? '',
          updatedAt: DateTime.tryParse(records.items.first.created) ?? DateTime.now(),
        );
        return _lastStatus!;
      }
    } catch (e) {
      debugPrint('Error getVolcanoStatus: $e');
    }
    
    return _lastStatus ?? VolcanoStatus(level: StatusLevel.normal, message: '-', updatedAt: DateTime.now());
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
          suhuMin: (data['suhu_min'] as num?)?.toDouble() ?? 0.0,
          suhuMax: (data['suhu_max'] as num?)?.toDouble() ?? (data['suhu_min'] as num?)?.toDouble() ?? 0.0,
          gempaCount: (data['gempa_count'] as num?)?.toInt() ?? 0,
          updatedAt: DateTime.tryParse(records.items.first.created) ?? DateTime.now(),
        );
        return _lastSensor!;
      }
    } catch (e) {
      debugPrint('Error getSensorData: $e');
    }
    
    return _lastSensor ?? SensorData(amplitudo: 0, suhuMin: 0, suhuMax: 0, gempaCount: 0, updatedAt: DateTime.now());
  }

  @override
  Future<List<ActivityLog>> getActivityLogs() async {
    return [
      ActivityLog(
        description: 'Terkoneksi ke PocketBase secara Realtime',
        timestamp: DateTime.now(),
        severity: 'info',
      ),
    ];
  }

  @override
  Future<EvacuationRoute> getEvacuationRoute() async {
    return EvacuationRoute(
      id: 'dummy',
      destination: 'Balai Desa Pronojiwo',
      distance: '13.5 KM',
      estimate: '± 45 menit',
      latitude: -8.2131,
      longitude: 112.9806,
      description: 'Menuju Balai Desa Pronojiwo yang aman.',
      emergencyContacts: [],
    );
  }

  @override
  Future<List<EvacuationRoute>> getEvacuationRoutes() async {
    return [await getEvacuationRoute()];
  }

  @override
  Future<bool> isSystemOnline() async {
    try {
      await pb.health.check();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    pb.collection('volcano_status').unsubscribe('*');
    pb.collection('sensor_data').unsubscribe('*');
    _statusController.close();
    _sensorController.close();
  }
}
