/// Konstanta geografis terpusat untuk aplikasi EWS Semeru.
///
/// Semua koordinat default dan referensi lokasi harus diambil dari sini,
/// bukan di-hardcode di masing-masing file.
library;

/// Koordinat puncak Gunung Semeru.
const double kSemeruLat = -8.1077;
const double kSemeruLng = 112.9220;

/// Koordinat default posisi user (Desa Supiturang, Pronojiwo, Lumajang).
/// Digunakan sebagai fallback saat GPS belum tersedia.
const double kDefaultUserLat = -8.2150;
const double kDefaultUserLng = 112.9350;

/// Radius bahaya default dalam kilometer.
const double kDefaultDangerRadiusKm = 13.0;
