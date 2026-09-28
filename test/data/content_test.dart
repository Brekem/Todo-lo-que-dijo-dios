import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final content = loadContent();

  test('hay palabras y están en orden cronológico continuo', () {
    expect(content.passages.length, greaterThanOrEqualTo(60));
    for (var i = 0; i < content.passages.length; i++) {
      expect(content.passages[i].order, i + 1);
    }
  });

  test(
    'las diez categorías pedidas (y las nuevas) existen y tienen palabras',
    () {
      const expected = [
        'miedo',
        'ansiedad',
        'culpa',
        'tristeza',
        'soledad',
        'fe',
        'obediencia',
        'amor',
        'perdon',
        'esperanza',
      ];
      expect(content.categories.map((c) => c.id), containsAll(expected));
      expect(
        content.categories.map((c) => c.id),
        containsAll(['arrepentimiento', 'justicia', 'voz']),
      );
      for (final id in expected) {
        expect(content.byCategory(id), isNotEmpty, reason: id);
      }
    },
  );

  test('cada palabra tiene los nueve apartados completos', () {
    for (final p in content.passages) {
      for (final field in [
        p.quote,
        p.reference,
        p.recipient,
        p.historicalContext,
        p.situation,
        p.problem,
        p.explanation,
        p.application,
        p.prayer,
      ]) {
        expect(field.trim(), isNotEmpty, reason: p.id);
      }
      expect(p.problems, isNotEmpty, reason: p.id);
      expect(content.eraById(p.era), isNotNull, reason: p.id);
    }
  });

  test('usa el nombre divino Yavé y no Jehová', () {
    for (final p in content.passages) {
      expect(p.quote.contains('Jehov'), isFalse, reason: p.id);
      expect(p.prayer.contains('Jehov'), isFalse, reason: p.id);
    }
    expect(content.passages.where((p) => p.quote.contains('Yavé')), isNotEmpty);
  });

  test('el recorrido empieza en Génesis y termina en Apocalipsis', () {
    expect(content.passages.first.book, 'Génesis');
    expect(content.passages.last.book, 'Apocalipsis');
    expect(content.eras.first.title, 'Adán');
    expect(content.eras.last.title, 'Apocalipsis');
  });

  test('la palabra de hoy es estable durante el día', () {
    final a = content.wordOfTheDay(DateTime(2026, 9, 28, 7));
    final b = content.wordOfTheDay(DateTime(2026, 9, 28, 23));
    final c = content.wordOfTheDay(DateTime(2026, 9, 29, 7));
    expect(a, b);
    expect(a, isNot(c));
  });

  test('incluye todos los «Así dice Yavé» y «la voz de Yavé»', () {
    final all = content.passages.map((p) => p.quote).join(' ');
    final asiDice = RegExp(
      r'[Aa]s[ií] (?:dice|ha dicho|dijo) (?:el Señor )?Yavé',
    );
    expect(asiDice.allMatches(all).length, greaterThan(300));
    expect(content.byCategory('voz').length, greaterThan(30));
    expect(content.passages.length, greaterThan(1050));
  });

  test('incluye la Ley dada a Moisés y la respuesta a Job completa', () {
    final refs = content.passages.map((p) => p.reference).toSet();
    expect(refs, containsAll(['Levítico 19:1-12', 'Éxodo 21:1-2']));
    for (final chapter in [38, 39, 40, 41]) {
      expect(
        refs.where((r) => r.startsWith('Job $chapter:')),
        isNotEmpty,
        reason: 'Job $chapter',
      );
    }
  });

  test('sin palabras vacías ni repetidas', () {
    final refs = <String>{};
    final intro = RegExp(r'(?:diciendo|dijo|diciéndoles?):$');
    final passages = content.passages;
    for (final (i, p) in passages.indexed) {
      // Solo la presentación («…, diciendo:») sin lo que Dios dijo, salvo que
      // lo siguiente sea una palabra explicada a mano.
      if (intro.hasMatch(p.quote.trimRight())) {
        expect(passages[i + 1].curated, isTrue, reason: p.reference);
      }
      expect(refs.add(p.reference), isTrue, reason: p.reference);
    }
  });

  test('las palabras explicadas a mano se conservan', () {
    expect(content.passages.where((p) => p.curated).length, 71);
    expect(content.passageById('isa-41-10')!.curated, isTrue);
  });
}
