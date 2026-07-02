/// Hierarki error terstruktur untuk aplikasi EWS Semeru.
///
/// Gunakan kelas-kelas ini di repository atau provider untuk menangani
/// error secara eksplisit, alih-alih melempar Exception generik.
///
/// Contoh penggunaan di repository:
/// ```dart
/// try {
///   return await dataService.getVolcanoStatus();
/// } on SocketException {
///   throw NetworkFailure('Tidak ada koneksi internet.');
/// } on FormatException catch (e) {
///   throw DataParsingFailure('Format data tidak valid.', originalError: e);
/// }
/// ```
sealed class AppFailure implements Exception {
  final String message;
  final Object? originalError;

  const AppFailure(this.message, {this.originalError});

  @override
  String toString() => message;
}

/// Gagal terhubung ke jaringan / server.
class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {super.originalError});
}

/// Gagal mendapatkan atau memproses data lokasi GPS.
class LocationFailure extends AppFailure {
  const LocationFailure(super.message, {super.originalError});
}

/// Data dari API/database tidak bisa di-parse ke model Dart.
class DataParsingFailure extends AppFailure {
  const DataParsingFailure(super.message, {super.originalError});
}

/// Error yang belum dikategorikan.
class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message, {super.originalError});
}
