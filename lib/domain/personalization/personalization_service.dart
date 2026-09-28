import '../../data/models/passage.dart';
import '../../data/models/saved_word.dart';

/// Personaliza explicación, aplicación y oración según lo que vive el usuario.
abstract interface class PersonalizationService {
  Future<Personalization> personalize({
    required Passage passage,
    required String userSituation,
  });
}

/// Palabras que indican una posible crisis: se añade siempre una invitación
/// a buscar ayuda inmediata (requisito de las políticas de Google Play).
const _crisisTerms = [
  'suicid',
  'matarme',
  'quitarme la vida',
  'no quiero vivir',
  'hacerme dano',
  'hacerme daño',
  'autolesion',
  'morirme',
];

bool isCrisis(String text) {
  final lower = text.toLowerCase();
  return _crisisTerms.any(lower.contains);
}

const crisisNotice =
    'Si estás pensando en hacerte daño, no estás solo: busca ayuda ahora mismo. '
    'Llama al número de emergencias de tu país o a una línea de prevención del '
    'suicidio, y habla hoy con alguien de confianza.';
