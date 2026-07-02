# EWS Erupsi Gunung Semeru

Aplikasi Peringatan Dini untuk masyarakat desa di sekitar Gunung Semeru. Dibangun dengan arsitektur modular dan siap dikembangkan lebih lanjut.

> **Dokumentasi Proyek**
> - [Latar Belakang & Arsitektur](./docs/PROJECT_BACKGROUND.md)
> - [Roadmap Pengembangan Lanjutan](./docs/DEVELOPMENT_ROADMAP.md)

## Fitur Utama
- **Status Real-time (Simulasi)**: Menampilkan tingkat bahaya gunung (Normal, Waspada, Siaga, Awas).
- **Data Sensor Vulkanologi**: Pantauan Amplitudo Getaran, Suhu Kawah, dan Gempa Vulkanik.
- **Rute Evakuasi & Navigasi**: Jalur evakuasi menuju titik kumpul aman terdekat dengan peta OpenStreetMap.
- **Pelacakan Lokasi GPS**: Deteksi posisi pengguna secara real-time menggunakan Geolocator.
- **Log Riwayat Kejadian**: Catatan log aktivitas gunung berapi.
- **Tema Dinamis (Light/Dark)**: Menyesuaikan otomatis dengan pengaturan sistem.

---

## Panduan Integrasi Data (Database / API / MQTT)

Aplikasi ini menggunakan arsitektur **Repository Pattern** agar kode UI tidak perlu diubah saat menyambungkan ke backend sungguhan.

**Alur data:**
```
UI (Widget) -> Provider (Riverpod) -> Repository -> DataService
```

### Langkah 1: Buat Class Service Baru

Buat file baru di `lib/services/` (misalnya `api_data_service.dart`). Buat class yang `implements DataService`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data_service.dart';
import '../models/volcano_status.dart';
import '../models/sensor_data.dart';
import '../models/evacuation_route.dart';
import '../models/activity_log.dart';

class ApiDataService implements DataService {
  final String baseUrl = "https://api.ews-semeru.com";

  @override
  Future<VolcanoStatus> getVolcanoStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/status'));
    return VolcanoStatus.fromJson(json.decode(response.body));
  }

  @override
  Future<SensorData> getSensorData() async {
    final response = await http.get(Uri.parse('$baseUrl/sensor'));
    return SensorData.fromJson(json.decode(response.body));
  }

  // ... implementasi method lainnya ...

  @override
  Stream<VolcanoStatus>? get statusStream => null;
  @override
  Stream<SensorData>? get sensorStream => null;
  @override
  Future<void> dispose() async {}
}
```

### Langkah 2: Daftarkan Service Baru di Provider

Buka file `lib/providers/data_providers.dart` dan ubah `dataServiceProvider`:

```dart
// Ubah ini:
final dataServiceProvider = Provider<DataService>((ref) {
  final service = DummyDataService();
  ...
});

// Menjadi ini:
final dataServiceProvider = Provider<DataService>((ref) {
  final service = ApiDataService();
  ...
});
```

Selesai. Seluruh UI otomatis menggunakan data dari sumber baru melalui Repository.

---

## Menjalankan Aplikasi

```bash
cd ews_semeru
flutter pub get
flutter run
```

## Menjalankan Test

```bash
flutter test
```

## Struktur Proyek

```
lib/
├── core/              # Error/failure types
├── data/
│   ├── constants/     # Koordinat dan konstanta
│   └── fixtures/      # Data dummy terpisah
├── models/            # Data model (VolcanoStatus, SensorData, dll.)
├── providers/         # Riverpod providers
├── repositories/      # Repository layer
├── services/          # DataService interface + implementasi
├── router/            # GoRouter configuration
├── screens/           # Halaman UI
├── theme/             # Theme system (Light/Dark)
└── widgets/           # Komponen UI reusable
```
