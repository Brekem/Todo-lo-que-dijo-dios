import 'package:flutter/material.dart';

/// Icono de manos orando dibujado a mano (Material Icons no lo incluye).
class PrayingHandsIcon extends StatelessWidget {
  const PrayingHandsIcon({super.key, this.size = 28, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Manos orando',
    child: CustomPaint(
      size: Size.square(size),
      painter: _HandsPainter(
        color ?? IconTheme.of(context).color ?? Colors.black,
      ),
    ),
  );
}

class _HandsPainter extends CustomPainter {
  _HandsPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Mano derecha (se refleja para la izquierda).
    Path hand() => Path()
      ..moveTo(12 * s, 3 * s)
      ..cubicTo(13.2 * s, 3 * s, 13.6 * s, 4.2 * s, 13.8 * s, 5.4 * s)
      ..lineTo(15.2 * s, 12.2 * s)
      ..cubicTo(15.6 * s, 13.8 * s, 16.8 * s, 14.8 * s, 18.4 * s, 15.6 * s)
      ..lineTo(20 * s, 16.6 * s)
      ..lineTo(17.4 * s, 21 * s)
      ..lineTo(14.2 * s, 19.4 * s)
      ..cubicTo(12.8 * s, 18.7 * s, 12 * s, 17.4 * s, 12 * s, 15.8 * s);

    canvas.drawPath(hand(), stroke);
    canvas.save();
    canvas.translate(24 * s, 0);
    canvas.scale(-1, 1);
    canvas.drawPath(hand(), stroke);
    canvas.restore();
    // Línea central donde se unen las palmas.
    canvas.drawLine(Offset(12 * s, 3 * s), Offset(12 * s, 15.8 * s), stroke);
    // Pequeño resplandor.
    final glow = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 1.2 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(12 * s, 0.4 * s), Offset(12 * s, 1.2 * s), glow);
    canvas.drawLine(Offset(8.6 * s, 1.6 * s), Offset(9.2 * s, 2.2 * s), glow);
    canvas.drawLine(Offset(15.4 * s, 1.6 * s), Offset(14.8 * s, 2.2 * s), glow);
  }

  @override
  bool shouldRepaint(_HandsPainter old) => old.color != color;
}
