import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_lo_que_dios_dijo/core/config/edition.dart';
import 'package:todo_lo_que_dios_dijo/core/theme/app_palette.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';
import 'package:todo_lo_que_dios_dijo/domain/listening/narration.dart';

ContentBundle loadApocalipsis() => ContentBundle.fromJson(
  jsonDecode(File(Edition.apocalipsis.contentAsset).readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  final apo = loadApocalipsis();

  test('el libro completo, del capítulo 1 al 22, sin huecos', () {
    final seen = <String>{};
    for (final p in apo.passages) {
      expect(p.book, 'Apocalipsis');
      final chapter = RegExp(r' (\d+):').firstMatch(p.reference)!.group(1);
      for (final v in p.verses) {
        expect(seen.add('$chapter:${v.number}'), isTrue, reason: p.id);
      }
    }
    expect(seen.length, 404);
    expect(apo.passages.first.reference, 'Apocalipsis 1:1-8');
    expect(apo.passages.last.reference, 'Apocalipsis 22:16-21');
    for (var i = 0; i < apo.passages.length; i++) {
      expect(apo.passages[i].order, i + 1);
    }
  });

  test('cada visión está explicada a mano', () {
    for (final p in apo.passages) {
      expect(p.curated, isTrue, reason: p.id);
      expect(p.quote, isNotEmpty, reason: p.id);
      expect(p.explanation.length, greaterThan(150), reason: p.id);
      expect(p.prayer.trim(), endsWith('Amén.'), reason: p.id);
    }
    for (final c in apo.categories) {
      expect(apo.byCategory(c.id), isNotEmpty, reason: c.id);
    }
  });

  test('Juan narra y las voces del cielo hablan con la voz de Dios', () {
    final newThings = apo.passages.firstWhere(
      (p) => p.reference == 'Apocalipsis 21:1-8',
    );
    final v5 = newThings.verses.firstWhere((v) => v.number == 5);
    expect(v5.parts.first.god, isFalse);
    expect(v5.parts.first.text, contains('el que estaba sentado en el trono'));
    expect(v5.parts[1].god, isTrue);
    expect(v5.parts[1].text, startsWith('He aquí, yo hago nuevas'));
    expect(newThings.verses.first.parts.single.god, isFalse);

    final laodicea = apo.passages.firstWhere(
      (p) => p.reference == 'Apocalipsis 3:14-22',
    );
    expect(
      Narration.readingParts(laodicea)
          .where((x) => x.god)
          .map((x) => x.text)
          .join(' '),
      contains('He aquí, yo estoy a la puerta y llamo'),
    );
    expect(Narration.speakerName(laodicea), 'Jesús');
  });

  test('la edición Apocalipsis es púrpura y dorada', () {
    for (final p in [AppPalette.apocalipsisLight, AppPalette.apocalipsisDark]) {
      expect(p.gold.r, greaterThan(p.gold.b));
      expect(p.blue.b, greaterThan(p.blue.g));
      expect(p.blue.r, greaterThan(p.blue.g));
    }
    expect(Edition.apocalipsis.light, AppPalette.apocalipsisLight);
    expect(Edition.apocalipsis.title, 'Las profecías del\nApocalipsis');
    expect(Edition.yave.title, 'Todo lo que\nDios dijo');
    expect(Edition.apocalipsis.syncsContent, isFalse);
  });
}
