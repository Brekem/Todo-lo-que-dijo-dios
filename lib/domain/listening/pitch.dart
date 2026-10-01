import 'dart:math' as math;
import 'dart:typed_data';

/// Mide el tono de una voz (su frecuencia fundamental, en hercios), para que
/// la voz del teléfono se parezca a la de una grabación.
abstract final class Pitch {
  /// Tono de la voz de referencia de la app: la del audio que eligió el
  /// autor (medido en su parte cantada), con el que suena la app de fábrica.
  static const referenceHz = 165.0;

  /// Dios habla más grave que el narrador: esta parte de su tono.
  static const divineRatio = 0.78;

  static const _minHz = 70.0;
  static const _maxHz = 400.0;

  /// Mediana del tono de las partes con voz, o `null` si casi no hay voz.
  /// Algoritmo YIN simplificado.
  static double? medianHz(Float64List samples, int sampleRate) {
    final frame = (sampleRate * 0.05).round();
    final hop = frame ~/ 2;
    final minLag = (sampleRate / _maxHz).floor();
    final maxLag = (sampleRate / _minHz).ceil();
    if (samples.length < frame + maxLag) return null;

    // Solo los trozos con suficiente volumen (no los silencios).
    var loudest = 0.0;
    final energies = <double>[];
    for (var s = 0; s + frame + maxLag <= samples.length; s += hop) {
      var e = 0.0;
      for (var i = s; i < s + frame; i++) {
        e += samples[i] * samples[i];
      }
      e = math.sqrt(e / frame);
      energies.add(e);
      loudest = math.max(loudest, e);
    }
    if (loudest < 1e-4) return null;

    final found = <double>[];
    final diff = Float64List(maxLag + 1);
    for (var f = 0; f < energies.length; f++) {
      if (energies[f] < loudest * 0.12) continue;
      final s = f * hop;
      for (var lag = 1; lag <= maxLag; lag++) {
        var sum = 0.0;
        for (var i = s; i < s + frame; i++) {
          final d = samples[i] - samples[i + lag];
          sum += d * d;
        }
        diff[lag] = sum;
      }
      // Diferencia normalizada acumulada.
      var running = 0.0;
      final cmnd = Float64List(maxLag + 1)..[0] = 1;
      for (var lag = 1; lag <= maxLag; lag++) {
        running += diff[lag];
        cmnd[lag] = running == 0 ? 1 : diff[lag] * lag / running;
      }
      var best = -1;
      for (var lag = minLag; lag < maxLag; lag++) {
        if (cmnd[lag] < 0.15) {
          while (lag + 1 < maxLag && cmnd[lag + 1] < cmnd[lag]) {
            lag++;
          }
          best = lag;
          break;
        }
      }
      if (best < 0) continue;
      // Interpolación parabólica para afinar.
      final a = cmnd[best - 1], b = cmnd[best], c = cmnd[best + 1];
      final den = a - 2 * b + c;
      final lag = den == 0 ? best.toDouble() : best + 0.5 * (a - c) / den;
      found.add(sampleRate / lag);
    }
    // Hacen falta al menos medio segundo de voz.
    if (found.length * hop < sampleRate / 2) return null;
    found.sort();
    return found[found.length ~/ 2];
  }

  /// Muestras de un WAV PCM de 16 bits (mezcla a mono). `null` si no se
  /// entiende el archivo.
  static ({Float64List samples, int sampleRate})? readWav(Uint8List bytes) {
    if (bytes.length < 44) return null;
    final data = ByteData.sublistView(bytes);
    String tag(int at) => String.fromCharCodes(bytes.sublist(at, at + 4));
    if (tag(0) != 'RIFF' || tag(8) != 'WAVE') return null;
    var channels = 1, rate = 0, bits = 16;
    var at = 12;
    while (at + 8 <= bytes.length) {
      final id = tag(at);
      var size = data.getUint32(at + 4, Endian.little);
      final body = at + 8;
      if (id == 'fmt ') {
        channels = data.getUint16(body + 2, Endian.little);
        rate = data.getUint32(body + 4, Endian.little);
        bits = data.getUint16(body + 14, Endian.little);
      } else if (id == 'data') {
        if (bits != 16 || rate == 0 || channels < 1) return null;
        // Algunos lectores dejan el tamaño sin rellenar.
        if (size == 0 || body + size > bytes.length) {
          size = bytes.length - body;
        }
        return (
          samples: pcm16(
            Uint8List.sublistView(bytes, body, body + size),
            channels: channels,
          ),
          sampleRate: rate,
        );
      }
      at = body + size + (size.isOdd ? 1 : 0);
    }
    return null;
  }

  /// PCM de 16 bits little-endian → muestras entre -1 y 1 (mono).
  static Float64List pcm16(Uint8List bytes, {int channels = 1}) {
    final data = ByteData.sublistView(bytes);
    final n = bytes.length ~/ (2 * channels);
    final out = Float64List(n);
    for (var i = 0; i < n; i++) {
      var sum = 0;
      for (var c = 0; c < channels; c++) {
        sum += data.getInt16((i * channels + c) * 2, Endian.little);
      }
      out[i] = sum / channels / 32768;
    }
    return out;
  }

  /// Cuánto hay que subir o bajar una voz de tono [naturalHz] para que suene
  /// en [targetHz] (el lector de Android acepta de 0.5 a 2).
  static double factor(double targetHz, double naturalHz) =>
      (targetHz / naturalHz).clamp(0.5, 2.0).toDouble();
}
