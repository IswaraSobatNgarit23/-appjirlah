import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../providers/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/status_hero_card.dart';
import '../widgets/error_state_view.dart';
import '../widgets/visual_cctv_card.dart';

/// Tab Beranda — Menampilkan seluruh data dari laporan MAGMA secara lengkap.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(volcanoStatusProvider);
    final onlineAsync = ref.watch(systemOnlineProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: statusAsync.when(
          loading: () => _buildLoadingState(context),
          error: (error, _) => ErrorStateView(
            error: error,
            onRetry: () {
              ref.invalidate(volcanoStatusProvider);
              ref.invalidate(systemOnlineProvider);
            },
          ),
          data: (status) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(volcanoStatusProvider);
              ref.invalidate(systemOnlineProvider);
            },
            color: context.ewsColors.accent,
            backgroundColor: context.ewsColors.bgCard,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context, onlineAsync, ref),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // 1. STATUS HERO CARD
                      StatusHeroCard(status: status),

                      const SizedBox(height: 24),

                      // 2. RINGKASAN DATA — 2 card kecil (Total Gempa + Author)
                      _SectionHeader(
                        label: 'RINGKASAN LAPORAN',
                        subtitle: 'Diperbarui ${status.formattedUpdateTime}',
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(context, status),

                      // 3.5. TEKS PENGAMATAN KEGEMPAAN
                      if (status.kegempaan.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const _SectionHeader(label: 'DETAIL KEGEMPAAN'),
                        const SizedBox(height: 12),
                        _KegempaanCard(status: status),
                      ],

                      // 4. PENGAMATAN VISUAL & CCTV
                      const SizedBox(height: 24),
                      const _SectionHeader(label: 'SITUASI TERKINI & CCTV'),
                      const SizedBox(height: 12),
                      VisualCctvCard(status: status),

                      // 4.5. TEKS PENGAMATAN VISUAL
                      if (status.visual.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _TextCard(
                          text: status.visual,
                          icon: Icons.visibility_rounded,
                          iconColor: const Color(0xFF3B82F6),
                        ),
                      ],

                      // 5. KLIMATOLOGI
                      if (status.klimatologi.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const _SectionHeader(label: 'KLIMATOLOGI'),
                        const SizedBox(height: 12),
                        _TextCard(
                          text: status.klimatologi,
                          icon: Icons.cloud_rounded,
                          iconColor: const Color(0xFF06B6D4),
                        ),
                      ],

                      // 6. REKOMENDASI PVMBG
                      if (status.rekomendasi.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const _SectionHeader(label: 'REKOMENDASI PVMBG'),
                        const SizedBox(height: 12),
                        _TextCard(
                          text: status.rekomendasi,
                          icon: Icons.security_rounded,
                          iconColor: const Color(0xFFEF4444),
                        ),
                      ],

                      // 7. INFO LOKASI
                      const SizedBox(height: 24),
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
      ),
    );
  }

  // Baris ringkasan: Total Gempa + Pelapor
  Widget _buildSummaryRow(BuildContext context, dynamic status) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // Total Gempa — card utama, besar dan menarik
        Expanded(
          flex: 5,
          child: _SummaryTile(
            icon: Icons.vibration_rounded,
            iconColor: const Color(0xFFEF4444),
            label: 'Total Gempa',
            value: '${status.gempaTotal}',
            unit: 'kejadian',
            onTap: () {
              if (status.kegempaan.isNotEmpty) {
                _showKegempaanSheet(context, status);
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        // Pelapor
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _SummaryTile(
                icon: Icons.badge_rounded,
                iconColor: const Color(0xFF8B5CF6),
                label: 'Pelapor',
                value: status.author.isNotEmpty ? status.author : '-',
                unit: '',
                isCompact: true,
              ),
              const SizedBox(height: 10),
              _SummaryTile(
                icon: Icons.shield_rounded,
                iconColor: status.color,
                label: 'Status',
                value: status.levelLabel,
                unit: status.levelDescription,
                isCompact: true,
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }

  void _showKegempaanSheet(BuildContext context, dynamic status) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _KegempaanDetailSheet(status: status),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AsyncValue<bool> onlineAsync, WidgetRef ref) {
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
            'Memuat data laporan...',
            style: context.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// KEGEMPAAN CARD — Ringkasan + Tombol Detail
// =============================================================================

class _KegempaanCard extends StatelessWidget {
  final dynamic status;

  const _KegempaanCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final items = status.kegempaanList as List<String>;
    // Tampilkan max 3 item di card, sisanya di bottom sheet
    final preview = items.take(3).toList();
    final hasMore = items.length > 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ewsColors.glassBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: context.ewsColors.glassBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.ssid_chart_rounded, size: 18, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${status.gempaTotal} kejadian gempa',
                    style: context.bodyLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${items.length} jenis tercatat',
                    style: context.caption.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 14),
          
          // Daftar jenis gempa (preview)
          ...preview.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: context.ewsColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: context.bodyMedium.copyWith(
                      height: 1.4,
                      fontSize: 12,
                      color: context.ewsColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),
          
          // Tombol lihat detail
          if (hasMore || items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _showFullDetail(context),
                  style: TextButton.styleFrom(
                    backgroundColor: context.ewsColors.accent.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: context.ewsColors.accent.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: context.ewsColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasMore ? 'Lihat Semua ${items.length} Jenis Gempa' : 'Lihat Detail Lengkap',
                        style: context.caption.copyWith(
                          color: context.ewsColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _KegempaanDetailSheet(status: status),
    );
  }
}

// =============================================================================
// KEGEMPAAN DETAIL BOTTOM SHEET
// =============================================================================

class _KegempaanDetailSheet extends StatelessWidget {
  final dynamic status;

  const _KegempaanDetailSheet({required this.status});

  @override
  Widget build(BuildContext context) {
    final items = status.kegempaanList as List<String>;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: context.ewsColors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: context.ewsColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.ewsColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.ssid_chart_rounded, size: 20, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Kegempaan',
                        style: context.headingSmall.copyWith(fontSize: 16),
                      ),
                      Text(
                        'Total ${status.gempaTotal} kejadian gempa',
                        style: context.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // Close button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: context.ewsColors.textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
          Divider(
            color: context.ewsColors.glassBorder,
            height: 20,
          ),
          
          // List semua jenis gempa
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.ewsColors.glassBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.ewsColors.glassBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: context.ewsColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: context.bodyLarge.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: context.ewsColors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: context.bodyMedium.copyWith(
                            height: 1.5,
                            fontSize: 13,
                            color: context.ewsColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUMMARY TILE — Card ringkasan data
// =============================================================================

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final bool isCompact;
  final VoidCallback? onTap;

  const _SummaryTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.unit = '',
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        decoration: BoxDecoration(
          color: context.ewsColors.glassBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: context.ewsColors.glassBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: isCompact ? 28 : 36,
                  height: isCompact ? 28 : 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                  ),
                  child: Icon(icon, size: isCompact ? 14 : 18, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: context.caption.copyWith(
                      fontSize: isCompact ? 9 : 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: context.ewsColors.textMuted,
                  ),
              ],
            ),
            SizedBox(height: isCompact ? 6 : 10),
            Text(
              value,
              style: isCompact
                  ? context.bodyLarge.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )
                  : context.sensorValue.copyWith(
                      fontSize: 28,
                      color: iconColor,
                    ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: context.caption.copyWith(
                  fontSize: isCompact ? 9 : 10,
                  color: context.ewsColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION HEADER
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String label;
  final String? subtitle;

  const _SectionHeader({required this.label, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
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

// =============================================================================
// INFO CARD
// =============================================================================

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

// =============================================================================
// TEXT CARD — untuk visual, klimatologi, rekomendasi
// =============================================================================

class _TextCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;

  const _TextCard({
    required this.text,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ewsColors.glassBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: context.ewsColors.glassBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: context.bodyMedium.copyWith(
                height: 1.5,
                color: context.ewsColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
