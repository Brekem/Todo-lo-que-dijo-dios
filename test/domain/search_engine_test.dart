import 'package:flutter_test/flutter_test.dart';
import 'package:todo_lo_que_dios_dijo/core/utils/text_normalizer.dart';
import 'package:todo_lo_que_dios_dijo/domain/search/search_engine.dart';

import '../helpers.dart';

void main() {
  final content = loadContent();
  final engine = SearchEngine(content.passages);

  List<String> ids(String q, [SearchMode mode = SearchMode.all]) =>
      engine.search(q, mode: mode).map((r) => r.passage.id).toList();

  test('normaliza tildes, mayúsculas y signos', () {
    expect(TextNormalizer.normalize('¡PERDÓN, Señor!'), 'perdon senor');
  });

  test('encuentra por referencia bíblica', () {
    expect(ids('Génesis 12:1').first, 'gen-12-1');
    expect(ids('josue 1:9').first, 'jos-1-9');
  });

  test('entiende sinónimos: estrés → ansiedad', () {
    final results = engine.search('estrés', mode: SearchMode.problem);
    expect(results, isNotEmpty);
    expect(
      results
          .take(5)
          .every(
            (r) =>
                r.passage.categories.contains('ansiedad') ||
                r.passage.problems.any(
                  (p) => p.contains('estrés') || p.contains('ansiedad'),
                ),
          ),
      isTrue,
    );
  });

  test('tolera errores de escritura', () {
    expect(ids('resureccion'), contains('jua-11-25'));
  });

  test('busca por personaje bíblico', () {
    final moises = ids('Moisés', SearchMode.person);
    expect(moises, containsAll(['exo-3-14', 'exo-33-14']));
    expect(ids('Elías', SearchMode.person).take(15), contains('1re-19-9'));
  });

  test('busca por tema', () {
    expect(ids('perdón', SearchMode.topic), contains('mat-18-22'));
  });

  test('frases completas del usuario', () {
    final r = ids('tengo mucho miedo al futuro');
    expect(r, isNotEmpty);
    expect(content.passageById(r.first)!.categories, contains('miedo'));
  });

  test('una búsqueda vacía no devuelve nada', () {
    expect(engine.search('   '), isEmpty);
    expect(engine.search('de la que'), isEmpty);
  });
}
