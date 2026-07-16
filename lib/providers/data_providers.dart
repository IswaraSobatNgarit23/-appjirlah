import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';

import '../models/volcano_status.dart';
import '../models/sensor_data.dart';
import '../models/evacuation_route.dart';
import '../models/activity_log.dart';
import '../services/data_service.dart';
import '../services/pocketbase_data_service.dart';
import '../services/location_service.dart';
import '../repositories/ews_repository.dart';
import 'package:flutter/material.dart';

// =============================================================================
// APP STATE PROVIDERS
// =============================================================================
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// =============================================================================
// SERVICE & REPOSITORY PROVIDERS
// =============================================================================

/// Provider utama untuk DataService.
final dataServiceProvider = Provider<DataService>((ref) {
  final service = PocketbaseDataService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Repository layer antara provider dan DataService.
final repositoryProvider = Provider<EwsRepository>((ref) {
  final dataService = ref.watch(dataServiceProvider);
  return EwsRepository(dataService);
});

// =============================================================================
// FUTURE PROVIDERS (One-shot data fetch)
// =============================================================================

/// Status gunung api terkini.
final volcanoStatusProvider = FutureProvider.autoDispose<VolcanoStatus>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return repository.getVolcanoStatus();
});

/// Data sensor terkini (simplified — hanya gempa total).
final sensorDataProvider = FutureProvider.autoDispose<SensorData>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return repository.getSensorData();
});

/// Info sistem online/offline.
final systemOnlineProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return repository.isSystemOnline();
});

/// Rute evakuasi pertama (backward compatible).
final evacuationRouteProvider = FutureProvider.autoDispose<EvacuationRoute>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return repository.getEvacuationRoute();
});

/// Semua lokasi evakuasi yang tersedia.
final evacuationRoutesProvider = FutureProvider.autoDispose<List<EvacuationRoute>>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return repository.getEvacuationRoutes();
});

/// Index lokasi evakuasi yang sedang dipilih.
final selectedEvacuationIndexProvider = StateProvider<int>((ref) => 0);

/// Daftar log kejadian.
final activityLogsProvider = FutureProvider.autoDispose<List<ActivityLog>>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return repository.getActivityLogs();
});

/// Data historis untuk chart (beberapa record terakhir).
final historicalDataProvider = FutureProvider.autoDispose<List<VolcanoStatus>>((ref) async {
  final service = ref.watch(dataServiceProvider) as PocketbaseDataService;
  return service.getHistoricalData(limit: 7);
});

// =============================================================================
// STREAM PROVIDERS (Real-time data)
// =============================================================================

/// Stream status gunung api secara real-time.
final volcanoStatusStreamProvider = StreamProvider.autoDispose<VolcanoStatus>((ref) {
  final repository = ref.watch(repositoryProvider);
  return repository.watchVolcanoStatus();
});

/// Stream data sensor secara real-time.
final sensorDataStreamProvider = StreamProvider.autoDispose<SensorData>((ref) {
  final repository = ref.watch(repositoryProvider);
  return repository.watchSensorData();
});

// =============================================================================
// LOCATION PROVIDER
// =============================================================================

/// Lokasi GPS asli pengguna menggunakan Geolocator.
final userLocationProvider = FutureProvider.autoDispose<Position>((ref) async {
  return await LocationService.getCurrentLocation();
});
