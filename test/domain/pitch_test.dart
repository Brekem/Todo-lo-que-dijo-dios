import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/pitch.dart';

/// Una «voz» sintética: tono [hz] con armónicos, ruido y silencios.
Float64List voice(double hz, int rate, {double seconds = 2}) {
  final random = Random(1);
  final n = (rate * seconds).round();
  final out = Float64List(n);
  for (var i = 0; i < n; i++) {
    final t = i / rate;
    final speaking = (t % 1) < 0.7; // pausas entre frases
    var v = 0.0;
    if (speaking) {
      for (var h = 1; h <= 5; h++) {
        v += sin(2 * pi * hz * h * t) / h;
      }
      v *= 0.3;
    }
    out[i] = v + (random.nextDouble() - 0.5) * 0.01;
  }
  return out;
}

Uint8List wav(Float64List samples, int rate) {
  final data = ByteData(44 + samples.length * 2);
  void tag(int at, String s) {
    for (var i = 0; i < 4; i++) {
      data.setUint8(at + i, s.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, rate, Endian.little);
  data.setUint32(28, rate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  tag(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    data.setInt16(44 + i * 2, (samples[i] * 32767).round(), Endian.little);
  }
  return data.buffer.asUint8List();
}

void main() {
  test('mide el tono de voces graves y agudas', () {
    for (final hz in [95.0, 120.0, 165.0, 210.0, 280.0]) {
      expect(Pitch.medianHz(voice(hz, 16000), 16000), closeTo(hz, hz * 0.02));
    }
  });

  test('sin voz no hay tono', () {
    expect(Pitch.medianHz(Float64List(16000), 16000), isNull);
  });

  test('lee el WAV que genera el lector de voz', () {
    final read = Pitch.readWav(wav(voice(150, 22050), 22050))!;
    expect(read.sampleRate, 22050);
    expect(Pitch.medianHz(read.samples, read.sampleRate), closeTo(150, 3));
    expect(Pitch.readWav(Uint8List(10)), isNull);
  });

  test('el ajuste de tono queda dentro de lo que acepta el teléfono', () {
    expect(Pitch.factor(165, 200), closeTo(0.825, 0.001));
    expect(Pitch.factor(400, 100), 2);
    expect(Pitch.factor(50, 200), 0.5);
  });
}
