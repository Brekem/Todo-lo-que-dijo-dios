import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_lo_que_dios_dijo/app/app.dart';
import 'package:todo_lo_que_dios_dijo/app/providers.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/listening_controller.dart';

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
    },
  );
}
