import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/config/edition.dart';
import '../../data/models/content_bundle.dart';
import '../../data/models/passage.dart';
import 'narration.dart';
import 'pitch.dart';
import 'tts_engine.dart';
import 'voice_sampler.dart';

enum ListeningStatus { idle, playing, paused, finished, error }

/// Repetir una palabra una y otra vez.
enum ListenRepeat {
  /// Sigue con la palabra siguiente.
  off('Sin repetir'),

  /// Repite la palabra completa: cita, explicación, aplicación y oración.
  word('Repetir esta palabra'),

  /// Repite solo lo que Dios dijo y su referencia, para meditarlo o memorizarlo.
  quote('Repetir solo lo que Dios dijo');

  const ListenRepeat(this.label);
  final String label;

  ListenRepeat get next => values[(index + 1) % values.length];
}

@immutable
class ListeningState {
  const ListeningState({
    this.status = ListeningStatus.idle,
    this.passageIndex = 0,
    this.step = 0,
    this.order,
    this.searchQuery,
    this.section = NarrationSection.intro,
    this.rate = 1.0,
    this.hasSavedPosition = false,
    this.repeat = ListenRepeat.off,
    this.repetitions = 0,
    this.godSpeaking = false,
    this.cue = true,
    this.divineVoice,
    this.wordsOnly = false,
    this.speakingText,
    this.narratorVoice,
    this.narratorPitch = 1.02,
    this.divinePitch = 0.72,
    this.voiceHz,
  });

  final ListeningStatus status;

  /// Índice (0-based) de la palabra en orden cronológico.
  final int passageIndex;

  /// Posición dentro del orden de escucha. En orden cronológico coincide con
  /// [passageIndex]; en aleatorio o en una búsqueda cuenta cuántas palabras
  /// van escuchadas.
  final int step;

  /// Orden de escucha (índices de palabras): aleatorio, o los resultados de
  /// una búsqueda. `null` si se escucha de Génesis a Apocalipsis.
  final List<int>? order;

  /// Búsqueda cuyos resultados se escuchan, o `null`.
  final String? searchQuery;
  final NarrationSection section;
  final double rate;

  /// Hay un punto guardado donde el usuario se quedó.
  final bool hasSavedPosition;

  final ListenRepeat repeat;

  /// Cuántas veces se ha repetido ya la palabra actual.
  final int repetitions;

  /// En este momento se oyen las palabras de Dios (no el narrador).
  final bool godSpeaking;

  /// Suena la campana antes de que Dios hable.
  final bool cue;

  /// Voz elegida para Dios; `null` = la del narrador, más grave y pausada.
  final TtsVoice? divineVoice;

  /// Solo se escuchan los versículos (sin contexto, explicación ni oración).
  final bool wordsOnly;

  /// Lo que se está leyendo de los versículos en este momento.
  final String? speakingText;

  /// Voz del narrador; `null` = la voz en español del teléfono.
  final TtsVoice? narratorVoice;

  /// Tono del narrador y de Dios (1 = el natural de cada voz).
  final double narratorPitch;
  final double divinePitch;

  /// Tono (Hz) al que se parecen las voces: el de la voz del usuario si la
  /// grabó, o `null` = el de la voz de referencia de la app.
  final double? voiceHz;

  bool get isPlaying => status == ListeningStatus.playing;
  bool get isActive =>
      status == ListeningStatus.playing || status == ListeningStatus.paused;
  bool get fromSearch => searchQuery != null && order != null;
  bool get shuffle => order != null && searchQuery == null;

  /// Cuántas palabras tiene el recorrido actual ([total] = todas).
  int length(int total) => order?.length ?? total;

  /// Ya se avanzó algo desde el principio del recorrido.
  bool get started => step > 0 || section.index > 0;

  ListeningState copyWith({
    ListeningStatus? status,
    int? passageIndex,
    int? step,
    List<int>? Function()? order,
    String? Function()? searchQuery,
    NarrationSection? section,
    double? rate,
    bool? hasSavedPosition,
    ListenRepeat? repeat,
    int? repetitions,
    bool? godSpeaking,
    bool? cue,
    TtsVoice? Function()? divineVoice,
    bool? wordsOnly,
    String? Function()? speakingText,
    TtsVoice? Function()? narratorVoice,
    double? narratorPitch,
    double? divinePitch,
    double? Function()? voiceHz,
  }) => ListeningState(
    status: status ?? this.status,
    passageIndex: passageIndex ?? this.passageIndex,
    step: step ?? this.step,
    order: order != null ? order() : this.order,
    searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
    section: section ?? this.section,
    rate: rate ?? this.rate,
    hasSavedPosition: hasSavedPosition ?? this.hasSavedPosition,
    repeat: repeat ?? this.repeat,
    repetitions: repetitions ?? this.repetitions,
    godSpeaking: godSpeaking ?? this.godSpeaking,
    cue: cue ?? this.cue,
    divineVoice: divineVoice != null ? divineVoice() : this.divineVoice,
    wordsOnly: wordsOnly ?? this.wordsOnly,
    speakingText: speakingText != null ? speakingText() : this.speakingText,
    narratorVoice: narratorVoice != null ? narratorVoice() : this.narratorVoice,
    narratorPitch: narratorPitch ?? this.narratorPitch,
    divinePitch: divinePitch ?? this.divinePitch,
    voiceHz: voiceHz != null ? voiceHz() : this.voiceHz,
  );
}

final ttsEngineProvider = Provider<TtsEngine>((ref) => FlutterTtsEngine());

/// Micrófono, para que la voz de la app se parezca a la del usuario.
final voiceSamplerProvider = Provider<VoiceSampler>((ref) => MicVoiceSampler());

/// Silencio entre una repetición y la siguiente.
final repeatPauseProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 1500),
);

/// Silencio después de que Dios habla, antes de que vuelva el narrador.
final pauseAfterGodProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 1200),
);

/// Lee en voz alta todas las palabras, de la primera a la última (o en orden
/// aleatorio, o solo las de una búsqueda), recordando dónde se quedó el usuario.
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
      searchQuery: order == null ? null : prefs.listeningSearch,
      section:
          NarrationSection.values[(saved?.$2 ?? 0).clamp(
            0,
            NarrationSection.values.length - 1,
          )],
      rate: prefs.listeningRate,
      hasSavedPosition: saved != null,
      repeat: ListenRepeat.values.firstWhere(
        (m) => m.name == prefs.listeningRepeat,
        orElse: () => ListenRepeat.off,
      ),
      cue: prefs.listeningCue,
      divineVoice: switch (prefs.listeningDivineVoice) {
        (final name, final locale) => TtsVoice(name: name, locale: locale),
        null => null,
      },
      wordsOnly: prefs.listeningWordsOnly,
      narratorVoice: switch (prefs.listeningNarratorVoice) {
        (final name, final locale) => TtsVoice(name: name, locale: locale),
        null => null,
      },
      narratorPitch: prefs.listeningPitch?.$1 ?? 1.02,
      divinePitch: prefs.listeningPitch?.$2 ?? 0.72,
      voiceHz: prefs.listeningVoiceHz,
    );
  }

  bool _defaultVoiceTried = false;

  /// La primera vez: la voz de Dios es la segunda voz en español del
  /// teléfono («Voz 2»), distinta de la del narrador, si el usuario nunca
  /// eligió otra; y todas las voces se ajustan al tono de la voz de
  /// referencia de la app (o al del usuario, si lo grabó).
  Future<void> _ensureDefaultVoice() async {
    if (_defaultVoiceTried) return;
    _defaultVoiceTried = true;
    final prefs = ref.read(preferencesRepositoryProvider);
    if (!prefs.listeningDivineVoiceChosen && state.divineVoice == null) {
      final voices = await _engine.voices();
      if (!ref.mounted) return;
      if (voices.length > 1 && !prefs.listeningDivineVoiceChosen) {
        state = state.copyWith(divineVoice: () => voices[1]);
      }
    }
    if (prefs.listeningPitch == null) {
      await _matchVoice(state.voiceHz ?? Pitch.referenceHz);
    }
  }

  final _naturalHz = <TtsVoice?, double?>{};

  Future<double?> _measure(TtsVoice? voice) async {
    if (_naturalHz.containsKey(voice)) return _naturalHz[voice];
    return _naturalHz[voice] = await _engine.naturalHz(voice);
  }

  /// Elige la voz del teléfono más parecida a [targetHz] para el narrador y
  /// ajusta el tono del narrador y de Dios. Devuelve `false` si no se pudo
  /// medir ninguna voz.
  Future<bool> _matchVoice(double targetHz) async {
    final candidates = <TtsVoice?>[
      null,
      ...(await _engine.voices()).where((v) => v.offline).take(6),
    ];
    TtsVoice? best;
    double? bestHz;
    for (final voice in candidates) {
      final hz = await _measure(voice);
      if (!ref.mounted) return false;
      if (hz == null) continue;
      if (bestHz == null ||
          (log(targetHz / hz)).abs() < (log(targetHz / bestHz)).abs()) {
        best = voice;
        bestHz = hz;
      }
    }
    if (bestHz == null) return false;
    final godHz = await _measure(state.divineVoice ?? best);
    if (!ref.mounted) return false;
    state = state.copyWith(narratorVoice: () => best);
    ref
        .read(preferencesRepositoryProvider)
        .setListeningNarratorVoice(
          best == null ? null : (best.name, best.locale),
        );
    await setPitch(
      narrator: Pitch.factor(targetHz, bestHz),
      divine: godHz == null
          ? state.divinePitch
          : Pitch.factor(targetHz * Pitch.divineRatio, godHz),
    );
    return true;
  }

  /// Tono de las voces (1 = el natural de cada voz).
  Future<void> setPitch({double? narrator, double? divine}) async {
    state = state.copyWith(narratorPitch: narrator, divinePitch: divine);
    ref.read(preferencesRepositoryProvider).setListeningPitch((
      state.narratorPitch,
      state.divinePitch,
    ));
    await _engine.setPitch(
      narrator: state.narratorPitch,
      divine: state.divinePitch,
    );
  }

  /// «Parecida a mi voz»: graba unos segundos, mide el tono del usuario y
  /// ajusta todas las voces a ese tono.
  Future<SampleError?> matchMyVoice({
    Duration length = const Duration(seconds: 10),
    void Function(double progress)? progress,
  }) async {
    await _interrupt();
    final result = await ref
        .read(voiceSamplerProvider)
        .sample(length, progress: progress);
    final hz = result.hz;
    if (!ref.mounted) return SampleError.failed;
    if (hz == null) return result.error ?? SampleError.failed;
    // Dios habla con la misma voz del usuario, más grave.
    state = state.copyWith(voiceHz: () => hz, divineVoice: () => null);
    final prefs = ref.read(preferencesRepositoryProvider);
    prefs.setListeningVoiceHz(hz);
    prefs.setListeningDivineVoice(null);
    await _engine.setDivineVoice(null);
    return await _matchVoice(hz) ? null : SampleError.failed;
  }

  /// Vuelve a la voz de fábrica: parecida a la voz de referencia de la app.
  Future<void> resetVoice() async {
    await _interrupt();
    state = state.copyWith(voiceHz: () => null);
    ref.read(preferencesRepositoryProvider).setListeningVoiceHz(null);
    // De fábrica, Dios vuelve a la «Voz 2» del teléfono.
    final voices = await _engine.voices();
    if (!ref.mounted) return;
    if (voices.length > 1) {
      state = state.copyWith(divineVoice: () => voices[1]);
      ref.read(preferencesRepositoryProvider).setListeningDivineVoice((
        voices[1].name,
        voices[1].locale,
      ));
      await _engine.setDivineVoice(voices[1]);
    }
    await _matchVoice(Pitch.referenceHz);
  }

  /// Voz del narrador (`null` = la del teléfono), con el tono ajustado para
  /// que siga pareciéndose a la voz elegida.
  Future<void> setNarratorVoice(TtsVoice? voice) async {
    state = state.copyWith(narratorVoice: () => voice);
    ref
        .read(preferencesRepositoryProvider)
        .setListeningNarratorVoice(
          voice == null ? null : (voice.name, voice.locale),
        );
    await _engine.setNarratorVoice(voice);
    final hz = await _measure(voice);
    if (hz != null && ref.mounted) {
      await setPitch(
        narrator: Pitch.factor(state.voiceHz ?? Pitch.referenceHz, hz),
      );
    }
  }

  /// Hace oír cómo suena el narrador (pausa lo que se escuchaba).
  Future<void> previewNarrator() async {
    await _interrupt();
    final run = _run;
    await _applyVoices();
    if (run != _run) return;
    await _engine.speak('En el principio creó Dios los cielos y la tierra.');
  }

  Future<void> _applyVoices() async {
    await _engine.setRate(state.rate);
    await _engine.setNarratorVoice(state.narratorVoice);
    await _engine.setDivineVoice(state.divineVoice);
    await _engine.setPitch(
      narrator: state.narratorPitch,
      divine: state.divinePitch,
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
    if (state.fromSearch) {
      // El contenido cambió: la búsqueda guardada ya no sirve.
      if (order!.any((i) => i < 0 || i >= total)) {
        _setOrder(null);
        _jump(state.passageIndex.clamp(0, total - 1));
      }
    } else if (order != null && order.length != total) {
      // El contenido cambió: nuevo orden aleatorio desde la palabra actual.
      _setOrder(
        _shuffled(total, first: state.passageIndex.clamp(0, total - 1)),
      );
    }
    if (state.status == ListeningStatus.finished ||
        state.step >= state.length(total)) {
      _startOver(total);
    }
    state = state.copyWith(status: ListeningStatus.playing);
    _loop(content);
  }

  Future<void> pause() async {
    if (!state.isPlaying) return;
    _run++;
    state = state.copyWith(
      status: ListeningStatus.paused,
      godSpeaking: false,
      speakingText: () => null,
    );
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
  /// abre un orden nuevo; en una búsqueda sigue con los resultados si la
  /// palabra está entre ellos.
  Future<void> playFrom(int passageIndex) async {
    await _interrupt();
    final content = await ref.read(contentProvider.future);
    final inSearch = state.fromSearch ? state.order!.indexOf(passageIndex) : -1;
    if (inSearch >= 0) {
      _jump(inSearch);
    } else if (state.shuffle) {
      _setOrder(_shuffled(content.passages.length, first: passageIndex));
      _jump(0);
    } else {
      if (state.fromSearch) _setOrder(null);
      _jump(passageIndex);
    }
    await play();
  }

  /// Escucha los resultados de una búsqueda, uno tras otro, empezando por
  /// [start] (posición dentro de los resultados).
  Future<void> playSearch(
    String query,
    List<int> passageIndexes, {
    int start = 0,
  }) async {
    if (passageIndexes.isEmpty) return;
    await _interrupt();
    _setOrder(List.of(passageIndexes), searchQuery: query.trim());
    _jump(start.clamp(0, passageIndexes.length - 1));
    await play();
  }

  /// Deja de escuchar la búsqueda y sigue con todas las palabras, desde la
  /// palabra actual.
  void leaveSearch() {
    if (!state.fromSearch) return;
    _setOrder(null);
    state = state.copyWith(step: state.passageIndex);
    _savePosition();
  }

  /// Activa o quita el orden aleatorio sin cortar la palabra que se escucha.
  /// Desde una búsqueda, pasa a todas las palabras mezcladas.
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

  /// Cambia el modo de repetición (sin repetir → palabra → solo la cita)
  /// sin cortar lo que se está escuchando.
  void cycleRepeat() => setRepeat(state.repeat.next);

  void setRepeat(ListenRepeat mode) {
    state = state.copyWith(repeat: mode, repetitions: 0);
    ref.read(preferencesRepositoryProvider).setListeningRepeat(mode.name);
  }

  /// Campana antes de que Dios hable.
  void setCue(bool on) {
    state = state.copyWith(cue: on);
    ref.read(preferencesRepositoryProvider).setListeningCue(on);
  }

  /// Voz para las palabras de Dios (`null` = la del narrador, más grave).
  Future<void> setDivineVoice(TtsVoice? voice) async {
    state = state.copyWith(divineVoice: () => voice);
    ref
        .read(preferencesRepositoryProvider)
        .setListeningDivineVoice(
          voice == null ? null : (voice.name, voice.locale),
        );
    await _engine.setDivineVoice(voice);
    final hz = await _measure(voice ?? state.narratorVoice);
    if (hz != null && ref.mounted) {
      await setPitch(
        divine: Pitch.factor(
          (state.voiceHz ?? Pitch.referenceHz) * Pitch.divineRatio,
          hz,
        ),
      );
    }
  }

  /// Voces en español del teléfono, para elegir la de Dios.
  Future<List<TtsVoice>> availableVoices() async {
    await _ensureDefaultVoice();
    return _engine.voices();
  }

  /// Escuchar solo los versículos, o la palabra completa con su explicación.
  void setWordsOnly(bool on) {
    state = state.copyWith(wordsOnly: on);
    ref.read(preferencesRepositoryProvider).setListeningWordsOnly(on);
  }

  /// Hace oír cómo suena Dios con la voz elegida (pausa lo que se escuchaba).
  Future<void> previewDivine() async {
    await _interrupt();
    final run = _run;
    await _ensureDefaultVoice();
    await _applyVoices();
    if (state.cue) await _engine.playCue();
    if (run != _run) return;
    await _engine.speak(
      'Yo soy ${Edition.current.divineName} tu Dios.',
      style: VoiceStyle.divine,
    );
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
    state = state.copyWith(godSpeaking: false, speakingText: () => null);
    await _engine.stop();
  }

  Future<void> _skip(int delta) async {
    final content = await ref.read(contentProvider.future);
    final last = state.length(content.passages.length) - 1;
    final target = (state.step + delta).clamp(0, last);
    final wasPlaying = state.isPlaying;
    await _interrupt();
    _jump(target);
    if (wasPlaying) await play();
  }

  Future<void> _interrupt() async {
    _run++;
    if (state.isPlaying) state = state.copyWith(status: ListeningStatus.paused);
    state = state.copyWith(godSpeaking: false, speakingText: () => null);
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

  void _setOrder(List<int>? order, {String? searchQuery}) {
    final query = order == null ? null : searchQuery;
    state = state.copyWith(order: () => order, searchQuery: () => query);
    final prefs = ref.read(preferencesRepositoryProvider);
    prefs.setListeningOrder(order);
    prefs.setListeningSearch(query);
  }

  int _passageAt(int step) => state.order?[step] ?? step;

  void _jump(int step) {
    state = state.copyWith(
      step: step,
      passageIndex: _passageAt(step),
      section: NarrationSection.intro,
      repetitions: 0,
      status: state.status == ListeningStatus.finished
          ? ListeningStatus.idle
          : state.status,
    );
    _savePosition();
  }

  Future<void> _loop(ContentBundle content) async {
    final run = ++_run;
    final total = content.passages.length;
    await _ensureDefaultVoice();
    if (run != _run) return;
    await _applyVoices();
    while (run == _run) {
      final length = state.length(total);
      if (state.step >= length) {
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
        if (section == NarrationSection.quote) {
          await _speakQuote(passage, run);
        } else {
          await _engine.speak(segments[section.index]);
        }
      } catch (e) {
        debugPrint('Error de lectura en voz alta: $e');
        if (run == _run) {
          state = state.copyWith(
            status: ListeningStatus.error,
            godSpeaking: false,
            speakingText: () => null,
          );
        }
        return;
      }
      if (run != _run) return; // pausado, saltado o reiniciado
      final next = _nextSection(section);
      if (next != null) {
        state = state.copyWith(section: next);
      } else if (state.repeat != ListenRepeat.off) {
        // Otra vez la misma palabra, tras un breve silencio.
        await Future<void>.delayed(ref.read(repeatPauseProvider));
        if (run != _run) return;
        state = state.copyWith(
          section: NarrationSection.quote,
          repetitions: state.repetitions + 1,
        );
      } else {
        final step = state.step + 1;
        state = state.copyWith(
          step: step,
          passageIndex: step < length ? _passageAt(step) : state.passageIndex,
          section: NarrationSection.intro,
          repetitions: 0,
        );
      }
    }
  }

  /// Los versículos completos: el narrador lee la narración y, cada vez que
  /// Dios habla, suena la campana y Dios habla con su propia voz. Los
  /// versículos siguen sin cortes; al final, un silencio antes de seguir.
  Future<void> _speakQuote(Passage passage, int run) async {
    final lead = Narration.lead(passage);
    // Al repetir, basta la campana: no se vuelve a anunciar.
    if (lead != null &&
        (state.repetitions == 0 || passage.id.startsWith('v-'))) {
      await _engine.speak(lead);
      if (run != _run) return;
    }
    var godSpoke = false;
    for (final part in Narration.readingParts(passage)) {
      if (part.god && state.cue) {
        await _engine.playCue();
        if (run != _run) return;
      }
      state = state.copyWith(
        godSpeaking: part.god,
        speakingText: () => part.text,
      );
      await _engine.speak(
        part.text,
        style: part.god ? VoiceStyle.divine : VoiceStyle.narrator,
      );
      if (run != _run) return;
      godSpoke |= part.god;
    }
    state = state.copyWith(godSpeaking: false, speakingText: () => null);
    if (godSpoke) await Future<void>.delayed(ref.read(pauseAfterGodProvider));
  }

  /// Sección que sigue dentro de la misma palabra, o `null` si ya terminó.
  NarrationSection? _nextSection(NarrationSection section) {
    if (state.repeat == ListenRepeat.quote || state.wordsOnly) {
      // Solo los versículos y su referencia.
      return switch (section) {
        NarrationSection.intro => NarrationSection.quote,
        NarrationSection.quote => NarrationSection.reference,
        _ => null,
      };
    }
    final next = section.index + 1;
    return next < NarrationSection.values.length
        ? NarrationSection.values[next]
        : null;
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
