import 'package:flutter/material.dart';

/// Level status aktivitas gunung berapi.
/// Mengikuti standar PVMBG (Pusat Vulkanologi dan Mitigasi Bencana Geologi).
enum StatusLevel {
  normal,
  waspada,
  siaga,
  awas,
}

/// Model data status gunung api.
///
/// Menyimpan seluruh data dari 1 laporan MAGMA:
/// status, visual, klimatologi, kegempaan, rekomendasi, dan total gempa.
class VolcanoStatus {
  final StatusLevel level;
  final String message;
  final String visual;
  final String klimatologi;
  final String kegempaan;
  final String rekomendasi;
  final String author;
  final int _gempaTotal;
  final String laporanUrl;
  final String imageUrl;
  final Map<String, dynamic> kegempaanDetails;
  final DateTime updatedAt;

  const VolcanoStatus({
    required this.level,
    required this.message,
    this.visual = '',
    this.klimatologi = '',
    this.kegempaan = '',
    this.rekomendasi = '',
    this.author = '',
    int gempaTotal = 0,
    this.laporanUrl = '',
    this.imageUrl = '',
    this.kegempaanDetails = const {},
    required this.updatedAt,
  }) : _gempaTotal = gempaTotal;

  /// Total gempa — jika field dari DB = 0 tapi teks kegempaan ada,
  /// hitung otomatis dari teks (fallback untuk data lama).
  int get gempaTotal {
    if (_gempaTotal > 0) return _gempaTotal;
    if (kegempaan.isEmpty) return 0;
    // Parse "X kali" dari setiap baris teks kegempaan
    int total = 0;
    final regex = RegExp(r'(\d+)\s+kali', caseSensitive: false);
    for (final match in regex.allMatches(kegempaan)) {
      total += int.tryParse(match.group(1) ?? '') ?? 0;
    }
    return total;
  }

  // Helper Methods EWS Seismik
  int _getGempaCount(String type) => (kegempaanDetails[type]?['count'] as num?)?.toInt() ?? 0;
  String _getGempaAmplitudo(String type) => (kegempaanDetails[type]?['amplitudo'] as String?) ?? '';

  int get guguranCount => _getGempaCount('guguran');
  int get letusanCount => _getGempaCount('letusan');
  int get tremorCount => _getGempaCount('tremor');
  int get laharCount => _getGempaCount('lahar');
  int get vulkanikCount => _getGempaCount('vulkanik');

  bool get hasHighGuguran => guguranCount >= 20;
  bool get hasLahar => laharCount > 0;
  bool get hasHarmonikTremor => tremorCount > 0;

  /// Label teks untuk ditampilkan di UI.
  String get levelLabel {
    switch (level) {
      case StatusLevel.normal:
        return 'NORMAL';
      case StatusLevel.waspada:
        return 'WASPADA';
      case StatusLevel.siaga:
        return 'SIAGA';
      case StatusLevel.awas:
        return 'AWAS';
    }
  }

  /// Deskripsi singkat level.
  String get levelDescription {
    switch (level) {
      case StatusLevel.normal:
        return 'Aktivitas vulkanik normal';
      case StatusLevel.waspada:
        return 'Peningkatan aktivitas vulkanik';
      case StatusLevel.siaga:
        return 'Menuju erupsi atau sudah erupsi';
      case StatusLevel.awas:
        return 'Segera evakuasi!';
    }
  }

  /// Warna utama sesuai level status.
  Color get color {
    switch (level) {
      case StatusLevel.normal:
        return const Color(0xFF2E7D32);
      case StatusLevel.waspada:
        return const Color(0xFFF9A825);
      case StatusLevel.siaga:
        return const Color(0xFFE65100);
      case StatusLevel.awas:
        return const Color(0xFFC62828);
    }
  }

  /// Gradient warna untuk hero card.
  List<Color> get gradientColors {
    switch (level) {
      case StatusLevel.normal:
        return const [Color(0xFF2E7D32), Color(0xFF00695C)];
      case StatusLevel.waspada:
        return const [Color(0xFFF9A825), Color(0xFFFF8F00)];
      case StatusLevel.siaga:
        return const [Color(0xFFE65100), Color(0xFFBF360C)];
      case StatusLevel.awas:
        return const [Color(0xFFC62828), Color(0xFF880E4F)];
    }
  }

  /// Warna glow/shadow sesuai level.
  Color get glowColor {
    switch (level) {
      case StatusLevel.normal:
        return const Color(0xFF2E7D32).withValues(alpha: 0.4);
      case StatusLevel.waspada:
        return const Color(0xFFF9A825).withValues(alpha: 0.4);
      case StatusLevel.siaga:
        return const Color(0xFFE65100).withValues(alpha: 0.4);
      case StatusLevel.awas:
        return const Color(0xFFC62828).withValues(alpha: 0.5);
    }
  }

  /// Icon sesuai level status.
  IconData get icon {
    switch (level) {
      case StatusLevel.normal:
        return Icons.check_circle_rounded;
      case StatusLevel.waspada:
        return Icons.info_rounded;
      case StatusLevel.siaga:
        return Icons.warning_amber_rounded;
      case StatusLevel.awas:
        return Icons.dangerous_rounded;
    }
  }

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

  /// Parse list kegempaan menjadi daftar per jenis gempa.
  List<String> get kegempaanList {
    if (kegempaan.isEmpty) return [];
    return kegempaan
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // INTEGRASI DATABASE / API
  // ---------------------------------------------------------------------------

  factory VolcanoStatus.fromJson(Map<String, dynamic> json) {
    final levelStr = json['level'] as String?;
    if (levelStr == null || levelStr.isEmpty) {
      throw FormatException(
        'Key "level" wajib ada dan tidak boleh kosong dalam JSON VolcanoStatus. '
        'Nilai yang diterima: $json',
      );
    }
    return VolcanoStatus(
      level: _parseLevelFromString(levelStr),
      message: json['message'] as String? ?? '',
      visual: json['visual'] as String? ?? '',
      klimatologi: json['klimatologi'] as String? ?? '',
      kegempaan: json['kegempaan'] as String? ?? '',
      rekomendasi: json['rekomendasi'] as String? ?? '',
      author: json['author'] as String? ?? '',
      gempaTotal: (json['gempa_total'] as num?)?.toInt() ?? 0,
      laporanUrl: json['laporan_url'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': levelLabel,
      'message': message,
      'visual': visual,
      'klimatologi': klimatologi,
      'kegempaan': kegempaan,
      'rekomendasi': rekomendasi,
      'author': author,
      'gempa_total': gempaTotal,
      'laporan_url': laporanUrl,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static StatusLevel _parseLevelFromString(String value) {
    switch (value.toUpperCase()) {
      case 'NORMAL':
        return StatusLevel.normal;
      case 'WASPADA':
        return StatusLevel.waspada;
      case 'SIAGA':
        return StatusLevel.siaga;
      case 'AWAS':
        return StatusLevel.awas;
      default:
        throw FormatException(
          'StatusLevel tidak dikenali: "$value". '
          'Nilai yang valid: NORMAL, WASPADA, SIAGA, AWAS.',
        );
    }
  }
}
