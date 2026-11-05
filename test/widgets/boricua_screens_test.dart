import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_lo_que_dios_dijo/app/boricua_providers.dart';
import 'package:todo_lo_que_dios_dijo/app/providers.dart';
import 'package:todo_lo_que_dios_dijo/core/theme/app_theme.dart';
import 'package:todo_lo_que_dios_dijo/data/models/bible.dart';
import 'package:todo_lo_que_dios_dijo/data/models/bible_user_data.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';
import 'package:todo_lo_que_dios_dijo/features/assistant/assistant_screen.dart';
import 'package:todo_lo_que_dios_dijo/features/bible/bible_screen.dart';
import 'package:todo_lo_que_dios_dijo/features/bible/chapter_screen.dart';
import 'package:todo_lo_que_dios_dijo/features/school/school_screen.dart';

import '../data/boricua_edition_test.dart';

class _Studies extends ContentNotifier {
  _Studies(this.bundle);
  final ContentBundle bundle;
  @override
  Future<ContentBundle> build() async => bundle;
}

void main() {
  final bible = loadBible();
  final studies = loadBoricua();
  final resources = loadResources();

  Future<ProviderContainer> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1080, 2220);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          contentProvider.overrideWith(() => _Studies(studies)),
          bibleProvider.overrideWith((ref) async => bible),
          boricuaResourcesProvider.overrideWith((ref) async => resources),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: screen),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return ProviderScope.containerOf(tester.element(find.byWidget(screen)));
  }

  testWidgets('la Biblia: libros del Antiguo y del Nuevo Testamento', (
    tester,
  ) async {
    await pump(tester, const BibleScreen());
    expect(find.byKey(const Key('book-gen')), findsOneWidget);
    await tester.tap(find.text('Nuevo'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('book-mat')), findsOneWidget);
    expect(find.byKey(const Key('book-gen')), findsNothing);
  });

  testWidgets('un versículo: texto, paráfrasis boricua, resaltado y nota', (
    tester,
  ) async {
    final container = await pump(
      tester,
      const ChapterScreen(bookId: 'jua', chapter: 3, verse: 16),
    );
    expect(find.text('Juan 3'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('verse-16')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const Key('verse-16')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('verse-16')));
    await tester.pumpAndSettle();
    expect(find.text('TEXTO BÍBLICO'), findsOneWidget);
    expect(find.byKey(const Key('paraphrase')), findsOneWidget);
    expect(find.textContaining('Dios amó tanto al mundo'), findsOneWidget);

    await tester.tap(find.byKey(const Key('highlight-yellow')));
    await tester.tap(find.byKey(const Key('bookmark')));
    await tester.pump();
    final a = container.read(bibleUserProvider).annotations['jua.3.16']!;
    expect(a.highlight, Highlight.yellow);
    expect(a.bookmarked, isTrue);

    await tester.tap(find.byKey(const Key('note')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-field')), 'Dios me ama');
    await tester.tap(find.byKey(const Key('note-save')));
    await tester.pumpAndSettle();
    expect(
      container.read(bibleUserProvider).annotations['jua.3.16']!.note,
      'Dios me ama',
    );
    expect(container.read(bibleUserProvider).history.first.chapter, 3);
  });

  testWidgets('un versículo sin estudio lo dice con claridad', (tester) async {
    await pump(tester, const ChapterScreen(bookId: 'gen', chapter: 2));
    await tester.tap(find.byKey(const Key('verse-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('no-explanation')), findsOneWidget);
  });

  testWidgets('Escuela Bíblica: niveles y una lección', (tester) async {
    await pump(tester, const SchoolScreen());
    expect(find.textContaining('Nivel 1: Conociendo a Dios'), findsOneWidget);
    final container = await pump(tester, const LessonScreen(lessonId: 'n1-1'));
    expect(find.text('Dios existe y se da a conocer'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('lesson-done')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('lesson-done')));
    await tester.pump();
    expect(container.read(bibleUserProvider).lessonsDone, contains('n1-1'));
  });

  testWidgets('el asistente contesta con pasaje, explicación y oración', (
    tester,
  ) async {
    await pump(tester, const AssistantScreen());
    await tester.enterText(
      find.byKey(const Key('assistant-field')),
      'Tengo mucha ansiedad y no puedo dormir',
    );
    await tester.tap(find.byKey(const Key('assistant-send')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('assistant-passage')), findsOneWidget);
    expect(find.textContaining('Por nada estéis afanosos'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('2. EXPLICACIÓN SENCILLA'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Filipenses 4:6-7'), findsOneWidget);
  });

  test('las citas de los estudios existen en la Biblia', () {
    for (final p in studies.passages) {
      expect(bible.parse(p.reference), isNotNull, reason: p.reference);
      expect(const VerseRef('jua', 3, 16).key, 'jua.3.16');
    }
  });
}
