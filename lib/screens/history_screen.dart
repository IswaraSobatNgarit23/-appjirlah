import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/volcano_status.dart';
import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/log_item_card.dart';
import '../widgets/error_state_view.dart';
import '../widgets/empty_state_view.dart';

/// Tab Log Riwayat — menampilkan data historis REAL dari PocketBase.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(activityLogsProvider);
    final historyAsync = ref.watch(historicalDataProvider);

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
                    'Data Laporan MAGMA',
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
            onRetry: () {
              ref.invalidate(activityLogsProvider);
              ref.invalidate(historicalDataProvider);
            },
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
              ref.invalidate(historicalDataProvider);
            },
            color: context.ewsColors.accent,
            backgroundColor: context.ewsColors.bgCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Chart Section ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: historyAsync.when(
                    data: (history) => _GempaChartCard(
                      data: history,
                      onTap: () => context.pushNamed('chartDetail'),
                    ),
                    loading: () => const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                const SizedBox(height: 4),

                // --- Summary Stats ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: historyAsync.when(
                    data: (history) => _SummaryStatsRow(data: history),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
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
                      Text('LOG LAPORAN', style: context.label),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          '${logs.length} laporan',
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

/// Chart gempa total menggunakan fl_chart — data REAL dari PocketBase.
class _GempaChartCard extends StatefulWidget {
  final List<VolcanoStatus> data;
  final VoidCallback onTap;

  const _GempaChartCard({required this.data, required this.onTap});

  @override
  State<_GempaChartCard> createState() => _GempaChartCardState();
}

class _GempaChartCardState extends State<_GempaChartCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    // Data diurutkan dari terlama ke terbaru untuk chart
    final chartData = widget.data.reversed.toList();
    
    if (chartData.isEmpty) return const SizedBox.shrink();

    final maxGempa = chartData
        .map((e) => e.gempaTotal.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final chartMaxY = (maxGempa * 1.3).clamp(10.0, double.infinity);

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
                      'Total Gempa per Laporan',
                      style: context.bodyLarge.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${chartData.length} laporan terakhir',
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

            // fl_chart BarChart — data REAL
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY,
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
                        final item = chartData[groupIndex];
                        return BarTooltipItem(
                          '${item.gempaTotal} gempa\n${item.levelLabel}',
                          context.caption.copyWith(
                            color: context.ewsColors.accent,
                            fontSize: 10,
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
                          if (index < 0 || index >= chartData.length) {
                            return const SizedBox.shrink();
                          }
                          final date = chartData[index].updatedAt;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: context.caption.copyWith(
                                fontSize: 8,
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
                          if (value % (chartMaxY / 4).ceil() != 0) {
                            return const SizedBox.shrink();
                          }
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
                    horizontalInterval: (chartMaxY / 4).ceilToDouble(),
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: 0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(chartData.length, (index) {
                    final isSelected = _touchedIndex == index;
                    final item = chartData[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.gempaTotal.toDouble(),
                          width: chartData.length <= 3 ? 30 : 18,
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

/// Baris statistik ringkasan — data REAL.
class _SummaryStatsRow extends StatelessWidget {
  final List<VolcanoStatus> data;

  const _SummaryStatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final gempaCounts = data.map((e) => e.gempaTotal).toList();
    final avg = gempaCounts.reduce((a, b) => a + b) / gempaCounts.length;
    final max = gempaCounts.reduce((a, b) => a > b ? a : b);
    final min = gempaCounts.reduce((a, b) => a < b ? a : b);

    final stats = [
      (label: 'Rata-rata', value: avg.toStringAsFixed(0), unit: 'gempa', color: context.ewsColors.accent),
      (label: 'Tertinggi', value: '$max', unit: 'gempa', color: const Color(0xFFFF6B6B)),
      (label: 'Terendah', value: '$min', unit: 'gempa', color: context.ewsColors.statusNormal),
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
