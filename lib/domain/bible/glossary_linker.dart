import '../../core/utils/text_normalizer.dart';
import '../../data/models/boricua_resources.dart';

/// Encuentra los términos de teología que aparecen en un texto, para
/// explicarlos automáticamente.
abstract final class GlossaryLinker {
  static List<GlossaryTerm> termsIn(String text, List<GlossaryTerm> glossary) {
    final t = ' ${TextNormalizer.normalize(text)} ';
    return [
      for (final g in glossary)
        if (_matches(TextNormalizer.normalize(g.term), t)) g,
    ];
  }

  static bool _matches(String term, String text) {
    // «Justificación» también encuentra «justificados»; «Salvación», «salvos».
    if (!term.contains(' ') && term.endsWith('cion') && term.length > 7) {
      return text.contains(' ${term.substring(0, term.length - 4)}');
    }
    // Palabras sueltas: la palabra entera o su plural («gracia», no
    // «gracias»; «pecado» y «pecados»).
    if (term == 'gracia') return text.contains(' gracia ');
    return text.contains(' $term ') ||
        text.contains(' ${term}s ') ||
        text.contains(' ${term}es ');
  }
}
