/// Diccionario de sinónimos para que la búsqueda entienda cómo habla la gente.
/// Claves y valores normalizados (sin tildes, minúsculas).
const Map<String, List<String>> kSynonyms = {
  'miedo': [
    'temor',
    'temas',
    'panico',
    'susto',
    'terror',
    'cobardia',
    'valiente',
    'desmayes',
  ],
  'ansiedad': [
    'angustia',
    'preocupacion',
    'afan',
    'estres',
    'nervios',
    'congojeis',
    'turbe',
    'inquietud',
    'agobio',
  ],
  'culpa': [
    'pecado',
    'pecados',
    'verguenza',
    'remordimiento',
    'rebeliones',
    'condeno',
    'error',
    'fracaso',
  ],
  'tristeza': [
    'depresion',
    'llanto',
    'lagrima',
    'dolor',
    'duelo',
    'luto',
    'desanimo',
    'deprimido',
    'triste',
  ],
  'soledad': [
    'solo',
    'sola',
    'abandono',
    'abandonado',
    'olvidado',
    'rechazo',
    'aislamiento',
  ],
  'fe': ['confianza', 'creer', 'duda', 'dudas', 'incredulidad', 'certeza'],
  'obediencia': [
    'obedecer',
    'mandamiento',
    'mandato',
    'llamado',
    'proposito',
    'vocacion',
    've',
  ],
  'amor': [
    'amar',
    'amado',
    'amados',
    'ameis',
    'misericordia',
    'compasion',
    'bondad',
  ],
  'perdon': [
    'perdonar',
    'perdonare',
    'rencor',
    'reconciliacion',
    'ofensa',
    'venganza',
  ],
  'esperanza': [
    'futuro',
    'promesa',
    'nuevo',
    'nueva',
    'restauracion',
    'porvenir',
    'animo',
  ],
  'muerte': ['morir', 'muerto', 'resurreccion', 'eternidad', 'perdida'],
  'debilidad': [
    'flaqueza',
    'cansancio',
    'cansado',
    'agotado',
    'fuerza',
    'fortaleza',
    'esfuerzo',
  ],
  'paz': [
    'descanso',
    'descansar',
    'calma',
    'quietos',
    'tranquilidad',
    'reposo',
  ],
  'enfermedad': ['sanidad', 'sanar', 'sanare', 'salud'],
  'insuficiencia': [
    'incapaz',
    'inseguridad',
    'autoestima',
    'complejo',
    'nino',
    'boca',
  ],
};

/// Mapa inverso: término → términos equivalentes (incluida la clave).
final Map<String, Set<String>> kSynonymIndex = () {
  final index = <String, Set<String>>{};
  kSynonyms.forEach((key, values) {
    final group = {key, ...values};
    for (final term in group) {
      (index[term] ??= <String>{}).addAll(group);
    }
  });
  return index;
}();
