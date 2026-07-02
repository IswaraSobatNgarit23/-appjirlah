import 'package:flutter/material.dart';
import '../models/volcano_status.dart';
import '../theme/app_theme.dart';

/// Hero card besar yang menampilkan status gunung — Professional Edition.
class StatusHeroCard extends StatelessWidget {
  final VolcanoStatus status;

  const StatusHeroCard({
    super.key,
    required this.status,
  });

  int get _levelIndex {
    switch (status.level) {
      case StatusLevel.normal:
        return 0;
      case StatusLevel.waspada:
        return 1;
      case StatusLevel.siaga:
        return 2;
      case StatusLevel.awas:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: status.gradientColors,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: context.glowShadow(status.color),
      ),
      child: Stack(
        children: [
          // --- Dekorasi lingkaran latar belakang ---
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 60,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // --- Konten utama ---
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Baris atas: label + pulse indicator ---
                Row(
                  children: [
                    _PulseIndicator(color: Colors.white.withValues(alpha: 0.9)),
                    const SizedBox(width: 8),
                    Text(
                      'STATUS GUNUNG SEMERU',
                      style: context.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1.5,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    // Waktu update
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatTime(status.updatedAt),
                        style: context.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // --- Baris tengah: Icon + Level ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon container
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        status.icon,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 18),
                    // Level text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level',
                          style: context.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status.levelLabel,
                          style: context.headingLarge.copyWith(
                            color: Colors.white,
                            fontSize: 40,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- Pesan ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status.message,
                    style: context.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- Level progress bar ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tingkat Bahaya',
                          style: context.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '${_levelIndex + 1}/4',
                          style: context.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Segmented progress
                    Row(
                      children: List.generate(4, (i) {
                        final isActive = i <= _levelIndex;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                            height: 5,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['Normal', 'Waspada', 'Siaga', 'Awas']
                          .map((l) => Text(
                                l,
                                style: context.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 9,
                                  letterSpacing: 0,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

/// Indikator pulse (lingkaran berkedip) untuk menandakan live status.
class _PulseIndicator extends StatefulWidget {
  final Color color;

  const _PulseIndicator({required this.color});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
