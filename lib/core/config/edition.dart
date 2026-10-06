import 'package:flutter/services.dart' show appFlavor;

import '../theme/app_palette.dart';

/// Ediciones de la app. Cada una se instala como una app aparte (sabor de
/// Android): `flutter build apk --flavor yave` o `--flavor jehova`.
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
  );

  const Edition({
    required this.appName,
    required this.divineName,
    required this.contentAsset,
    required this.span,
    required this.milestones,
    required this.light,
    required this.dark,
  });

  final String appName;

  /// El nombre de Dios que usa esta edición.
  final String divineName;

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
  static final Edition current = appFlavor == 'jehova' ? jehova : yave;
}
