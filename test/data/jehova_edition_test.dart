import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_lo_que_dios_dijo/core/config/edition.dart';
import 'package:todo_lo_que_dios_dijo/core/theme/app_palette.dart';
import 'package:todo_lo_que_dios_dijo/data/models/content_bundle.dart';

import '../helpers.dart';

ContentBundle loadJehova() => ContentBundle.fromJson(
  jsonDecode(File(Edition.jehova.contentAsset).readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  final full = loadContent();
  final jehova = loadJehova();
  const newTestament = {'evangelios', 'iglesia', 'apocalipsis'};

  test('sin sabor, la app es la edición completa con «Yavé»', () {
    expect(Edition.current, Edition.yave);
    expect(Edition.yave.contentAsset, 'assets/data/content.json');
  });

  test('solo el Antiguo Testamento: de Génesis a Malaquías', () {
    final oldTestament = full.passages
        .where((p) => !newTestament.contains(p.era))
        .toList();
    expect(jehova.passages.map((p) => p.id), oldTestament.map((p) => p.id));
    expect(jehova.passages.first.book, 'Génesis');
    expect(jehova.passages.last.book, 'Malaquías');
    expect(jehova.eras.map((e) => e.id), isNot(contains('evangelios')));
    expect(jehova.eras.last.title, 'Israel');
    for (var i = 0; i < jehova.passages.length; i++) {
      expect(jehova.passages[i].order, i + 1);
    }
    for (final c in jehova.categories) {
      expect(jehova.byCategory(c.id), isNotEmpty, reason: c.id);
    }
  });

  test('usa el nombre divino «Jehová» y nunca «Yavé»', () {
    final raw = File(Edition.jehova.contentAsset).readAsStringSync();
    expect(raw.contains('Yavé'), isFalse);
    expect(raw.contains('YAVÉ'), isFalse);
    final byId = {for (final p in full.passages) p.id: p};
    for (final p in jehova.passages) {
      final original = byId[p.id]!;
      // Mismo texto, solo cambia el nombre.
      expect(p.quote, original.quote.replaceAll('Yavé', 'Jehová'));
      expect(
        p.verses.map((v) => v.text),
        original.verses.map((v) => v.text.replaceAll('Yavé', 'Jehová')),
      );
    }
    expect(
      jehova.passages.where((p) => p.quote.contains('Jehová')),
      hasLength(full.passages.where((p) => p.quote.contains('Yavé')).length),
    );
  });

  test('la edición Jehová es azul y blanca', () {
    for (final p in [AppPalette.jehovaLight, AppPalette.jehovaDark]) {
      // El acento (en lugar del dorado) es azul: domina el canal azul.
      expect(p.gold.b, greaterThan(p.gold.r));
      expect(p.gold.b, greaterThan(p.gold.g));
      expect(p.blue.b, greaterThan(p.blue.r));
    }
    expect(AppPalette.jehovaLight.background.toARGB32(), 0xFFFFFFFF);
    expect(Edition.jehova.light, AppPalette.jehovaLight);
    expect(Edition.yave.light, AppPalette.light);
  });
}
