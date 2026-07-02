import 'package:flutter/material.dart';
import '../models/activity_log.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Card untuk menampilkan satu item log kejadian — Professional Edition.
class LogItemCard extends StatelessWidget {
  final ActivityLog log;

  const LogItemCard({
    super.key,
    required this.log,
  });

  Color _severityColor(BuildContext context) {
    switch (log.severity) {
      case 'critical':
        return context.ewsColors.statusAwas;
      case 'high':
        return context.ewsColors.statusSiaga;
      case 'medium':
        return context.ewsColors.statusWaspada;
      case 'low':
        return context.ewsColors.statusNormal;
      default:
        return context.ewsColors.textTertiary;
    }
  }

  String get _severityLabel {
    switch (log.severity) {
      case 'critical':
        return 'KRITIS';
      case 'high':
        return 'TINGGI';
      case 'medium':
        return 'SEDANG';
      case 'low':
        return 'RENDAH';
      default:
        return 'INFO';
    }
  }

  IconData get _severityIcon {
    switch (log.severity) {
      case 'critical':
        return Icons.dangerous_rounded;
      case 'high':
        return Icons.warning_amber_rounded;
      case 'medium':
        return Icons.info_rounded;
      case 'low':
        return Icons.check_circle_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(context);

    return GlassCard(
      padding: EdgeInsets.zero,
      blurSigma: 6,
      borderColor: color.withValues(alpha: 0.15),
      child: Stack(
        children: [
          // --- Garis indikator severity ---
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color,
                    color.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusM),
                  bottomLeft: Radius.circular(AppTheme.radiusM),
                ),
              ),
            ),
          ),

          // --- Konten ---
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris atas: waktu + badge severity
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: context.ewsColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        log.formattedTime,
                        style: context.caption.copyWith(
                          letterSpacing: 0.3,
                          color: context.ewsColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      // Badge severity
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: color.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _severityIcon,
                              size: 10,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _severityLabel,
                              style: context.caption.copyWith(
                                color: color,
                                fontSize: 9,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Deskripsi kejadian
                  Text(
                    log.description,
                    style: context.bodyLarge.copyWith(
                      fontSize: 13,
                      height: 1.5,
                      color: context.ewsColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
