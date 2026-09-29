import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Quién habla: el narrador de la app, o Dios.
enum VoiceStyle {
  /// Presentación, contexto, explicación, oración…
  narrator,

  /// Lo que Dios dijo: voz más grave, pausada y solemne.
  divine,
}

/// Una voz del teléfono.
@immutable
class TtsVoice {
  const TtsVoice({
    required this.name,
    required this.locale,
    this.offline = true,
  });

  final String name;
  final String locale;

  /// Funciona sin conexión.
  final bool offline;

  @override
  bool operator ==(Object other) =>
      other is TtsVoice && other.name == name && other.locale == locale;

  @override
  int get hashCode => Object.hash(name, locale);
}

/// Abstracción del lector de voz (permite probar sin dispositivo).
abstract interface class TtsEngine {
  /// Completa cuando termina de leer [text] (o cuando se detiene).
  Future<void> speak(String text, {VoiceStyle style = VoiceStyle.narrator});
  Future<void> stop();

  /// 1.0 = velocidad normal.
  Future<void> setRate(double rate);

  /// Suena la señal de que Dios va a hablar. Completa cuando termina.
  Future<void> playCue();

  /// Voces en español instaladas en el teléfono.
  Future<List<TtsVoice>> voices();

  /// Voz para las palabras de Dios; `null` = la misma del narrador, más grave.
  Future<void> setDivineVoice(TtsVoice? voice);
}

/// Voz del sistema Android (funciona sin conexión si hay voz en español).
class FlutterTtsEngine implements TtsEngine {
  final FlutterTts _tts = FlutterTts();
  AudioPlayer? _player;
  Future<void>? _ready;
  String? _language;
  double _rate = 1;
  TtsVoice? _divineVoice;
  VoiceStyle? _current;

  /// Dios habla más grave y un poco más despacio que el narrador.
  static const _divinePitch = 0.72;
  static const _divineSlowdown = 0.82;
  static const _narratorPitch = 1.02;

  Future<void> _init() async {
    await _tts.awaitSpeakCompletion(true);
    for (final lang in const ['es-US', 'es-MX', 'es-ES', 'es']) {
      try {
        if (await _tts.isLanguageAvailable(lang) == true) {
          await _tts.setLanguage(lang);
          _language = lang;
          break;
        }
      } catch (e) {
        debugPrint('Idioma $lang no disponible: $e');
      }
    }
    await _tts.setVolume(1);
    await _apply(VoiceStyle.narrator);
  }

  Future<void> _apply(VoiceStyle style) async {
    final divine = style == VoiceStyle.divine;
    // Cambiar de voz solo cuando hace falta.
    if (_divineVoice != null && _current != style) {
      if (divine) {
        await _tts.setVoice({
          'name': _divineVoice!.name,
          'locale': _divineVoice!.locale,
        });
      } else if (_language != null) {
        await _tts.setLanguage(_language!); // vuelve a la voz del idioma
      }
    }
    await _tts.setPitch(divine ? _divinePitch : _narratorPitch);
    // En Android 0.5 es la velocidad natural.
    await _tts.setSpeechRate(
      (0.5 * _rate * (divine ? _divineSlowdown : 1)).clamp(0.2, 1.0),
    );
    _current = style;
  }

  @override
  Future<void> speak(
    String text, {
    VoiceStyle style = VoiceStyle.narrator,
  }) async {
    await (_ready ??= _init());
    await _apply(style);
    final run = _stops;
    // Android no lee textos de más de 4000 caracteres de una vez.
    for (final chunk in chunks(text)) {
      if (run != _stops) return;
      await _tts.speak(chunk);
    }
  }

  /// Parte un texto largo en trozos que el lector acepte, cortando al final
  /// de una frase (nunca a mitad de palabra).
  static List<String> chunks(String text, {int max = 3000}) {
    final out = <String>[];
    var rest = text.trim();
    while (rest.length > max) {
      var cut = -1;
      for (final mark in ['. ', '; ', ': ', ', ', ' ']) {
        cut = rest.lastIndexOf(mark, max);
        if (cut > max ~/ 2) break;
      }
      if (cut <= 0) cut = max;
      out.add(rest.substring(0, cut + 1).trim());
      rest = rest.substring(cut + 1).trim();
    }
    if (rest.isNotEmpty) out.add(rest);
    return out;
  }

  int _stops = 0;

  @override
  Future<void> stop() async {
    _stops++;
    await _player?.stop();
    await _tts.stop();
  }

  @override
  Future<void> setRate(double rate) async {
    _rate = rate;
    if (_ready != null) await _apply(_current ?? VoiceStyle.narrator);
  }

  @override
  Future<void> playCue() async {
    final player = _player ??= AudioPlayer();
    try {
      final done = player.onPlayerComplete.first;
      await player.play(AssetSource('audio/voz_de_dios.wav'), volume: 0.9);
      await done.timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('No se pudo reproducir la señal: $e');
    }
  }

  @override
  Future<List<TtsVoice>> voices() async {
    await (_ready ??= _init());
    final raw = await _tts.getVoices;
    if (raw is! List) return const [];
    final voices = <TtsVoice>[];
    for (final v in raw) {
      if (v is! Map) continue;
      final name = v['name']?.toString();
      final locale = v['locale']?.toString();
      if (name == null || locale == null) continue;
      if (!locale.toLowerCase().startsWith('es')) continue;
      voices.add(
        TtsVoice(
          name: name,
          locale: locale,
          offline: v['network_required']?.toString() != '1',
        ),
      );
    }
    voices.sort((a, b) {
      final byLocale = a.locale.compareTo(b.locale);
      return byLocale != 0 ? byLocale : a.name.compareTo(b.name);
    });
    return voices;
  }

  @override
  Future<void> setDivineVoice(TtsVoice? voice) async {
    final hadVoice = _divineVoice != null;
    _divineVoice = voice;
    // Si se quitó la voz propia de Dios, volver a la del idioma.
    if (hadVoice && voice == null && _language != null && _ready != null) {
      await _tts.setLanguage(_language!);
    }
    _current = null;
  }
}
