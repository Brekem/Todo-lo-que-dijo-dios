import 'package:flutter/foundation.dart';

import '../../core/utils/text_normalizer.dart';
import '../../data/models/bible.dart';

/// Un versículo encontrado.
typedef BibleHit = ({VerseRef ref, String text});

/// Índice de búsqueda de la Biblia completa (31,102 versículos). Se arma una
/// vez, fuera del hilo de la pantalla.
class BibleIndex {
  BibleIndex._(this._bible, this._refs, this._normalized);

  final Bible _bible;
  final List<VerseRef> _refs;
  final List<String> _normalized;

  static Future<BibleIndex> build(Bible bible) async {
    final refs = <VerseRef>[];
    final texts = <String>[];
    for (final b in bible.books) {
      for (var c = 0; c < b.chapterCount; c++) {
        final ch = b.chapters[c];
        for (var v = 0; v < ch.length; v++) {
          refs.add(VerseRef(b.id, c + 1, v + 1));
          texts.add(ch[v]);
        }
      }
    }
    final normalized = await compute(_normalizeAll, texts);
    return BibleIndex._(bible, refs, normalized);
  }

  int get length => _refs.length;

  /// Una cita escrita a mano («juan 3:16», «Salmos 23»): el capítulo y el
  /// versículo, si existen.
  ({BibleBook book, int chapter, int? verse})? reference(String query) {
    final m = RegExp(r'^\s*(\d?\s*[^\d:]+?)\s+(\d+)(?:\s*:\s*(\d+))?\s*$')
        .firstMatch(query);
    if (m == null) return null;
    final name = TextNormalizer.normalize(m.group(1)!).replaceAll(' ', '');
    for (final b in _bible.books) {
      final full = TextNormalizer.normalize(b.name).replaceAll(' ', '');
      final abbr = TextNormalizer.normalize(b.abbr).replaceAll(' ', '');
      if (name == full ||
          name == abbr ||
          (name.length >= 3 && full.startsWith(name))) {
        final ch = int.parse(m.group(2)!);
        if (ch < 1 || ch > b.chapterCount) return null;
        final v = m.group(3) == null ? null : int.parse(m.group(3)!);
        if (v != null && (v < 1 || v > b.chapter(ch).length)) return null;
        return (book: b, chapter: ch, verse: v);
      }
    }
    return null;
  }

  /// Versículos que contienen todas las palabras de [query] (sin tildes ni
  /// mayúsculas), en el orden de la Biblia.
  List<BibleHit> search(String query, {int limit = 200, Testament? testament}) {
    final words = TextNormalizer.tokens(query);
    if (words.isEmpty) return const [];
    final out = <BibleHit>[];
    for (var i = 0; i < _normalized.length && out.length < limit; i++) {
      final ref = _refs[i];
      if (testament != null &&
          _bible.book(ref.bookId)!.testament != testament) {
        continue;
      }
      final text = _normalized[i];
      if (words.every(text.contains)) {
        out.add((ref: ref, text: _bible.text(ref)!));
      }
    }
    return out;
  }
}

List<String> _normalizeAll(List<String> texts) => [
  for (final t in texts) ' ${TextNormalizer.normalize(t)} ',
];
