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
}
