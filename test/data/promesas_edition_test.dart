import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_lo_que_dios_dijo/core/config/edition.dart';
import 'package:todo_lo_que_dios_dijo/core/theme/app_palette.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';

ContentBundle loadPromesas() => ContentBundle.fromJson(
  jsonDecode(File(Edition.promesas.contentAsset).readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  final promesas = loadPromesas();

  test('promesas de Génesis a Apocalipsis, explicadas a mano', () {
    expect(promesas.passages.length, greaterThan(70));
    expect(promesas.passages.first.book, 'Génesis');
    expect(promesas.passages.last.book, 'Apocalipsis');
    final ids = <String>{};
    for (var i = 0; i < promesas.passages.length; i++) {
      final p = promesas.passages[i];
      expect(p.order, i + 1);
      expect(ids.add(p.id), isTrue, reason: p.id);
      expect(p.curated, isTrue, reason: p.id);
      expect(p.quote, isNotEmpty, reason: p.id);
      expect(p.prayer.trim(), endsWith('Amén.'), reason: p.id);
      expect(p.verses.expand((v) => v.parts).where((x) => x.god), isNotEmpty);
    }
    for (final c in promesas.categories) {
      expect(promesas.byCategory(c.id), isNotEmpty, reason: c.id);
    }
  });

  test('la promesa suena con la voz de Dios y la introducción la narra', () {
    final abram = promesas.passages.firstWhere(
      (p) => p.reference == 'Génesis 12:1-3',
    );
    final v1 = abram.verses.first;
    expect(v1.parts.first.god, isFalse);
    expect(v1.parts.first.text, contains('Yavé había dicho a Abram'));
    expect(v1.parts.last.god, isTrue);
    expect(v1.parts.last.text, startsWith('Vete de tu tierra'));

    final shepherd = promesas.passages.firstWhere(
      (p) => p.reference == 'Salmos 23:1-6',
    );
    // El título del salmo no es parte de la promesa.
    expect(shepherd.verses.first.parts.first.text, 'Salmo de David.');
    expect(shepherd.verses.first.parts.first.god, isFalse);
    expect(shepherd.quote, startsWith('Yavé es mi pastor'));

    final fear = promesas.passages.firstWhere(
      (p) => p.reference == 'Isaías 41:10',
    );
    expect(fear.quote, startsWith('No temas, que yo soy contigo'));
  });

  test('la edición Promesas es celeste y dorada', () {
    for (final p in [AppPalette.promesasLight, AppPalette.promesasDark]) {
      expect(p.gold.r, greaterThan(p.gold.b));
      expect(p.blue.b, greaterThan(p.blue.r));
    }
    expect(Edition.promesas.light, AppPalette.promesasLight);
    expect(Edition.promesas.title, 'Promesas de\nla Biblia');
    expect(Edition.promesas.syncsContent, isFalse);
  });
}
