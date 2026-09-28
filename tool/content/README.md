# Fuente del contenido

`assets/data/content.json` se genera a partir de estos archivos Python:

- `part1.py` – Adán → Josué
- `part2.py` – Profetas e Israel (exilio y regreso)
- `part3.py` – Evangelios, Iglesia y Apocalipsis
- `build.py` – define etapas y categorías, calcula el orden cronológico y valida cada palabra

```bash
cd tool/content
python3 build.py ../../assets/data/content.json
```

Para añadir una palabra, agrega una llamada `add(...)` en la etapa correspondiente
(el orden dentro del archivo es el orden cronológico) y vuelve a generar.
Incrementa `version` en `build.py` si vas a publicarla por Firestore.
