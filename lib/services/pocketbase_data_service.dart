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

  final _statusController = StreamController<VolcanoStatus>.broadcast();

  PocketbaseDataService() {
    final url = dotenv.env['POCKETBASE_URL'] ?? 'https://db-ews.sagamuda.id';
    pb = PocketBase(url);
    debugPrint('PocketBase Service diinisialisasi dengan URL: $url');
    _initRealtime();
  }

  void _initRealtime() {
    getVolcanoStatus().then((val) => _statusController.add(val));

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
          gempaTotal: (data['gempa_total'] as num?)?.toInt() ?? 0,
          laporanUrl: data['laporan_url']?.toString() ?? '',
          updatedAt: DateTime.tryParse(e.record!.get<String>('updated')) ?? DateTime.now(),
        );
        _statusController.add(_lastStatus!);
      }
    }).catchError((dynamic err) {
      debugPrint('Subscribe error volcano_status: $err');
      return () async {};
    });
  }

  @override
  Stream<VolcanoStatus>? get statusStream => _statusController.stream;

  @override
  Stream<SensorData>? get sensorStream => null;

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
          gempaTotal: (data['gempa_total'] as num?)?.toInt() ?? 0,
          laporanUrl: data['laporan_url']?.toString() ?? '',
          updatedAt: DateTime.tryParse(records.items.first.get<String>('created')) ?? DateTime.now(),
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
    // SensorData sekarang diambil dari volcano_status (gempa_total)
    final status = await getVolcanoStatus();
    return SensorData(
      gempaTotal: status.gempaTotal,
      updatedAt: status.updatedAt,
    );
  }

  @override
  Future<List<ActivityLog>> getActivityLogs() async {
    try {
      // Ambil 30 record terakhir dari volcano_status sebagai log
      final records = await pb.collection('volcano_status').getList(
        page: 1,
        perPage: 30,
        sort: '-created',
      );

      return records.items.map((record) {
        final data = record.data;
        final levelInt = (data['level'] as num?)?.toInt() ?? 1;
        final statusText = data['status_text']?.toString() ?? 'Normal';
        int gempaTotal = (data['gempa_total'] as num?)?.toInt() ?? 0;
        final kegempaan = data['kegempaan']?.toString() ?? '';
        final author = data['author']?.toString() ?? '';
        
        if (gempaTotal == 0 && kegempaan.isNotEmpty) {
          final regex = RegExp(r'(\d+)\s+kali', caseSensitive: false);
          for (final match in regex.allMatches(kegempaan)) {
            gempaTotal += int.tryParse(match.group(1) ?? '') ?? 0;
          }
        }
        
        String severity;
        if (levelInt >= 4) {
          severity = 'critical';
        } else if (levelInt == 3) {
          severity = 'high';
        } else if (levelInt == 2) {
          severity = 'medium';
        } else {
          severity = 'low';
        }

        final description = 'Level $statusText — $gempaTotal kejadian gempa tercatat'
            '${author.isNotEmpty ? ' (Pelapor: $author)' : ''}';

        return ActivityLog(
          description: description,
          timestamp: DateTime.tryParse(record.get<String>('created')) ?? DateTime.now(),
          severity: severity,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getActivityLogs: $e');
      return [];
    }
  }

  /// Ambil data historis untuk chart (gempa_total per record).
  Future<List<VolcanoStatus>> getHistoricalData({int limit = 7}) async {
    try {
      final records = await pb.collection('volcano_status').getList(
        page: 1,
        perPage: limit,
        sort: '-created',
      );

      return records.items.map((record) {
        final data = record.data;
        StatusLevel level = StatusLevel.normal;
        final levelInt = data['level'] as int? ?? 1;
        if (levelInt == 2) level = StatusLevel.waspada;
        if (levelInt == 3) level = StatusLevel.siaga;
        if (levelInt == 4) level = StatusLevel.awas;

        return VolcanoStatus(
          level: level,
          message: data['message']?.toString() ?? '',
          visual: data['visual']?.toString() ?? '',
          klimatologi: data['klimatologi']?.toString() ?? '',
          kegempaan: data['kegempaan']?.toString() ?? '',
          rekomendasi: data['rekomendasi']?.toString() ?? '',
          author: data['author']?.toString() ?? '',
          gempaTotal: (data['gempa_total'] as num?)?.toInt() ?? 0,
          laporanUrl: data['laporan_url']?.toString() ?? '',
          updatedAt: DateTime.tryParse(record.get<String>('created')) ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getHistoricalData: $e');
      return [];
    }
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
    _statusController.close();
  }
}
