import 'package:flutter/foundation.dart';

/// Un libro de la Biblia completa (RV1909), para leer sin conexión.
@immutable
class BibleBook {
  const BibleBook({
    required this.id,
    required this.name,
    required this.abbr,
    required this.testament,
    required this.chapters,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) => BibleBook(
    id: json['id'] as String,
    name: json['name'] as String,
    abbr: json['abbr'] as String,
    testament: json['testament'] == 'NT'
        ? Testament.newTestament
        : Testament.oldTestament,
    chapters: [
      for (final c in json['chapters'] as List<dynamic>)
        (c as List<dynamic>).cast<String>(),
    ],
  );

  /// Id corto estable («gen», «jua», «1co»…).
  final String id;
  final String name;
  final String abbr;
  final Testament testament;

  /// Capítulos (desde el 1) con sus versículos (desde el 1).
  final List<List<String>> chapters;

  int get chapterCount => chapters.length;

  List<String> chapter(int number) => chapters[number - 1];
}

enum Testament {
  oldTestament('Antiguo Testamento'),
  newTestament('Nuevo Testamento');

  const Testament(this.title);
  final String title;
}

/// Un versículo concreto («Juan 3:16»).
@immutable
class VerseRef implements Comparable<VerseRef> {
  const VerseRef(this.bookId, this.chapter, this.verse);

  /// «jua.3.16»
  factory VerseRef.parse(String key) {
    final parts = key.split('.');
    return VerseRef(parts[0], int.parse(parts[1]), int.parse(parts[2]));
  }

  final String bookId;
  final int chapter;
  final int verse;

  /// Clave estable para guardar notas, resaltados y marcadores.
  String get key => '$bookId.$chapter.$verse';

  @override
  int compareTo(VerseRef other) {
    final c = chapter.compareTo(other.chapter);
    return c != 0 ? c : verse.compareTo(other.verse);
  }

  @override
  bool operator ==(Object other) => other is VerseRef && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => key;
}

/// La Biblia completa.
class Bible {
  Bible({required this.translation, required this.books})
    : _byId = {for (final b in books) b.id: b},
      _byName = {for (final b in books) b.name: b};

  factory Bible.fromJson(Map<String, dynamic> json) => Bible(
    translation: json['translation'] as String,
    books: [
      for (final b in json['books'] as List<dynamic>)
        BibleBook.fromJson(b as Map<String, dynamic>),
    ],
  );

  final String translation;
  final List<BibleBook> books;
  final Map<String, BibleBook> _byId;
  final Map<String, BibleBook> _byName;

  BibleBook? book(String id) => _byId[id];
  BibleBook? bookByName(String name) => _byName[name];

  List<BibleBook> testament(Testament t) =>
      books.where((b) => b.testament == t).toList(growable: false);

  String? text(VerseRef ref) {
    final b = _byId[ref.bookId];
    if (b == null || ref.chapter < 1 || ref.chapter > b.chapterCount) {
      return null;
    }
    final ch = b.chapter(ref.chapter);
    return ref.verse < 1 || ref.verse > ch.length ? null : ch[ref.verse - 1];
  }

  /// «Juan 3:16» o «1 Corintios 13:4-7» → los versículos. `null` si no se
  /// entiende la cita.
  ({BibleBook book, int chapter, int from, int to})? parse(String reference) {
    final m = RegExp(r'^(.+?) (\d+):(\d+)(?:-(\d+))?$').firstMatch(reference);
    if (m == null) return null;
    final b = _byName[m.group(1)];
    if (b == null) return null;
    final ch = int.parse(m.group(2)!);
    if (ch < 1 || ch > b.chapterCount) return null;
    final from = int.parse(m.group(3)!);
    final to = int.parse(m.group(4) ?? m.group(3)!);
    final last = b.chapter(ch).length;
    if (from < 1 || from > last) return null;
    return (book: b, chapter: ch, from: from, to: to.clamp(from, last));
  }

  String reference(VerseRef ref) {
    final b = _byId[ref.bookId];
    return '${b?.name ?? ref.bookId} ${ref.chapter}:${ref.verse}';
  }
}
