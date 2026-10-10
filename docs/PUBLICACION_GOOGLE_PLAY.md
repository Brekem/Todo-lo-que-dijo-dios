# Publicar en Google Play

## 1. Configurar Firebase (opcional, recomendado)

La app funciona 100 % offline sin Firebase. Para activar sincronización de contenido,
IA, analíticas y reporte de errores:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<tu-proyecto> --platforms=android
```

Esto sobrescribe `lib/firebase_options.dart` (y puede crear `android/app/google-services.json`,
que el build aplica automáticamente si existe).

En la consola de Firebase:

1. **Firestore**: crea la base de datos y despliega las reglas: `firebase deploy --only firestore`.
2. **AI Logic**: activa *Gemini Developer API*. El modelo se elige con
   `--dart-define=AI_MODEL=<modelo>` (por defecto `gemini-2.5-flash`).
3. **App Check**: registra la app con *Play Integrity* y activa el *enforcement* para
   AI Logic y Firestore. En debug, registra el token que imprime la app.
4. **Crashlytics** y **Analytics**: se activan solos al inicializar Firebase.

Publicar contenido nuevo sin sacar versión:

```bash
python3 tool/build_content.py   # sube CONTENT_VERSION antes
cd ../firestore && npm install && GOOGLE_APPLICATION_CREDENTIALS=... node seed.mjs
```

## 2. Clave de firma

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

Crea `android/key.properties` (no se sube al repositorio):

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/ruta/absoluta/upload-keystore.jks
```

En GitHub Actions usa los secretos `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS` y `ANDROID_KEY_PASSWORD` (ver `.github/workflows/android.yml`).

## 3. Compilar

```bash
flutter build appbundle --flavor yave --release --obfuscate --split-debug-info=build/symbols   # Google Play
flutter build apk --flavor yave --release                                         # APK para instalar directo
flutter build apk --flavor jehova --release                                       # edición «Jehová» (otra app)
flutter build apk --flavor jesus --release                                        # edición «Jesús» (otra app)
```

Sube `build/symbols` a Crashlytics para ver trazas legibles.
Incrementa `version:` en `pubspec.yaml` (`1.0.1+2`) en cada subida.

## 4. Ficha de Play Console

| Campo | Valor |
|---|---|
| Nombre | Todo lo que Dios Dijo |
| Descripción breve | Cada palabra que Dios pronunció en la Biblia, explicada para tu vida. |
| Categoría | Libros y obras de consulta (o Estilo de vida) |
| Icono | `store/icon_512.png` |
| Capturas | `store/screenshots/` (claro y oscuro) |
| Política de privacidad | Publica `docs/PRIVACIDAD.md` en una URL pública |
| Clasificación de contenido | Todo público |
| Anuncios | No contiene anuncios |

**Seguridad de los datos** (formulario de Play):

- Datos recopilados: *Actividad en la app* (analíticas), *Información y rendimiento de la app*
  (Crashlytics) y *Otro contenido generado por el usuario* (texto enviado a la IA, no
  almacenado). Todos cifrados en tránsito; no se venden ni comparten con terceros para publicidad.
- Funciones de IA generativa: la app muestra que el contenido es generado por IA,
  incluye aviso de que no sustituye consejo profesional y añade recursos de ayuda ante
  señales de crisis.

**Derechos del texto bíblico**: el contenido usa la Reina-Valera 1909 (dominio público).
Si quieres usar la Biblia de Jerusalén, la Biblia Latinoamericana u otra traducción
moderna, necesitas licencia escrita de su editorial antes de publicar.

## 5. Descripción larga sugerida

> Todo lo que Dios Dijo reúne, en orden cronológico, casi mil momentos en que Dios habló
> directamente en la Biblia —incluidos todos los «Así dice Yavé»—: desde «Sea la luz» en Génesis hasta «Ciertamente, vengo en
> breve» en Apocalipsis.
>
> Cada palabra incluye: a quién habló Dios, el contexto histórico, qué estaba pasando,
> el problema que Dios estaba tratando, una explicación sencilla, una aplicación para
> hoy y una oración de liberación.
>
> • Recorrido de la Voz de Dios: Adán, Noé, Abraham, Moisés, los profetas, los Evangelios…
> • Busca por problema (miedo, ansiedad, culpa…), tema o personaje bíblico.
> • «Necesito esta palabra para mí»: una reflexión y una oración para tu situación.
> • Guarda tus palabras, lleva tu camino espiritual y lee sin conexión.
> • Modo claro y oscuro. Sin anuncios.
