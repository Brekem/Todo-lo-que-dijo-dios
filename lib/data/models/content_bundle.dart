import 'category.dart';
import 'era.dart';
import 'passage.dart';

/// Todo el contenido de la app, versionado para poder actualizarlo desde Firebase.
class ContentBundle {
  ContentBundle({
    required this.version,
    required this.translation,
    required this.categories,
    required this.eras,
    required List<Passage> passages,
  }) : passages = List.unmodifiable(
         [...passages]..sort((a, b) => a.order.compareTo(b.order)),
       );

  factory ContentBundle.fromJson(Map<String, dynamic> json) => ContentBundle(
    version: (json['version'] as num).toInt(),
    translation: json['translation'] as String,
    categories: (json['categories'] as List<dynamic>)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    eras: (json['eras'] as List<dynamic>)
        .map((e) => Era.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    passages: (json['passages'] as List<dynamic>)
        .map((e) => Passage.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final int version;
  final String translation;
  final List<Category> categories;

  /// Etapas del "Recorrido de la Voz de Dios", en orden.
  final List<Era> eras;

  /// Ordenados cronológicamente.
  final List<Passage> passages;

  late final Map<String, Passage> _byId = {for (final p in passages) p.id: p};
  late final Map<String, Category> _categoriesById = {
    for (final c in categories) c.id: c,
  };

  Passage? passageById(String id) => _byId[id];
  Category? categoryById(String id) => _categoriesById[id];

  List<Passage> byCategory(String categoryId) =>
      passages.where((p) => p.categories.contains(categoryId)).toList();

  late final Map<String, Era> _erasById = {for (final e in eras) e.id: e};

  Era? eraById(String id) => _erasById[id];

  List<Passage> byEra(String eraId) =>
      passages.where((p) => p.era == eraId).toList();

  /// Índice cronológico (0-based) de un pasaje.
  int indexOf(Passage passage) => passages.indexOf(passage);

  /// "Palabra de hoy": cambia cada día, estable durante el día.
  static const _dayStride = 7919;

  Passage wordOfTheDay(DateTime now) {
    final day = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime.utc(2024)).inDays;
    // Salto grande y primo con el total: cada día una palabra de otra parte de
    // la Biblia, y no se repite ninguna hasta haberlas visto todas.
    return passages[(day * _dayStride) % passages.length];
  }

  List<String> get allPeople => _distinct(passages.expand((p) => p.people));
  List<String> get allTopics => _distinct(passages.expand((p) => p.topics));
  List<String> get allProblems => _distinct(passages.expand((p) => p.problems));

  static List<String> _distinct(Iterable<String> values) {
    final counts = <String, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    // Más frecuentes primero, luego alfabético.
    return counts.keys.toList()..sort((a, b) {
      final c = counts[b]!.compareTo(counts[a]!);
      return c != 0 ? c : a.compareTo(b);
    });
  }
}
