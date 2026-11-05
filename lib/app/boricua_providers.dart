import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/bible.dart';
import '../data/models/bible_user_data.dart';
import '../data/models/boricua_resources.dart';
import '../data/models/passage.dart';
import '../data/repositories/bible_user_repository.dart';
import '../data/sources/bible_source.dart';
import '../domain/assistant/assistant_service.dart';
import '../domain/bible/bible_search.dart';
import '../domain/bible/verse_explainer.dart';
import 'providers.dart';

// ---------------------------------------------------------------------------
// Biblia completa y recursos (sin conexión)
// ---------------------------------------------------------------------------

final bibleSourceProvider = Provider<BibleSource>((ref) => const BibleSource());

final bibleProvider = FutureProvider<Bible>(
  (ref) => ref.watch(bibleSourceProvider).loadBible(),
);

final boricuaResourcesProvider = FutureProvider<BoricuaResources>(
  (ref) => ref.watch(bibleSourceProvider).loadResources(),
);

final bibleIndexProvider = FutureProvider<BibleIndex>(
  (ref) async => BibleIndex.build(await ref.watch(bibleProvider.future)),
);

// ---------------------------------------------------------------------------
// Explicación de versículos y asistente
// ---------------------------------------------------------------------------

final verseExplainerProvider = FutureProvider<VerseExplainer>((ref) async {
  final bible = await ref.watch(bibleProvider.future);
  final studies = await ref.watch(contentProvider.future);
  final own = StudyVerseExplainer(studies, bible);
  if (!ref.watch(firebaseReadyProvider)) return own;
  return AiVerseExplainer(
    fallback: own,
    prefs: ref.watch(sharedPreferencesProvider),
    bible: bible,
  );
});

/// El estudio escrito a mano que incluye un versículo, si lo hay.
final studyForVerseProvider = FutureProvider.family<Passage?, VerseRef>((
  ref,
  verse,
) async {
  final bible = await ref.watch(bibleProvider.future);
  final studies = await ref.watch(contentProvider.future);
  return StudyVerseExplainer(studies, bible).studyFor(verse);
});

final verseExplanationProvider =
    FutureProvider.family<VerseExplanation?, VerseRef>((ref, verse) async {
      final bible = await ref.watch(bibleProvider.future);
      final explainer = await ref.watch(verseExplainerProvider.future);
      return explainer.explain(verse, text: bible.text(verse) ?? '');
    });

final assistantProvider = FutureProvider<AssistantService>((ref) async {
  final resources = await ref.watch(boricuaResourcesProvider.future);
  final offline = OfflineAssistant(resources);
  if (!ref.watch(firebaseReadyProvider)) return offline;
  return AiAssistant(
    fallback: offline,
    bible: await ref.watch(bibleProvider.future),
  );
});

// ---------------------------------------------------------------------------
// Notas, resaltados, marcadores, historial y progreso
// ---------------------------------------------------------------------------

final bibleUserRepositoryProvider = Provider<BibleUserRepository>(
  (ref) => BibleUserRepository(ref.watch(sharedPreferencesProvider)),
);

/// Sincronización en la nube (`null` sin Firebase o en los tests).
final bibleCloudSyncProvider = Provider<BibleCloudSync?>(
  (ref) => ref.watch(firebaseReadyProvider) ? FirestoreBibleSync() : null,
);

class BibleUserNotifier extends Notifier<BibleUserData> {
  Timer? _pushTimer;

  @override
  BibleUserData build() {
    ref.onDispose(() => _pushTimer?.cancel());
    final local = ref.watch(bibleUserRepositoryProvider).load();
    final cloud = ref.watch(bibleCloudSyncProvider);
    if (cloud != null) {
      Future.microtask(() async {
        final remote = await cloud.pull();
        if (remote != null && ref.mounted) _persist(state.merge(remote));
      });
    }
    return local;
  }

  VerseAnnotation? annotation(VerseRef verse) => state.annotations[verse.key];

  void setNote(VerseRef verse, String? note) => _update(
    verse,
    (a) => (note == null || note.trim().isEmpty)
        ? a.copyWith(clearNote: true)
        : a.copyWith(note: note.trim()),
  );

  void setHighlight(VerseRef verse, Highlight? color) => _update(
    verse,
    (a) => color == null
        ? a.copyWith(clearHighlight: true)
        : a.copyWith(highlight: color),
  );

  void toggleBookmark(VerseRef verse) =>
      _update(verse, (a) => a.copyWith(bookmarked: !a.bookmarked));

  void visit(String bookId, int chapter) {
    final now = ChapterVisit(bookId, chapter, DateTime.now());
    ref.read(bibleUserRepositoryProvider).setLastChapter('$bookId.$chapter');
    _persist(
      state.copyWith(
        history: [
          now,
          ...state.history.where(
            (v) => v.bookId != bookId || v.chapter != chapter,
          ),
        ].take(BibleUserData.maxHistory).toList(),
      ),
    );
  }

  void togglePlanDay(String planId, int day) {
    final days = {...?state.plans[planId]};
    days.contains(day) ? days.remove(day) : days.add(day);
    _persist(state.copyWith(plans: {...state.plans, planId: days}));
  }

  void markLesson(String lessonId, {bool done = true}) {
    final lessons = {...state.lessonsDone};
    done ? lessons.add(lessonId) : lessons.remove(lessonId);
    _persist(state.copyWith(lessonsDone: lessons));
  }

  void _update(VerseRef verse, VerseAnnotation Function(VerseAnnotation) f) {
    final current =
        state.annotations[verse.key] ??
        VerseAnnotation(key: verse.key, updatedAt: DateTime.now());
    final next = f(current);
    final all = {...state.annotations};
    next.isEmpty ? all.remove(verse.key) : all[verse.key] = next;
    _persist(state.copyWith(annotations: all));
  }

  void _persist(BibleUserData data) {
    state = data;
    ref.read(bibleUserRepositoryProvider).save(data);
    final cloud = ref.read(bibleCloudSyncProvider);
    if (cloud == null) return;
    // Se agrupan los cambios seguidos en una sola escritura.
    _pushTimer?.cancel();
    _pushTimer = Timer(const Duration(seconds: 3), () => cloud.push(state));
  }
}

final bibleUserProvider = NotifierProvider<BibleUserNotifier, BibleUserData>(
  BibleUserNotifier.new,
);
