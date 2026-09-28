import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

/// Destello dorado ligero que recorre el contenido una sola vez
/// (se usa al abrir una palabra).
class GoldenShimmer extends StatefulWidget {
  const GoldenShimmer({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 500),
  });

  final Widget child;
  final Duration delay;

  @override
  State<GoldenShimmer> createState() => _GoldenShimmerState();
}

class _GoldenShimmerState extends State<GoldenShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    final gold = AppPalette.of(context).gold;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        if (!_c.isAnimating) return child!;
        final t = Curves.easeInOut.transform(_c.value);
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.transparent,
              gold.withValues(alpha: 0.85),
              Colors.transparent,
            ],
            stops: [
              (t * 1.6 - 0.5).clamp(0.0, 1.0),
              (t * 1.6 - 0.3).clamp(0.0, 1.0),
              (t * 1.6 - 0.1).clamp(0.0, 1.0),
            ],
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}
