import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../../core/config/app_config.dart';
import '../../core/config/edition.dart';
import '../../data/models/passage.dart';
import '../../data/models/saved_word.dart';
import 'personalization_service.dart';

/// Personalización con IA mediante Firebase AI Logic (Gemini).
///
/// Si falla (sin conexión, cuota, etc.) delega en [fallback].
class AiPersonalizer implements PersonalizationService {
  AiPersonalizer({required this.fallback, GenerativeModel? model})
    : _model = model ?? _createModel();

  final PersonalizationService fallback;
  final GenerativeModel _model;

  static GenerativeModel _createModel() =>
      FirebaseAI.googleAI().generativeModel(
        model: AppConfig.aiModel,
        systemInstruction: Content.system(_systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.6,
          maxOutputTokens: 1200,
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'explanation': Schema.string(),
              'application': Schema.string(),
              'prayer': Schema.string(),
            },
            propertyOrdering: const ['explanation', 'application', 'prayer'],
          ),
        ),
      );

  static final _systemPrompt =
      '''
Eres un acompañante pastoral cristiano, cálido, sereno y fiel a la Biblia.
Hablas en español neutro, con frases sencillas y respetuosas. ${Edition.current == Edition.jesus ? 'Hablas de Jesús como el Hijo de Dios.' : 'Usas "${Edition.current.divineName}" como\nnombre de Dios en el Antiguo Testamento.'}
Recibirás un pasaje donde ${Edition.current.speaker} habla directamente y la situación de una persona.
Devuelve JSON con:
- explanation: 2–3 frases que expliquen qué significó el pasaje en su contexto y
  qué significa para la situación de la persona.
- application: comienza con "Si hoy estás enfrentando…" y da 2–3 pasos prácticos,
  concretos y realistas.
- prayer: una oración en primera persona (4–6 frases) que comience con "Señor,".
Reglas: no inventes versículos ni cites otras referencias que no conozcas con
certeza; no prometas resultados específicos (sanidad, dinero, pareja); no
condenes; no des consejo médico, legal ni financiero. Si la persona menciona
autolesión, suicidio, abuso o peligro, anímala con amor a buscar ayuda
profesional y a llamar a emergencias o a una línea de prevención de su país.
''';

  @override
  Future<Personalization> personalize({
    required Passage passage,
    required String userSituation,
  }) async {
    final situation = userSituation.trim();
    try {
      final prompt =
          '''
Pasaje: ${passage.reference}
Lo que ${Edition.current.speaker} dijo: "${passage.quote}"
A quién: ${passage.recipient}
Contexto: ${passage.historicalContext}
Situación entonces: ${passage.situation}
Problema que ${Edition.current.speaker} trataba: ${passage.problem}

Situación de la persona hoy: "$situation"
''';
      final response = await _model
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 25));
      final json = jsonDecode(response.text ?? '') as Map<String, dynamic>;
      var application = (json['application'] as String).trim();
      if (isCrisis(situation) && !application.contains('emergencia')) {
        application = '$application\n\n$crisisNotice';
      }
      return Personalization(
        userSituation: situation,
        explanation: (json['explanation'] as String).trim(),
        application: application,
        prayer: (json['prayer'] as String).trim(),
        generatedByAi: true,
      );
    } catch (_) {
      return fallback.personalize(passage: passage, userSituation: situation);
    }
  }
}
