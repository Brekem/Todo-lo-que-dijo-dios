// ARCHIVO DE MARCADOR DE POSICIÓN.
//
// Genera la configuración real de tu proyecto de Firebase con:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=<tu-proyecto> --platforms=android
//
// Ese comando sobrescribe este archivo. Mientras no exista configuración,
// la app funciona 100 % offline: sin sincronización, sin analíticas y con la
// personalización sin IA.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Firebase no está configurado. Ejecuta `flutterfire configure`.',
  );
}
