import '../../models/activity_log.dart';

/// Data dummy log aktivitas untuk keperluan development dan testing.
///
/// Untuk menambah/mengubah log dummy, edit file ini saja.
List<ActivityLog> getDummyLogs() {
  return [
    ActivityLog(
      timestamp: DateTime(2026, 6, 16, 19, 42),
      description:
          'Guguran lava pijar terdeteksi, jarak luncur 1.5 KM dari puncak.',
      severity: 'high',
    ),
    ActivityLog(
      timestamp: DateTime(2026, 6, 16, 14, 15),
      description:
          'Gempa vulkanik dangkal tercatat sebanyak 12 kali dalam 6 jam.',
      severity: 'medium',
    ),
    ActivityLog(
      timestamp: DateTime(2026, 6, 15, 8, 30),
      description:
          'Kolom abu setinggi 600 meter dari kawah, angin ke arah tenggara.',
      severity: 'medium',
    ),
    ActivityLog(
      timestamp: DateTime(2026, 6, 14, 16, 10),
      description:
          'Tremor harmonik meningkat, durasi rata-rata 45 detik.',
      severity: 'low',
    ),
    ActivityLog(
      timestamp: DateTime(2026, 6, 14, 6, 0),
      description:
          'Emisi gas SO2 meningkat menjadi 320 ton/hari.',
      severity: 'medium',
    ),
  ];
}
