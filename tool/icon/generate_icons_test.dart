// Genera los iconos de Android y de Google Play:
//   flutter test tool/icon/generate_icons_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'icon_painter.dart';

Future<void> _render(
  String path,
  int px,
  AppIconPainter painter, {
  bool round = false,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size.square(px.toDouble());
  if (round) {
    canvas.clipPath(Path()..addOval(Offset.zero & size));
  }
  painter.paint(canvas, size);
  final image = await recorder.endRecording().toImage(px, px);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('genera iconos', () async {
    const res = 'android/app/src/main/res';
    const densities = {
      'mdpi': 1.0,
      'hdpi': 1.5,
      'xhdpi': 2.0,
      'xxhdpi': 3.0,
      'xxxhdpi': 4.0,
    };
    for (final e in densities.entries) {
      // Icono clásico (48 dp) para Android < 8.
      await _render(
        '$res/mipmap-${e.key}/ic_launcher.png',
        (48 * e.value).round(),
        const AppIconPainter(),
      );
      await _render(
        '$res/mipmap-${e.key}/ic_launcher_round.png',
        (48 * e.value).round(),
        const AppIconPainter(),
        round: true,
      );
      // Primer plano del icono adaptativo (108 dp, zona segura 66 dp).
      await _render(
        '$res/mipmap-${e.key}/ic_launcher_foreground.png',
        (108 * e.value).round(),
        const AppIconPainter(background: false, scale: 0.62),
      );
    }
    // Icono de alta resolución para la ficha de Google Play.
    await _render('store/icon_512.png', 512, const AppIconPainter());
  });
}
