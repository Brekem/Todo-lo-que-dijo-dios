import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_lo_que_dios_dijo/app/providers.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/listening_controller.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/narration.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/pitch.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/tts_engine.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/voice_sampler.dart';

import '../helpers.dart';

/// Lector falso: cada frase "termina" cuando el test llama a [finish].
///
/// El anuncio «Escucha. Habla…» y la campana terminan solos, para que cada
/// apartado siga necesitando un solo [finish].
class FakeTts implements TtsEngine {
  final spoken = <String>[];

  /// Frases dichas con la voz de Dios.
  final divine = <String>[];
  int cues = 0;
  TtsVoice? divineVoice;
  Completer<void>? _current;

  bool get speaking => _current != null && !_current!.isCompleted;

  @override
  Future<void> speak(String text, {VoiceStyle style = VoiceStyle.narrator}) {
    spoken.add(text);
    if (style == VoiceStyle.divine) divine.add(text);
    if (text.startsWith('Escucha. Habla')) return Future.value();
    _current = Completer<void>();
    return _current!.future;
  }

  @override
  Future<void> playCue() async => cues++;

  @override
  Future<List<TtsVoice>> voices() async => const [
    TtsVoice(name: 'es-us-x-esd-local', locale: 'es-US'),
    TtsVoice(name: 'es-us-x-esf-network', locale: 'es-US', offline: false),
  ];

  @override
  Future<void> setDivineVoice(TtsVoice? voice) async => divineVoice = voice;

  Future<void> finish() async {
    _current?.complete();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<void> stop() async {
    if (speaking) _current!.complete();
  }

  @override
  Future<void> setRate(double rate) async {}

  TtsVoice? narratorVoice;
  ({double narrator, double divine})? pitch;

  /// Tono natural de cada voz: la del teléfono es grave (de hombre) y la
  /// «Voz 1» aguda (de mujer); la de internet no se puede medir.
  final naturalHzByName = <String?, double>{
    null: 120,
    'es-us-x-esd-local': 200,
  };

  @override
  Future<void> setNarratorVoice(TtsVoice? voice) async => narratorVoice = voice;

  @override
  Future<void> setPitch({
    required double narrator,
    required double divine,
  }) async => pitch = (narrator: narrator, divine: divine);

  @override
  Future<double?> naturalHz(TtsVoice? voice) async =>
      naturalHzByName[voice?.name];
}

/// Micrófono falso: «oye» siempre la misma voz.
class FakeSampler implements VoiceSampler {
  FakeSampler(this.hz, [this.error]);
  final double? hz;
  final SampleError? error;

  @override
  Future<({double? hz, SampleError? error})> sample(
    Duration length, {
    void Function(double progress)? progress,
  }) async {
    progress?.call(1);
    return (hz: hz, error: error);
  }
}

class _FakeContent extends ContentNotifier {
  _FakeContent(this.bundle);
  final ContentBundle bundle;
  @override
  Future<ContentBundle> build() async => bundle;
}

Future<(ProviderContainer, FakeTts, SharedPreferences)> setUpContainer([
  Map<String, Object> prefsValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  final tts = FakeTts();
  final content = loadContent();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      contentProvider.overrideWith(() => _FakeContent(content)),
      ttsEngineProvider.overrideWithValue(tts),
      repeatPauseProvider.overrideWithValue(Duration.zero),
      pauseAfterGodProvider.overrideWithValue(Duration.zero),
      voiceSamplerProvider.overrideWithValue(FakeSampler(110)),
    ],
  );
  await container.read(contentProvider.future);
  return (container, tts, prefs);
}

Future<void> settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// Termina el apartado que se está leyendo. Los versículos se leen en varios
/// trozos (narrador, Dios, narrador…): se terminan todos.
Future<void> nextSection(ProviderContainer c, FakeTts tts) async {
  ListeningState now() => c.read(listeningProvider);
  final before = now();
  for (var i = 0; i < 100; i++) {
    await tts.finish();
    await settle();
    final s = now();
    if (s.section != before.section ||
        s.step != before.step ||
        s.repetitions != before.repetitions ||
        s.status != before.status ||
        !tts.speaking) {
      return;
    }
  }
}

void voiceTests() {
  final content = loadContent();

  group('La voz de Dios', () {
    test('el versículo completo: narrador, campana y la voz de Dios', () async {
      final (c, tts, _) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.playFrom(0);
      await settle();
      expect(c.read(listeningProvider).godSpeaking, isFalse);
      await tts.finish(); // presentación
      await settle();
      var s = c.read(listeningProvider);
      expect(s.section, NarrationSection.quote);
      // «Y dijo Dios:» lo lee el narrador…
      expect(tts.spoken.last, 'Y dijo Dios:');
      expect(s.godSpeaking, isFalse);
      expect(tts.cues, 0);
      await tts.finish();
      await settle();
      // …suena la campana y Dios habla con su voz…
      s = c.read(listeningProvider);
      expect(s.godSpeaking, isTrue);
      expect(s.speakingText, 'Sea la luz:');
      expect(tts.cues, 1);
      expect(tts.divine, ['Sea la luz:']);
      await tts.finish();
      await settle();
      // …y el narrador termina el versículo.
      expect(tts.spoken.last, 'y fue la luz.');
      expect(c.read(listeningProvider).godSpeaking, isFalse);
      await tts.finish();
      await settle();
      expect(c.read(listeningProvider).section, NarrationSection.reference);
      expect(tts.divine, hasLength(1));
      await ctrl.pause();
      expect(c.read(listeningProvider).godSpeaking, isFalse);
    });

    test('la campana suena cada vez que Dios habla', () async {
      final (c, tts, _) = await setUpContainer();
      // Génesis 15:5: «Mira ahora a los cielos…» y «Así será tu simiente».
      final index = content.passages.indexWhere((p) => p.id == 'gen-15-5');
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.playFrom(index);
      await settle();
      await nextSection(c, tts); // presentación
      await nextSection(c, tts); // versículos
      expect(tts.divine, [
        startsWith('Mira ahora a los cielos'),
        'Así será tu simiente.',
      ]);
      expect(tts.cues, 2);
      await ctrl.pause();
    });

    test('solo la Palabra: sin explicación, y se recuerda', () async {
      final (c, tts, prefs) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      ctrl.setWordsOnly(true);
      expect(prefs.getBool('listen_words_only'), isTrue);
      await ctrl.playFrom(0);
      await settle();
      await nextSection(c, tts); // presentación
      await nextSection(c, tts); // versículos
      expect(c.read(listeningProvider).section, NarrationSection.reference);
      await nextSection(c, tts); // referencia
      expect(c.read(listeningProvider).passageIndex, 1);
      expect(c.read(listeningProvider).section, NarrationSection.intro);
      expect(tts.spoken.where((t) => t.startsWith('Explicación')), isEmpty);
      await ctrl.pause();
      c.dispose();
      final (c2, _, _) = await setUpContainer({'listen_words_only': true});
      expect(c2.read(listeningProvider).wordsOnly, isTrue);
    });

    test('la voz de Dios es la «Voz 2» si no se eligió otra', () async {
      final (c, tts, _) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.playFrom(0);
      await settle();
      final voices = await tts.voices();
      expect(tts.divineVoice, voices[1]);
      expect(c.read(listeningProvider).divineVoice, voices[1]);
      await ctrl.pause();
      c.dispose();
      // Si el usuario eligió la voz automática, se respeta.
      final (c2, tts2, _) = await setUpContainer({
        'listen_divine_voice': 'auto',
      });
      await c2.read(listeningProvider.notifier).playFrom(0);
      await settle();
      expect(tts2.divineVoice, isNull);
      await c2.read(listeningProvider.notifier).pause();
    });

    test('de fábrica, las voces se parecen a la voz de referencia', () async {
      final (c, tts, prefs) = await setUpContainer();
      await c.read(listeningProvider.notifier).playFrom(0);
      await settle();
      final s = c.read(listeningProvider);
      // 165 Hz está más cerca de la «Voz 1» (200 Hz) que de la del teléfono
      // (120 Hz): el narrador usa la Voz 1, un poco más grave.
      expect(s.narratorVoice?.name, 'es-us-x-esd-local');
      expect(tts.narratorVoice?.name, 'es-us-x-esd-local');
      expect(s.narratorPitch, closeTo(Pitch.referenceHz / 200, 0.001));
      expect(tts.pitch?.narrator, closeTo(Pitch.referenceHz / 200, 0.001));
      // La «Voz 2» de Dios necesita internet y no se pudo medir: tono de
      // siempre.
      expect(s.divinePitch, 0.72);
      expect(prefs.getStringList('listen_pitch'), isNotNull);
      expect(tts.spoken.first, startsWith('Palabra 1 de'));
      await c.read(listeningProvider.notifier).pause();
      c.dispose();
      // Ya ajustada, no se vuelve a medir.
      final (c2, tts2, _) = await setUpContainer({
        'listen_pitch': ['0.9', '0.7'],
      });
      tts2.naturalHzByName.clear();
      await c2.read(listeningProvider.notifier).playFrom(0);
      await settle();
      expect(tts2.pitch, (narrator: 0.9, divine: 0.7));
      expect(c2.read(listeningProvider).narratorVoice, isNull);
      await c2.read(listeningProvider.notifier).pause();
    });

    test('«Parecida a mi voz»: graba, mide y ajusta todas las voces', () async {
      final (c, tts, prefs) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.availableVoices(); // de fábrica: Dios con la «Voz 2»
      expect(c.read(listeningProvider).divineVoice, isNotNull);
      expect(await ctrl.matchMyVoice(), isNull);
      final s = c.read(listeningProvider);
      // Dios habla con la voz del usuario (la misma del narrador), más grave.
      expect(s.divineVoice, isNull);
      expect(tts.divineVoice, isNull);
      expect(prefs.getString('listen_divine_voice'), 'auto');
      // 110 Hz: la voz del teléfono (120 Hz) es la más parecida.
      expect(s.voiceHz, 110);
      expect(s.narratorVoice, isNull);
      expect(s.narratorPitch, closeTo(110 / 120, 0.001));
      // Dios: la misma voz, más grave.
      expect(s.divinePitch, closeTo(110 * Pitch.divineRatio / 120, 0.001));
      expect(tts.pitch?.divine, closeTo(110 * Pitch.divineRatio / 120, 0.001));
      expect(prefs.getDouble('listen_voice_hz'), 110);
      // Elegir otra voz para el narrador mantiene el tono del usuario.
      await ctrl.setNarratorVoice(
        const TtsVoice(name: 'es-us-x-esd-local', locale: 'es-US'),
      );
      expect(
        c.read(listeningProvider).narratorPitch,
        closeTo(110 / 200, 0.001),
      );
      expect(prefs.getString('listen_narrator_voice'), contains('esd-local'));
      // El tono también se puede afinar a mano.
      await ctrl.setPitch(narrator: 1.1);
      expect(c.read(listeningProvider).narratorPitch, 1.1);
      expect(tts.pitch?.narrator, 1.1);
      // Y volver a la voz de fábrica (Dios, otra vez con la «Voz 2»).
      await ctrl.resetVoice();
      expect(c.read(listeningProvider).voiceHz, isNull);
      expect(c.read(listeningProvider).divineVoice, (await tts.voices())[1]);
      expect(prefs.getDouble('listen_voice_hz'), isNull);
      expect(
        c.read(listeningProvider).narratorPitch,
        closeTo(Pitch.referenceHz / 200, 0.001),
      );
    });

    test('si no se oye la voz, avisa y no cambia nada', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ttsEngineProvider.overrideWithValue(FakeTts()),
          voiceSamplerProvider.overrideWithValue(
            FakeSampler(null, SampleError.silence),
          ),
        ],
      );
      final ctrl = c.read(listeningProvider.notifier);
      expect(await ctrl.matchMyVoice(), SampleError.silence);
      expect(c.read(listeningProvider).voiceHz, isNull);
      expect(c.read(listeningProvider).narratorPitch, 1.02);
    });

    test('se puede quitar la campana y se recuerda', () async {
      final (c, tts, prefs) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      ctrl.setCue(false);
      expect(prefs.getBool('listen_cue'), isFalse);
      await ctrl.playFrom(0);
      await settle();
      await nextSection(c, tts);
      await nextSection(c, tts);
      expect(tts.cues, 0);
      expect(tts.divine, ['Sea la luz:']);
      await ctrl.pause();
    });

    test('los pasajes sobre «la voz de Yavé» los lee el narrador', () async {
      final (c, tts, _) = await setUpContainer();
      final index = content.passages.indexWhere((p) => p.id.startsWith('v-'));
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.playFrom(index);
      await settle();
      await nextSection(c, tts);
      await settle();
      expect(tts.spoken.last, startsWith('Sobre la voz de Yavé.'));
      expect(tts.divine, isEmpty);
      expect(tts.cues, 0);
      expect(c.read(listeningProvider).godSpeaking, isFalse);
      await ctrl.pause();
    });

    test('elegir la voz de Dios, probarla y recordarla', () async {
      final (c, tts, prefs) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      final voices = await ctrl.availableVoices();
      await ctrl.setDivineVoice(voices.first);
      expect(tts.divineVoice, voices.first);
      expect(prefs.getString('listen_divine_voice'), isNotNull);
      unawaited(ctrl.previewDivine());
      await settle();
      expect(tts.divine.single, 'Yo soy Yavé tu Dios.');
      expect(tts.cues, 1);
      await nextSection(c, tts);
      c.dispose();

      final (c2, _, _) = await setUpContainer({
        'listen_divine_voice': prefs.getString('listen_divine_voice')!,
      });
      expect(c2.read(listeningProvider).divineVoice, voices.first);
      await c2.read(listeningProvider.notifier).setDivineVoice(null);
      expect(c2.read(listeningProvider).divineVoice, isNull);
      expect(prefs.getString('listen_divine_voice'), isNot('auto'));
    });

    test('anuncia quién habla solo si el versículo no lo cuenta', () {
      String? lead(String id) => Narration.lead(content.passageById(id)!);
      expect(lead('gen-1-3'), isNull); // «Y dijo Dios:» ya lo dice
      expect(lead('isa-41-10'), 'Escucha. Habla Yavé.');
      String who(String id) => Narration.speakerName(content.passageById(id)!);
      expect(who('mat-3-17'), 'el Padre');
      expect(who('2co-12-9'), 'el Señor');
    });
  });
}

void main() {
  shuffleTests();
  repeatTests();
  voiceTests();
  final content = loadContent();
  final total = content.passages.length;
  const sections = NarrationSection.values;

  group('Narration', () {
    test('lee los nueve apartados más la presentación, en orden', () {
      final p = content.passages.first;
      final s = Narration.segments(p, position: 1, total: 71, eraTitle: 'Adán');
      expect(s, hasLength(sections.length));
      expect(s[0], 'Palabra 1 de 71. Adán.');
      expect(s[1], 'Y dijo Dios: Sea la luz: y fue la luz.');
      expect(s[2], 'Génesis, capítulo 1, versículo 3.');
      expect(s.last, startsWith('Oración de liberación. Señor,'));
      for (final text in s) {
        expect(text.contains('«'), isFalse);
      }
    });

    test('referencias habladas', () {
      expect(
        Narration.spokenReference('Génesis 12:1-2'),
        'Génesis, capítulo 12, versículos 1 al 2',
      );
      expect(
        Narration.spokenReference('1 Reyes 19:9, 18'),
        'Primero de Reyes, capítulo 19, versículos 9 y 18',
      );
      expect(
        Narration.spokenReference('2 Corintios 12:9'),
        'Segunda de Corintios, capítulo 12, versículo 9',
      );
    });

    test('expande abreviaturas de fechas', () {
      final p = content.passageById('gen-12-1')!;
      final s = Narration.segments(
        p,
        position: 7,
        total: 71,
        eraTitle: 'Abraham',
      );
      expect(
        s[NarrationSection.context.index],
        contains('2000 antes de Cristo'),
      );
    });
  });

  group('ListeningController', () {
    test('lee todo de corrido y pasa a la palabra siguiente', () async {
      final (c, tts, _) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.play();
      await settle();
      for (var i = 0; i < sections.length; i++) {
        expect(c.read(listeningProvider).section, sections[i]);
        await nextSection(c, tts);
      }
      final s = c.read(listeningProvider);
      expect(s.passageIndex, 1);
      expect(s.section, NarrationSection.intro);
      expect(tts.spoken.last, startsWith('Palabra 2 de $total'));
      expect(
        c.read(progressProvider).readIds,
        contains(content.passages[0].id),
      );
    });

    test('guarda dónde se quedó y continúa desde ahí', () async {
      final (c, tts, prefs) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.playFrom(11);
      await settle();
      await nextSection(c, tts); // presentación
      await nextSection(c, tts); // cita
      await ctrl.pause();
      expect(prefs.getInt('listen_passage'), 11);
      expect(prefs.getInt('listen_section'), NarrationSection.reference.index);
      c.dispose();

      // Otra sesión: recuerda la posición.
      final (c2, tts2, _) = await setUpContainer({
        'listen_passage': 11,
        'listen_section': NarrationSection.reference.index,
      });
      final s = c2.read(listeningProvider);
      expect(s.hasSavedPosition, isTrue);
      expect(s.passageIndex, 11);
      await c2.read(listeningProvider.notifier).play();
      await settle();
      expect(
        tts2.spoken.single,
        startsWith(Narration.spokenReference(content.passages[11].reference)),
      );
    });

    test('comenzar de nuevo vuelve a la palabra 1', () async {
      final (c, tts, _) = await setUpContainer({
        'listen_passage': 40,
        'listen_section': 5,
      });
      await c.read(listeningProvider.notifier).restart();
      await settle();
      expect(c.read(listeningProvider).passageIndex, 0);
      expect(tts.spoken.last, 'Palabra 1 de $total. Adán.');
    });

    test('al terminar la última palabra marca el recorrido completo', () async {
      final (c, tts, prefs) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.playFrom(content.passages.length - 1);
      await settle();
      for (var i = 0; i < sections.length; i++) {
        await nextSection(c, tts);
      }
      await settle();
      final s = c.read(listeningProvider);
      expect(s.status, ListeningStatus.finished);
      expect(prefs.getInt('listen_passage'), isNull);
      // Volver a escuchar empieza desde el principio.
      await ctrl.play();
      await settle();
      expect(tts.spoken.last, 'Palabra 1 de $total. Adán.');
    });

    test('saltar a la palabra siguiente y anterior', () async {
      final (c, tts, _) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.play();
      await settle();
      await ctrl.nextWord();
      await settle();
      expect(c.read(listeningProvider).passageIndex, 1);
      expect(tts.spoken.last, startsWith('Palabra 2 de $total'));
      await ctrl.previousWord();
      await settle();
      expect(c.read(listeningProvider).passageIndex, 0);
      expect(c.read(listeningProvider).isPlaying, isTrue);
    });
  });
}

void shuffleTests() {
  final content = loadContent();
  final total = content.passages.length;
  const sections = NarrationSection.values;

  group('Orden aleatorio', () {
    test('mezcla sin cortar la palabra actual y recorre todas', () async {
      final (c, tts, prefs) = await setUpContainer({
        'listen_passage': 5,
        'listen_section': 0,
      });
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.toggleShuffle();
      var s = c.read(listeningProvider);
      expect(s.shuffle, isTrue);
      expect(s.passageIndex, 5);
      expect(s.step, 0);
      expect(s.order!.toSet(), hasLength(total));
      expect(prefs.getString('listen_order'), isNotNull);

      await ctrl.play();
      await settle();
      for (var i = 0; i < sections.length; i++) {
        await nextSection(c, tts);
      }
      s = c.read(listeningProvider);
      expect(s.step, 1);
      expect(s.passageIndex, s.order![1]);
      expect(tts.spoken.last, startsWith('Palabra ${s.order![1] + 1} de'));

      await ctrl.nextWord();
      await settle();
      expect(c.read(listeningProvider).passageIndex, s.order![2]);
    });

    test('recuerda el orden aleatorio entre sesiones', () async {
      final (c, tts, prefs) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.toggleShuffle();
      await ctrl.nextWord();
      await ctrl.nextWord();
      final before = c.read(listeningProvider);
      c.dispose();

      final (c2, _, _) = await setUpContainer({
        'listen_passage': prefs.getInt('listen_passage')!,
        'listen_section': 0,
        'listen_step': prefs.getInt('listen_step')!,
        'listen_order': prefs.getString('listen_order')!,
      });
      final s = c2.read(listeningProvider);
      expect(s.shuffle, isTrue);
      expect(s.step, 2);
      expect(s.passageIndex, before.passageIndex);
      expect(s.order, before.order);
    });

    test('quitar el aleatorio sigue en orden desde la misma palabra', () async {
      final (c, _, prefs) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.toggleShuffle();
      await ctrl.nextWord();
      final index = c.read(listeningProvider).passageIndex;
      await ctrl.toggleShuffle();
      final s = c.read(listeningProvider);
      expect(s.shuffle, isFalse);
      expect(s.passageIndex, index);
      expect(s.step, index);
      expect(prefs.getString('listen_order'), isNull);
    });

    test('comenzar de nuevo en aleatorio crea otro orden', () async {
      final (c, _, _) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.toggleShuffle();
      final first = c.read(listeningProvider).order;
      await ctrl.restart();
      await settle();
      final s = c.read(listeningProvider);
      expect(s.step, 0);
      expect(s.order, isNot(equals(first)));
      expect(s.passageIndex, s.order!.first);
      await ctrl.pause();
    });
  });
}

void repeatTests() {
  final content = loadContent();
  final total = content.passages.length;
  const sections = NarrationSection.values;

  group('Repetir', () {
    test('repite la palabra completa una y otra vez', () async {
      final (c, tts, prefs) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      ctrl.cycleRepeat();
      expect(c.read(listeningProvider).repeat, ListenRepeat.word);
      expect(prefs.getString('listen_repeat'), 'word');
      await ctrl.playFrom(3);
      await settle();
      for (var round = 1; round <= 3; round++) {
        final from = round == 1 ? 0 : 1; // sin presentación al repetir
        for (var i = from; i < sections.length; i++) {
          expect(c.read(listeningProvider).section, sections[i]);
          await nextSection(c, tts);
        }
        await settle();
        final s = c.read(listeningProvider);
        expect(s.passageIndex, 3);
        expect(s.repetitions, round);
        expect(s.section, NarrationSection.quote);
      }
      expect(
        tts.spoken.where((t) => t.startsWith('Palabra 4 de $total')),
        hasLength(1),
      );
      await ctrl.pause();
    });

    test('repite solo los versículos y su referencia', () async {
      final (c, tts, _) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      ctrl.setRepeat(ListenRepeat.quote);
      await ctrl.playFrom(0);
      await settle();
      for (var i = 0; i < 7; i++) {
        await nextSection(c, tts);
      }
      expect(tts.spoken, [
        'Palabra 1 de $total. Adán.',
        for (var i = 0; i < 3; i++) ...[
          'Y dijo Dios:',
          'Sea la luz:',
          'y fue la luz.',
          'Génesis, capítulo 1, versículo 3.',
        ],
        'Y dijo Dios:',
      ]);
      expect(tts.cues, 3); // la campana suena en cada repetición
      expect(tts.divine, List.filled(3, 'Sea la luz:'));
      expect(c.read(listeningProvider).passageIndex, 0);
      await ctrl.pause();
    });

    test('se puede quitar la repetición y seguir con la siguiente', () async {
      final (c, tts, _) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      ctrl.setRepeat(ListenRepeat.quote);
      await ctrl.play();
      await settle();
      await ctrl.nextWord();
      await settle();
      expect(c.read(listeningProvider).passageIndex, 1);
      expect(c.read(listeningProvider).repetitions, 0);
      await nextSection(c, tts); // presentación
      await nextSection(c, tts); // cita
      ctrl.cycleRepeat(); // solo la cita → sin repetir
      expect(c.read(listeningProvider).repeat, ListenRepeat.off);
      for (var i = NarrationSection.reference.index; i < sections.length; i++) {
        await nextSection(c, tts);
      }
      await settle();
      expect(c.read(listeningProvider).passageIndex, 2);
      await ctrl.pause();
    });

    test('recuerda el modo de repetición', () async {
      final (c, _, _) = await setUpContainer({'listen_repeat': 'quote'});
      expect(c.read(listeningProvider).repeat, ListenRepeat.quote);
    });
  });

  group('Escuchar una búsqueda', () {
    test('sigue con las palabras siguientes de la búsqueda', () async {
      final (c, tts, prefs) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      const results = [40, 7, 300];
      await ctrl.playSearch('miedo', results);
      await settle();
      var s = c.read(listeningProvider);
      expect(s.fromSearch, isTrue);
      expect(s.shuffle, isFalse);
      expect(s.searchQuery, 'miedo');
      expect(s.passageIndex, 40);
      expect(prefs.getString('listen_search'), 'miedo');
      for (final expected in [7, 300]) {
        for (var i = 0; i < sections.length; i++) {
          await nextSection(c, tts);
        }
        s = c.read(listeningProvider);
        expect(s.passageIndex, expected);
        expect(tts.spoken.last, startsWith('Palabra ${expected + 1} de'));
      }
      for (var i = 0; i < sections.length; i++) {
        await nextSection(c, tts);
      }
      await settle();
      s = c.read(listeningProvider);
      expect(s.status, ListeningStatus.finished);
      expect(s.passageIndex, 40);
    });

    test('empieza desde un resultado y salta dentro de la búsqueda', () async {
      final (c, _, _) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.playSearch('fe', [5, 9, 12, 20], start: 2);
      await settle();
      expect(c.read(listeningProvider).passageIndex, 12);
      await ctrl.nextWord();
      expect(c.read(listeningProvider).passageIndex, 20);
      await ctrl.nextWord(); // ya es la última
      expect(c.read(listeningProvider).passageIndex, 20);
      await ctrl.previousWord();
      expect(c.read(listeningProvider).passageIndex, 12);
      // «Escuchar desde aquí» de una palabra de la búsqueda sigue en ella.
      await ctrl.playFrom(9);
      expect(c.read(listeningProvider).step, 1);
      expect(c.read(listeningProvider).fromSearch, isTrue);
      await ctrl.pause();
    });

    test('recuerda la búsqueda entre sesiones y se puede dejar', () async {
      final (c, _, prefs) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.playSearch('luz', [3, 1, 8]);
      await ctrl.nextWord();
      await ctrl.pause();
      c.dispose();

      final (c2, _, prefs2) = await setUpContainer({
        'listen_passage': prefs.getInt('listen_passage')!,
        'listen_section': 0,
        'listen_step': prefs.getInt('listen_step')!,
        'listen_order': prefs.getString('listen_order')!,
        'listen_search': prefs.getString('listen_search')!,
      });
      var s = c2.read(listeningProvider);
      expect(s.fromSearch, isTrue);
      expect(s.searchQuery, 'luz');
      expect(s.step, 1);
      expect(s.passageIndex, 1);

      c2.read(listeningProvider.notifier).leaveSearch();
      s = c2.read(listeningProvider);
      expect(s.fromSearch, isFalse);
      expect(s.order, isNull);
      expect(s.step, 1);
      expect(prefs2.getString('listen_search'), isNull);
      expect(prefs2.getString('listen_order'), isNull);
    });
  });
}
