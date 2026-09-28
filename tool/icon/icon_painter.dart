import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Icono de la app: libro abierto dorado del que brota luz, sobre azul profundo.
class AppIconPainter extends CustomPainter {
  const AppIconPainter({this.background = true, this.scale = 1});

  /// `false` para el primer plano del icono adaptativo (fondo transparente).
  final bool background;

  /// Escala del dibujo respecto al lienzo (el icono adaptativo usa ~0.62).
  final double scale;

  static const blue = Color(0xFF1F2E52);
  static const blueDeep = Color(0xFF121B33);
  static const gold = Color(0xFFD9B865);
  static const goldDeep = Color(0xFFB8964E);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    if (background) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(0, -0.2),
            radius: 0.9,
            colors: [Color(0xFF2B3D69), blue, blueDeep],
            stops: [0, 0.55, 1],
          ).createShader(Offset.zero & size),
      );
    }
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(scale);
    canvas.translate(-c.dx, -c.dy);

    // Resplandor
    canvas.drawCircle(
      Offset(s / 2, s * 0.44),
      s * 0.28,
      Paint()
        ..shader =
            RadialGradient(
              colors: [gold.withValues(alpha: 0.45), gold.withValues(alpha: 0)],
            ).createShader(
              Rect.fromCircle(
                center: Offset(s / 2, s * 0.44),
                radius: s * 0.28,
              ),
            ),
    );

    // Rayos
    final ray = Paint()
      ..color = gold
      ..strokeWidth = s * 0.018
      ..strokeCap = StrokeCap.round;
    for (var i = -3; i <= 3; i++) {
      final a = -math.pi / 2 + i * 0.32;
      final r1 = s * 0.16, r2 = s * (i == 0 ? 0.3 : 0.26);
      final o = Offset(s / 2, s * 0.52);
      canvas.drawLine(
        o + Offset(math.cos(a), math.sin(a)) * r1,
        o + Offset(math.cos(a), math.sin(a)) * r2,
        ray,
      );
    }

    // Libro abierto
    final page = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gold, goldDeep],
      ).createShader(Rect.fromLTWH(0, s * 0.5, s, s * 0.25));
    Path leaf(bool right) {
      final d = right ? 1 : -1;
      final cx = s / 2;
      return Path()
        ..moveTo(cx, s * 0.58)
        ..quadraticBezierTo(
          cx + d * s * 0.12,
          s * 0.52,
          cx + d * s * 0.27,
          s * 0.56,
        )
        ..lineTo(cx + d * s * 0.27, s * 0.74)
        ..quadraticBezierTo(cx + d * s * 0.12, s * 0.70, cx, s * 0.76)
        ..close();
    }

    canvas.drawPath(leaf(false), page);
    canvas.drawPath(leaf(true), page);
    // Lomo
    canvas.drawLine(
      Offset(s / 2, s * 0.58),
      Offset(s / 2, s * 0.76),
      Paint()
        ..color = blueDeep.withValues(alpha: 0.6)
        ..strokeWidth = s * 0.01,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(AppIconPainter old) => false;
}
