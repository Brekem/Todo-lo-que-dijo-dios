import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_lo_que_dios_dijo/app/app.dart';
import 'package:todo_lo_que_dios_dijo/shared/widgets/passage_tile.dart';
import 'package:todo_lo_que_dios_dijo/app/providers.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';

import '../helpers.dart';

class _FakeContent extends ContentNotifier {
  _FakeContent(this.bundle);
  final ContentBundle bundle;
  @override
  Future<ContentBundle> build() async => bundle;
}

Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
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
}

/// Un frame para programar la navegación y luego deja correr las animaciones.
Future<void> settle(WidgetTester tester, [int seconds = 2]) async {
  await tester.pump();
  await tester.pump(Duration(seconds: seconds));
}

void main() {
  testWidgets('recorrido: bienvenida → inicio → lectura', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await pumpApp(tester);
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Todo lo que\nDios dijo'), findsOneWidget);
    expect(
      find.text(
        'Explora cada palabra pronunciada por Dios y descubre su significado para tu vida.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Comenzar recorrido'));
    await settle(tester);
    expect(find.text('PALABRA DE HOY'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Dios habla sobre el miedo'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('DIOS HABLA SOBRE…'), findsOneWidget);
    expect(find.text('1 palabra').evaluate().isEmpty, isTrue);

    await tester.tap(find.text('Dios habla sobre el miedo'));
    await settle(tester);
    expect(
      find.textContaining('palabras en orden cronológico'),
      findsOneWidget,
    );

    await tester.tap(find.byType(PassageTile).first);
    await settle(tester, 3);
    expect(find.text('¿A quién habló Dios?'), findsOneWidget);
    expect(find.text('Contexto histórico'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Necesito esta palabra para mí'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Oración de liberación'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
