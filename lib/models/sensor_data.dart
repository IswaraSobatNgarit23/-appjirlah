/// Model data sensor vulkanologi.
///
/// Untuk integrasi MQTT/API:
/// ```dart
/// final sensor = SensorData.fromJson(mqttPayload);
/// ```
class SensorData {
  /// Amplitudo getaran dalam milimeter (mm).
  final double amplitudo;

  /// Suhu kawah dalam derajat Celcius (°C).
  final double suhu;

  /// Jumlah gempa vulkanik per hari.
  final int gempaCount;

  /// Waktu data terakhir diperbarui.
  final DateTime updatedAt;

  const SensorData({
    required this.amplitudo,
    required this.suhu,
    required this.gempaCount,
    required this.updatedAt,
  });

  /// Format waktu update yang mudah dibaca.
  String get formattedUpdateTime {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final d = updatedAt;
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month]} ${d.year}, $hour:$minute WIB';
  }

  // ---------------------------------------------------------------------------
  // INTEGRASI DATABASE / API
  // ---------------------------------------------------------------------------

  /// Membuat instance dari JSON response sensor.
  /// Contoh JSON: {"amplitudo": 20.0, "suhu": 78.5, "gempa_count": 34, "updated_at": "..."}
  factory SensorData.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('amplitudo')) {
      throw FormatException(
        'Key "amplitudo" wajib ada dalam JSON SensorData. Data: $json',
      );
    }
    if (!json.containsKey('suhu')) {
      throw FormatException(
        'Key "suhu" wajib ada dalam JSON SensorData. Data: $json',
      );
    }
    return SensorData(
      amplitudo: (json['amplitudo'] as num).toDouble(),
      suhu: (json['suhu'] as num).toDouble(),
      gempaCount: (json['gempa_count'] as int?) ?? 0,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amplitudo': amplitudo,
      'suhu': suhu,
      'gempa_count': gempaCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
