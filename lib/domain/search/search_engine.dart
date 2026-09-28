import '../../core/utils/text_normalizer.dart';
import '../../data/models/passage.dart';
import 'synonyms.dart';

enum SearchMode { all, problem, topic, person }

class SearchResult {
  const SearchResult(this.passage, this.score);
  final Passage passage;
  final double score;
}

/// Motor de búsqueda local (offline) con:
/// - normalización (tildes, mayúsculas, signos),
/// - sinónimos ("estrés" encuentra "ansiedad"),
/// - coincidencia por prefijo ("perdo" → "perdón"),
/// - tolerancia a errores de escritura (distancia de edición 1–2),
/// - pesos por campo según el modo elegido.
class SearchEngine {
  SearchEngine(List<Passage> passages)
    : _docs = [for (final p in passages) _IndexedPassage(p)];

  final List<_IndexedPassage> _docs;

  List<SearchResult> search(String query, {SearchMode mode = SearchMode.all}) {
    final queryTokens = TextNormalizer.tokens(query);
    if (queryTokens.isEmpty) return const [];

    final normalizedQuery = TextNormalizer.normalize(query);
    final results = <SearchResult>[];

    for (final doc in _docs) {
      var score = 0.0;
      var matchedTokens = 0;

      for (final token in queryTokens) {
        final variants = _expand(token);
        var best = 0.0;
        var sum = 0.0;
        for (final field in doc.fields) {
          final weight = field.weightFor(mode);
          if (weight == 0) continue;
          final value = field.match(token, variants) * weight;
          sum += value;
          if (value > best) best = value;
        }
        if (best > 0) matchedTokens++;
        // El mejor campo manda; coincidir en varios campos suma un poco más.
        score += best + 0.25 * (sum - best);
      }

      if (matchedTokens == 0) continue;

      // Premia que coincidan todas las palabras y las frases exactas.
      score *= matchedTokens / queryTokens.length;
      if (doc.reference.contains(normalizedQuery)) score += 20;
      if (normalizedQuery.length > 3 && doc.quote.contains(normalizedQuery)) {
        score += 10;
      }
      // Frases exactas de problemas, temas o personajes ("miedo al futuro").
      for (final tag in doc.tagsFor(mode)) {
        if (tag.length > 3 && ' $normalizedQuery '.contains(' $tag ')) {
          score += 4.0 * tag.split(' ').length;
        }
      }
      results.add(SearchResult(doc.passage, score));
    }

    results.sort((a, b) {
      final c = b.score.compareTo(a.score);
      return c != 0 ? c : a.passage.order.compareTo(b.passage.order);
    });
    return results;
  }

  static Set<String> _expand(String token) {
    final out = <String>{token};
    final direct = kSynonymIndex[token];
    if (direct != null) out.addAll(direct);
    // Sinónimos también por prefijo (p. ej. "preocup" → preocupacion).
    if (token.length >= 4) {
      for (final entry in kSynonymIndex.entries) {
        if (entry.key.startsWith(token)) out.addAll(entry.value);
      }
    }
    return out;
  }
}

class _IndexedPassage {
  _IndexedPassage(this.passage)
    : reference = TextNormalizer.normalize(passage.reference),
      quote = TextNormalizer.normalize(passage.quote) {
    fields = [
      _Field.of(
        [passage.reference, passage.book],
        all: 6,
        problem: 0,
        topic: 0,
        person: 0,
      ),
      _Field.of([passage.quote], all: 4, problem: 1, topic: 1, person: 0),
      _Field.of(passage.problems, all: 5, problem: 8, topic: 1, person: 0),
      _Field.of([passage.problem], all: 3, problem: 5, topic: 0, person: 0),
      _Field.of(passage.topics, all: 5, problem: 1, topic: 8, person: 0),
      _Field.of(
        passage.categories.map((c) => c.replaceAll('-', ' ')),
        all: 3,
        problem: 3,
        topic: 4,
        person: 0,
      ),
      _Field.of(
        [...passage.people, passage.recipient],
        all: 5,
        problem: 0,
        topic: 0,
        person: 8,
      ),
      _Field.of([passage.speaker], all: 2, problem: 0, topic: 0, person: 3),
      _Field.of(
        [passage.situation, passage.historicalContext],
        all: 1,
        problem: 1,
        topic: 1,
        person: 1,
      ),
      _Field.of(
        [passage.explanation, passage.application],
        all: 1,
        problem: 2,
        topic: 1,
        person: 0,
      ),
    ];
  }

  final Passage passage;
  final String reference;
  final String quote;
  late final List<_Field> fields;

  late final List<String> _problemTags = [
    for (final t in passage.problems) TextNormalizer.normalize(t),
  ];
  late final List<String> _topicTags = [
    for (final t in [...passage.topics, ...passage.categories])
      TextNormalizer.normalize(t),
  ];
  late final List<String> _personTags = [
    for (final t in passage.people) TextNormalizer.normalize(t),
  ];

  List<String> tagsFor(SearchMode mode) => switch (mode) {
    SearchMode.all => [..._problemTags, ..._topicTags, ..._personTags],
    SearchMode.problem => _problemTags,
    SearchMode.topic => _topicTags,
    SearchMode.person => _personTags,
  };
}

class _Field {
  _Field(this.tokens, this._weights);

  factory _Field.of(
    Iterable<String> values, {
    required double all,
    required double problem,
    required double topic,
    required double person,
  }) => _Field(
    {for (final v in values) ...TextNormalizer.normalize(v).split(' ')}
      ..remove(''),
    [all, problem, topic, person],
  );

  final Set<String> tokens;
  final List<double> _weights;

  double weightFor(SearchMode mode) => _weights[mode.index];

  /// 1.0 exacta/sinónimo, 0.8 prefijo, 0.5 aproximada, 0 sin coincidencia.
  double match(String token, Set<String> variants) {
    for (final v in variants) {
      if (tokens.contains(v)) return 1.0;
    }
    if (token.length >= 3) {
      for (final t in tokens) {
        if (t.startsWith(token)) return 0.8;
      }
    }
    if (token.length >= 5) {
      final maxDistance = token.length >= 8 ? 2 : 1;
      for (final t in tokens) {
        if ((t.length - token.length).abs() <= maxDistance &&
            _levenshtein(t, token, maxDistance) <= maxDistance) {
          return 0.5;
        }
      }
    }
    return 0;
  }

  static int _levenshtein(String a, String b, int max) {
    var prev = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final curr = List<int>.filled(b.length + 1, 0)..[0] = i;
      var rowMin = curr[0];
      for (var j = 1; j <= b.length; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        curr[j] = [
          prev[j] + 1,
          curr[j - 1] + 1,
          prev[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
        if (curr[j] < rowMin) rowMin = curr[j];
      }
      if (rowMin > max) return max + 1;
      prev = curr;
    }
    return prev[b.length];
  }
}
