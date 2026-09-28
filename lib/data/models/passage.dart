import 'package:flutter/foundation.dart';

/// Un pasaje donde Yavé (Dios) habla directamente.
@immutable
class Passage {
  const Passage({
    required this.id,
    required this.order,
    required this.era,
    required this.reference,
    required this.book,
    required this.speaker,
    required this.quote,
    required this.recipient,
    required this.people,
    required this.historicalContext,
    required this.situation,
    required this.problem,
    required this.explanation,
    required this.application,
    required this.prayer,
    required this.categories,
    required this.topics,
    required this.problems,
  });

  factory Passage.fromJson(Map<String, dynamic> json) => Passage(
    id: json['id'] as String,
    order: (json['order'] as num).toInt(),
    era: json['era'] as String,
    reference: json['reference'] as String,
    book: json['book'] as String,
    speaker: json['speaker'] as String,
    quote: json['quote'] as String,
    recipient: json['recipient'] as String,
    people: _strings(json['people']),
    historicalContext: json['historicalContext'] as String,
    situation: json['situation'] as String,
    problem: json['problem'] as String,
    explanation: json['explanation'] as String,
    application: json['application'] as String,
    prayer: json['prayer'] as String,
    categories: _strings(json['categories']),
    topics: _strings(json['topics']),
    problems: _strings(json['problems']),
  );

  final String id;

  /// Posición cronológica dentro del recorrido (1 = primera palabra de Dios).
  final int order;

  /// Etapa de la historia bíblica (p. ej. "Los patriarcas").
  final String era;
  final String reference;
  final String book;

  /// Quién habla: Yavé, la voz del Padre, Jesucristo, el Espíritu Santo…
  final String speaker;

  /// 1. Lo que Dios dijo.
  final String quote;

  /// 3. Persona o grupo que recibió el mensaje.
  final String recipient;

  /// Personajes bíblicos relacionados (para buscar por personaje).
  final List<String> people;

  /// 4. Contexto histórico.
  final String historicalContext;

  /// 5. Situación que estaba ocurriendo.
  final String situation;

  /// 6. Problema que Dios estaba corrigiendo o liberando.
  final String problem;

  /// 7. Explicación sencilla.
  final String explanation;

  /// 8. Aplicación práctica para la vida moderna.
  final String application;

  /// 9. Oración inspirada en el mensaje.
  final String prayer;

  /// Ids de [Category].
  final List<String> categories;
  final List<String> topics;
  final List<String> problems;

  Map<String, dynamic> toJson() => {
    'id': id,
    'order': order,
    'era': era,
    'reference': reference,
    'book': book,
    'speaker': speaker,
    'quote': quote,
    'recipient': recipient,
    'people': people,
    'historicalContext': historicalContext,
    'situation': situation,
    'problem': problem,
    'explanation': explanation,
    'application': application,
    'prayer': prayer,
    'categories': categories,
    'topics': topics,
    'problems': problems,
  };

  /// Texto listo para compartir.
  String toShareText() =>
      '«$quote»\n— $reference\n\n'
      'Dirigido a: $recipient\n\n'
      '$application\n\n'
      'Compartido desde «Todo lo que Dios Dijo».';

  static List<String> _strings(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<String>();

  @override
  bool operator ==(Object other) => other is Passage && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
