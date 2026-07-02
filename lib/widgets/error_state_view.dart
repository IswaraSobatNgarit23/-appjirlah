import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Widget reusable untuk menampilkan pesan error — Professional Edition.
class ErrorStateView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: GlassCard(
          backgroundColor: context.ewsColors.statusAwas.withValues(alpha: 0.06),
          borderColor: context.ewsColors.statusAwas.withValues(alpha: 0.2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.ewsColors.statusAwas.withValues(alpha: 0.1),
                  border: Border.all(
                    color: context.ewsColors.statusAwas.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: context.ewsColors.statusAwas,
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Gagal Memuat Data',
                style: context.headingSmall.copyWith(
                  color: context.ewsColors.statusAwas.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: context.bodyMedium.copyWith(
                  color: context.ewsColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              // Tombol retry
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.ewsColors.statusAwas.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    elevation: 0,
                    textStyle: context.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
