# Latar Belakang Proyek: EWS Semeru

## Definisi Masalah

Masyarakat di sekitar lereng Gunung Semeru sering kesulitan mendapatkan informasi peringatan dini yang akurat, cepat, dan mudah dipahami. Informasi melalui grup obrolan rawan misinformasi dan lambat. Aplikasi kebencanaan yang ada sering memiliki tampilan rumit, kontras buruk untuk dibaca di kondisi darurat, serta tidak menyediakan rute evakuasi berbasis lokasi pengguna.

## Tujuan Aplikasi

Aplikasi **EWS Semeru** dirancang sebagai Sistem Peringatan Dini (*Early Warning System*) dengan mengedepankan:

1. **Kejelasan Visual**: Tema dinamis (Light/Dark Mode) yang menyesuaikan kondisi pencahayaan. Light Mode untuk keterbacaan siang hari, Dark Mode untuk menghindari silau di malam hari.
2. **Kesiagaan Real-time**: Menampilkan status tingkat bahaya (Normal, Waspada, Siaga, Awas) dan data vulkanologi.
3. **Navigasi Evakuasi**: Menuntun pengguna menuju titik kumpul aman berdasarkan lokasi GPS.

## Arsitektur Saat Ini (Fase Skeleton)

Proyek berada dalam fase kerangka (*skeleton*) dengan arsitektur modular dan siap dikembangkan:

- **Framework**: Flutter (Dart)
- **State Management**: `flutter_riverpod`
- **Arsitektur Data**: Repository Pattern
  ```
  UI (Widget) → Provider (Riverpod) → Repository → DataService
  ```
  Saat ini menggunakan `DummyDataService`. Untuk integrasi backend, buat implementasi `DataService` baru dan ganti di `lib/providers/data_providers.dart`.
- **Error Handling**: Hierarki `AppFailure` terstruktur (`NetworkFailure`, `LocationFailure`, `DataParsingFailure`) di `lib/core/failures.dart`.
- **Location Services**: Package `geolocator` dengan `LocationService` untuk pelacakan GPS.
- **Pemetaan**: `flutter_map` (OpenStreetMap) dengan koordinat terpusat di `lib/data/constants/geo_constants.dart`.
- **Desain**: `ThemeExtension` kustom (`EWSColors`) untuk transisi tema Light/Dark.
- **Data Dummy**: Dipisahkan ke `lib/data/fixtures/` agar mudah diganti saat integrasi backend.
- **Stream Skeleton**: Provider stream (`volcanoStatusStreamProvider`, `sensorDataStreamProvider`) sudah disiapkan untuk jalur real-time.

## Cara Mengganti Sumber Data

Lihat instruksi lengkap di [README.md](../README.md#panduan-integrasi-data-database--api--mqtt).
