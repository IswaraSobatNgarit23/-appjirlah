import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Background premium dengan gradient dalam + orb dekoratif melayang.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: Gradient utama
        Container(
          decoration: BoxDecoration(
            color: context.ewsColors.bgDark,
            gradient: context.backgroundGradient,
          ),
        ),
        // Layer 2: Orb dekoratif
        const Positioned(
          top: -80,
          right: -60,
          child: _DecorativeOrb(
            size: 280,
            color: Color(0xFF00D4AA),
            opacity: 0.06,
          ),
        ),
        const Positioned(
          bottom: 100,
          left: -80,
          child: _DecorativeOrb(
            size: 240,
            color: Color(0xFF4A9EFF),
            opacity: 0.05,
          ),
        ),
        const Positioned(
          top: 300,
          right: -40,
          child: _DecorativeOrb(
            size: 160,
            color: Color(0xFF00D4AA),
            opacity: 0.04,
          ),
        ),
        // Layer 3: Konten
        child,
      ],
    );
  }
}

/// Orb bulat dengan gradien radial untuk efek kedalaman.
class _DecorativeOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _DecorativeOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

