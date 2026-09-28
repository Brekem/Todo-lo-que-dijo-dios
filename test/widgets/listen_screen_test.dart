import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_lo_que_dios_dijo/app/app.dart';
import 'package:todo_lo_que_dios_dijo/app/providers.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/listening_controller.dart';
import 'package:todo_lo_que_dios_dijo/shared/widgets/rotating_search_bar.dart';

import '../domain/listening_test.dart' show FakeTts;
import '../helpers.dart';

class _FakeContent extends ContentNotifier {
  _FakeContent(this.bundle);
  final ContentBundle bundle;
  @override
  Future<ContentBundle> build() async => bundle;
}

Future<void> settle(WidgetTester tester, [int seconds = 2]) async {
  await tester.pump();
  await tester.pump(Duration(seconds: seconds));
}

final total = loadContent().passages.length;

void main() {
  testWidgets(
    'escuchar: te quedaste en…, continuar, mini reproductor y comenzar de nuevo',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2220);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({
        'listen_passage': 11,
        'listen_section': 4,
      });
      final prefs = await SharedPreferences.getInstance();
      final tts = FakeTts();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            contentProvider.overrideWith(() => _FakeContent(loadContent())),
            ttsEngineProvider.overrideWithValue(tts),
          ],
          child: const TodoLoQueDiosDijoApp(),
        ),
      );
      await settle(tester, 3);
      await tester.ensureVisible(find.text('Comenzar recorrido'));
      await tester.tap(find.text('Comenzar recorrido'));
      await settle(tester);

      // Inicio muestra dónde se quedó.
      expect(
        find.text('Te quedaste en la palabra 12 de $total'),
        findsOneWidget,
      );
      await tester.tap(find.text('Escuchar las $total palabras'));
      await settle(tester);

      expect(
        find.text('Te quedaste en la palabra 12 de $total'),
        findsOneWidget,
      );
      expect(find.textContaining('Contexto histórico'), findsWidgets);
      await tester.tap(find.text('Continuar'));
      await settle(tester);
      expect(tts.spoken.single, startsWith('Contexto histórico.'));

      // Al volver, el mini reproductor sigue visible.
      await tester.tap(find.byType(BackButton));
      await settle(tester);
      expect(find.textContaining('Palabra 12 de $total ·'), findsOneWidget);
      await tester.tap(find.byTooltip('Pausar'));
      await settle(tester);
      expect(find.byTooltip('Continuar'), findsOneWidget);

      // Comenzar de nuevo desde la pantalla de escuchar.
      await tester.tap(find.textContaining('Palabra 12 de $total ·'));
      await settle(tester);
      await tester.tap(find.text('Comenzar de nuevo').first);
      await settle(tester);
      expect(tts.spoken.last, 'Palabra 1 de $total. Adán.');
      await tester.scrollUntilVisible(
        find.byIcon(Icons.pause_rounded),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await settle(tester);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Botón de orden aleatorio.
      await tester.tap(find.byTooltip('Escuchar en orden aleatorio'));
      await settle(tester);
      expect(find.text('Orden aleatorio'), findsOneWidget);
      expect(find.textContaining('ALEATORIO · 1 DE $total'), findsOneWidget);
      expect(find.byTooltip('Quitar orden aleatorio'), findsOneWidget);
      await tester.tap(find.byTooltip('Quitar orden aleatorio'));
      await settle(tester);
      expect(
        find.text('Orden cronológico · de Génesis a Apocalipsis'),
        findsOneWidget,
      );

      // Botón de repetir: sin repetir → palabra → solo lo que Dios dijo.
      final repeat = find.byKey(const Key('repeat-button'));
      await tester.ensureVisible(repeat);
      expect(find.text('Sin repetir'), findsOneWidget);
      await tester.tap(repeat);
      await settle(tester);
      expect(find.text('Repetir esta palabra'), findsOneWidget);
      expect(find.textContaining('EN REPETICIÓN'), findsOneWidget);
      await tester.tap(repeat);
      await settle(tester);
      expect(find.text('Repetir solo lo que Dios dijo'), findsOneWidget);
      await tester.tap(repeat);
      await settle(tester);
      expect(find.text('Sin repetir'), findsOneWidget);
      expect(prefs.getString('listen_repeat'), 'off');

      // La voz de Dios: campana y voces del teléfono.
      final voiceButton = find.byKey(const Key('divine-voice-button'));
      await tester.pump(const Duration(seconds: 6)); // se van los avisos
      await tester.ensureVisible(voiceButton);
      await tester.tap(voiceButton);
      await settle(tester);
      expect(find.text('Campana antes de que Dios hable'), findsOneWidget);
      // Abrir la hoja del todo para ver las voces.
      await tester.drag(
        find.text('La voz de Dios').last,
        const Offset(0, -600),
      );
      await settle(tester);
      await tester.tap(find.text('Voz 1 · es-US'));
      await settle(tester);
      expect(tts.divineVoice?.name, 'es-us-x-esd-local');
      await tester.tap(find.text('Campana antes de que Dios hable'));
      await settle(tester);
      expect(prefs.getBool('listen_cue'), isFalse);
    },
  );

  testWidgets('escuchar los resultados de una búsqueda, uno tras otro', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2220);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final tts = FakeTts();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          contentProvider.overrideWith(() => _FakeContent(loadContent())),
          ttsEngineProvider.overrideWithValue(tts),
        ],
        child: const TodoLoQueDiosDijoApp(),
      ),
    );
    await settle(tester, 3);
    await tester.ensureVisible(find.text('Comenzar recorrido'));
    await tester.tap(find.text('Comenzar recorrido'));
    await settle(tester);

    await tester.tap(find.byType(RotatingSearchBar));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'miedo');
    await settle(tester);
    expect(find.textContaining('PALABRAS ENCONTRADAS'), findsOneWidget);
    await tester.tap(find.text('Escuchar todas, una tras otra'));
    await settle(tester);

    expect(find.textContaining('BÚSQUEDA · 1 DE'), findsOneWidget);
    expect(find.textContaining('búsqueda «miedo»'), findsOneWidget);
    expect(tts.spoken.single, startsWith('Palabra '));
    expect(prefs.getString('listen_search'), 'miedo');

    await tester.scrollUntilVisible(
      find.byTooltip('Palabra siguiente'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byTooltip('Palabra siguiente'));
    await settle(tester);
    expect(find.textContaining('BÚSQUEDA · 2 DE'), findsOneWidget);

    // Dejar la búsqueda y volver a todas las palabras.
    await tester.scrollUntilVisible(
      find.text('Escuchar las $total palabras'),
      -200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Escuchar las $total palabras'));
    await settle(tester);
    expect(find.textContaining('BÚSQUEDA'), findsNothing);
    expect(prefs.getString('listen_search'), isNull);
    await tester.scrollUntilVisible(
      find.byIcon(Icons.pause_rounded),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await settle(tester);
  });
}
