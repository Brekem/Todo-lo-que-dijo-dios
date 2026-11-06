import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_lo_que_dios_dijo/core/config/edition.dart';
import 'package:todo_lo_que_dios_dijo/core/theme/app_palette.dart';
import 'package:todo_lo_que_dios_dijo/data/models/bible.dart';
import 'package:todo_lo_que_dios_dijo/data/models/bible_user_data.dart';
import 'package:todo_lo_que_dios_dijo/data/models/boricua_resources.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';
import 'package:todo_lo_que_dios_dijo/domain/assistant/assistant_service.dart';
import 'package:todo_lo_que_dios_dijo/domain/bible/bible_search.dart';
import 'package:todo_lo_que_dios_dijo/domain/bible/glossary_linker.dart';
import 'package:todo_lo_que_dios_dijo/domain/bible/verse_explainer.dart';

Map<String, dynamic> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Bible loadBible() => Bible.fromJson(_json('assets/data/biblia_rv1909.json'));
ContentBundle loadBoricua() =>
    ContentBundle.fromJson(_json(Edition.boricua.contentAsset));
BoricuaResources loadResources() =>
    BoricuaResources.fromJson(_json('assets/data/boricua_recursos.json'));

/// Palabras que la Biblia Boricua no usa fuera del texto bíblico.
final archaic = RegExp(
  r'\b(he aquí|vosotros|empero|acaec\w*|hallarse|mas)\b',
  caseSensitive: false,
);

void main() {
  final bible = loadBible();
  final studies = loadBoricua();
  final resources = loadResources();

  group('Biblia completa', () {
    test('los 66 libros y los 31,102 versículos', () {
      expect(bible.books, hasLength(66));
      expect(bible.testament(Testament.oldTestament), hasLength(39));
      expect(bible.testament(Testament.newTestament), hasLength(27));
      final verses = bible.books.fold<int>(
        0,
        (n, b) => n + b.chapters.fold<int>(0, (m, c) => m + c.length),
      );
      expect(verses, 31102);
      expect(bible.books.first.name, 'Génesis');
      expect(bible.books.last.name, 'Apocalipsis');
      expect(bible.book('sal')!.chapterCount, 150);
    });

    test('tras el título del salmo, la oración empieza con mayúscula', () {
      expect(
        bible.text(const VerseRef('sal', 46, 1)),
        endsWith(
          'Salmo sobre Alamoth. Dios es nuestro amparo y fortaleza, '
          'nuestro pronto auxilio en las tribulaciones.',
        ),
      );
      expect(
        bible.text(const VerseRef('sal', 13, 1)),
        contains('David. ¿Hasta cuándo'),
      );
    });

    test('RV1909 con el nombre «Jehová»', () {
      expect(
        bible.text(const VerseRef('jua', 3, 16)),
        startsWith('Porque de tal manera amó Dios al mundo'),
      );
      final raw = File('assets/data/biblia_rv1909.json').readAsStringSync();
      expect(raw.contains('Yavé'), isFalse);
      expect(raw.contains('Jehová'), isTrue);
    });

    test('entiende citas', () {
      final p = bible.parse('1 Corintios 13:4-7')!;
      expect((p.book.id, p.chapter, p.from, p.to), ('1co', 13, 4, 7));
      expect(bible.parse('Libro 1:1'), isNull);
      expect(bible.parse('Juan 99:1'), isNull);
    });

    test('búsqueda por palabras y por cita', () async {
      final index = await BibleIndex.build(bible);
      expect(index.length, 31102);
      final hits = index.search('no temas que yo soy contigo');
      expect(hits.map((h) => bible.reference(h.ref)), contains('Isaías 41:10'));
      final nt = index.search('amor', testament: Testament.newTestament);
      expect(nt, isNotEmpty);
      expect(
        nt.every(
          (h) => bible.book(h.ref.bookId)!.testament == Testament.newTestament,
        ),
        isTrue,
      );
      expect(index.reference('jn 3:16')?.book.name, 'Juan');
      expect(index.reference('Salmos 23')?.verse, isNull);
      expect(index.reference('sal 23')?.chapter, 23);
      expect(index.reference('Juan 3:99'), isNull);
    });
  });

  group('Estudios en español boricua', () {
    test(
      'cada estudio tiene paráfrasis de cada versículo y las seis partes',
      () {
        expect(studies.passages.length, greaterThanOrEqualTo(1640));
        int count(String book) =>
            studies.passages.where((p) => p.book == book).length;
        expect(count('Salmos'), greaterThanOrEqualTo(35));
        expect(count('Proverbios'), greaterThanOrEqualTo(15));
        expect(count('Hechos'), greaterThanOrEqualTo(10));
        // Compendio: 40 o más estudios por libro.
        for (final book in ['Génesis', 'Éxodo', 'Levítico', 'Números', 'Deuteronomio', 'Josué', 'Jueces', 'Rut', '1 Samuel', '2 Samuel', '1 Reyes', '2 Reyes', '1 Crónicas', '2 Crónicas', 'Esdras', 'Nehemías', 'Ester', 'Job', 'Salmos', 'Proverbios', 'Eclesiastés', 'Cantar de los Cantares', 'Isaías', 'Jeremías', 'Lamentaciones', 'Ezequiel', 'Daniel', 'Oseas', 'Joel', 'Amós', 'Abdías', 'Jonás', 'Miqueas', 'Nahúm', 'Habacuc', 'Sofonías', 'Hageo', 'Zacarías', 'Malaquías', 'Mateo']) {
          // Los libros cortos (menos de 40 estudios posibles) se cubren
          // completos: cada versículo tiene su estudio.
          final total = bible
              .bookByName(book)!
              .chapters
              .fold<int>(
                0,
                (n, c) => n + c.where((t) => t.trim().isNotEmpty).length,
              );
          final covered = <String>{
            for (final p in studies.passages.where((p) => p.book == book))
              for (
                var v = bible.parse(p.reference)!.from;
                v <= bible.parse(p.reference)!.to;
                v++
              )
                '${bible.parse(p.reference)!.chapter}.$v',
          };
          expect(
            count(book) >= 40 || covered.length == total,
            isTrue,
            reason:
                '$book: ${count(book)} estudios, '
                '${covered.length} de $total versículos',
          );
        }
        expect(
          studies.passages
              .where((p) => p.era == 'iglesia' && p.book != 'Hechos')
              .length,
          greaterThanOrEqualTo(45),
        );
        expect(
          studies.passages.where((p) => p.era == 'evangelios').length,
          greaterThanOrEqualTo(50),
        );
        // Cada versículo está, como mucho, en un estudio.
        final seen = <String>{};
        for (final p in studies.passages) {
          final r = bible.parse(p.reference)!;
          for (var v = r.from; v <= r.to; v++) {
            expect(
              seen.add('${r.book.id}.${r.chapter}.$v'),
              isTrue,
              reason: p.id,
            );
          }
        }
        expect(studies.passages.first.book, 'Génesis');
        expect(studies.passages.last.book, 'Apocalipsis');
        for (final p in studies.passages) {
          final study = p.study!;
          final r = bible.parse(p.reference)!;
          expect(study.paraphrase.keys, [
            for (var v = r.from; v <= r.to; v++) v,
          ], reason: p.id);
          expect(
            p.verses.map((v) => v.number),
            study.paraphrase.keys,
            reason: p.id,
          );
          for (final t in [
            p.situation,
            p.explanation,
            study.aboutGod,
            study.aboutHumans,
            study.aboutChrist,
            p.application,
          ]) {
            expect(t.length, greaterThan(40), reason: p.id);
          }
          expect(p.prayer.trim(), endsWith('Amén.'), reason: p.id);
        }
      },
    );

    test('sin palabras antiguas fuera del texto bíblico', () {
      for (final p in studies.passages) {
        final s = p.study!;
        for (final t in [
          ...s.paraphrase.values,
          p.situation,
          p.explanation,
          s.aboutGod,
          s.aboutHumans,
          s.aboutChrist,
          p.application,
          p.prayer,
        ]) {
          expect(archaic.hasMatch(t), isFalse, reason: '${p.id}: $t');
        }
      }
      for (final l in resources.school.expand((l) => l.lessons)) {
        for (final t in [l.explanation, l.reflection, l.example, l.prayer]) {
          expect(archaic.hasMatch(t), isFalse, reason: l.id);
        }
      }
    });

    test('en los evangelios solo Jesús habla con su voz', () {
      final peter = studies.passageById('b-jua-21-15')!;
      final v15 = peter.verses.first.parts;
      expect(
        v15.where((p) => p.god).map((p) => p.text),
        contains(startsWith('Simón, hijo de Jonás')),
      );
      expect(
        v15.where((p) => !p.god).map((p) => p.text).join(' '),
        contains('Sí, Señor: tú sabes que te amo'),
      );
      final woman = studies.passageById('b-mar-5-25')!;
      expect(
        woman.verses.firstWhere((v) => v.number == 31).parts.single.god,
        isFalse,
      );
      expect(woman.verses.last.parts.last.text, startsWith('Hija, tu fe'));
      final saul = studies.passageById('b-hch-9-3')!;
      final v6 = saul.verses.last.parts;
      expect(v6.first.god, isFalse);
      expect(v6.first.text, contains('¿qué quieres que haga?'));
      expect(v6.last.god, isTrue);
      expect(v6.last.text, startsWith('Levántate'));
    });

    test(
      'lo que dice Adán y lo que cuenta el narrador no van con la voz de Dios',
      () {
        final eden = studies.passageById('b-gen-3-8')!;
        final god = eden.verses
            .expand((v) => v.parts)
            .where((p) => p.god)
            .map((p) => p.text);
        expect(god, ['¿Dónde estás tú?']);
        final cain = studies.passageById('b-gen-4-9')!.verses.first.parts;
        expect(cain.map((p) => p.god), [false, true, false]);
        expect(cain[1].text, '¿Dónde está Abel tu hermano?');
        final image = studies.passageById('b-gen-1-26')!;
        expect(
          image.verses.firstWhere((v) => v.number == 27).parts.single.god,
          isFalse,
        );
      },
    );

    test(
      'el versículo de un estudio se explica con lo escrito a mano',
      () async {
        final explainer = StudyVerseExplainer(studies, bible);
        final x = await explainer.explain(
          const VerseRef('jua', 3, 16),
          text: '',
        );
        expect(x!.source, ExplanationSource.study);
        expect(x.paraphrase, startsWith('Dios amó tanto al mundo'));
        expect(x.study!.reference, 'Juan 3:16-17');
        expect(
          await explainer.explain(const VerseRef('gen', 2, 1), text: ''),
          isNull,
        );
      },
    );
  });

  group('Escuela, glosario y asistente', () {
    test('siete niveles con lecturas que existen en la Biblia', () {
      expect(resources.school.map((l) => l.title), [
        'Conociendo a Dios',
        'Conociendo a Jesucristo',
        'La Salvación',
        'El Espíritu Santo',
        'Cómo Vivir Como Cristiano',
        'Madurez Espiritual',
        'Cómo Ayudar a Otros a Crecer',
      ]);
      for (final level in resources.school) {
        expect(level.lessons.length, greaterThanOrEqualTo(3));
        for (final l in level.lessons) {
          for (final r in l.readings) {
            expect(bible.parse(r), isNotNull, reason: '${l.id}: $r');
          }
          expect(l.prayer, endsWith('Amén.'));
        }
      }
      expect(resources.lesson('n3-2')!.title, contains('gracia'));
    });

    test('teología simple: los términos se explican automáticamente', () {
      final byTerm = {for (final g in resources.glossary) g.term: g};
      expect(
        byTerm['Justificación']!.short,
        'Dios te declara inocente por medio de Jesucristo, aunque hayas pecado.',
      );
      expect(
        byTerm['Gracia']!.short,
        'El favor inmerecido de Dios hacia nosotros.',
      );
      expect(
        byTerm.keys,
        containsAll(['Santificación', 'Redención', 'Trinidad']),
      );
      List<String> found(String text) => GlossaryLinker.termsIn(
        text,
        resources.glossary,
      ).map((g) => g.term).toList();
      expect(
        found('Fuimos justificados por la fe'),
        containsAll(['Justificación', 'Fe']),
      );
      expect(found('Le dimos gracias a Dios'), isNot(contains('Gracia')));
      expect(
        found('Salvados por gracia'),
        containsAll(['Gracia', 'Salvación']),
      );
    });

    test('el asistente contesta con las cinco partes', () async {
      final assistant = OfflineAssistant(resources);
      final r = await assistant.ask('¿Cómo hago para perdonar a mi papá?');
      expect(r.reference, 'Colosenses 3:13');
      expect(r.text, isNotEmpty);
      expect(r.prayer, endsWith('Amén.'));
      expect(r.nextStep, isNotEmpty);
      for (final a in resources.assistant) {
        final p = bible.parse(a.reference);
        expect(p, isNotNull, reason: a.reference);
        expect(a.text, startsWith(p!.book.chapter(p.chapter)[p.from - 1]));
      }
    });

    test('ante una crisis, siempre las líneas de ayuda', () async {
      final r = await OfflineAssistant(resources).ask('ya no quiero vivir');
      expect(r.help, contains('988'));
      expect(r.help, contains('1-800-981-0023'));
    });

    test('sin respuesta escrita, invita a seguir buscando', () async {
      final r = await OfflineAssistant(resources).ask('xyz qwerty');
      expect(r.reference, 'Jeremías 33:3');
    });
  });

  group('Datos personales', () {
    test('se unen los de dos teléfonos: gana el cambio más reciente', () {
      final old = DateTime(2026, 1, 1);
      final newer = DateTime(2026, 2, 1);
      final a = BibleUserData(
        annotations: {
          'jua.3.16': VerseAnnotation(
            key: 'jua.3.16',
            note: 'vieja',
            updatedAt: old,
          ),
        },
        plans: const {
          'juan21': {0},
        },
        lessonsDone: const {'n1-1'},
      );
      final b = BibleUserData(
        annotations: {
          'jua.3.16': VerseAnnotation(
            key: 'jua.3.16',
            note: 'nueva',
            updatedAt: newer,
          ),
          'sal.23.1': VerseAnnotation(
            key: 'sal.23.1',
            bookmarked: true,
            updatedAt: old,
          ),
        },
        plans: const {
          'juan21': {1},
        },
        lessonsDone: const {'n1-2'},
      );
      final m = a.merge(b);
      expect(m.annotations['jua.3.16']!.note, 'nueva');
      expect(m.annotations['sal.23.1']!.bookmarked, isTrue);
      expect(m.plans['juan21'], {0, 1});
      expect(m.lessonsDone, {'n1-1', 'n1-2'});
      final round = BibleUserData.fromJson(
        jsonDecode(jsonEncode(m.toJson())) as Map<String, dynamic>,
      );
      expect(round.annotations.keys, m.annotations.keys);
      expect(round.plans, m.plans);
    });
  });

  test('la Biblia Boricua tiene los colores de la bandera', () {
    expect(Edition.boricua.appName, 'Biblia Boricua');
    expect(Edition.boricua.hasFullBible, isTrue);
    expect(Edition.yave.hasFullBible, isFalse);
    expect(Edition.boricua.syncsContent, isFalse);
    final p = AppPalette.boricuaLight;
    expect(p.gold.r, greaterThan(p.gold.b)); // rojo
    expect(p.blue.b, greaterThan(p.blue.r)); // azul
    expect(p.background.toARGB32(), 0xFFFFFFFF);
    expect(
      resources.plans.map((p) => p.id),
      containsAll(['juan21', 'biblia365']),
    );
    expect(resources.plan('biblia365')!.days, hasLength(365));
    expect(
      resources.plan('biblia365')!.days.fold<int>(0, (n, d) => n + d.length),
      1189,
    );
  });
}
