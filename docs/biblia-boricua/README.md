# Biblia Boricua

Aplicación bíblica para Puerto Rico. Sirve para leer, entender y aplicar la
Biblia en español puertorriqueño de hoy, con un tono cercano, humano y
respetuoso.

La paráfrasis y las explicaciones **no reemplazan una traducción oficial**. El
texto bíblico es la Reina-Valera 1909 (dominio público), con ortografía
actualizada y el nombre «Jehová».

La app se construye sobre la misma base de código que las demás ediciones de
este repositorio, como el sabor de Android `boricua`
(`com.brekem.todoloquediosdijo.boricua`).

```bash
flutter run --flavor boricua
flutter build apk --flavor boricua --release        # APK
flutter build appbundle --flavor boricua --release  # Google Play
```

## Documentos

| Documento | Contenido |
|---|---|
| [ARQUITECTURA.md](ARQUITECTURA.md) | Arquitectura limpia, carpetas, módulos, búsqueda, discipulado, asistente y escalabilidad (entregables 1, 2, 10–14) |
| [BASE_DE_DATOS.md](BASE_DE_DATOS.md) | Firestore, reglas de seguridad, formatos JSON y modelos de datos (entregables 3, 4, 9) |
| [UX_UI.md](UX_UI.md) | Principios de diseño, paleta, accesibilidad, wireframes y flujo de navegación (entregables 5–7) |
| [DESPLIEGUE.md](DESPLIEGUE.md) | Firebase, Google Play, App Store y fases (entregable 16) |
| [CONTENIDO.md](CONTENIDO.md) | Guía de estilo del español boricua y cómo escribir estudios, lecciones y respuestas |

## Estado (fase 1)

| Función | Estado | Dónde |
|---|---|---|
| Biblia completa: 66 libros, 1,189 capítulos y 31,102 versículos, sin conexión | ✅ | `assets/data/biblia_rv1909.json`, `features/bible` |
| Cada versículo con texto bíblico, paráfrasis boricua, explicación, aplicación y oración | ✅ en los 181 estudios escritos a mano · ⚙️ IA para todos los demás versículos cuando Firebase esté configurado | `domain/bible/verse_explainer.dart` |
| Estructura educativa: qué pasó, qué enseña de Dios, del ser humano y de Jesucristo, cómo lo aplico y oración | ✅ 181 estudios (53 de los evangelios, 37 de Salmos, 16 de Proverbios, 11 de Hechos y 52 de las cartas) | `tool/boricua/estudios*.py`, `features/passage/study_view.dart` |
| Teología simple: términos explicados automáticamente | ✅ 40 términos | `tool/boricua/recursos.py`, `domain/bible/glossary_linker.dart` |
| Escuela Bíblica: 7 niveles × 3 lecciones, con lecturas, explicación, reflexión, ejemplo real y oración | ✅ | `features/school` |
| Asistente cristiano: pasaje, explicación, aplicación, oración y próximo paso | ✅ 17 respuestas sin conexión y líneas de ayuda en crisis · ⚙️ IA para cualquier pregunta | `domain/assistant` |
| Buscador: palabras, citas, testamento, temas y emociones | ✅ | `domain/bible/bible_search.dart`, `domain/search` |
| Favoritos, marcadores, historial, notas y resaltado (4 colores) | ✅ | `data/models/bible_user_data.dart` |
| Biblia en audio, también con la pantalla apagada | ✅ | `features/bible/chapter_reader.dart` |
| Versículo del día y devocional | ✅ en la app · ⚙️ notificación push programada | `functions/src/index.ts` |
| Planes de lectura: Juan en 21 días, Salmos, Proverbios, el NT en 90 días y la Biblia en un año | ✅ | `features/plans` |
| Modo oscuro, tamaño de letra y compartir | ✅ | Ajustes |
| Sincronización en la nube (Firebase Auth + Firestore) | ⚙️ programada; se activa al configurar Firebase | `data/repositories/bible_user_repository.dart` |
| Notificaciones push personalizadas | ⚙️ tema «versículo del día» | `core/push_notifications.dart` |
| iPhone (App Store) | ⏳ falta generar el proyecto iOS en una Mac | [DESPLIEGUE.md](DESPLIEGUE.md) |

✅ funciona hoy, sin conexión · ⚙️ el código está listo y se activa al
configurar Firebase · ⏳ pendiente

> **Importante.** Firebase todavía no está configurado en este repositorio:
> en CI se salta el paso «Configurar Firebase» y `lib/firebase_options.dart`
> es un marcador. Mientras tanto, la app funciona 100 % sin conexión. Los
> pasos para activarlo están en [DESPLIEGUE.md](DESPLIEGUE.md).
