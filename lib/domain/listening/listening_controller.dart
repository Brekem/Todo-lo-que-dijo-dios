import 'dart:math';

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
    this.step = 0,
    this.order,
    this.section = NarrationSection.intro,
    this.rate = 1.0,
    this.hasSavedPosition = false,
  });

  final ListeningStatus status;

  /// Índice (0-based) de la palabra en orden cronológico.
  final int passageIndex;

  /// Posición dentro del orden de escucha. En orden cronológico coincide con
  /// [passageIndex]; en aleatorio cuenta cuántas palabras van escuchadas.
  final int step;

  /// Orden aleatorio de escucha (índices de palabras), o `null` si se escucha
  /// de Génesis a Apocalipsis.
  final List<int>? order;
  final NarrationSection section;
  final double rate;

  /// Hay un punto guardado donde el usuario se quedó.
  final bool hasSavedPosition;

  bool get isPlaying => status == ListeningStatus.playing;
  bool get isActive =>
      status == ListeningStatus.playing || status == ListeningStatus.paused;
  bool get shuffle => order != null;

  /// Ya se avanzó algo desde el principio del recorrido.
  bool get started => step > 0 || section.index > 0;

  ListeningState copyWith({
    ListeningStatus? status,
    int? passageIndex,
    int? step,
    List<int>? Function()? order,
    NarrationSection? section,
    double? rate,
    bool? hasSavedPosition,
  }) => ListeningState(
    status: status ?? this.status,
    passageIndex: passageIndex ?? this.passageIndex,
    step: step ?? this.step,
    order: order != null ? order() : this.order,
    section: section ?? this.section,
    rate: rate ?? this.rate,
    hasSavedPosition: hasSavedPosition ?? this.hasSavedPosition,
  );
}

final ttsEngineProvider = Provider<TtsEngine>((ref) => FlutterTtsEngine());

/// Lee en voz alta todas las palabras, de la primera a la última (o en orden
/// aleatorio), recordando dónde se quedó el usuario.
class ListeningController extends Notifier<ListeningState> {
  int _run = 0;

  @override
  ListeningState build() {
    final prefs = ref.watch(preferencesRepositoryProvider);
    final saved = prefs.listeningPosition;
    ref.onDispose(() => _run++);
    var order = prefs.listeningOrder;
    if (order != null && order.isEmpty) order = null;
    // Sin posición guardada, el recorrido empieza por la primera del orden.
    final passage = saved?.$1 ?? order?.first ?? 0;
    var step = saved == null ? 0 : prefs.listeningStep ?? passage;
    if (order != null) {
      // Si el orden guardado no cuadra con la palabra guardada, se busca.
      if (step < 0 || step >= order.length || order[step] != passage) {
        step = order.indexOf(passage);
        if (step < 0) order = null;
      }
    }
    return ListeningState(
      passageIndex: passage,
      step: order == null ? passage : step,
      order: order,
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
  Random get _random => ref.read(randomProvider);

  /// Continúa desde donde se quedó (o desde el principio si no hay nada guardado).
  Future<void> play() async {
    if (state.isPlaying) return;
    final content = await ref.read(contentProvider.future);
    final total = content.passages.length;
    final order = state.order;
    if (order != null && order.length != total) {
      // El contenido cambió: nuevo orden aleatorio desde la palabra actual.
      _setOrder(
        _shuffled(total, first: state.passageIndex.clamp(0, total - 1)),
      );
    }
    if (state.status == ListeningStatus.finished || state.step >= total) {
      _startOver(total);
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

  /// Vuelve al principio y empieza a leer. En aleatorio, con un orden nuevo.
  Future<void> restart() async {
    await _interrupt();
    final content = await ref.read(contentProvider.future);
    _startOver(content.passages.length);
    await play();
  }

  /// Empieza a leer desde una palabra concreta. En aleatorio, esa palabra
  /// abre un orden nuevo.
  Future<void> playFrom(int passageIndex) async {
    await _interrupt();
    final content = await ref.read(contentProvider.future);
    if (state.shuffle) {
      _setOrder(_shuffled(content.passages.length, first: passageIndex));
      _jump(0);
    } else {
      _jump(passageIndex);
    }
    await play();
  }

  /// Activa o quita el orden aleatorio sin cortar la palabra que se escucha.
  Future<void> toggleShuffle() async {
    final content = await ref.read(contentProvider.future);
    final current = state.passageIndex.clamp(0, content.passages.length - 1);
    if (state.shuffle) {
      _setOrder(null);
      state = state.copyWith(step: current);
    } else {
      _setOrder(_shuffled(content.passages.length, first: current));
      state = state.copyWith(step: 0);
    }
    if (state.status == ListeningStatus.finished) {
      state = state.copyWith(status: ListeningStatus.idle);
    }
    _savePosition();
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
    final target = (state.step + delta).clamp(0, content.passages.length - 1);
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

  void _startOver(int total) {
    if (state.shuffle) {
      _setOrder(_shuffled(total, first: _random.nextInt(total)));
    }
    _jump(0);
  }

  /// Todas las palabras en orden aleatorio, empezando por [first].
  List<int> _shuffled(int total, {required int first}) {
    final rest = [
      for (var i = 0; i < total; i++)
        if (i != first) i,
    ]..shuffle(_random);
    return [first, ...rest];
  }

  void _setOrder(List<int>? order) {
    state = state.copyWith(order: () => order);
    ref.read(preferencesRepositoryProvider).setListeningOrder(order);
  }

  int _passageAt(int step) => state.order?[step] ?? step;

  void _jump(int step) {
    state = state.copyWith(
      step: step,
      passageIndex: _passageAt(step),
      section: NarrationSection.intro,
      status: state.status == ListeningStatus.finished
          ? ListeningStatus.idle
          : state.status,
    );
    _savePosition();
  }

  Future<void> _loop(ContentBundle content) async {
    final run = ++_run;
    final total = content.passages.length;
    await _engine.setRate(state.rate);
    while (run == _run) {
      if (state.step >= total) {
        state = state.copyWith(
          status: ListeningStatus.finished,
          passageIndex: _passageAt(0),
          step: 0,
          section: NarrationSection.intro,
          hasSavedPosition: false,
        );
        ref.read(preferencesRepositoryProvider).clearListeningPosition();
        return;
      }
      final index = state.passageIndex;
      final passage = content.passages[index];
      final segments = Narration.segments(
        passage,
        position: index + 1,
        total: total,
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
      if (next < NarrationSection.values.length) {
        state = state.copyWith(section: NarrationSection.values[next]);
      } else {
        final step = state.step + 1;
        state = state.copyWith(
          step: step,
          passageIndex: step < total ? _passageAt(step) : state.passageIndex,
          section: NarrationSection.intro,
        );
      }
    }
  }

  void _savePosition() {
    state = state.copyWith(hasSavedPosition: true);
    final prefs = ref.read(preferencesRepositoryProvider);
    prefs.setListeningPosition(state.passageIndex, state.section.index);
    prefs.setListeningStep(state.step);
  }
}

final listeningProvider = NotifierProvider<ListeningController, ListeningState>(
  ListeningController.new,
);
