# Despliegue

## 1. Activar Firebase (nube, IA, sincronización y push)

1. Crea un proyecto en <https://console.firebase.google.com> con el plan Blaze (necesario para Cloud Functions y para la IA).
2. Agrega una app Android con el paquete `com.brekem.todoloquediosdijo.boricua`.
3. En la raíz del repositorio corre:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<tu-proyecto> --platforms=android
   ```
   Esto genera `lib/firebase_options.dart`.
4. En GitHub, ve a **Settings → Secrets → Actions** y crea el secreto `FIREBASE_OPTIONS_DART` con el contenido de ese archivo. CI ya lo usa en el paso «Configurar Firebase».
5. En la consola de Firebase:
   - **Authentication:** activa «Anónimo». Más adelante puedes activar Google o correo; la cuenta anónima se vincula sin perder datos.
   - **Firestore:** crea la base de datos (`us-east1`).
   - **AI Logic:** activa la Gemini Developer API. El modelo está en `AppConfig.aiModel`.
   - **App Check:** registra Play Integrity y aplícalo a Firestore y AI Logic.
   - **Cloud Messaging:** viene activo por defecto.
6. Despliega las reglas y las funciones:
   ```bash
   npm i -g firebase-tools && firebase login
   firebase deploy --only firestore:rules
   cd functions && npm install && npm run deploy
   ```

Con esto se activan:
- la paráfrasis boricua con IA de cualquier versículo;
- el asistente para cualquier pregunta;
- la sincronización de notas;
- el versículo del día por push.

## 2. Google Play

1. **Firma.** Crea una llave de subida y guárdala en los secretos `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` y `ANDROID_KEY_PASSWORD`. CI firma solo cuando existen.
2. **Compilación.** CI genera `build/app/outputs/bundle/boricuaRelease/app-boricua-release.aab` (lo sube como artefacto) y la APK `Biblia-Boricua.apk` en Releases.
3. **Play Console:**
   - Crea la app «Biblia Boricua» (`com.brekem.todoloquediosdijo.boricua`). Es otra app distinta de «Todo lo que Dios Dijo».
   - **Ficha:** descripción en español de Puerto Rico, capturas de 360 × 740 dp (las pruebas de pantalla sirven de guía) e ícono 512 × 512 azul `#0A3D91`.
   - **Seguridad de los datos:** declara el identificador de la cuenta anónima, las notas y marcadores del usuario (sincronización) y los diagnósticos (Crashlytics). No se venden datos. Política: `docs/PRIVACIDAD.md`.
   - **Clasificación de contenido:** referencia; sin violencia.
   - **Público objetivo:** mayores de 13 años. Si se dirige a niños aplican las políticas de Familias.
4. **Lanzamiento.** Prueba interna → prueba cerrada (iglesias y grupos piloto) → producción por etapas (10 % → 50 % → 100 %).
5. **Versiones.** Sube el número después de `+` en `version:` de `pubspec.yaml` cada vez. CI publica una release por versión.

## 3. App Store (iPhone)

Este repositorio todavía **no tiene proyecto iOS**. Se crea en una Mac con Xcode:

1. Corre `flutter create --platforms=ios .` y define el bundle id `com.brekem.bibliaboricua`.
2. Corre `flutterfire configure --platforms=ios` (genera `GoogleService-Info`).
3. Configura los esquemas de Xcode por sabor (`boricua`) o un target dedicado.
4. **Capacidades:**
   - *Background Modes → Audio* (lectura con la pantalla apagada);
   - *Push Notifications*;
   - *Background Modes → Remote notifications*.

   Sube a Firebase la llave APNs (.p8).
5. Agrega `PrivacyInfo.xcprivacy` (APIs de UserDefaults y razones de uso) y los textos de `Info.plist` para el micrófono («Parecida a mi voz»).
6. En App Store Connect:
   - crea la app;
   - completa Privacidad (las mismas categorías que en Play);
   - sube con `flutter build ipa --flavor boricua`;
   - pásala por TestFlight y luego a revisión.
7. Revisión de Apple: deja claro que la paráfrasis y la IA no reemplazan la Biblia (el aviso ya está en la app) y que el asistente no da consejo médico.

## 4. Fases

| Fase | Contenido | Estado |
|---|---|---|
| 1 | Biblia completa sin conexión; 1123 estudios (45 de Génesis, 42 de Éxodo, 43 de Levítico, 42 de Números, 45 de Deuteronomio, 43 de Josué, 43 de Jueces, 41 de Rut, 41 de 1 Samuel, 40 de 2 Samuel, 42 de 1 Reyes, 40 de 2 Reyes, 42 de 1 Crónicas, 40 de 2 Crónicas, 40 de Esdras, 40 de Nehemías, 40 de Ester, 42 de Job, 42 de Salmos, 41 de Proverbios, 41 de Eclesiastés, 42 de Cantar de los Cantares, 44 de Isaías, 44 de Jeremías, 53 de los evangelios, 11 de Hechos, 1 de Apocalipsis y 52 de las cartas); glosario; Escuela de 7 niveles; asistente; notas, resaltado y marcadores; audio; planes; Firebase listo para activar | ✅ esta versión |
| 2 | Activar Firebase; cuentas con Google o correo; revisar por muestreo la paráfrasis con IA; recordatorios locales | Próxima |
| 3 | Más estudios a mano: más estudios de Hechos, las cartas, el Antiguo Testamento y un estudio por capítulo de los Evangelios; devocionales de 365 días | Contenido |
| 4 | iOS; búsqueda semántica; versión web para maestros de escuela bíblica | Plataforma |

Toda la paráfrasis y los estudios deben pasar por **revisión pastoral y
teológica** antes de cada lanzamiento. Ver [CONTENIDO.md](CONTENIDO.md).
