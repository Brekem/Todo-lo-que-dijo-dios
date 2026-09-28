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
  final content = loadContent();
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
      expect(tts.spoken.last, startsWith('Palabra 2 de 71'));
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
      expect(tts.spoken.last, 'Palabra 1 de 71. Adán.');
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
      expect(tts.spoken.last, 'Palabra 1 de 71. Adán.');
    });

    test('saltar a la palabra siguiente y anterior', () async {
      final (c, tts, _) = await setUpContainer();
      final ctrl = c.read(listeningProvider.notifier);
      await ctrl.play();
      await settle();
      await ctrl.nextWord();
      await settle();
      expect(c.read(listeningProvider).passageIndex, 1);
      expect(tts.spoken.last, startsWith('Palabra 2 de 71'));
      await ctrl.previousWord();
      await settle();
      expect(c.read(listeningProvider).passageIndex, 0);
      expect(c.read(listeningProvider).isPlaying, isTrue);
    });
  });
}
