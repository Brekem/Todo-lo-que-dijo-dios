/// Normaliza texto en español para búsquedas: minúsculas, sin tildes ni signos.
abstract final class TextNormalizer {
  static const Map<String, String> _accents = {
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'â': 'a',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'ê': 'e',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'î': 'i',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ô': 'o',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'û': 'u',
    'ñ': 'n',
    'ç': 'c',
  };

  static final RegExp _nonWord = RegExp(r'[^a-z0-9\s:]');
  static final RegExp _spaces = RegExp(r'\s+');

  static const Set<String> stopWords = {
    'a',
    'al',
    'con',
    'de',
    'del',
    'el',
    'en',
    'es',
    'la',
    'las',
    'lo',
    'los',
    'me',
    'mi',
    'mis',
    'o',
    'para',
    'por',
    'que',
    'se',
    'si',
    'su',
    'sus',
    'te',
    'tu',
    'tus',
    'un',
    'una',
    'y',
    'yo',
    'estoy',
    'tengo',
    'siento',
    'muy',
    'mucho',
    'mucha',
    'como',
    'cuando',
    'dios',
    'dice',
    'dijo',
  };

  static String normalize(String input) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_accents[ch] ?? ch);
    }
    return buffer
        .toString()
        .replaceAll(_nonWord, ' ')
        .replaceAll(_spaces, ' ')
        .trim();
  }

  /// Tokens significativos (sin palabras vacías).
  static List<String> tokens(String input) =>
      normalize(input)
          .split(' ')
          .where((t) => t.isNotEmpty && !stopWords.contains(t))
          .toList();
}
