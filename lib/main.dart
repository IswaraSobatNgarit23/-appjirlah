import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

// =============================================================================
// EWS ERUPSI GUNUNG SEMERU
// Aplikasi Peringatan Dini untuk Masyarakat Desa
//
// CARA INTEGRASI DATABASE / API / MQTT:
// 1. Buat class baru yang implement DataService (lihat services/data_service.dart)
// 2. Buka `lib/providers/data_providers.dart` dan ubah `dataServiceProvider`.
// 3. Selesai! Seluruh UI otomatis menggunakan data dari sumber baru.
// =============================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables dari file assets/.env
  // Gagal memuat file .env akan diabaikan secara diam-diam (fallback ke default)
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    debugPrint('Peringatan: File .env tidak ditemukan, menggunakan nilai default.');
  }

  // ProviderScope wajib ada agar Riverpod bisa berjalan
  runApp(const ProviderScope(child: EWSApp()));
}
