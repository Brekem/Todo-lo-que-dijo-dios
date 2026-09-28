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

  test('las diez categorías pedidas existen y tienen palabras', () {
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
    expect(content.categories.map((c) => c.id), expected);
    for (final id in expected) {
      expect(content.byCategory(id), isNotEmpty, reason: id);
    }
  });

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
}
