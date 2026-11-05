import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../data/models/bible.dart';
import '../../data/models/content_bundle.dart';
import '../../data/models/passage.dart';

/// De dónde viene la explicación de un versículo.
enum ExplanationSource {
  /// Escrita a mano en un estudio de la app.
  study,

  /// Generada con IA (y guardada para no generarla otra vez).
  ai,
}

/// Paráfrasis boricua, explicación simple, aplicación y oración de un versículo.
@immutable
class VerseExplanation {
  const VerseExplanation({
    required this.paraphrase,
    required this.explanation,
    required this.application,
    required this.prayer,
    required this.source,
    this.study,
  });

  factory VerseExplanation.fromJson(Map<String, dynamic> j) => VerseExplanation(
    paraphrase: j['paraphrase'] as String,
    explanation: j['explanation'] as String,
    application: j['application'] as String,
    prayer: j['prayer'] as String,
    source: ExplanationSource.ai,
  );

  final String paraphrase;
  final String explanation;
  final String application;
  final String prayer;
  final ExplanationSource source;

  /// El estudio completo que incluye este versículo, si lo hay.
  final Passage? study;

  Map<String, dynamic> toJson() => {
    'paraphrase': paraphrase,
    'explanation': explanation,
    'application': application,
    'prayer': prayer,
  };
}

abstract interface class VerseExplainer {
  /// `null` si no hay explicación disponible (sin estudio y sin IA).
  Future<VerseExplanation?> explain(VerseRef ref, {required String text});
}

/// Los estudios escritos a mano: si el versículo está en uno, se usa ese.
class StudyVerseExplainer implements VerseExplainer {
  StudyVerseExplainer(this.studies, this.bible);

  final ContentBundle studies;
  final Bible bible;

  Passage? studyFor(VerseRef ref) {
    final name = bible.book(ref.bookId)?.name;
    for (final p in studies.passages) {
      final study = p.study;
      if (study == null || p.book != name) continue;
      final parsed = bible.parse(p.reference);
      if (parsed != null &&
          parsed.chapter == ref.chapter &&
          ref.verse >= parsed.from &&
          ref.verse <= parsed.to) {
        return p;
      }
    }
    return null;
  }

  @override
  Future<VerseExplanation?> explain(
    VerseRef ref, {
    required String text,
  }) async {
    final p = studyFor(ref);
    final paraphrase = p?.study?.paraphrase[ref.verse];
    if (p == null || paraphrase == null) return null;
    return VerseExplanation(
      paraphrase: paraphrase,
      explanation: p.explanation,
      application: p.application,
      prayer: p.prayer,
      source: ExplanationSource.study,
      study: p,
    );
  }
}

/// Explicación con IA (Gemini en Firebase AI Logic) para cualquier versículo
/// que no tenga estudio. Se guarda en el teléfono y en la caché compartida de
/// Firestore (verseStudies/{libro.cap.vers}): cada versículo se genera una
/// sola vez para todos los usuarios.
class AiVerseExplainer implements VerseExplainer {
  AiVerseExplainer({
    required this.fallback,
    required this.prefs,
    required this.bible,
    FirebaseFirestore? db,
    GenerativeModel? model,
  }) : _db = db ?? FirebaseFirestore.instance,
       _model = model ?? _createModel();

  final VerseExplainer fallback;
  final SharedPreferences prefs;
  final Bible bible;
  final FirebaseFirestore _db;
  final GenerativeModel _model;

  static const _cachePrefix = 'verse_ai_v1:';

  static GenerativeModel _createModel() =>
      FirebaseAI.googleAI().generativeModel(
        model: AppConfig.aiModel,
        systemInstruction: Content.system(systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.4,
          maxOutputTokens: 900,
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'paraphrase': Schema.string(),
              'explanation': Schema.string(),
              'application': Schema.string(),
              'prayer': Schema.string(),
            },
            propertyOrdering: const [
              'paraphrase',
              'explanation',
              'application',
              'prayer',
            ],
          ),
        ),
      );

  static const systemPrompt = '''
Eres un maestro bíblico cristiano de Puerto Rico: un creyente maduro que le
explica la Biblia a otro puertorriqueño sentado a su lado. Hablas en español
puertorriqueño contemporáneo, claro, natural y respetuoso. Nunca usas palabras
antiguas como "he aquí", "vosotros", "empero", "mas" (por "pero"), "acaecer" ni
"hallarse". No usas jerga vulgar ni expresiones que resten reverencia.
Recibirás un versículo de la Reina-Valera 1909 con su contexto.
Devuelve JSON con:
- paraphrase: el versículo dicho en español boricua de hoy, fiel al sentido
  original, sin añadir ideas.
- explanation: 2–3 oraciones sencillas sobre qué significa en su contexto.
- application: comienza con "Hoy" y da 1–2 pasos prácticos y realistas.
- prayer: una oración breve en primera persona que termine con "Amén."
Reglas: sé fiel a la Biblia y a la fe cristiana histórica; si un término
teológico aparece, explícalo en palabras sencillas; no inventes datos ni
fechas; no prometas resultados específicos; no des consejo médico, legal ni
financiero.
''';

  @override
  Future<VerseExplanation?> explain(
    VerseRef ref, {
    required String text,
  }) async {
    final own = await fallback.explain(ref, text: text);
    if (own != null) return own;

    final cached = prefs.getString('$_cachePrefix${ref.key}');
    if (cached != null) {
      return VerseExplanation.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      );
    }
    final doc = _db.collection('verseStudies').doc(ref.key);
    try {
      final shared = await doc.get();
      if (shared.exists) return _keep(ref, shared.data()!);
    } catch (e) {
      debugPrint('Caché compartida no disponible: $e');
    }
    try {
      final b = bible.book(ref.bookId)!;
      final chapter = b.chapter(ref.chapter);
      String verse(int v) =>
          v >= 1 && v <= chapter.length ? chapter[v - 1] : '';
      final response = await _model.generateContent([
        Content.text('''
Versículo: ${bible.reference(ref)}
Texto: "$text"
Antes: "${verse(ref.verse - 1)}"
Después: "${verse(ref.verse + 1)}"
'''),
      ]);
      final data = jsonDecode(response.text ?? '') as Map<String, dynamic>;
      final result = _keep(ref, data);
      _share(doc, result).ignore();
      return result;
    } catch (e) {
      debugPrint('Explicación con IA no disponible: $e');
      return null;
    }
  }

  /// Para todos: se escribe solo si no existía (ver firestore.rules), con una
  /// cuenta (anónima si no hay otra).
  Future<void> _share(
    DocumentReference<Map<String, dynamic>> doc,
    VerseExplanation result,
  ) async {
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) await auth.signInAnonymously();
      await doc.set({...result.toJson(), 'model': AppConfig.aiModel});
    } catch (e) {
      debugPrint('No se guardó en la caché compartida: $e');
    }
  }

  VerseExplanation _keep(VerseRef ref, Map<String, dynamic> data) {
    final result = VerseExplanation.fromJson(data);
    prefs.setString('$_cachePrefix${ref.key}', jsonEncode(result.toJson()));
    return result;
  }
}
