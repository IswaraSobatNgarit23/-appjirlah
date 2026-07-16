import 'package:flutter/material.dart';
import '../models/volcano_status.dart';
import '../theme/app_theme.dart';

class SeismicEwsDashboard extends StatelessWidget {
  final VolcanoStatus status;

  const SeismicEwsDashboard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Kumpulkan metrik
    final items = [
      _MetricData('Guguran', status.guguranCount, status.hasHighGuguran, Icons.landslide_rounded),
      _MetricData('Letusan', status.letusanCount, status.letusanCount > 0, Icons.volcano_rounded),
      _MetricData('Tremor', status.tremorCount, status.hasHarmonikTremor, Icons.waves_rounded),
      _MetricData('Lahar', status.laharCount, status.hasLahar, Icons.flood_rounded),
      _MetricData('Vulkanik', status.vulkanikCount, false, Icons.blur_circular_rounded),
    ];

    // Filter yang lebih dari 0 saja
    final activeItems = items.where((i) => i.count > 0).toList();
    if (activeItems.isEmpty) return const SizedBox.shrink();

    // Cek peringatan darurat
    final hasWarning = status.hasHighGuguran || status.hasLahar || status.hasHarmonikTremor;

    return Container(
      decoration: BoxDecoration(
        color: context.ewsColors.glassBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: hasWarning ? const Color(0xFFEF4444).withValues(alpha: 0.5) : context.ewsColors.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Warning Banner
          if (hasWarning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusM - 1),
                  topRight: Radius.circular(AppTheme.radiusM - 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'PERINGATAN: Anomali Seismik Terdeteksi',
                    style: context.bodyMedium.copyWith(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Dashboard Grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activeItems.map((item) => _MetricWidget(item: item)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final String label;
  final int count;
  final bool isWarning;
  final IconData icon;

  const _MetricData(this.label, this.count, this.isWarning, this.icon);
}

class _MetricWidget extends StatelessWidget {
  final _MetricData item;

  const _MetricWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isWarning ? const Color(0xFFEF4444) : context.ewsColors.textPrimary;
    final bgColor = item.isWarning 
        ? const Color(0xFFEF4444).withValues(alpha: 0.1) 
        : context.ewsColors.bgCard;

    return Container(
      width: (MediaQuery.of(context).size.width - 32 - 24 - 8) / 2, // 2 kolom
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.isWarning ? const Color(0xFFEF4444).withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(item.icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: context.label.copyWith(
                    color: item.isWarning ? color : context.ewsColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '${item.count}x',
                  style: context.bodyLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
