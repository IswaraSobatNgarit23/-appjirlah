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
/// Untuk integrasi database/API, cukup buat instance dari JSON response:
/// ```dart
/// final status = VolcanoStatus.fromJson(jsonData);
/// ```
class VolcanoStatus {
  final StatusLevel level;
  final String message;
  final String visual;
  final String klimatologi;
  final String kegempaan;
  final String rekomendasi;
  final String author;
  final DateTime updatedAt;

  const VolcanoStatus({
    required this.level,
    required this.message,
    this.visual = '',
    this.klimatologi = '',
    this.kegempaan = '',
    this.rekomendasi = '',
    this.author = '',
    required this.updatedAt,
  });

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

  // ---------------------------------------------------------------------------
  // INTEGRASI DATABASE / API
  // Uncomment dan sesuaikan method di bawah saat menghubungkan ke backend.
  // ---------------------------------------------------------------------------

  /// Membuat instance dari JSON response API.
  /// Contoh JSON: {"level": "SIAGA", "message": "Jauhi radius 13 KM", "updated_at": "2026-06-16T21:00:00Z"}
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
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Konversi ke JSON untuk dikirim ke API.
  Map<String, dynamic> toJson() {
    return {
      'level': levelLabel,
      'message': message,
      'visual': visual,
      'klimatologi': klimatologi,
      'kegempaan': kegempaan,
      'rekomendasi': rekomendasi,
      'author': author,
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
