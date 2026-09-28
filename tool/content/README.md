# Palabras explicadas a mano

`part1.py`, `part2.py` y `part3.py` contienen las 71 palabras con explicación,
aplicación y oración escritas a mano (curated). Se combinan con el corpus
completo de la RV1909 (`tool/corpus/`) en un único archivo:

```bash
python3 tool/corpus/extract.py   # vuelve a extraer los discursos (si cambió el extractor)
python3 tool/build_content.py    # genera assets/data/content.json
```

Para añadir o mejorar una palabra explicada, agrega o edita una llamada `add(...)`.
Si cubre versículos de un discurso automático, esos versículos se quitan de él.
Incrementa `CONTENT_VERSION` en `tool/build_content.py` antes de publicar por Firestore.
