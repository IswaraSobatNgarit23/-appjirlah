import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/log_item_card.dart';
import '../widgets/error_state_view.dart';
import '../widgets/empty_state_view.dart';

/// Tab Log Riwayat — Professional Edition dengan fl_chart.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(activityLogsProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: context.ewsColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.ewsColors.secondary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: context.ewsColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Riwayat Aktivitas',
                    style: context.headingSmall.copyWith(
                      fontSize: 15,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '7 Hari Terakhir',
                    style: context.caption.copyWith(
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: logsAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: context.ewsColors.accent),
          ),
          error: (error, _) => ErrorStateView(
            error: error,
            onRetry: () => ref.invalidate(activityLogsProvider),
          ),
          data: (logs) {
            if (logs.isEmpty) {
              return const EmptyStateView(
                icon: Icons.history_rounded,
                title: 'Belum Ada Riwayat',
                subtitle: 'Log aktivitas gunung akan muncul di sini.',
              );
            }

            return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activityLogsProvider);
            },
            color: context.ewsColors.accent,
            backgroundColor: context.ewsColors.bgCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Chart Section ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _VibrasiChartCard(
                    onTap: () => context.pushNamed('chartDetail'),
                  ),
                ),

                const SizedBox(height: 4),

                // --- Summary Stats ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _SummaryStatsRow(),
                ),

                // --- Header Log ---
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 14,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [context.ewsColors.accent, context.ewsColors.accentDim],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('LOG KEJADIAN', style: context.label),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          '${logs.length} kejadian',
                          style: context.caption.copyWith(
                            fontSize: 10,
                            color: context.ewsColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- List Log ---
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: logs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return LogItemCard(log: logs[index]);
                    },
                  ),
                ),
              ],
            ),
          );
          },
        ),
      ),
    );
  }
}

/// Chart getaran menggunakan fl_chart — bisa di-tap untuk detail.
class _VibrasiChartCard extends StatefulWidget {
  final VoidCallback onTap;

  const _VibrasiChartCard({required this.onTap});

  @override
  State<_VibrasiChartCard> createState() => _VibrasiChartCardState();
}

class _VibrasiChartCardState extends State<_VibrasiChartCard> {
  int? _touchedIndex;

  // Data simulasi getaran 7 hari terakhir
  static const _dataPoints = [
    (day: 'Sen', value: 2.1),
    (day: 'Sel', value: 3.4),
    (day: 'Rab', value: 1.8),
    (day: 'Kam', value: 5.7),
    (day: 'Jum', value: 4.2),
    (day: 'Sab', value: 2.9),
    (day: 'Min', value: 3.6),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header chart
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amplitudo Getaran',
                      style: context.bodyLarge.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '7 hari terakhir • mm',
                      style: context.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: context.ewsColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.ewsColors.accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Detail',
                        style: context.caption.copyWith(
                          color: context.ewsColors.accent,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: context.ewsColors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // fl_chart BarChart
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 8,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      setState(() {
                        if (response == null ||
                            response.spot == null ||
                            !event.isInterestedForInteractions) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            response.spot!.touchedBarGroupIndex;
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          context.ewsColors.bgCard.withValues(alpha: 0.95),
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(1)} mm',
                          context.caption.copyWith(
                            color: context.ewsColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= _dataPoints.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _dataPoints[index].day,
                              style: context.caption.copyWith(
                                fontSize: 9,
                                color: _touchedIndex == index
                                    ? context.ewsColors.accent
                                    : context.ewsColors.textMuted,
                              ),
                            ),
                          );
                        },
                        reservedSize: 22,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          if (value % 2 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: context.caption.copyWith(
                              fontSize: 9,
                              color: context.ewsColors.textMuted,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
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
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(_dataPoints.length, (index) {
                    final isSelected = _touchedIndex == index;
                    final point = _dataPoints[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: point.value,
                          width: 18,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isSelected
                                ? [
                                    context.ewsColors.accent,
                                    context.ewsColors.accentDim,
                                  ]
                                : [
                                    context.ewsColors.accent.withValues(alpha: 0.7),
                                    context.ewsColors.accent.withValues(alpha: 0.3),
                                  ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Baris statistik ringkasan.
class _SummaryStatsRow extends StatelessWidget {
  const _SummaryStatsRow();

  @override
  Widget build(BuildContext context) {
    final stats = [
      (label: 'Rata-rata', value: '3.4', unit: 'mm', color: context.ewsColors.accent),
      (label: 'Tertinggi', value: '5.7', unit: 'mm', color: const Color(0xFFFF6B6B)),
      (label: 'Terendah', value: '1.8', unit: 'mm', color: context.ewsColors.statusNormal),
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: stat == stats.last ? 0 : 8,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: stat.color.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: context.caption.copyWith(
                    fontSize: 9,
                    color: context.ewsColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: stat.value,
                        style: context.sensorValue.copyWith(
                          fontSize: 18,
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
