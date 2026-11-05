import 'package:flutter/foundation.dart';

/// Un término de teología explicado en palabras sencillas.
@immutable
class GlossaryTerm {
  const GlossaryTerm({
    required this.term,
    required this.short,
    required this.long,
    required this.reference,
    required this.theme,
  });

  factory GlossaryTerm.fromJson(Map<String, dynamic> j) => GlossaryTerm(
    term: j['term'] as String,
    short: j['short'] as String,
    long: j['long'] as String,
    reference: j['reference'] as String,
    theme: j['theme'] as String,
  );

  final String term;

  /// Definición de una línea.
  final String short;
  final String long;
  final String reference;

  /// Id de [StudyTheme].
  final String theme;
}

/// Una lección de la Escuela Bíblica.
@immutable
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.readings,
    required this.explanation,
    required this.reflection,
    required this.example,
    required this.prayer,
  });

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
    id: j['id'] as String,
    title: j['title'] as String,
    readings: (j['readings'] as List<dynamic>).cast<String>(),
    explanation: j['explanation'] as String,
    reflection: j['reflection'] as String,
    example: j['example'] as String,
    prayer: j['prayer'] as String,
  );

  final String id;
  final String title;

  /// Citas para leer («Juan 1:1-14»).
  final List<String> readings;
  final String explanation;

  /// Preguntas para pensar.
  final String reflection;

  /// Un ejemplo de la vida real.
  final String example;
  final String prayer;
}

@immutable
class SchoolLevel {
  const SchoolLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.lessons,
  });

  factory SchoolLevel.fromJson(Map<String, dynamic> j) => SchoolLevel(
    level: (j['level'] as num).toInt(),
    title: j['title'] as String,
    description: j['description'] as String,
    lessons: [
      for (final l in j['lessons'] as List<dynamic>)
        Lesson.fromJson(l as Map<String, dynamic>),
    ],
  );

  final int level;
  final String title;
  final String description;
  final List<Lesson> lessons;
}

/// Respuesta del asistente cristiano: siempre con pasaje, explicación,
/// aplicación, oración y próximo paso.
@immutable
class AssistantAnswer {
  const AssistantAnswer({
    required this.question,
    required this.keywords,
    required this.reference,
    required this.text,
    required this.explanation,
    required this.application,
    required this.prayer,
    required this.nextStep,
    this.help,
  });

  factory AssistantAnswer.fromJson(Map<String, dynamic> j) => AssistantAnswer(
    question: j['question'] as String,
    keywords: (j['keywords'] as List<dynamic>? ?? const []).cast<String>(),
    reference: j['reference'] as String,
    text: j['text'] as String,
    explanation: j['explanation'] as String,
    application: j['application'] as String,
    prayer: j['prayer'] as String,
    nextStep: j['nextStep'] as String,
    help: j['help'] as String?,
  );

  final String question;
  final List<String> keywords;
  final String reference;

  /// Texto bíblico de [reference].
  final String text;
  final String explanation;
  final String application;
  final String prayer;
  final String nextStep;

  /// Líneas de ayuda (crisis, adicción, violencia), si aplica.
  final String? help;
}

/// Un plan de lectura: cada día, uno o más capítulos.
@immutable
class ReadingPlan {
  const ReadingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.days,
  });

  factory ReadingPlan.fromJson(Map<String, dynamic> j) => ReadingPlan(
    id: j['id'] as String,
    title: j['title'] as String,
    description: j['description'] as String,
    days: [
      for (final d in j['days'] as List<dynamic>)
        [
          for (final c in d as List<dynamic>)
            (
              bookId: (c as List<dynamic>)[0] as String,
              chapter: (c[1] as num).toInt(),
            ),
        ],
    ],
  );

  final String id;
  final String title;
  final String description;
  final List<List<({String bookId, int chapter})>> days;
}

@immutable
class StudyTheme {
  const StudyTheme({
    required this.id,
    required this.title,
    required this.items,
  });

  factory StudyTheme.fromJson(Map<String, dynamic> j) => StudyTheme(
    id: j['id'] as String,
    title: j['title'] as String,
    items: (j['items'] as List<dynamic>).cast<String>(),
  );

  final String id;
  final String title;
  final List<String> items;
}

/// Glosario, Escuela Bíblica, asistente y planes de la Biblia Boricua.
class BoricuaResources {
  BoricuaResources({
    required this.glossary,
    required this.school,
    required this.assistant,
    required this.plans,
    required this.themes,
  });

  factory BoricuaResources.fromJson(Map<String, dynamic> j) => BoricuaResources(
    glossary: [
      for (final g in j['glossary'] as List<dynamic>)
        GlossaryTerm.fromJson(g as Map<String, dynamic>),
    ],
    school: [
      for (final l in j['school'] as List<dynamic>)
        SchoolLevel.fromJson(l as Map<String, dynamic>),
    ],
    assistant: [
      for (final a in j['assistant'] as List<dynamic>)
        AssistantAnswer.fromJson(a as Map<String, dynamic>),
    ],
    plans: [
      for (final p in j['plans'] as List<dynamic>)
        ReadingPlan.fromJson(p as Map<String, dynamic>),
    ],
    themes: [
      for (final t in j['themes'] as List<dynamic>)
        StudyTheme.fromJson(t as Map<String, dynamic>),
    ],
  );

  final List<GlossaryTerm> glossary;
  final List<SchoolLevel> school;
  final List<AssistantAnswer> assistant;
  final List<ReadingPlan> plans;
  final List<StudyTheme> themes;

  Lesson? lesson(String id) {
    for (final level in school) {
      for (final l in level.lessons) {
        if (l.id == id) return l;
      }
    }
    return null;
  }

  ReadingPlan? plan(String id) => plans.where((p) => p.id == id).firstOrNull;
}
