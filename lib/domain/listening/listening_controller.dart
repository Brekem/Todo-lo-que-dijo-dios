import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/models/content_bundle.dart';
import 'narration.dart';
import 'tts_engine.dart';

enum ListeningStatus { idle, playing, paused, finished, error }

@immutable
class ListeningState {
  const ListeningState({
    this.status = ListeningStatus.idle,
    this.passageIndex = 0,
    this.section = NarrationSection.intro,
    this.rate = 1.0,
    this.hasSavedPosition = false,
  });

  final ListeningStatus status;

  /// Índice (0-based) de la palabra en orden cronológico.
  final int passageIndex;
  final NarrationSection section;
  final double rate;

  /// Hay un punto guardado donde el usuario se quedó.
  final bool hasSavedPosition;

  bool get isPlaying => status == ListeningStatus.playing;
  bool get isActive =>
      status == ListeningStatus.playing || status == ListeningStatus.paused;

  ListeningState copyWith({
    ListeningStatus? status,
    int? passageIndex,
    NarrationSection? section,
    double? rate,
    bool? hasSavedPosition,
  }) => ListeningState(
    status: status ?? this.status,
    passageIndex: passageIndex ?? this.passageIndex,
    section: section ?? this.section,
    rate: rate ?? this.rate,
    hasSavedPosition: hasSavedPosition ?? this.hasSavedPosition,
  );
}

final ttsEngineProvider = Provider<TtsEngine>((ref) => FlutterTtsEngine());

/// Lee en voz alta todas las palabras, de la primera a la última,
/// recordando dónde se quedó el usuario.
class ListeningController extends Notifier<ListeningState> {
  int _run = 0;

  @override
  ListeningState build() {
    final prefs = ref.watch(preferencesRepositoryProvider);
    final saved = prefs.listeningPosition;
    ref.onDispose(() => _run++);
    return ListeningState(
      passageIndex: saved?.$1 ?? 0,
      section:
          NarrationSection.values[(saved?.$2 ?? 0).clamp(
            0,
            NarrationSection.values.length - 1,
          )],
      rate: prefs.listeningRate,
      hasSavedPosition: saved != null,
    );
  }

  TtsEngine get _engine => ref.read(ttsEngineProvider);

  /// Continúa desde donde se quedó (o desde el principio si no hay nada guardado).
  Future<void> play() async {
    if (state.isPlaying) return;
    final content = await ref.read(contentProvider.future);
    if (state.status == ListeningStatus.finished ||
        state.passageIndex >= content.passages.length) {
      _jump(0);
    }
    state = state.copyWith(status: ListeningStatus.playing);
    _loop(content);
  }

  Future<void> pause() async {
    if (!state.isPlaying) return;
    _run++;
    state = state.copyWith(status: ListeningStatus.paused);
    await _engine.stop();
  }

  Future<void> toggle() => state.isPlaying ? pause() : play();

  /// Vuelve a la palabra 1 y empieza a leer.
  Future<void> restart() async {
    await _interrupt();
    _jump(0);
    await play();
  }

  /// Empieza a leer desde una palabra concreta.
  Future<void> playFrom(int passageIndex) async {
    await _interrupt();
    _jump(passageIndex);
    await play();
  }

  Future<void> nextWord() => _skip(1);
  Future<void> previousWord() => _skip(-1);

  Future<void> setRate(double rate) async {
    state = state.copyWith(rate: rate);
    ref.read(preferencesRepositoryProvider).setListeningRate(rate);
    await _engine.setRate(rate);
  }

  /// Detiene la lectura sin perder la posición.
  Future<void> stop() async {
    _run++;
    if (state.isActive) state = state.copyWith(status: ListeningStatus.paused);
    await _engine.stop();
  }

  Future<void> _skip(int delta) async {
    final content = await ref.read(contentProvider.future);
    final target = (state.passageIndex + delta).clamp(
      0,
      content.passages.length - 1,
    );
    final wasPlaying = state.isPlaying;
    await _interrupt();
    _jump(target);
    if (wasPlaying) await play();
  }

  Future<void> _interrupt() async {
    _run++;
    if (state.isPlaying) state = state.copyWith(status: ListeningStatus.paused);
    await _engine.stop();
  }

  void _jump(int passageIndex) {
    state = state.copyWith(
      passageIndex: passageIndex,
      section: NarrationSection.intro,
      status: state.status == ListeningStatus.finished
          ? ListeningStatus.idle
          : state.status,
    );
    _savePosition();
  }

  Future<void> _loop(ContentBundle content) async {
    final run = ++_run;
    await _engine.setRate(state.rate);
    while (run == _run) {
      final index = state.passageIndex;
      if (index >= content.passages.length) {
        state = state.copyWith(
          status: ListeningStatus.finished,
          passageIndex: 0,
          section: NarrationSection.intro,
          hasSavedPosition: false,
        );
        ref.read(preferencesRepositoryProvider).clearListeningPosition();
        return;
      }
      final passage = content.passages[index];
      final segments = Narration.segments(
        passage,
        position: index + 1,
        total: content.passages.length,
        eraTitle: content.eraById(passage.era)?.title ?? '',
      );
      final section = state.section;
      if (section == NarrationSection.intro) {
        ref.read(progressProvider.notifier).markRead(passage.id);
      }
      _savePosition();
      try {
        await _engine.speak(segments[section.index]);
      } catch (e) {
        debugPrint('Error de lectura en voz alta: $e');
        if (run == _run) state = state.copyWith(status: ListeningStatus.error);
        return;
      }
      if (run != _run) return; // pausado, saltado o reiniciado
      final next = section.index + 1;
      state = next < NarrationSection.values.length
          ? state.copyWith(section: NarrationSection.values[next])
          : state.copyWith(
              passageIndex: index + 1,
              section: NarrationSection.intro,
            );
    }
  }

  void _savePosition() {
    state = state.copyWith(hasSavedPosition: true);
    ref
        .read(preferencesRepositoryProvider)
        .setListeningPosition(state.passageIndex, state.section.index);
  }
}

final listeningProvider = NotifierProvider<ListeningController, ListeningState>(
  ListeningController.new,
);
