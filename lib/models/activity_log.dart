/// Model log kejadian/aktivitas gunung.
///
/// Untuk integrasi API riwayat:
/// ```dart
/// final logs = jsonList.map((j) => ActivityLog.fromJson(j)).toList();
/// ```
class ActivityLog {
  /// Waktu kejadian.
  final DateTime timestamp;

  /// Deskripsi kejadian.
  final String description;

  /// Tingkat keparahan: 'low', 'medium', 'high', 'critical'
  final String severity;

  const ActivityLog({
    required this.timestamp,
    required this.description,
    this.severity = 'medium',
  });

  /// Format waktu yang mudah dibaca.
  String get formattedTime {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final d = timestamp;
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month]} ${d.year}, $hour:$minute WIB';
  }

  // ---------------------------------------------------------------------------
  // INTEGRASI DATABASE / API
  // ---------------------------------------------------------------------------

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      description: json['description'] as String? ?? '',
      severity: json['severity'] as String? ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'severity': severity,
    };
  }
}
