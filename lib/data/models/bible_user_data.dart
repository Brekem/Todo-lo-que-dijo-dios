import 'package:flutter/foundation.dart';

/// Colores de resaltado de un versículo.
enum Highlight { yellow, green, blue, pink }

/// Lo que el usuario hizo con un versículo: nota, resaltado o marcador.
@immutable
class VerseAnnotation {
  const VerseAnnotation({
    required this.key,
    this.note,
    this.highlight,
    this.bookmarked = false,
    required this.updatedAt,
  });

  factory VerseAnnotation.fromJson(Map<String, dynamic> j) => VerseAnnotation(
    key: j['key'] as String,
    note: j['note'] as String?,
    highlight: Highlight.values
        .where((h) => h.name == j['highlight'])
        .firstOrNull,
    bookmarked: j['bookmarked'] as bool? ?? false,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      (j['updatedAt'] as num).toInt(),
    ),
  );

  /// [VerseRef.key] («jua.3.16»).
  final String key;
  final String? note;
  final Highlight? highlight;
  final bool bookmarked;
  final DateTime updatedAt;

  bool get isEmpty =>
      (note == null || note!.trim().isEmpty) &&
      highlight == null &&
      !bookmarked;

  VerseAnnotation copyWith({
    String? note,
    bool clearNote = false,
    Highlight? highlight,
    bool clearHighlight = false,
    bool? bookmarked,
  }) => VerseAnnotation(
    key: key,
    note: clearNote ? null : (note ?? this.note),
    highlight: clearHighlight ? null : (highlight ?? this.highlight),
    bookmarked: bookmarked ?? this.bookmarked,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    if (note != null) 'note': note,
    if (highlight != null) 'highlight': highlight!.name,
    if (bookmarked) 'bookmarked': true,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };
}

/// Un capítulo leído (historial).
@immutable
class ChapterVisit {
  const ChapterVisit(this.bookId, this.chapter, this.at);

  factory ChapterVisit.fromJson(Map<String, dynamic> j) => ChapterVisit(
    j['book'] as String,
    (j['chapter'] as num).toInt(),
    DateTime.fromMillisecondsSinceEpoch((j['at'] as num).toInt()),
  );

  final String bookId;
  final int chapter;
  final DateTime at;

  Map<String, dynamic> toJson() => {
    'book': bookId,
    'chapter': chapter,
    'at': at.millisecondsSinceEpoch,
  };
}

/// Todo lo personal de la Biblia Boricua: se guarda en el teléfono y, con
/// Firebase, se sincroniza en la nube (users/{uid}).
@immutable
class BibleUserData {
  const BibleUserData({
    this.annotations = const {},
    this.history = const [],
    this.plans = const {},
    this.lessonsDone = const {},
    this.updatedAt,
  });

  factory BibleUserData.fromJson(Map<String, dynamic> j) => BibleUserData(
    annotations: {
      for (final a in j['annotations'] as List<dynamic>? ?? const [])
        (a as Map<String, dynamic>)['key'] as String: VerseAnnotation.fromJson(
          a,
        ),
    },
    history: [
      for (final h in j['history'] as List<dynamic>? ?? const [])
        ChapterVisit.fromJson(h as Map<String, dynamic>),
    ],
    plans: {
      for (final e in (j['plans'] as Map<String, dynamic>? ?? const {}).entries)
        e.key: {for (final d in e.value as List<dynamic>) (d as num).toInt()},
    },
    lessonsDone: {...(j['lessonsDone'] as List<dynamic>? ?? const []).cast()},
    updatedAt: j['updatedAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch((j['updatedAt'] as num).toInt()),
  );

  /// Por [VerseRef.key].
  final Map<String, VerseAnnotation> annotations;

  /// Lo más reciente primero (máximo 50).
  final List<ChapterVisit> history;

  /// Plan → días terminados (desde 0).
  final Map<String, Set<int>> plans;
  final Set<String> lessonsDone;
  final DateTime? updatedAt;

  static const maxHistory = 50;

  BibleUserData copyWith({
    Map<String, VerseAnnotation>? annotations,
    List<ChapterVisit>? history,
    Map<String, Set<int>>? plans,
    Set<String>? lessonsDone,
  }) => BibleUserData(
    annotations: annotations ?? this.annotations,
    history: history ?? this.history,
    plans: plans ?? this.plans,
    lessonsDone: lessonsDone ?? this.lessonsDone,
    updatedAt: DateTime.now(),
  );

  /// Une los datos de dos dispositivos: en cada versículo gana el cambio más
  /// reciente; planes, lecciones e historial se suman.
  BibleUserData merge(BibleUserData other) {
    final notes = {...annotations};
    for (final a in other.annotations.values) {
      final mine = notes[a.key];
      if (mine == null || a.updatedAt.isAfter(mine.updatedAt)) notes[a.key] = a;
    }
    final visits = {
      for (final v in [...history, ...other.history])
        '${v.bookId}.${v.chapter}': v,
    }.values.toList()..sort((a, b) => b.at.compareTo(a.at));
    final plansOut = {...plans};
    for (final e in other.plans.entries) {
      plansOut[e.key] = {...?plansOut[e.key], ...e.value};
    }
    return BibleUserData(
      annotations: notes,
      history: visits.take(maxHistory).toList(),
      plans: plansOut,
      lessonsDone: {...lessonsDone, ...other.lessonsDone},
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'annotations': [for (final a in annotations.values) a.toJson()],
    'history': [for (final h in history) h.toJson()],
    'plans': {for (final e in plans.entries) e.key: (e.value.toList()..sort())},
    'lessonsDone': lessonsDone.toList()..sort(),
    if (updatedAt != null) 'updatedAt': updatedAt!.millisecondsSinceEpoch,
  };
}
