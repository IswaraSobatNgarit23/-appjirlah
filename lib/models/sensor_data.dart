/// Model data sensor vulkanologi.
///
/// Untuk integrasi MQTT/API:
/// ```dart
/// final sensor = SensorData.fromJson(mqttPayload);
/// ```
class SensorData {
  /// Amplitudo getaran dalam milimeter (mm).
  final double amplitudo;

  /// Suhu kawah minimum dalam derajat Celcius (°C).
  final double suhuMin;
  
  /// Suhu kawah maksimum dalam derajat Celcius (°C).
  final double suhuMax;

  /// Jumlah gempa vulkanik per hari.
  final int gempaCount;

  /// Waktu data terakhir diperbarui.
  final DateTime updatedAt;

  const SensorData({
    required this.amplitudo,
    required this.suhuMin,
    required this.suhuMax,
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
    if (!json.containsKey('suhu_min')) {
      throw FormatException(
        'Key "suhu_min" wajib ada dalam JSON SensorData. Data: $json',
      );
    }
    return SensorData(
      amplitudo: (json['amplitudo'] as num).toDouble(),
      suhuMin: (json['suhu_min'] as num).toDouble(),
      suhuMax: (json['suhu_max'] as num?)?.toDouble() ?? (json['suhu_min'] as num).toDouble(),
      gempaCount: (json['gempa_count'] as int?) ?? 0,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amplitudo': amplitudo,
      'suhu_min': suhuMin,
      'suhu_max': suhuMax,
      'gempa_count': gempaCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
