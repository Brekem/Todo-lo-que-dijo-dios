import '../../data/models/passage.dart';

/// Secciones que se leen en voz alta, en el mismo orden que la pantalla de lectura.
enum NarrationSection {
  intro('Presentación'),
  quote('Lo que dijo Dios'),
  reference('Referencia bíblica'),
  recipient('¿A quién habló Dios?'),
  context('Contexto histórico'),
  situation('¿Qué estaba pasando?'),
  problem('Problema que Dios estaba tratando'),
  explanation('Explicación sencilla'),
  application('Aplicación para hoy'),
  prayer('Oración de liberación');

  const NarrationSection(this.title);
  final String title;
}

/// Convierte cada palabra de Dios en frases listas para el lector de voz.
abstract final class Narration {
  static List<String> segments(
    Passage p, {
    required int position,
    required int total,
    required String eraTitle,
  }) {
    return [
      for (final section in NarrationSection.values)
        _clean(switch (section) {
          NarrationSection.intro => 'Palabra $position de $total. $eraTitle.',
          // Los pasajes completos ya incluyen «Y dijo Yavé…» en el texto.
          NarrationSection.quote =>
            p.curated ? '${p.speaker} dijo: ${p.quote}' : p.quote,
          NarrationSection.reference => '${spokenReference(p.reference)}.',
          NarrationSection.recipient =>
            '¿A quién habló Dios? A ${p.recipient}.',
          NarrationSection.context =>
            'Contexto histórico. ${p.historicalContext}',
          NarrationSection.situation => '¿Qué estaba pasando? ${p.situation}',
          NarrationSection.problem =>
            'Problema que Dios estaba tratando. Dios estaba corrigiendo: '
                '${p.problems.join(', ')}. ${p.problem}',
          NarrationSection.explanation =>
            'Explicación sencilla. ${p.explanation}',
          NarrationSection.application =>
            'Aplicación para hoy. ${p.application}',
          NarrationSection.prayer => 'Oración de liberación. ${p.prayer}',
        }),
    ];
  }

  static const _books = {
    '1 Samuel': 'Primero de Samuel',
    '2 Samuel': 'Segundo de Samuel',
    '1 Reyes': 'Primero de Reyes',
    '2 Reyes': 'Segundo de Reyes',
    '1 Crónicas': 'Primero de Crónicas',
    '2 Crónicas': 'Segundo de Crónicas',
    '1 Corintios': 'Primera de Corintios',
    '2 Corintios': 'Segunda de Corintios',
  };

  static final _ref = RegExp(r'^(.+?)\s+(\d+):(.+)$');

  /// "Génesis 12:1-2" → "Génesis, capítulo 12, versículos 1 al 2".
  static String spokenReference(String reference) {
    final m = _ref.firstMatch(reference);
    if (m == null) return reference;
    final book = _books[m[1]!] ?? m[1]!;
    final verses = m[3]!.replaceAll(' ', '');
    final many = verses.contains('-') || verses.contains(',');
    final spokenVerses = verses.replaceAll('-', ' al ').replaceAll(',', ' y ');
    return '$book, capítulo ${m[2]}, '
        '${many ? 'versículos' : 'versículo'} $spokenVerses';
  }

  /// Quita signos que el lector pronunciaría mal.
  static String _clean(String text) => text
      .replaceAll('«', '')
      .replaceAll('»', '')
      .replaceAll('…', ', ')
      .replaceAll('a. C.', 'antes de Cristo')
      .replaceAll('d. C.', 'después de Cristo')
      .replaceAll(RegExp(r'\bc\. (?=\d)'), 'cerca del año ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
