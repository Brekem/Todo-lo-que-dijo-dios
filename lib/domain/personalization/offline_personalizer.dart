import '../../core/utils/text_normalizer.dart';
import '../../data/models/passage.dart';
import '../../data/models/saved_word.dart';
import '../search/synonyms.dart';
import 'personalization_service.dart';

/// Personalización sin conexión, basada en plantillas y en el contenido del
/// pasaje. Se usa cuando no hay internet o la IA no está configurada.
class OfflinePersonalizer implements PersonalizationService {
  const OfflinePersonalizer();

  static const Map<String, String> _steps = {
    'miedo': 'Nombra en voz alta aquello que temes y, junto a ello, declara la promesa de este pasaje. El miedo pierde fuerza cuando lo pones delante de Dios.',
    'ansiedad': 'Respira despacio, escribe lo que te preocupa y entrégaselo a Dios punto por punto. Luego da un solo paso concreto para hoy, no para toda la semana.',
    'culpa': 'Confiesa con sinceridad lo que hiciste, pide perdón a quien corresponda y acepta que el perdón de Dios es real. No sigas cargando lo que Él ya quitó.',
    'tristeza': 'Permítete llorar delante de Dios, sin fingir. Busca hoy a una persona de confianza y cuéntale cómo te sientes.',
    'soledad': 'Recuerda que Dios está contigo ahora mismo. Da un paso hacia otros: escribe a alguien, visita a alguien, únete a una comunidad.',
    'fe': 'Escribe esta promesa y colócala donde la veas cada día. Actúa hoy como alguien que cree que Dios cumple lo que dice.',
    'obediencia': 'Identifica una cosa concreta que Dios te está pidiendo y hazla hoy, aunque sea pequeña. La obediencia se aprende caminando.',
    'amor': 'Elige a una persona y muéstrale hoy el amor de Dios con un gesto concreto: tiempo, escucha, una palabra amable.',
    'perdon': 'Piensa en la persona que te hirió y decide soltar la deuda delante de Dios. Perdonar no es negar el dolor, es dejar de cargarlo.',
    'esperanza': 'Escribe qué esperas que Dios haga y agradécele por adelantado. La esperanza crece cuando recuerdas lo que Él ya hizo.',
  };

  @override
  Future<Personalization> personalize({
    required Passage passage,
    required String userSituation,
  }) async {
    final situation = userSituation.trim();
    final topic = _detectTopic(situation) ?? _fallbackTopic(passage);
    final shortQuote = _shorten(passage.quote);

    final explanation =
        'Yavé le habló a ${passage.recipient} en un momento muy concreto: '
        '${_lowerFirst(passage.situation)} Hoy tú le traes esto: «$situation». '
        '${passage.explanation} Lo que Dios le dijo entonces también revela cómo te mira a ti ahora.';

    final application = StringBuffer()
      ..write('Si hoy estás enfrentando «$situation», ')
      ..write('${_lowerFirst(passage.application)}\n\n')
      ..write('Un paso para hoy: ${_steps[topic] ?? _steps['fe']!}');
    if (isCrisis(situation)) application.write('\n\n$crisisNotice');

    final prayer =
        'Señor, hoy pongo delante de ti esto que estoy viviendo: '
        '$situation. Tú dijiste: «$shortQuote». Creo que esa palabra también es '
        'para mí. ${passage.prayer}';

    return Personalization(
      userSituation: situation,
      explanation: explanation,
      application: application.toString(),
      prayer: prayer,
      generatedByAi: false,
    );
  }

  static String? _detectTopic(String text) {
    for (final token in TextNormalizer.tokens(text)) {
      for (final entry in kSynonyms.entries) {
        if (entry.key == token || entry.value.contains(token)) {
          if (_steps.containsKey(entry.key)) return entry.key;
        }
      }
    }
    return null;
  }

  static String _fallbackTopic(Passage p) {
    final first = p.categories.isEmpty ? 'fe' : p.categories.first;
    return first.split('-').last;
  }

  static String _shorten(String quote) {
    if (quote.length <= 180) return quote;
    final cut = quote.substring(0, 180);
    final lastSpace = cut.lastIndexOf(' ');
    return '${cut.substring(0, lastSpace > 0 ? lastSpace : 180)}…';
  }

  static String _lowerFirst(String s) =>
      s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);
}
