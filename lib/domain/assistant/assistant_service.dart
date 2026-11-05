import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/text_normalizer.dart';
import '../../data/models/bible.dart';
import '../../data/models/boricua_resources.dart';

/// Lo que contesta el asistente: siempre pasaje, explicación, aplicación,
/// oración y próximo paso.
@immutable
class AssistantReply {
  const AssistantReply({
    required this.question,
    required this.reference,
    required this.text,
    required this.explanation,
    required this.application,
    required this.prayer,
    required this.nextStep,
    this.help,
    this.fromAi = false,
  });

  factory AssistantReply.fromAnswer(String question, AssistantAnswer a) =>
      AssistantReply(
        question: question,
        reference: a.reference,
        text: a.text,
        explanation: a.explanation,
        application: a.application,
        prayer: a.prayer,
        nextStep: a.nextStep,
        help: a.help,
      );

  final String question;
  final String reference;
  final String text;
  final String explanation;
  final String application;
  final String prayer;
  final String nextStep;
  final String? help;
  final bool fromAi;
}

abstract interface class AssistantService {
  Future<AssistantReply> ask(String question);
}

/// Respuestas escritas a mano: busca la pregunta más parecida.
class OfflineAssistant implements AssistantService {
  OfflineAssistant(this.resources);

  final BoricuaResources resources;

  /// Señales de crisis: se responde siempre con las líneas de ayuda.
  static final _crisis = RegExp(
    r'suicid|matarme|quitarme la vida|no quiero vivir|hacerme dano|morirme',
  );

  bool isCrisis(String question) =>
      _crisis.hasMatch(TextNormalizer.normalize(question));

  AssistantAnswer? best(String question) {
    final q = ' ${TextNormalizer.normalize(question)} ';
    if (isCrisis(question)) {
      return resources.assistant.firstWhere(
        (a) => a.help?.contains('988') ?? false,
      );
    }
    AssistantAnswer? best;
    var bestScore = 0;
    for (final a in resources.assistant) {
      var score = 0;
      for (final k in a.keywords) {
        if (q.contains(TextNormalizer.normalize(k))) score += 2;
      }
      for (final w in TextNormalizer.tokens(a.question)) {
        if (w.length > 3 && q.contains(' $w')) score += 1;
      }
      if (score > bestScore) {
        bestScore = score;
        best = a;
      }
    }
    return best;
  }

  @override
  Future<AssistantReply> ask(String question) async {
    final a = best(question);
    if (a != null) return AssistantReply.fromAnswer(question, a);
    // Sin coincidencia: una respuesta general que invita a seguir buscando.
    final general = resources.assistant.firstWhere(
      (a) => a.question.contains('empiezo a leer'),
      orElse: () => resources.assistant.first,
    );
    return AssistantReply(
      question: question,
      reference: 'Jeremías 33:3',
      text: 'Clama a mí, y te responderé, y te enseñaré cosas grandes y dificultosas que tú no sabes.',
      explanation: 'Todavía no tengo una respuesta escrita para esa pregunta, pero Dios te invita a buscarlo con confianza. Él escucha y responde.',
      application: 'Usa el buscador de la Biblia con una palabra clave de tu situación y lee los estudios relacionados. Habla también con un pastor o un hermano maduro en la fe.',
      prayer: 'Señor, tú conoces mi situación mejor que yo. Te busco y confío en que me vas a responder. Amén.',
      nextStep: general.nextStep,
    );
  }
}

/// Con Firebase: Gemini contesta cualquier pregunta con el mismo formato. El
/// texto bíblico sale siempre de la Biblia de la app (nunca de la IA).
class AiAssistant implements AssistantService {
  AiAssistant({
    required this.fallback,
    required this.bible,
    GenerativeModel? model,
  }) : _model = model ?? _createModel();

  final OfflineAssistant fallback;
  final Bible bible;
  final GenerativeModel _model;

  static GenerativeModel _createModel() =>
      FirebaseAI.googleAI().generativeModel(
        model: AppConfig.aiModel,
        systemInstruction: Content.system('''
Eres un consejero cristiano de Puerto Rico, cálido y fiel a la Biblia. Hablas
en español puertorriqueño contemporáneo, sencillo y respetuoso, sin palabras
antiguas ("he aquí", "vosotros", "empero") ni jerga vulgar.
Contesta la pregunta con JSON:
- reference: UNA cita bíblica real y pertinente, con el nombre del libro en
  español y el formato "Libro capítulo:versículo" o "Libro capítulo:inicio-fin"
  (por ejemplo "Filipenses 4:6-7").
- explanation: 2–4 oraciones sencillas.
- application: 2–3 pasos prácticos.
- prayer: una oración breve que termine con "Amén."
- nextStep: un próximo paso concreto (un estudio, un pasaje o una acción).
Si la persona menciona suicidio, autolesión, abuso o peligro, anímala con amor
a llamar al 988 o al 911 y a buscar ayuda profesional. No des consejo médico,
legal ni financiero; no prometas resultados específicos.
'''),
        generationConfig: GenerationConfig(
          temperature: 0.5,
          maxOutputTokens: 1000,
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'reference': Schema.string(),
              'explanation': Schema.string(),
              'application': Schema.string(),
              'prayer': Schema.string(),
              'nextStep': Schema.string(),
            },
          ),
        ),
      );

  @override
  Future<AssistantReply> ask(String question) async {
    // Las crisis y las preguntas que ya tienen respuesta escrita no van a la IA.
    final written = fallback.best(question);
    if (written != null) return AssistantReply.fromAnswer(question, written);
    try {
      final response = await _model.generateContent([Content.text(question)]);
      final j = jsonDecode(response.text ?? '') as Map<String, dynamic>;
      final reference = j['reference'] as String;
      final parsed = bible.parse(reference);
      if (parsed == null) return await fallback.ask(question);
      final text = [
        for (var v = parsed.from; v <= parsed.to; v++)
          parsed.book.chapter(parsed.chapter)[v - 1],
      ].join(' ');
      return AssistantReply(
        question: question,
        reference: reference,
        text: text,
        explanation: j['explanation'] as String,
        application: j['application'] as String,
        prayer: j['prayer'] as String,
        nextStep: j['nextStep'] as String,
        fromAi: true,
      );
    } catch (e) {
      debugPrint('Asistente con IA no disponible: $e');
      return fallback.ask(question);
    }
  }
}
