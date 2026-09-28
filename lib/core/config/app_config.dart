/// Constantes globales de la aplicación.
abstract final class AppConfig {
  static const appName = 'Todo lo que Dios Dijo';
  static const tagline = 'Las palabras de Yavé, de Génesis a Apocalipsis';

  /// Contenido empaquetado: garantiza lectura offline desde la primera apertura.
  static const bundledContentAsset = 'assets/data/content.json';

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
