import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reading_progress.dart';
import '../models/saved_word.dart';

/// Palabras guardadas, tema, tamaño de letra y progreso, en el dispositivo.
class PreferencesRepository {
  PreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _savedKey = 'saved_words_v1';
  static const _themeModeKey = 'theme_mode';
  static const _textScaleKey = 'text_scale';
  static const _progressKey = 'reading_progress_v1';
  static const _listenPassageKey = 'listen_passage';
  static const _listenSectionKey = 'listen_section';
  static const _listenRateKey = 'listen_rate';
  static const _listenStepKey = 'listen_step';
  static const _listenOrderKey = 'listen_order';
  static const _listenRepeatKey = 'listen_repeat';
  static const _listenSearchKey = 'listen_search';
  static const _listenCueKey = 'listen_cue';
  static const _listenDivineVoiceKey = 'listen_divine_voice';
  static const _listenWordsOnlyKey = 'listen_words_only';

  List<SavedWord> get savedWords {
    final raw = _prefs.getString(_savedKey);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => SavedWord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> setSavedWords(List<SavedWord> words) => _prefs.setString(
    _savedKey,
    jsonEncode([for (final w in words) w.toJson()]),
  );

  ThemeMode get themeMode => ThemeMode.values.firstWhere(
    (m) => m.name == _prefs.getString(_themeModeKey),
    orElse: () => ThemeMode.system,
  );
  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);

  double get textScale => _prefs.getDouble(_textScaleKey) ?? 1.0;
  Future<void> setTextScale(double value) =>
      _prefs.setDouble(_textScaleKey, value);

  ReadingProgress get progress {
    final raw = _prefs.getString(_progressKey);
    if (raw == null) return const ReadingProgress();
    try {
      return ReadingProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const ReadingProgress();
    }
  }

  Future<void> setProgress(ReadingProgress progress) =>
      _prefs.setString(_progressKey, jsonEncode(progress.toJson()));

  /// Dónde se quedó la lectura en voz alta: (índice de palabra, sección).
  (int, int)? get listeningPosition {
    final passage = _prefs.getInt(_listenPassageKey);
    if (passage == null) return null;
    return (passage, _prefs.getInt(_listenSectionKey) ?? 0);
  }

  Future<void> setListeningPosition(int passage, int section) async {
    await _prefs.setInt(_listenPassageKey, passage);
    await _prefs.setInt(_listenSectionKey, section);
  }

  Future<void> clearListeningPosition() async {
    await _prefs.remove(_listenPassageKey);
    await _prefs.remove(_listenSectionKey);
    await _prefs.remove(_listenStepKey);
  }

  /// Posición dentro del orden de escucha (en aleatorio no coincide con la
  /// palabra).
  int? get listeningStep => _prefs.getInt(_listenStepKey);
  Future<void> setListeningStep(int step) =>
      _prefs.setInt(_listenStepKey, step);

  /// Orden aleatorio de escucha; `null` si se escucha en orden cronológico.
  List<int>? get listeningOrder {
    final raw = _prefs.getString(_listenOrderKey);
    if (raw == null || raw.isEmpty) return null;
    final order = <int>[];
    for (final part in raw.split(',')) {
      final value = int.tryParse(part);
      if (value == null) return null;
      order.add(value);
    }
    return order;
  }

  Future<void> setListeningOrder(List<int>? order) => order == null
      ? _prefs.remove(_listenOrderKey)
      : _prefs.setString(_listenOrderKey, order.join(','));

  double get listeningRate => _prefs.getDouble(_listenRateKey) ?? 1.0;
  Future<void> setListeningRate(double rate) =>
      _prefs.setDouble(_listenRateKey, rate);

  /// Modo de repetición guardado (nombre del enum), o `null` si no hay.
  String? get listeningRepeat => _prefs.getString(_listenRepeatKey);
  Future<void> setListeningRepeat(String mode) =>
      _prefs.setString(_listenRepeatKey, mode);

  /// Búsqueda cuyos resultados se están escuchando (el orden va en
  /// [listeningOrder]), o `null`.
  String? get listeningSearch => _prefs.getString(_listenSearchKey);
  Future<void> setListeningSearch(String? query) => query == null
      ? _prefs.remove(_listenSearchKey)
      : _prefs.setString(_listenSearchKey, query);

  /// Campana antes de que Dios hable (activada si no se ha tocado).
  bool get listeningCue => _prefs.getBool(_listenCueKey) ?? true;
  Future<void> setListeningCue(bool on) => _prefs.setBool(_listenCueKey, on);

  /// El usuario ya eligió la voz de Dios (aunque sea la automática).
  bool get listeningDivineVoiceChosen =>
      _prefs.containsKey(_listenDivineVoiceKey);

  /// Voz elegida para Dios: (nombre, idioma), o `null` = automática.
  (String, String)? get listeningDivineVoice {
    final raw = _prefs.getString(_listenDivineVoiceKey);
    final parts = raw?.split('\t');
    if (parts == null || parts.length != 2) return null;
    return (parts[0], parts[1]);
  }

  Future<void> setListeningDivineVoice((String, String)? voice) =>
      _prefs.setString(
        _listenDivineVoiceKey,
        voice == null ? 'auto' : '${voice.$1}\t${voice.$2}',
      );

  /// Escuchar solo lo que Dios dijo, sin contexto, explicación ni oración.
  bool get listeningWordsOnly => _prefs.getBool(_listenWordsOnlyKey) ?? false;
  Future<void> setListeningWordsOnly(bool on) =>
      _prefs.setBool(_listenWordsOnlyKey, on);
}
