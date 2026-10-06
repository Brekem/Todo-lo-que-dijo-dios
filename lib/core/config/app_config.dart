import 'edition.dart';

/// Constantes globales de la aplicación.
abstract final class AppConfig {
  static String get appName => Edition.current.appName;
  static String get tagline =>
      'Las palabras de ${Edition.current.divineName}, ${Edition.current.span}';

  /// Contenido empaquetado: garantiza lectura offline desde la primera apertura.
  static String get bundledContentAsset => Edition.current.contentAsset;

  /// Firestore: `content/current` guarda { version, translation, categories, passages }.
  static const firestoreContentCollection = 'content';
  static const firestoreContentDoc = 'current';

  static const cachedContentFile = 'content_cache.json';

  /// Modelo de Firebase AI Logic. Se puede cambiar sin tocar código:
  /// `flutter build appbundle --dart-define=AI_MODEL=gemini-2.5-flash`.
  static const aiModel = String.fromEnvironment(
    'AI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );
}
