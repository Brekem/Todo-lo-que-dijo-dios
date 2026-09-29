import 'package:flutter/foundation.dart';

/// Un trozo de versículo: lo que cuenta el narrador o lo que dice Dios.
@immutable
class VersePart {
  const VersePart(this.text, {required this.god});

  final String text;

  /// `true` si son palabras de Dios.
  final bool god;
}

/// Un versículo completo, separado en narración y palabras de Dios.
@immutable
class VerseText {
  const VerseText(this.number, this.parts);

  factory VerseText.fromJson(List<dynamic> json) =>
      VerseText((json[0] as num).toInt(), [
        for (final part in json[1] as List<dynamic>)
          VersePart(
            (part as List<dynamic>)[0] as String,
            god: (part[1] as num) != 0,
          ),
      ]);

  /// Número de versículo (0 si no se conoce).
  final int number;
  final List<VersePart> parts;

  String get text => parts.map((p) => p.text).join(' ');

  List<dynamic> toJson() => [
    number,
    [
      for (final p in parts) [p.text, p.god ? 1 : 0],
    ],
  ];
}

/// Un pasaje donde Yavé (Dios) habla directamente.
@immutable
class Passage {
  Passage({
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
    this.curated = true,
    String? fullReference,
    List<VerseText>? verses,
  }) : fullReference = fullReference ?? reference,
       verses =
           verses ??
           // Contenido antiguo sin versículos: la cita corta entera.
           [
             VerseText(0, [VersePart(quote, god: !id.startsWith('v-'))]),
           ];

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
    curated: json['curated'] as bool? ?? true,
    fullReference: json['fullReference'] as String?,
    verses: (json['verses'] as List<dynamic>?)
        ?.map((v) => VerseText.fromJson(v as List<dynamic>))
        .toList(),
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

  /// Referencia de los versículos completos (la conversación entera), que
  /// puede ser más amplia que [reference].
  final String fullReference;

  /// Los versículos completos: la narración y todo lo que Dios dice.
  final List<VerseText> verses;

  /// Hay palabras de Dios en los versículos (no solo narración).
  bool get hasGodWords => verses.any((v) => v.parts.any((p) => p.god));

  /// `true` si la explicación, aplicación y oración fueron escritas a mano;
  /// `false` si se generaron a partir del tema del pasaje.
  final bool curated;

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
    'curated': curated,
    'fullReference': fullReference,
    'verses': [for (final v in verses) v.toJson()],
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
