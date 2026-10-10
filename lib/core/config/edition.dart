import 'package:flutter/services.dart' show appFlavor;

import '../theme/app_palette.dart';

/// Ediciones de la app. Cada una se instala como una app aparte (sabor de
/// Android): `flutter build apk --flavor yave`, `--flavor jehova` o
/// `--flavor jesus`.
enum Edition {
  /// Todas las palabras, de Génesis a Apocalipsis, con el nombre «Yavé».
  yave(
    appName: 'Todo lo que Dios Dijo',
    divineName: 'Yavé',
    contentAsset: 'assets/data/content.json',
    span: 'de Génesis a Apocalipsis',
    milestones: 'Génesis · Profetas · Evangelios · Apocalipsis',
    light: AppPalette.light,
    dark: AppPalette.dark,
  ),

  /// Solo el Antiguo Testamento, con el nombre «Jehová», en azul y blanco.
  jehova(
    appName: 'Todo lo que Jehová Dijo',
    divineName: 'Jehová',
    contentAsset: 'assets/data/content_jehova.json',
    span: 'de Génesis a Malaquías',
    milestones: 'Génesis · Moisés · Profetas · Malaquías',
    light: AppPalette.jehovaLight,
    dark: AppPalette.jehovaDark,
  ),

  /// Todas las palabras de Jesús, de Mateo a Apocalipsis, en dorado y verde.
  jesus(
    appName: 'Todo lo que Jesús Dijo',
    divineName: 'Jesús',
    speaker: 'Jesús',
    contentAsset: 'assets/data/content_jesus.json',
    span: 'de Mateo a Apocalipsis',
    start: 'Mateo',
    milestones: 'Mateo · Marcos · Lucas · Juan · Apocalipsis',
    divineSample: 'Yo soy el camino, y la verdad, y la vida.',
    narratorSample: 'En el principio era el Verbo, y el Verbo era con Dios.',
    readAloud:
        'Yo soy el buen pastor: el buen pastor su vida da por las ovejas. '
        'Venid a mí todos los que estáis trabajados y cargados, y yo os '
        'haré descansar.',
    light: AppPalette.jesusLight,
    dark: AppPalette.jesusDark,
  );

  const Edition({
    required this.appName,
    required this.divineName,
    required this.contentAsset,
    required this.span,
    required this.milestones,
    required this.light,
    required this.dark,
    this.speaker = 'Dios',
    this.start = 'Génesis',
    this.divineSample,
    this.narratorSample = 'En el principio creó Dios los cielos y la tierra.',
    this.readAloud,
  });

  final String appName;

  /// El nombre de Dios que usa esta edición.
  final String divineName;

  /// Quién habla en las palabras de esta edición («Dios», «Jesús»), para
  /// los textos de la app.
  final String speaker;

  /// El libro donde empieza el recorrido.
  final String start;

  final String? divineSample;

  /// Frase para probar la voz del narrador.
  final String narratorSample;

  final String? readAloud;

  /// Frase para probar la voz de Dios (o de Jesús).
  String get divineSampleText => divineSample ?? 'Yo soy $divineName tu Dios.';

  /// Texto que el usuario lee en voz alta para medir el tono de su voz.
  String get readAloudText =>
      readAloud ??
      '$divineName es mi pastor; nada me faltará. En lugares de delicados '
          'pastos me hará yacer; junto a aguas de reposo me pastoreará. '
          'Confortará mi alma.';

  /// Contenido empaquetado en la app.
  final String contentAsset;

  /// Desde dónde hasta dónde va el recorrido («de Génesis a Malaquías»).
  final String span;

  /// Hitos del recorrido para la bienvenida.
  final String milestones;

  final AppPalette light;
  final AppPalette dark;

  /// Solo la edición completa recibe actualizaciones del contenido por
  /// internet (traen todas las palabras con «Yavé»).
  bool get syncsContent => this == yave;

  /// La edición de esta app, según el sabor con que se compiló.
  static final Edition current = switch (appFlavor) {
    'jehova' => jehova,
    'jesus' => jesus,
    _ => yave,
  };
}
