import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_card.dart';

/// Layar detail grafik getaran — Professional Edition dengan fl_chart.
class ChartDetailScreen extends StatefulWidget {
  const ChartDetailScreen({super.key});

  @override
  State<ChartDetailScreen> createState() => _ChartDetailScreenState();
}

class _ChartDetailScreenState extends State<ChartDetailScreen> {
  int _selectedRange = 0; // 0=7h, 1=30h, 2=3bln
  int? _touchedIndex;

  static const _ranges = ['7 Hari', '30 Hari', '3 Bulan'];

  // Data simulasi untuk setiap range
  static const _data7Days = [
    (label: 'Sen', value: 2.1),
    (label: 'Sel', value: 3.4),
    (label: 'Rab', value: 1.8),
    (label: 'Kam', value: 5.7),
    (label: 'Jum', value: 4.2),
    (label: 'Sab', value: 2.9),
    (label: 'Min', value: 3.6),
  ];

  static const _data30Days = [
    (label: '1', value: 1.5),
    (label: '5', value: 2.8),
    (label: '10', value: 4.1),
    (label: '15', value: 3.2),
    (label: '20', value: 5.9),
    (label: '25', value: 2.4),
    (label: '30', value: 3.7),
  ];

  static const _data3Months = [
    (label: 'Apr', value: 2.3),
    (label: 'Apr+', value: 3.8),
    (label: 'Mei', value: 5.1),
    (label: 'Mei+', value: 4.4),
    (label: 'Jun', value: 3.9),
    (label: 'Jun+', value: 5.7),
    (label: 'Sek', value: 3.2),
  ];

  List<({String label, double value})> get _currentData {
    switch (_selectedRange) {
      case 0:
        return _data7Days;
      case 1:
        return _data30Days;
      case 2:
        return _data3Months;
      default:
        return _data7Days;
    }
  }

  double get _maxValue =>
      _currentData.map((d) => d.value).reduce((a, b) => a > b ? a : b);
  double get _minValue =>
      _currentData.map((d) => d.value).reduce((a, b) => a < b ? a : b);
  double get _avgValue {
    final sum = _currentData.map((d) => d.value).reduce((a, b) => a + b);
    return sum / _currentData.length;
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Detail Grafik Getaran',
                style: context.headingSmall.copyWith(
                  fontSize: 15,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Amplitudo • mm',
                style: context.caption.copyWith(fontSize: 10),
              ),
            ],
          ),
          leading: IconButton(
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: context.ewsColors.glassBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.ewsColors.glassBorder),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: context.ewsColors.textPrimary,
              ),
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Range filter tabs ---
              _RangeTabBar(
                ranges: _ranges,
                selected: _selectedRange,
                onChanged: (i) => setState(() {
                  _selectedRange = i;
                  _touchedIndex = null;
                }),
              ),

              const SizedBox(height: 16),

              // --- Main Chart Card ---
              GlassCard(
                padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
                child: Column(
                  children: [
                    // Chart
                    SizedBox(
                      height: 260,
                      child: LineChart(
                        _buildLineChart(),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 2,
                          decoration: BoxDecoration(
                            color: context.ewsColors.accent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Amplitudo Getaran',
                          style: context.caption.copyWith(
                            fontSize: 10,
                            color: context.ewsColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- Summary Stats ---
              _StatsGrid(
                average: _avgValue,
                max: _maxValue,
                min: _minValue,
              ),

              const SizedBox(height: 16),

              // --- Info note ---
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.ewsColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: context.ewsColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Data ditampilkan menggunakan simulasi. '
                        'Sambungkan ke API/Firebase untuk data sensor real-time.',
                        style: context.bodyMedium.copyWith(
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData _buildLineChart() {
    final spots = _currentData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        touchCallback: (event, response) {
          setState(() {
            if (response == null ||
                response.lineBarSpots == null ||
                !event.isInterestedForInteractions) {
              _touchedIndex = null;
              return;
            }
            _touchedIndex = response.lineBarSpots!.first.spotIndex;
          });
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => context.ewsColors.bgCard.withValues(alpha: 0.97),
          tooltipRoundedRadius: 10,
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItems: (spots) {
            return spots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} mm',
                context.bodyLarge.copyWith(
                  color: context.ewsColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: '\n${_currentData[spot.spotIndex].label}',
                    style: context.caption.copyWith(
                      color: context.ewsColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: context.ewsColors.accent.withValues(alpha: 0.3),
                strokeWidth: 1.5,
                dashArray: [4, 4],
              ),
              FlDotData(
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: context.ewsColors.accent,
                    strokeWidth: 3,
                    strokeColor: context.ewsColors.bgCard,
                  );
                },
              ),
            );
          }).toList();
        },
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (_) => FlLine(
          color: Colors.white.withValues(alpha: 0.05),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= _currentData.length) {
                return const SizedBox.shrink();
              }
              final isTouched = _touchedIndex == index;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _currentData[index].label,
                  style: context.caption.copyWith(
                    fontSize: 10,
                    color: isTouched ? context.ewsColors.accent : context.ewsColors.textMuted,
                    fontWeight: isTouched ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(0),
                style: context.caption.copyWith(
                  fontSize: 10,
                  color: context.ewsColors.textMuted,
                ),
              );
            },
          ),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (_currentData.length - 1).toDouble(),
      minY: 0,
      maxY: 8,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: context.ewsColors.accent,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              final isTouched = _touchedIndex == index;
              return FlDotCirclePainter(
                radius: isTouched ? 5 : 3.5,
                color: isTouched ? context.ewsColors.accent : context.ewsColors.bgCard,
                strokeWidth: isTouched ? 3 : 2,
                strokeColor: context.ewsColors.accent,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.ewsColors.accent.withValues(alpha: 0.2),
                context.ewsColors.accent.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Tab bar untuk memilih range waktu.
class _RangeTabBar extends StatelessWidget {
  final List<String> ranges;
  final int selected;
  final ValueChanged<int> onChanged;

  const _RangeTabBar({
    required this.ranges,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ranges.asMap().entries.map((entry) {
          final i = entry.key;
          final label = entry.value;
          final isSelected = i == selected;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.ewsColors.accent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  border: isSelected
                      ? Border.all(
                          color: context.ewsColors.accent.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: context.caption.copyWith(
                    color: isSelected
                        ? context.ewsColors.accent
                        : context.ewsColors.textMuted,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Grid statistik 3 kolom.
class _StatsGrid extends StatelessWidget {
  final double average;
  final double max;
  final double min;

  const _StatsGrid({
    required this.average,
    required this.max,
    required this.min,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        label: 'Rata-rata',
        value: average.toStringAsFixed(1),
        unit: 'mm',
        icon: Icons.show_chart_rounded,
        color: context.ewsColors.accent,
      ),
      (
        label: 'Tertinggi',
        value: max.toStringAsFixed(1),
        unit: 'mm',
        icon: Icons.arrow_upward_rounded,
        color: const Color(0xFFFF6B6B),
      ),
      (
        label: 'Terendah',
        value: min.toStringAsFixed(1),
        unit: 'mm',
        icon: Icons.arrow_downward_rounded,
        color: context.ewsColors.statusNormal,
      ),
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: stat == stats.last ? 0 : 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: stat.color.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      stat.icon,
                      size: 12,
                      color: stat.color.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stat.label,
                      style: context.caption.copyWith(
                        fontSize: 9,
                        color: context.ewsColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: stat.value,
                        style: context.sensorValue.copyWith(
                          fontSize: 20,
                          color: stat.color,
                        ),
                      ),
                      TextSpan(
                        text: ' ${stat.unit}',
                        style: context.caption.copyWith(
                          fontSize: 9,
                          color: stat.color.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
