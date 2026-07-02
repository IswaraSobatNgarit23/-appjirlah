import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Widget reusable untuk menampilkan kondisi data kosong (empty state).
///
/// Gunakan di layar yang menampilkan list data untuk menangani
/// kasus ketika data yang dikembalikan kosong (bukan error).
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyStateView({
    super.key,
    this.icon = Icons.inbox_rounded,
    this.title = 'Belum Ada Data',
    this.subtitle = 'Data akan muncul di sini saat sudah tersedia.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.ewsColors.textMuted.withValues(alpha: 0.08),
                  border: Border.all(
                    color: context.ewsColors.textMuted.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: context.ewsColors.textMuted,
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: context.headingSmall.copyWith(
                  color: context.ewsColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: context.bodyMedium.copyWith(
                  color: context.ewsColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
