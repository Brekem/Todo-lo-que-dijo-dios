import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_lo_que_dios_dijo/app/app.dart';
import 'package:todo_lo_que_dios_dijo/app/providers.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';

import 'package:todo_lo_que_dios_dijo/shared/widgets/rotating_search_bar.dart';

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

/// El Scrollable de la lista con la clave [key].
Finder scrollOf(String key) => find
    .descendant(of: find.byKey(Key(key)), matching: find.byType(Scrollable))
    .first;

void main() {
  for (final dark in [false, true]) {
    testWidgets('todas las pantallas en móvil pequeño (oscuro: $dark)', (
      tester,
    ) async {
      // 360 × 740 dp con letra grande: el caso más exigente.
      tester.view.physicalSize = const Size(1080, 2220);
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      SharedPreferences.setMockInitialValues({
        'theme_mode': dark ? 'dark' : 'light',
      });
      final prefs = await SharedPreferences.getInstance();
      final content = loadContent();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            contentProvider.overrideWith(() => _FakeContent(content)),
          ],
          child: const TodoLoQueDiosDijoApp(),
        ),
      );
      await settle(tester, 3);

      await tester.ensureVisible(find.text('Comenzar recorrido'));
      await tester.tap(find.text('Comenzar recorrido'));
      await settle(tester);

      // Recorrido (timeline)
      await tester.tap(find.text('Recorrido'));
      await settle(tester);
      expect(find.text('Recorrido de la\nVoz de Dios'), findsOneWidget);
      expect(find.text('Adán'), findsWidgets);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
      await settle(tester);

      // Abrir una palabra desde el timeline, guardarla y orar.
      await tester.tap(find.textContaining('«').first);
      await settle(tester, 3);
      await tester.tap(find.byTooltip('Guardar palabra'));
      await settle(tester);
      await tester.scrollUntilVisible(
        find.text('Amén · hice esta oración'),
        300,
        scrollable: scrollOf('reading-list'),
      );
      await settle(tester, 1);
      await tester.tap(find.text('Amén · hice esta oración'));
      await settle(tester);
      expect(find.text('Amén. Oraste esta palabra.'), findsOneWidget);

      // Personalizar (sin Firebase → modo offline)
      await tester.scrollUntilVisible(
        find.text('Necesito esta palabra para mí'),
        300,
        scrollable: scrollOf('reading-list'),
      );
      await settle(tester, 1);
      await tester.tap(find.text('Necesito esta palabra para mí'));
      await settle(tester);
      await tester.enterText(
        find.byType(TextField),
        'Tengo miedo de perder mi trabajo',
      );
      await settle(tester, 1);
      await tester.scrollUntilVisible(
        find.text('Recibir esta palabra'),
        200,
        scrollable: scrollOf('personalize-list'),
      );
      await tester.tap(find.text('Recibir esta palabra'));
      await settle(tester, 3);
      await tester.scrollUntilVisible(
        find.text('Tu oración'),
        300,
        scrollable: scrollOf('personalize-list'),
      );
      await settle(tester, 1);
      expect(find.text('Tu oración'), findsOneWidget);

      // Volver al shell
      await tester.tap(find.byType(BackButton).last);
      await settle(tester);
      await tester.tap(find.byType(BackButton).last);
      await settle(tester);

      // Guardadas
      await tester.tap(find.text('Guardadas'));
      await settle(tester);
      expect(find.text('Las palabras\nque guardé'), findsOneWidget);
      expect(find.textContaining('1 palabra guardada'), findsOneWidget);

      // Estadísticas
      await tester.tap(find.text('Mi camino'));
      await settle(tester);
      expect(find.text('Palabras leídas'), findsOneWidget);
      expect(find.text('Oraciones realizadas'), findsOneWidget);

      // Búsqueda
      await tester.tap(find.text('Inicio'));
      await settle(tester);
      await tester.tap(find.byType(RotatingSearchBar));
      await settle(tester);
      await tester.tap(find.text('Personaje'));
      await settle(tester, 1);
      await tester.enterText(find.byType(TextField), 'Moisés');
      await settle(tester, 1);
      expect(find.textContaining('PALABRAS ENCONTRADAS'), findsOneWidget);
      await tester.tap(find.byType(BackButton).last);
      await settle(tester);

      // Ajustes
      await tester.tap(find.byTooltip('Ajustes'));
      await settle(tester);
      expect(find.text('Lectura sin conexión'), findsOneWidget);
    });
  }
}
