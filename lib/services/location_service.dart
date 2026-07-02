import 'package:geolocator/geolocator.dart';
import '../core/failures.dart';

/// Layanan untuk mengakses lokasi GPS perangkat.
///
/// Menangani izin OS (Android/iOS) dan melempar [LocationFailure]
/// jika terjadi masalah (GPS mati, izin ditolak, dll).
class LocationService {
  /// Memeriksa izin dan mengambil lokasi saat ini.
  ///
  /// Melempar [LocationFailure] jika:
  /// - Layanan lokasi (GPS) dimatikan.
  /// - Izin akses lokasi ditolak.
  /// - Izin akses lokasi ditolak secara permanen.
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure('Layanan Lokasi (GPS) dimatikan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationFailure('Izin akses lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Izin akses lokasi ditolak secara permanen. '
        'Mohon aktifkan melalui Pengaturan Aplikasi.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
