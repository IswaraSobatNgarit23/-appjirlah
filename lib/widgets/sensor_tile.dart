import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Tile individual untuk menampilkan satu data sensor — Professional Edition.
/// Menampilkan nilai, unit, dan bar indikator level.
class SensorTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color? iconColor;
  final double? progressValue; // 0.0 - 1.0, null = tidak tampil
  final String? trendLabel; // contoh: '+2.3' atau '-0.5'
  final bool trendUp;
  final VoidCallback? onTap;
  final bool isVertical;

  const SensorTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.iconColor,
    this.progressValue,
    this.trendLabel,
    this.trendUp = true,
    this.onTap,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? context.ewsColors.accent;

    return GlassCard(
      padding: EdgeInsets.zero,
      blurSigma: 0,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: effectiveIconColor.withValues(alpha: 0.05),
          splashColor: effectiveIconColor.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Ikon (kiri) & Trend (kanan)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: effectiveIconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Icon(icon, size: 18, color: effectiveIconColor),
                    ),
                    if (trendLabel != null)
                      _TrendBadge(label: trendLabel!, isUp: trendUp, color: effectiveIconColor),
                  ],
                ),
                
                // Mendorong konten teks ke bagian bawah
                const Spacer(),
                
                // Label
                Text(
                  label, 
                  style: context.bodyMedium.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Value + Unit
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value, 
                      style: context.sensorValue.copyWith(
                        color: context.ewsColors.textPrimary,
                        fontSize: 22,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        unit,
                        style: context.caption.copyWith(
                          fontSize: 10,
                          color: context.ewsColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Progress Bar (hanya untuk tile yang tall/kiri)
                if (progressValue != null && isVertical) ...[
                  const SizedBox(height: 8),
                  _ProgressBar(value: progressValue!, color: effectiveIconColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bar progres tipis berwarna.
class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Background
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Foreground
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              height: 4,
              width: constraints.maxWidth * value.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.6),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Badge kecil untuk trend naik/turun.
class _TrendBadge extends StatelessWidget {
  final String label;
  final bool isUp;
  final Color color;

  const _TrendBadge({
    required this.label,
    required this.isUp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          size: 12,
          color: color.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: context.caption.copyWith(
            color: color.withValues(alpha: 0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
