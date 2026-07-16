import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/status_hero_card.dart';
import '../widgets/sensor_tile.dart';
import '../widgets/error_state_view.dart';

/// Tab Beranda — Professional Edition.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(volcanoStatusProvider);
    final sensorAsync = ref.watch(sensorDataProvider);
    final onlineAsync = ref.watch(systemOnlineProvider);

    final isLoading = statusAsync.isLoading || sensorAsync.isLoading;
    final error = statusAsync.error ?? sensorAsync.error;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: error != null
            ? ErrorStateView(
                error: error,
                onRetry: () {
                  ref.invalidate(volcanoStatusProvider);
                  ref.invalidate(sensorDataProvider);
                  ref.invalidate(systemOnlineProvider);
                },
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(volcanoStatusProvider);
                  ref.invalidate(sensorDataProvider);
                  ref.invalidate(systemOnlineProvider);
                },
                color: context.ewsColors.accent,
                backgroundColor: context.ewsColors.bgCard,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildSliverAppBar(context, onlineAsync),
                    if (isLoading)
                      SliverFillRemaining(
                        child: _buildLoadingState(context),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            if (statusAsync.hasValue)
                              StatusHeroCard(status: statusAsync.value!),
                            
                            const SizedBox(height: 28),
                            _SectionHeader(
                              label: 'DATA SENSOR',
                              subtitle: sensorAsync.hasValue
                                  ? 'Diperbarui ${sensorAsync.value!.formattedUpdateTime}'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            
                            if (sensorAsync.hasValue)
                              _buildSensorBentoGrid(context, sensorAsync.value!),
                              
                            const SizedBox(height: 28),
                            const _SectionHeader(label: 'INFO LOKASI'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.location_on_rounded,
                                    iconColor: context.ewsColors.accent,
                                    title: 'Pronojiwo',
                                    subtitle: 'Lumajang, Jawa Timur',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.terrain_rounded,
                                    iconColor: const Color(0xFF8B7CF6),
                                    title: '3.676 mdpl',
                                    subtitle: 'Ketinggian Puncak',
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AsyncValue<bool> onlineAsync) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      backgroundColor: context.ewsColors.bgDark.withValues(alpha: 0.95),
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D4AA), Color(0xFF00A88A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.volcano_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'EWS Semeru',
                style: context.headingSmall.copyWith(
                  fontSize: 16,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Peringatan Dini Erupsi',
                style: context.caption.copyWith(
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Consumer(
            builder: (context, ref, _) {
              final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: context.ewsColors.textSecondary,
                ),
                onPressed: () {
                  ref.read(themeModeProvider.notifier).state = 
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Pendekatan Ponytail: Bento Grid (Clean & Professional)
  Widget _buildSensorBentoGrid(BuildContext context, dynamic sensor) {
    return SizedBox(
      height: 260, // Diperbesar dari 220 ke 260 agar tidak overflow jika ukuran teks HP besar
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kiri: Amplitudo (Tinggi / Tall)
          Expanded(
            flex: 5,
            child: SensorTile(
              label: 'Amplitudo Getaran',
              value: sensor.amplitudo.toStringAsFixed(1),
              unit: 'mm',
              icon: Icons.vibration_rounded,
              iconColor: const Color(0xFFEF4444), // Red 500
              progressValue: (sensor.amplitudo / 10.0).clamp(0.0, 1.0),
              trendLabel: '+0.3',
              trendUp: true,
              isVertical: true, // Ubah layout menjadi kolom
              onTap: () => context.push('/chart'),
            ),
          ),
          const SizedBox(width: 10),
          // Kanan: Suhu & Gempa (Ditumpuk)
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Expanded(
                  child: SensorTile(
                    label: 'Suhu Kawah',
                    value: sensor.suhu.toStringAsFixed(1),
                    unit: '°C',
                    icon: Icons.thermostat_rounded,
                    iconColor: const Color(0xFFF59E0B), // Amber 500
                    progressValue: (sensor.suhu / 1000.0).clamp(0.0, 1.0),
                    trendLabel: '-12°',
                    trendUp: false,
                    onTap: () => context.push('/chart'),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SensorTile(
                    label: 'Gempa Vulkanik',
                    value: '${sensor.gempaCount}',
                    unit: 'x/hari',
                    icon: Icons.timeline_rounded,
                    iconColor: const Color(0xFF2563EB), // Blue 600
                    progressValue: (sensor.gempaCount / 50.0).clamp(0.0, 1.0),
                    trendLabel: '+5',
                    trendUp: true,
                    onTap: () => context.push('/chart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.ewsColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: context.ewsColors.accent.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: CircularProgressIndicator(
                color: context.ewsColors.accent,
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data sensor...',
            style: context.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Header section dengan label dan subtitle opsional.
class _SectionHeader extends StatelessWidget {
  final String label;
  final String? subtitle;

  const _SectionHeader({required this.label, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Garis aksen kiri
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
        Text(label, style: context.label),
        if (subtitle != null) ...[
          const Spacer(),
          Text(
            subtitle!,
            style: context.caption.copyWith(
              color: context.ewsColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}

/// Card info ringkas 2 kolom.
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.ewsColors.glassBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: context.ewsColors.glassBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyLarge.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: context.caption.copyWith(
                    fontSize: 10,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
