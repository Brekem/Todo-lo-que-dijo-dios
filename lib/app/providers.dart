import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/content_bundle.dart';
import '../data/models/passage.dart';
import '../data/models/reading_progress.dart';
import '../data/models/saved_word.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/preferences_repository.dart';
import '../data/sources/local_content_source.dart';
import '../data/sources/remote_content_source.dart';
import '../domain/personalization/ai_personalizer.dart';
import '../domain/personalization/offline_personalizer.dart';
import '../domain/personalization/personalization_service.dart';
import '../domain/search/search_engine.dart';

// ---------------------------------------------------------------------------
// Infraestructura (se sobrescriben en bootstrap / tests)
// ---------------------------------------------------------------------------

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Se sobrescribe en bootstrap()'),
);

/// `true` si Firebase se inicializó correctamente.
final firebaseReadyProvider = Provider<bool>((ref) => false);

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(ref.watch(sharedPreferencesProvider)),
);

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  final firebase = ref.watch(firebaseReadyProvider);
  return ContentRepository(
    local: LocalContentSource(),
    remote: firebase ? RemoteContentSource(FirebaseFirestore.instance) : null,
  );
});

/// Azar para «Palabra al azar» y la escucha aleatoria (fijo en los tests).
final randomProvider = Provider<Random>((ref) => Random());

final personalizationServiceProvider = Provider<PersonalizationService>((ref) {
  const offline = OfflinePersonalizer();
  if (!ref.watch(firebaseReadyProvider)) return offline;
  return AiPersonalizer(fallback: offline);
});

// ---------------------------------------------------------------------------
// Contenido
// ---------------------------------------------------------------------------

class ContentNotifier extends AsyncNotifier<ContentBundle> {
  @override
  Future<ContentBundle> build() async {
    final repo = ref.watch(contentRepositoryProvider);
    final bundle = await repo.load();
    // Sincroniza en segundo plano sin bloquear la lectura offline.
    Future.microtask(() async {
      final updated = await repo.syncFromRemote(bundle.version);
      if (updated != null && ref.mounted) state = AsyncData(updated);
    });
    return bundle;
  }
}

final contentProvider = AsyncNotifierProvider<ContentNotifier, ContentBundle>(
  ContentNotifier.new,
);

final searchEngineProvider = Provider<SearchEngine?>((ref) {
  final content = ref.watch(contentProvider).value;
  return content == null ? null : SearchEngine(content.passages);
});

final passageProvider = Provider.family<Passage?, String>(
  (ref, id) => ref.watch(contentProvider).value?.passageById(id),
);

// ---------------------------------------------------------------------------
// Preferencias
// ---------------------------------------------------------------------------

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(preferencesRepositoryProvider).themeMode;

  void set(ThemeMode mode) {
    state = mode;
    ref.read(preferencesRepositoryProvider).setThemeMode(mode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class TextScaleNotifier extends Notifier<double> {
  @override
  double build() => ref.watch(preferencesRepositoryProvider).textScale;

  void set(double value) {
    state = value;
    ref.read(preferencesRepositoryProvider).setTextScale(value);
  }
}

final textScaleProvider = NotifierProvider<TextScaleNotifier, double>(
  TextScaleNotifier.new,
);

// ---------------------------------------------------------------------------
// Palabras guardadas
// ---------------------------------------------------------------------------

class SavedWordsNotifier extends Notifier<List<SavedWord>> {
  @override
  List<SavedWord> build() =>
      ref.watch(preferencesRepositoryProvider).savedWords;

  bool isSaved(String passageId) => state.any((w) => w.passageId == passageId);

  /// Guarda o actualiza (si llega una personalización nueva).
  void save(String passageId, {Personalization? personalization}) {
    final existing = state.where((w) => w.passageId == passageId).firstOrNull;
    final word = SavedWord(
      passageId: passageId,
      savedAt: DateTime.now(),
      personalization: personalization ?? existing?.personalization,
    );
    _persist([word, ...state.where((w) => w.passageId != passageId)]);
  }

  void remove(String passageId) =>
      _persist(state.where((w) => w.passageId != passageId).toList());

  /// Devuelve `true` si quedó guardada.
  bool toggle(String passageId) {
    if (isSaved(passageId)) {
      remove(passageId);
      return false;
    }
    save(passageId);
    return true;
  }

  void _persist(List<SavedWord> words) {
    state = words;
    ref.read(preferencesRepositoryProvider).setSavedWords(words);
  }
}

final savedWordsProvider =
    NotifierProvider<SavedWordsNotifier, List<SavedWord>>(
      SavedWordsNotifier.new,
    );

final isSavedProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(savedWordsProvider).any((w) => w.passageId == id),
);

// ---------------------------------------------------------------------------
// Progreso / estadísticas espirituales
// ---------------------------------------------------------------------------

class ProgressNotifier extends Notifier<ReadingProgress> {
  @override
  ReadingProgress build() => ref.watch(preferencesRepositoryProvider).progress;

  void markRead(String passageId) {
    final today = ReadingProgress.dayKey(DateTime.now());
    _persist(
      state.copyWith(
        readIds: {...state.readIds, passageId},
        activeDays: {...state.activeDays, today},
        lastReadId: passageId,
      ),
    );
  }

  void markPrayed(String passageId) {
    final today = ReadingProgress.dayKey(DateTime.now());
    _persist(
      state.copyWith(
        prayedIds: {...state.prayedIds, passageId},
        prayersCount: state.prayersCount + 1,
        activeDays: {...state.activeDays, today},
      ),
    );
  }

  void reset() => _persist(const ReadingProgress());

  void _persist(ReadingProgress p) {
    state = p;
    ref.read(preferencesRepositoryProvider).setProgress(p);
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, ReadingProgress>(
  ProgressNotifier.new,
);
