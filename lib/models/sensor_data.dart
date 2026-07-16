/// Model data sensor vulkanologi (simplified).
///
/// Sekarang hanya menyimpan total gempa, karena data amplitudo dan suhu
/// sebenarnya bukan data sensor mandiri melainkan bagian dari narasi laporan.
class SensorData {
  /// Jumlah total gempa dari semua jenis.
  final int gempaTotal;

  /// Waktu data terakhir diperbarui.
  final DateTime updatedAt;

  const SensorData({
    required this.gempaTotal,
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

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      gempaTotal: (json['gempa_total'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gempa_total': gempaTotal,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
