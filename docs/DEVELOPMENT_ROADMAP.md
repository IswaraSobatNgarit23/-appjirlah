# Roadmap Pengembangan Lanjutan

Aplikasi saat ini memiliki kerangka UI dan arsitektur modular yang siap dikembangkan. Berikut tahapan pengembangan selanjutnya.

## Kerangka yang Sudah Tersedia

Sebelum melanjutkan ke fase berikutnya, pastikan Anda memahami fondasi yang sudah ada:

- [x] Repository Pattern (`EwsRepository`) sebagai abstraksi antara provider dan data source.
- [x] Error skeleton (`AppFailure`, `NetworkFailure`, `LocationFailure`, `DataParsingFailure`) di `lib/core/failures.dart`.
- [x] Stream provider skeleton (`volcanoStatusStreamProvider`, `sensorDataStreamProvider`) siap digunakan saat backend mendukung real-time.
- [x] Data dummy terpisah di `lib/data/fixtures/` — mudah diganti tanpa menyentuh logika.
- [x] Koordinat terpusat di `lib/data/constants/geo_constants.dart`.
- [x] Empty state handling di layar evakuasi dan riwayat.

---

## Fase 1: Integrasi API / Backend (Data Asli)

Target: Mengganti data simulasi dengan data vulkanologi asli.

- [ ] Buat `ApiDataService` yang mengimplementasikan `DataService`.
- [ ] Gunakan package `http` atau `dio` untuk fetch data.
- [ ] Ubah `dataServiceProvider` di `lib/providers/data_providers.dart`.
- [ ] Manfaatkan `EwsRepository` untuk menambahkan validasi dan error mapping menggunakan `AppFailure`.
- [ ] Ambil data rute evakuasi dari database geospasial berdasarkan lokasi GPS pengguna.

## Fase 2: Peringatan Dini (Push Notifications)

Target: Membangunkan smartphone meskipun aplikasi ditutup saat status berubah menjadi 'Awas'.

- [ ] Setup Firebase Cloud Messaging (FCM).
- [ ] Tambahkan package `firebase_core` dan `firebase_messaging`.
- [ ] Implementasikan background message handler dengan alarm khusus.
- [ ] Tambahkan notifikasi lokal untuk peringatan gempa vulkanik.

## Fase 3: Ketahanan Bencana (Offline Mode)

Target: Aplikasi tetap berfungsi saat menara seluler tumbang.

- [ ] Implementasi local cache di `EwsRepository` (gunakan `shared_preferences` atau `Isar`/`Hive`).
- [ ] Cache map tiles untuk area Gunung Semeru.
- [ ] Simpan rute evakuasi terakhir sebagai fallback offline.

## Fase 4: Fitur Lanjutan

- [ ] Kalkulasi jarak aman (Haversine formula) antara pengguna dan kawah.
- [ ] Fitur tracking keluarga/grup (butuh autentikasi dan realtime database).
- [ ] Integrasi Crashlytics untuk monitoring error di produksi.

---

**Catatan untuk Engineer Baru:**
Baca `lib/providers/data_providers.dart` sebagai entry point aliran data. Semua provider mengambil data melalui `EwsRepository`, yang kemudian memanggil `DataService`.
