import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_lo_que_dios_dijo/core/config/edition.dart';
import 'package:todo_lo_que_dios_dijo/core/theme/app_palette.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/narration.dart';

ContentBundle loadJesus() => ContentBundle.fromJson(
  jsonDecode(File(Edition.jesus.contentAsset).readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  final jesus = loadJesus();

  test('todas las palabras de Jesús, de Mateo a Apocalipsis', () {
    expect(jesus.passages.length, greaterThan(300));
    expect(jesus.passages.first.book, 'Mateo');
    expect(jesus.passages.last.book, 'Apocalipsis');
    final books = jesus.passages.map((p) => p.book).toSet();
    expect(
      books,
      containsAll([
        'Mateo',
        'Marcos',
        'Lucas',
        'Juan',
        'Hechos',
        '1 Corintios',
        '2 Corintios',
        'Apocalipsis',
      ]),
    );
    for (var i = 0; i < jesus.passages.length; i++) {
      expect(jesus.passages[i].order, i + 1);
      expect(jesus.passages[i].speaker, 'Jesús');
    }
    for (final c in jesus.categories) {
      expect(jesus.byCategory(c.id), isNotEmpty, reason: c.id);
    }
    expect(jesus.eras.map((e) => e.id).toSet(), {
      for (final p in jesus.passages) p.era,
    });
  });

  test('cada pasaje tiene palabras de Jesús y versículos completos', () {
    for (final p in jesus.passages) {
      expect(p.verses, isNotEmpty, reason: p.id);
      expect(
        p.verses.expand((v) => v.parts).where((x) => x.god),
        isNotEmpty,
        reason: p.id,
      );
      expect(p.prayer.trim(), endsWith('Amén.'), reason: p.id);
      expect(p.historicalContext, isNotEmpty, reason: p.id);
      expect(p.situation, isNotEmpty, reason: p.id);
    }
  });

  test('narración y voz de Jesús separadas dentro del versículo', () {
    // Juan 14:6: «Jesús le dice: Yo soy el camino, y la verdad, y la vida…»
    final p = jesus.passages.firstWhere(
      (p) =>
          p.book == 'Juan' &&
          p.verses.any((v) => v.number == 6) &&
          p.fullReference!.startsWith('Juan 14:'),
    );
    final verse = p.verses.firstWhere((v) => v.number == 6);
    expect(verse.parts.first.god, isFalse);
    expect(verse.parts.first.text, contains('Jesús le dice'));
    expect(verse.parts.last.god, isTrue);
    expect(verse.parts.last.text, startsWith('Yo soy el camino'));

    // Las bienaventuranzas: todo el versículo lo dice Jesús.
    final sermon = jesus.passages.firstWhere(
      (p) => p.fullReference!.startsWith('Mateo 5:'),
    );
    final blessed = sermon.verses.firstWhere((v) => v.number == 3);
    expect(blessed.parts.single.god, isTrue);
    expect(Narration.readingParts(sermon).where((x) => x.god), isNotEmpty);
  });

  test('las palabras más conocidas están', () {
    String all(String book) => jesus.passages
        .where((p) => p.book == book)
        .expand((p) => p.verses.expand((v) => v.parts))
        .where((x) => x.god)
        .map((x) => x.text)
        .join(' ');
    expect(
      all('Mateo'),
      contains('Venid a mí todos los que estáis trabajados'),
    );
    expect(all('Juan'), contains('Consumado es'));
    expect(all('Juan'), contains('Yo soy la resurrección y la vida'));
    expect(all('Lucas'), contains('Padre, perdónalos'));
    expect(all('Hechos'), contains('Yo soy Jesús a quien tú persigues'));
    expect(all('2 Corintios'), contains('Bástate mi gracia'));
    expect(
      all('Apocalipsis'),
      contains('He aquí, yo estoy a la puerta y llamo'),
    );
  });

  test('la edición Jesús es roja y blanca', () {
    for (final p in [AppPalette.jesusLight, AppPalette.jesusDark]) {
      expect(p.gold.r, greaterThan(p.gold.g));
      expect(p.gold.r, greaterThan(p.gold.b));
    }
    expect(AppPalette.jesusLight.background.toARGB32(), 0xFFFFFFFF);
    expect(Edition.jesus.light, AppPalette.jesusLight);
    expect(Edition.jesus.speaker, 'Jesús');
    expect(Edition.jesus.syncsContent, isFalse);
    expect(Edition.yave.speaker, 'Dios');
  });
}
