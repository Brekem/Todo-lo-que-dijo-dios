import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Abstracción del lector de voz (permite probar sin dispositivo).
abstract interface class TtsEngine {
  /// Completa cuando termina de leer [text] (o cuando se detiene).
  Future<void> speak(String text);
  Future<void> stop();

  /// 1.0 = velocidad normal.
  Future<void> setRate(double rate);
}

/// Voz del sistema Android (funciona sin conexión si hay voz en español).
class FlutterTtsEngine implements TtsEngine {
  final FlutterTts _tts = FlutterTts();
  Future<void>? _ready;

  Future<void> _init() async {
    await _tts.awaitSpeakCompletion(true);
    for (final lang in const ['es-US', 'es-MX', 'es-ES', 'es']) {
      try {
        if (await _tts.isLanguageAvailable(lang) == true) {
          await _tts.setLanguage(lang);
          break;
        }
      } catch (e) {
        debugPrint('Idioma $lang no disponible: $e');
      }
    }
    await _tts.setPitch(0.95);
    await setRate(1);
  }

  @override
  Future<void> speak(String text) async {
    await (_ready ??= _init());
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<void> setRate(double rate) async {
    // En Android 0.5 es la velocidad natural.
    await _tts.setSpeechRate((0.5 * rate).clamp(0.2, 1.0));
  }
}
