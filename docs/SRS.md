# Software Requirements Specification (SRS)
## EWS Semeru - Early Warning System

**Versi:** 1.0
**Tanggal:** 22 Juni 2026

---

## 1. Pendahuluan

### 1.1 Tujuan Dokumen
Dokumen *Software Requirements Specification* (SRS) ini bertujuan untuk mendefinisikan secara spesifik dan rinci seluruh kebutuhan fungsional dan non-fungsional dari aplikasi **EWS Semeru**. Dokumen ini menjadi acuan utama bagi tim pengembang dalam membangun, mengintegrasikan, dan memelihara sistem peringatan dini bencana alam.

### 1.2 Ruang Lingkup Proyek
**EWS Semeru** adalah aplikasi *mobile* berbasis Android dan iOS yang berfungsi sebagai sistem peringatan dini aktivitas vulkanik Gunung Semeru. Aplikasi ini dirancang untuk memberikan informasi yang cepat, akurat, dan mudah dipahami kepada masyarakat di sekitar lereng Semeru, dilengkapi dengan panduan evakuasi berbasis lokasi *real-time* pengguna.

### 1.3 Definisi dan Singkatan
*   **EWS:** *Early Warning System* (Sistem Peringatan Dini).
*   **FCM:** *Firebase Cloud Messaging* (Layanan push notification).
*   **MQTT/WebSockets:** Protokol komunikasi *real-time*.
*   **UI/UX:** *User Interface / User Experience*.
*   **GPS:** *Global Positioning System*.

---

## 2. Deskripsi Umum

### 2.1 Perspektif Produk
Saat ini, masyarakat rentan terhadap misinformasi dan keterlambatan peringatan bencana dari grup obrolan. Aplikasi kebencanaan yang ada cenderung rumit. EWS Semeru hadir sebagai solusi mandiri yang fokus pada kejelasan visual keadaan darurat, penerimaan peringatan *real-time*, dan ketahanan sistem (berfungsi sebagian saat offline).

### 2.2 Karakteristik Pengguna
Pengguna target adalah masyarakat umum di sekitar Gunung Semeru, relawan, dan aparat terkait. UI didesain sesederhana mungkin agar dapat digunakan dengan cepat dalam kondisi panik/darurat oleh berbagai kalangan usia.

### 2.3 Lingkungan Operasi
*   **OS Mobile:** Android 8.0+ dan iOS 12.0+.
*   **Konektivitas:** Internet (4G/3G) dengan dukungan *Offline Mode* terbatas.

---

## 3. Kebutuhan Fungsional (Functional Requirements)

### SF-01: Pemantauan Status Gunung Berapi (*Real-time*)
*   **Deskripsi:** Sistem harus menampilkan tingkat bahaya Gunung Semeru (Normal, Waspada, Siaga, Awas) secara *real-time*.
*   **Detail:** 
    *   Menggunakan WebSockets atau MQTT untuk mendengarkan perubahan status tanpa perlu di-*refresh* manual (latensi rendah).
    *   Layar aplikasi harus berubah warna (berkedip atau penyesuaian tema khusus darurat) secara otomatis saat status berubah menjadi tingkat bahaya tinggi ('Siaga' atau 'Awas').

### SF-02: Visualisasi Data Sensor Vulkanologi
*   **Deskripsi:** Pengguna dapat melihat grafik riwayat aktivitas sensor vulkanik.
*   **Detail:** 
    *   Aplikasi mengintegrasikan *library* `fl_chart` untuk menampilkan grafik garis (*Line Chart*) dari riwayat sensor (misal: jumlah gempa vulkanik, amplitudo) dengan data akurat yang ditarik dari *Backend API*.

### SF-03: Peringatan Dini (*Push Notification*)
*   **Deskripsi:** Sistem dapat membangunkan perangkat pengguna dan memberikan peringatan suara.
*   **Detail:**
    *   Terintegrasi dengan FCM (*Firebase Cloud Messaging*).
    *   Menampilkan notifikasi instan meskipun aplikasi sedang ditutup (*background mode*).
    *   Notifikasi khusus untuk status 'Awas' menggunakan nada dering/alarm darurat (mengabaikan mode senyap jika diizinkan oleh sistem operasi).

### SF-04: Navigasi dan Rute Evakuasi
*   **Deskripsi:** Mengarahkan pengguna ke titik kumpul aman terdekat.
*   **Detail:**
    *   Mengakses GPS pengguna secara *real-time* via `geolocator`.
    *   Menampilkan peta dengan `flutter_map` (OpenStreetMap).
    *   Menghitung rute teraman dari titik koordinat pengguna saat ini menuju lokasi aman yang telah ditentukan di *database* geospasial.
    *   Menggunakan *Haversine formula* untuk kalkulasi jarak aman antara pengguna dan kawah Gunung Semeru.

### SF-05: Pelacakan Grup dan Keluarga (Fitur Lanjutan)
*   **Deskripsi:** Memungkinkan pengguna saling memantau lokasi anggota keluarga selama proses evakuasi.
*   **Detail:**
    *   Membutuhkan sistem autentikasi (Login/Register).
    *   Menggunakan *Realtime Database* untuk membagikan dan melacak koordinat GPS secara privat di dalam sebuah grup keluarga.

### SF-06: Manajemen Error & Redirect Koneksi
*   **Deskripsi:** Sistem wajib menangani kegagalan jaringan secara elegan.
*   **Detail:**
    *   Jika API atau Server terdeteksi *offline*, sistem (via GoRouter) akan mengalihkan pengguna ke layar khusus "Sistem *Offline*" atau "Koneksi Terputus".

---

## 4. Kebutuhan Non-Fungsional (Non-Functional Requirements)

### NFR-01: Kejelasan Visual (Usability & Accessibility)
*   **Deskripsi:** Desain UI harus berbasis *Glassmorphism* yang jernih dengan kontras tinggi.
*   **Detail:** Wajib mendukung penyesuaian cahaya dinamis (*Light/Dark Mode*). *Light Mode* untuk keterbacaan di siang hari terik, *Dark Mode* untuk mencegah mata silau saat evakuasi malam hari.

### NFR-02: Ketahanan Bencana (*Offline Mode*)
*   **Deskripsi:** Aplikasi harus tetap memberikan informasi dasar saat infrastruktur telekomunikasi terputus.
*   **Detail:**
    *   Penerapan *local cache* pada data evakuasi dan rute terakhir menggunakan `shared_preferences`, `Hive`, atau `Isar`.
    *   Penyimpanan *cache* untuk aset peta (Map Tiles) wilayah Gunung Semeru.

### NFR-03: Kinerja dan Pemantauan (*Performance & Reliability*)
*   **Deskripsi:** Aplikasi harus ringan, responsif, dan error dapat dilacak.
*   **Detail:**
    *   Integrasi Crashlytics untuk pemantauan *error* dan *crash* pada perangkat pengguna akhir di tahap produksi.

---

## 5. Arsitektur Sistem

Untuk memastikan skalabilitas dan perawatan kode yang baik, sistem dibangun di atas kerangka arsitektur modern berikut:
*   **Framework Mobile:** Flutter (Dart).
*   **State Management:** `flutter_riverpod` (Pemisahan status secara granular melalui sistem Provider).
*   **Pola Desain (Design Pattern):** *Repository Pattern* (Alur data: `UI` -> `Provider` -> `EwsRepository` -> `DataService`).
*   **Routing & Navigasi:** `go_router` untuk transisi halaman yang aman dan pendeteksian pengalihan (*redirect*) secara dinamis.
*   **Penanganan Error:** Hierarki `AppFailure` kustom (`NetworkFailure`, `LocationFailure`, `DataParsingFailure`) pada tingkat domain.
