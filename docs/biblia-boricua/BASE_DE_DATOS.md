# Base de datos y modelos

## Sin conexión (assets empaquetados)

| Archivo | Tamaño | Contenido | Se genera con |
|---|---|---|---|
| `assets/data/biblia_rv1909.json` | ~3.9 MB | Los 66 libros: `{books: [{id, name, abbr, testament, chapters: [[versículo, …], …]}]}` | `tool/boricua/build_biblia.py` |
| `assets/data/content_boricua.json` | ~120 KB | Los estudios, en el formato de pasajes de la app, con `study` | `tool/boricua/build_boricua.py` |
| `assets/data/boricua_recursos.json` | ~60 KB | `glossary`, `school`, `assistant`, `plans`, `themes` | `tool/boricua/build_boricua.py` |

Estos assets solo se incluyen en el sabor `boricua` (pubspec `flavors:`), así
que no aumentan el tamaño de las demás ediciones.

## Firestore

```
users/{uid}                       uno por persona (Auth; empieza anónima)
  bible: {
    annotations: [ {key: "jua.3.16", note?, highlight?, bookmarked?, updatedAt} ],
    history:     [ {book: "jua", chapter: 3, at} ]          (máx. 50)
    plans:       { "juan21": [0, 1, 2] }                    (días terminados)
    lessonsDone: [ "n1-1", "n3-2" ]
    updatedAt
  }
  updatedAt: serverTimestamp

verseStudies/{libro.cap.vers}     caché compartida de explicaciones con IA
  paraphrase, explanation, application, prayer, model

content/current (+ chunks/{n})    contenido publicado (las demás ediciones)
```

**Unión de datos entre dispositivos** (`BibleUserData.merge`):
- en cada versículo gana el cambio más reciente (`updatedAt`);
- los días de los planes y las lecciones se suman;
- el historial se une y se ordena.

**Reglas** (`firebase/firestore.rules`):
- `users/{uid}`: solo el dueño lee y escribe, con las claves permitidas y límites de tamaño.
- `verseStudies`: lectura pública. Una cuenta autenticada puede crear el documento si no existe, con la clave validada (`^[0-9a-z]{3}\.\d{1,3}\.\d{1,3}$`), los campos exactos y longitudes máximas. No se puede actualizar ni borrar desde la app; las correcciones las hace el equipo con credenciales de servicio.
- Todo lo demás está denegado.

**Índices:** no hacen falta; todas las lecturas son por id de documento.

## Modelos (Dart)

| Modelo | Archivo | Campos clave |
|---|---|---|
| `Bible`, `BibleBook`, `VerseRef` | `data/models/bible.dart` | `books`, `chapters`, `key` («jua.3.16»), `parse("Juan 3:16-17")` |
| `Passage` + `PassageStudy` | `data/models/passage.dart` | `situation` (qué pasó), `explanation`, `application`, `prayer`; `study.paraphrase{v: texto}`, `aboutGod`, `aboutHumans`, `aboutChrist` |
| `VerseExplanation` | `domain/bible/verse_explainer.dart` | `paraphrase`, `explanation`, `application`, `prayer`, `source` (estudio o IA) |
| `GlossaryTerm` | `data/models/boricua_resources.dart` | `term`, `short`, `long`, `reference`, `theme` |
| `SchoolLevel`, `Lesson` | ″ | `readings`, `explanation`, `reflection`, `example`, `prayer` |
| `AssistantAnswer` / `AssistantReply` | ″ / `domain/assistant` | `reference`, `text`, `explanation`, `application`, `prayer`, `nextStep`, `help` |
| `ReadingPlan` | ″ | `days: [[(bookId, chapter)]]` |
| `VerseAnnotation`, `ChapterVisit`, `BibleUserData` | `data/models/bible_user_data.dart` | ver Firestore arriba |

Todos son inmutables y tienen `fromJson` (y `toJson` los que se guardan). Las
pruebas en `test/data/boricua_edition_test.dart` hacen ida y vuelta por JSON.

## Backend (Cloud Functions)

`functions/src/index.ts` (TypeScript, Node 22):
- **`versiculoDelDia`**: se ejecuta a las 7:00 a. m. hora de Puerto Rico (Cloud Scheduler) y envía por FCM el versículo del día al tema `boricua-versiculo-del-dia`. Al tocar la notificación se abre el estudio.
- **`limpiarCuenta`**: al borrar una cuenta de Auth, borra `users/{uid}`.

Para compilar: `cd functions && npm install && npx tsc --noEmit`.
