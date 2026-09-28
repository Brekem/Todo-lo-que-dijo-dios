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
    // Cada discurso de Yavé extraído de la RV1909 (id «y-…»); la cita muestra
    // solo lo que Dios dijo, sin «Así dice Yavé».
    final discursos = content.passages.where((p) => p.id.startsWith('y-'));
    expect(discursos.length, greaterThan(800));
    expect(content.byCategory('voz').length, greaterThan(30));
    expect(content.passages.length, greaterThan(900));
  });

  test('incluye la Ley dada a Moisés y la respuesta a Job completa', () {
    final refs = content.passages.map((p) => p.reference).toSet();
    expect(refs.where((r) => r.startsWith('Levítico 19:')), isNotEmpty);
    expect(refs.where((r) => r.startsWith('Éxodo 21:')), isNotEmpty);
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

  test('todas las palabras están explicadas a mano', () {
    for (final p in content.passages) {
      expect(p.curated, isTrue, reason: p.reference);
      expect(p.problem.trim(), isNotEmpty, reason: p.reference);
      expect(p.explanation.trim(), isNotEmpty, reason: p.reference);
      expect(p.application.trim(), isNotEmpty, reason: p.reference);
      expect(p.prayer.trimRight(), endsWith('Amén.'), reason: p.reference);
    }
    expect(content.passageById('isa-41-10')!.curated, isTrue);
  });

  test('lo que Dios dijo es corto y preciso', () {
    for (final p in content.passages) {
      expect(p.quote.trim(), isNotEmpty, reason: p.reference);
      expect(p.quote.length, lessThanOrEqualTo(300), reason: p.reference);
    }
  });
}
