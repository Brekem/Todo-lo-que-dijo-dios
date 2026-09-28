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

/// La cita, separada en el anuncio del narrador y lo que Dios dijo.
typedef QuoteParts = ({String announcement, String words, bool divine});

/// Convierte cada palabra de Dios en frases listas para el lector de voz.
abstract final class Narration {
  /// Anuncio antes de la cita («Escucha. Habla Yavé.») y las palabras mismas.
  ///
  /// [divine] es `false` cuando la cita no son palabras de Dios sino un
  /// pasaje sobre «la voz de Yavé»; entonces la lee el narrador.
  static QuoteParts quoteParts(Passage p) {
    final words = _clean(p.quote);
    if (p.id.startsWith('v-')) {
      return (
        announcement: 'Sobre la voz de Yavé.',
        words: words,
        divine: false,
      );
    }
    final who = switch (p.speaker) {
      'La voz del Padre' => 'el Padre',
      'El Señor' || 'La voz del Señor' => 'el Señor',
      'El Espíritu Santo' => 'el Espíritu Santo',
      'Jesús resucitado' || 'Jesús glorificado' => 'Jesús',
      final s => s,
    };
    return (announcement: 'Escucha. Habla $who.', words: words, divine: true);
  }

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
          NarrationSection.quote => () {
            final q = quoteParts(p);
            return '${q.announcement} ${q.words}';
          }(),
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
