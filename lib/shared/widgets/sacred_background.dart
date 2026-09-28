import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

/// Fondo de "biblioteca sagrada": luz suave desde arriba y partículas doradas
/// que flotan muy lentamente. Respeta "reducir animaciones" del sistema.
class SacredBackground extends StatefulWidget {
  const SacredBackground({super.key, this.child, this.particles = 38});

  final Widget? child;
  final int particles;

  @override
  State<SacredBackground> createState() => _SacredBackgroundState();
}

class _SacredBackgroundState extends State<SacredBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 90),
  );
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = math.Random(7);
    _particles = List.generate(
      widget.particles,
      (_) => _Particle.random(random),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -1.1),
              radius: 1.3,
              colors: [
                Color.alphaBlend(palette.glow, palette.goldSoft),
                palette.background,
              ],
              stops: const [0, 0.75],
            ),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: _ParticlePainter(_controller, _particles, palette.gold),
          ),
        ),
        ?widget.child,
      ],
    );
  }
}

class _Particle {
  _Particle(this.x, this.y, this.radius, this.speed, this.phase, this.opacity);

  factory _Particle.random(math.Random r) => _Particle(
    r.nextDouble(),
    r.nextDouble(),
    0.6 + r.nextDouble() * 1.8,
    0.3 + r.nextDouble() * 0.7,
    r.nextDouble() * math.pi * 2,
    0.15 + r.nextDouble() * 0.45,
  );

  final double x, y, radius, speed, phase, opacity;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.animation, this.particles, this.color)
    : super(repaint: animation);

  final Animation<double> animation;
  final List<_Particle> particles;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final paint = Paint();
    for (final p in particles) {
      // Ascenso lento y ligera oscilación horizontal.
      final y = (p.y - t * p.speed * 2) % 1.0;
      final x = p.x + math.sin(t * math.pi * 2 * p.speed * 3 + p.phase) * 0.02;
      final twinkle =
          0.6 + 0.4 * math.sin(t * math.pi * 40 * p.speed + p.phase);
      paint
        ..color = color.withValues(alpha: p.opacity * twinkle)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.color != color;
}
