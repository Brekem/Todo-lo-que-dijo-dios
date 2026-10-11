"""Genera assets/data/content_apocalipsis.json: las profecías del Apocalipsis.

Todo el libro (22 capítulos, RV1909), en sus visiones, con explicación escrita
a mano (tool/apocalipsis/secciones.py). Juan narra; lo que dicen Jesús, Dios,
los ángeles y las voces del cielo se oye con la voz de Dios. Qué parte de cada
versículo es voz sale de las comillas de la WEB (tool/apocalipsis/voces.json).

Uso:
  python3 tool/apocalipsis/build_apocalipsis.py
"""
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(ROOT / 'tool' / 'jesus'))

from build_jesus import load_bible, split_verse  # noqa: E402
from build_content import CATEGORIES, CATEGORIES_BY_ID, CONTENT_VERSION  # noqa: E402

OUT = ROOT / 'assets' / 'data' / 'content_apocalipsis.json'
VOCES = json.loads((HERE / 'voces.json').read_text(encoding='utf-8'))

ERAS = [
    ('cartas', 'Las siete iglesias', 'Jesús habla a su Iglesia', 'Apocalipsis 1–3'),
    ('trono', 'El trono y el Cordero', 'Quién gobierna la historia', 'Apocalipsis 4–5'),
    ('sellos', 'Los siete sellos', 'Los jinetes y los sellados', 'Apocalipsis 6–7'),
    ('trompetas', 'Las siete trompetas', 'Advertencias y testigos', 'Apocalipsis 8–11'),
    ('conflicto', 'El dragón y las bestias', 'La gran batalla espiritual', 'Apocalipsis 12–14'),
    ('copas', 'Las siete copas', 'La ira de Dios se consuma', 'Apocalipsis 15–16'),
    ('babilonia', 'La caída de Babilonia', 'El fin del sistema del mal', 'Apocalipsis 17–19'),
    ('victoria', 'La victoria final', 'El Rey de reyes y el juicio', 'Apocalipsis 19–20'),
    ('nueva', 'Todas las cosas nuevas', 'Cielo nuevo y tierra nueva', 'Apocalipsis 21–22'),
]

CONTEXT = (
    'Hacia el año 95, bajo el emperador Domiciano, los cristianos de Asia Menor (la actual '
    'Turquía) eran presionados a adorar al emperador, y muchos sufrían cárcel o muerte. El '
    'apóstol Juan, desterrado en la isla de Patmos, recibe esta revelación de Jesucristo en '
    'visiones llenas de símbolos tomados del Antiguo Testamento (Daniel, Ezequiel, Isaías, '
    'el éxodo). Los cristianos lo han interpretado de varias maneras (como historia de su '
    'tiempo, como profecía del fin o como imagen de la lucha de toda la historia), pero su '
    'mensaje central es claro: Dios reina, el Cordero ha vencido y Jesús viene pronto.'
)

# Las categorías de la app, dichas por el Apocalipsis.
CATEGORY_TEXT_APO = {
    'miedo': 'No temas: el que tiene las llaves de la muerte está en medio de su pueblo.',
    'tristeza': 'Dios limpiará toda lágrima de los ojos de ellos: profecías de consuelo.',
    'esperanza': 'El Cordero vencerá: cielo nuevo, tierra nueva y Jesús que viene pronto.',
    'arrepentimiento': 'Advertencias a las iglesias y al mundo para volverse a Dios a tiempo.',
    'fe': 'Quién está en el trono: profecías para confiar en Dios cuando el mundo tiembla.',
}


# Donde las comillas de la WEB no caen bien en la RV1909, o habla Juan.
FIXES = {
    (6, 5): [['Y cuando él abrió el tercer sello, oí al tercer animal, que decía:', False],
             ['Ven y ve.', True],
             ['Y miré, y he aquí un caballo negro: y el que estaba sentado encima de él, tenía '
              'un peso en su mano.', False]],
    (7, 14): [['Y yo le dije: Señor, tú lo sabes. Y él me dijo:', False],
              ['Estos son los que han venido de grande tribulación, y han lavado sus ropas, y '
               'las han blanqueado en la sangre del Cordero.', True]],
}


def verse_key(ref):
    ch, v = ref.split(':')
    return int(ch), int(v)


def main():
    bible = load_bible()
    sections = []

    def s(a, b, era, speaker, recipient, quote_verses, situation, problem, explanation,
          application, prayer, cats, topics, problems, people):
        assert prayer.rstrip().endswith('Amén.'), a
        assert all(c in CATEGORIES_BY_ID for c in cats), a
        sections.append(locals())

    exec(compile((HERE / 'secciones.py').read_text(encoding='utf-8'), 'secciones.py', 'exec'),
         {'s': s})

    passages = []
    expected = (1, 1)
    for i, x in enumerate(sections, 1):
        (ch, v1), (ch2, v2) = verse_key(x['a']), verse_key(x['b'])
        assert ch == ch2, f'{x["a"]}: una visión no cruza capítulos'
        assert (ch, v1) == expected, f'falta {expected} antes de {x["a"]}'
        texts = bible[('Revelation of John', ch)]
        expected = (ch, v2 + 1) if v2 + 1 in texts else (ch + 1, 1)
        verses = []
        for v in range(v1, v2 + 1):
            runs = VOCES.get(f'{ch}:{v}', [[1.0, 0]])
            parts = FIXES.get((ch, v))
            if parts:
                assert ' '.join(t for t, _ in parts) == texts[v], (ch, v)
            elif any(q for _, q in runs):
                parts = split_verse(texts[v], runs)
            else:
                parts = [[texts[v], False]]
            verses.append([v, [[t, 1 if g else 0] for t, g in parts]])
        for v in x['quote_verses']:
            assert v1 <= v <= v2, f'{x["a"]}: la cita {v} está fuera de la visión'
        picked = [p for v, p in verses if v in x['quote_verses']]
        voice = [t for parts in picked for t, g in parts if g]
        quote = ' '.join(voice or [t for parts in picked for t, _ in parts])
        ref = f'Apocalipsis {ch}:{v1}-{v2}'
        passages.append({
            'id': f'a-{ch}-{v1}', 'order': i, 'era': x['era'], 'reference': ref,
            'book': 'Apocalipsis', 'speaker': x['speaker'], 'quote': quote,
            'recipient': x['recipient'], 'people': x['people'], 'historicalContext': CONTEXT,
            'situation': x['situation'], 'problem': x['problem'],
            'explanation': x['explanation'], 'application': x['application'],
            'prayer': x['prayer'], 'categories': x['cats'], 'topics': x['topics'],
            'problems': x['problems'], 'curated': True, 'verses': verses,
            'fullReference': ref,
        })
    assert expected == (23, 1), f'el libro no termina completo: {expected}'

    used = {c for p in passages for c in p['categories']}
    out = {
        'version': CONTENT_VERSION,
        'translation': 'Reina-Valera 1909 (dominio público), heredera de la Biblia del Oso de '
                       'Casiodoro de Reina (1569), con ortografía actualizada. El libro completo '
                       'del Apocalipsis.',
        'eras': [dict(id=a, title=b, subtitle=c, period=d) for a, b, c, d in ERAS],
        'categories': [dict(id=a, title=t, headline=h, description=CATEGORY_TEXT_APO.get(a, d),
                            icon=e, color='FF' + f)
                       for a, t, h, d, e, f in CATEGORIES if a in used],
        'passages': passages,
    }
    OUT.write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    print(f'Edición Apocalipsis: {len(passages)} visiones, '
          f'{sum(len(p["verses"]) for p in passages)} versículos; {OUT.stat().st_size // 1024} KB')
    for p in passages:
        assert p['quote'], p['id']
        assert not re.search(r'\s{2}', p['quote']), p['id']


if __name__ == '__main__':
    main()
