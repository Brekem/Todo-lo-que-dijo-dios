import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import 'pitch.dart';

/// Por qué no se pudo medir la voz del usuario.
enum SampleError { permission, silence, failed }

/// Graba unos segundos del micrófono para medir el tono de la voz.
abstract interface class VoiceSampler {
  /// Graba [length] y devuelve el tono de la voz en hercios. [progress]
  /// recibe de 0 a 1 mientras graba.
  Future<({double? hz, SampleError? error})> sample(
    Duration length, {
    void Function(double progress)? progress,
  });
}

class MicVoiceSampler implements VoiceSampler {
  static const _rate = 16000;

  @override
  Future<({double? hz, SampleError? error})> sample(
    Duration length, {
    void Function(double progress)? progress,
  }) async {
    final recorder = AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        return (hz: null, error: SampleError.permission);
      }
      final stream = await recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _rate,
          numChannels: 1,
        ),
      );
      final bytes = BytesBuilder(copy: false);
      final sub = stream.listen(bytes.add);
      final steps = length.inMilliseconds ~/ 100;
      for (var i = 1; i <= steps; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        progress?.call(i / steps);
      }
      await recorder.stop();
      await sub.cancel();
      final hz = Pitch.medianHz(Pitch.pcm16(bytes.takeBytes()), _rate);
      return hz == null
          ? (hz: null, error: SampleError.silence)
          : (hz: hz, error: null);
    } catch (e) {
      debugPrint('No se pudo grabar la voz: $e');
      return (hz: null, error: SampleError.failed);
    } finally {
      await recorder.dispose();
    }
  }
}
