# Guía de contenido

## La voz boricua
- **Quién habla.** Un creyente maduro le explica la Biblia a otro puertorriqueño sentado a su lado. Usa «tú» y «ustedes».
- **Lenguaje.** Español de Puerto Rico de hoy, claro y natural. Puede haber palabras cotidianas de la isla («bregar», «guagua», «el tapón», «los nenes»), pero sin jerga vulgar ni chistes que resten reverencia.
- **Palabras prohibidas** fuera del texto bíblico: «he aquí», «vosotros», «empero», «mas» (por «pero»), «acaecer», «hallarse». `tool/boricua/build_boricua.py` falla si aparecen, y los tests también lo comprueban.
- **Términos teológicos.** Se explican siempre. Si aparece uno nuevo, agrégalo al glosario (`recursos.py`, función `t`).
- **Ejemplos.** Situaciones reales de Puerto Rico: huracanes, apagones, la diáspora, el tapón o el trabajo. Sin estereotipos.
- **Fidelidad.** La paráfrasis no añade ideas al texto. Lo que es interpretación va en la explicación, no en la paráfrasis.

## Cómo agregar
- **Un estudio** (`tool/boricua/estudios.py`):
  ```python
  e('Libro c:v-w', 'Quién habla', 'A quién', ['categoría', …],
    {v: 'paráfrasis', …},          # un texto por cada versículo
    'Qué pasó', 'Explicación simple', 'Qué enseña de Dios',
    'del ser humano', 'de Jesucristo', 'Cómo lo aplico hoy',
    'Oración … Amén.')
  ```
- **Una lección o una respuesta del asistente:** en `tool/boricua/recursos.py` (funciones `leccion` y `r`).
- **Para generar los archivos**, corre `python3 tool/boricua/build_boricua.py`. Valida las citas, las palabras antiguas, la paráfrasis completa y que la oración termine con «Amén.».

## Revisión
1. El autor escribe y corre el generador.
2. **Revisión teológica:** un pastor o maestro bíblico revisa la fidelidad.
3. **Revisión de lenguaje:** un lector puertorriqueño confirma que suena natural.
4. Para las explicaciones con IA en Firestore (`verseStudies`), revisa una muestra semanal. Las correcciones se escriben con credenciales de servicio, porque la app no puede modificarlas.
