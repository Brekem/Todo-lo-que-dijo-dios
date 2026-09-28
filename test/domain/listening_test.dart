import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_lo_que_dios_dijo/app/providers.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/listening_controller.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/narration.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/tts_engine.dart';

import '../helpers.dart';

/// Lector falso: cada frase "termina" cuando el test llama a [finish].
class FakeTts implements TtsEngine {
  final spoken = <String>[];
  Completer<void>? _current;

  bool get speaking => _current != null && !_current!.isCompleted;

  @override
  Future<void> speak(String text) {
    spoken.add(text);
    _current = Completer<void>();
    return _current!.future;
  }

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
    ],
  );
  await container.read(contentProvider.future);
  return (container, tts, prefs);
}

Future<void> settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  shuffleTests();
  repeatTests();
  final content = loadContent();
  final total = content.passages.length;
  const sections = NarrationSection.values;

  group('Narration', () {
    test('lee los nueve apartados más la presentación, en orden', () {
      final p = content.passages.first;
      final s = Narration.segments(p, position: 1, total: 71, eraTitle: 'Adán');
      expect(s, hasLength(sections.length));
      expect(s[0], 'Palabra 1 de 71. Adán.');
      expect(s[1], 'Dios dijo: Sea la luz.');
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
        await tts.finish();
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
      await tts.finish(); // presentación
      await tts.finish(); // cita
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
        await tts.finish();
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
        await tts.finish();
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
          await tts.finish();
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

    test('repite solo lo que Dios dijo y su referencia', () async {
      final (c, tts, _) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      ctrl.setRepeat(ListenRepeat.quote);
      await ctrl.playFrom(0);
      await settle();
      for (var i = 0; i < 7; i++) {
        await tts.finish();
        await settle();
      }
      expect(tts.spoken, [
        'Palabra 1 de $total. Adán.',
        for (var i = 0; i < 3; i++) ...[
          'Dios dijo: Sea la luz.',
          'Génesis, capítulo 1, versículo 3.',
        ],
        'Dios dijo: Sea la luz.',
      ]);
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
      await tts.finish(); // presentación
      await tts.finish(); // cita
      ctrl.cycleRepeat(); // solo la cita → sin repetir
      expect(c.read(listeningProvider).repeat, ListenRepeat.off);
      for (var i = NarrationSection.reference.index; i < sections.length; i++) {
        await tts.finish();
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
          await tts.finish();
        }
        s = c.read(listeningProvider);
        expect(s.passageIndex, expected);
        expect(tts.spoken.last, startsWith('Palabra ${expected + 1} de'));
      }
      for (var i = 0; i < sections.length; i++) {
        await tts.finish();
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
