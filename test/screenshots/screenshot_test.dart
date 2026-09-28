// Genera capturas de las pantallas principales: flutter test test/screenshots --update-goldens
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_lo_que_dios_dijo/app/app.dart';
import 'package:todo_lo_que_dios_dijo/app/providers.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';

import '../helpers.dart';

class _FakeContent extends ContentNotifier {
  _FakeContent(this.bundle);
  final ContentBundle bundle;
  @override
  Future<ContentBundle> build() async => bundle;
}

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(
        Future.value(
          ByteData.sublistView(File('assets/fonts/$f').readAsBytesSync()),
        ),
      );
    }
    await loader.load();
  }

  await load('Cormorant', [
    'CormorantGaramond-Medium.ttf',
    'CormorantGaramond-MediumItalic.ttf',
    'CormorantGaramond-SemiBold.ttf',
  ]);
  await load('Inter', [
    'Inter-Regular.ttf',
    'Inter-Medium.ttf',
    'Inter-SemiBold.ttf',
  ]);
  final icons = File(
    '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await loader.load();
  }
}

/// Avanza fotograma a fotograma para que las animaciones progresen.
Future<void> settle(WidgetTester tester, [int ms = 2500]) async {
  await tester.pump();
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUpAll(_loadFonts);

  for (final dark in [false, true]) {
    final suffix = dark ? 'oscuro' : 'claro';
    testWidgets('capturas $suffix', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        'theme_mode': dark ? 'dark' : 'light',
      });
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            contentProvider.overrideWith(() => _FakeContent(loadContent())),
          ],
          child: const TodoLoQueDiosDijoApp(),
        ),
      );
      await settle(tester, 4000);
      Future<void> shot(String name) => expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('out/${name}_$suffix.png'),
      );

      await shot('1_bienvenida');
      await tester.tap(find.text('Comenzar recorrido'));
      await settle(tester, 4000);
      await shot('2_inicio');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -520));
      await settle(tester, 3000);
      await shot('3_inicio_tarjetas');

      await tester.tap(find.text('Recorrido'));
      await settle(tester, 3000);
      await shot('4_recorrido');

      await tester.tap(find.text('Abraham').first); // chip de etapa
      await settle(tester, 5000);
      await shot('5_lectura');
      final list = find
          .descendant(
            of: find.byKey(const Key('reading-list')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.tap(find.text('Contexto histórico'));
      await settle(tester, 1000);
      await tester.drag(list, const Offset(0, -560));
      await settle(tester, 3000);
      await shot('6_lectura_tarjetas');
      await tester.drag(list, const Offset(0, -700));
      await settle(tester, 3000);
      await shot('7_lectura_explicacion');
      await tester.drag(list, const Offset(0, -700));
      await settle(tester, 3000);
      await shot('8_lectura_oracion');
    });
  }
}
