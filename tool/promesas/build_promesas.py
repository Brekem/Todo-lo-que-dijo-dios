"""Genera assets/data/content_promesas.json: las promesas de la Biblia.

Cada promesa está escrita a mano en tool/promesas/promesas.py, con el texto
de la RV1909. Lo que se promete suena con la voz de Dios; la introducción del
versículo («Y dijo Yavé a Abram:») la lee el narrador.

Uso:
  python3 tool/promesas/build_promesas.py
"""
import csv
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(ROOT / 'tool' / 'jesus'))

from build_jesus import KNOWN_PEOPLE as NT_PEOPLE, introduces  # noqa: E402
from build_content import (CATEGORIES, CATEGORIES_BY_ID, CONTENT_VERSION,  # noqa: E402
                           KNOWN_PEOPLE, CAT_WORD)
from extract import SOURCE, fix_caps, modernize  # noqa: E402

OUT = ROOT / 'assets' / 'data' / 'content_promesas.json'

# Nombre en español → (nombre en la fuente, era).
BOOKS = {
    'Génesis': ('Genesis', 'ley'), 'Éxodo': ('Exodus', 'ley'), 'Números': ('Numbers', 'ley'),
    'Deuteronomio': ('Deuteronomy', 'ley'), 'Josué': ('Joshua', 'historia'),
    '2 Crónicas': ('II Chronicles', 'historia'), 'Nehemías': ('Nehemiah', 'historia'),
    'Job': ('Job', 'salmos'), 'Salmos': ('Psalms', 'salmos'), 'Proverbios': ('Proverbs', 'salmos'),
    'Isaías': ('Isaiah', 'profetas'), 'Jeremías': ('Jeremiah', 'profetas'),
    'Lamentaciones': ('Lamentations', 'profetas'), 'Ezequiel': ('Ezekiel', 'profetas'),
    'Joel': ('Joel', 'profetas'), 'Miqueas': ('Micah', 'profetas'),
    'Sofonías': ('Zephaniah', 'profetas'), 'Malaquías': ('Malachi', 'profetas'),
    'Mateo': ('Matthew', 'evangelios'), 'Marcos': ('Mark', 'evangelios'),
    'Juan': ('John', 'evangelios'), 'Hechos': ('Acts', 'iglesia'),
    'Romanos': ('Romans', 'iglesia'), '1 Corintios': ('I Corinthians', 'iglesia'),
    '2 Corintios': ('II Corinthians', 'iglesia'), 'Filipenses': ('Philippians', 'iglesia'),
    'Hebreos': ('Hebrews', 'iglesia'), 'Santiago': ('James', 'iglesia'),
    '1 Pedro': ('I Peter', 'iglesia'), '1 Juan': ('I John', 'iglesia'),
    'Apocalipsis': ('Revelation of John', 'apocalipsis'),
}

ERAS = [
    ('ley', 'La Ley', 'Promesas a los patriarcas y a Moisés', 'Génesis–Deuteronomio'),
    ('historia', 'La historia de Israel', 'Promesas en la tierra prometida', 'Josué–Nehemías'),
    ('salmos', 'Salmos y sabiduría', 'Promesas para orar y vivir', 'Job–Proverbios'),
    ('profetas', 'Los profetas', 'Consuelo y restauración', 'Isaías–Malaquías'),
    ('evangelios', 'Los evangelios', 'Las promesas de Jesús', 'Mateo–Juan'),
    ('iglesia', 'La Iglesia', 'Promesas para los creyentes', 'Hechos–1 Juan'),
    ('apocalipsis', 'Apocalipsis', 'La promesa final', 'Apocalipsis'),
]

CONTEXT = {
    'ley': 'En los primeros libros de la Biblia, Dios llama a Abraham, forma un pueblo y lo saca '
           'de la esclavitud de Egipto por medio de Moisés. Sus primeras promesas son pactos: '
           'compromisos que Dios toma sobre sí mismo.',
    'historia': 'Israel entra en la tierra prometida, tiene reyes, se aparta de Dios y vuelve del '
                'exilio. A lo largo de esa historia, Dios renueva sus promesas una y otra vez.',
    'salmos': 'Los Salmos son las oraciones y canciones de Israel, y Proverbios y Job su '
              'sabiduría. Sus promesas nacen de la experiencia de quienes confiaron en Dios en '
              'medio del peligro, la enfermedad y el dolor.',
    'profetas': 'Los profetas hablaron de parte de Dios a un pueblo que se alejaba de él, antes, '
                'durante y después del exilio en Babilonia. Junto a sus advertencias anunciaron '
                'las promesas de consuelo, perdón y restauración más hermosas de la Biblia.',
    'evangelios': 'Jesús, el Hijo de Dios, cumple las promesas del Antiguo Testamento y hace las '
                  'suyas: descanso, paz, vida eterna y su presencia todos los días.',
    'iglesia': 'Después de la resurrección de Jesús, los apóstoles escriben cartas a las primeras '
               'iglesias, que vivían en ciudades paganas y muchas veces perseguidas. Sus promesas '
               'son para todos los que están en Cristo.',
    'apocalipsis': 'Hacia el año 95, desterrado en Patmos, el apóstol Juan recibe la revelación de '
                   'Jesucristo. La Biblia termina con la promesa de que Dios hará nuevas todas '
                   'las cosas.',
}

CATEGORY_DESC = {
    'miedo': '«No temas, que yo soy contigo»: promesas para cuando el miedo te paraliza.',
    'ansiedad': 'Echa sobre él tu carga: promesas de paz y descanso.',
    'culpa': 'Ninguna condenación: promesas de limpieza y vida nueva.',
    'tristeza': 'A la mañana vendrá la alegría: promesas de consuelo.',
    'soledad': '«No te dejaré ni te desampararé»: promesas de su presencia.',
    'fe': 'Ni una de sus buenas palabras ha faltado: promesas para confiar.',
    'obediencia': 'Promesas para el camino: guía, sabiduría y fuerza para obedecer.',
    'amor': 'Con amor eterno te he amado: promesas de su amor fiel.',
    'perdon': 'Blancos como la nieve: promesas de perdón.',
    'esperanza': 'Pensamientos de paz y no de mal: promesas de un futuro.',
    'arrepentimiento': 'Volved a mí: promesas para el que regresa a Dios.',
    'justicia': 'Bienaventurados los que tienen hambre y sed de justicia.',
}


def load_bible():
    names = {source for source, _ in BOOKS.values()}
    bible = {}
    with SOURCE.open(encoding='utf-8') as f:
        for r in csv.DictReader(f):
            if r['Book'] in names:
                text = modernize(fix_caps(r['Text'], r['Verse']))
                bible[(r['Book'], int(r['Chapter']), int(r['Verse']))] = text
    return bible


# Una introducción cuenta quién habla («Y dijo Yavé a Abram:», «Dícele Jesús:»);
# los dos puntos dentro de lo que se promete («Me invocará, y yo le
# responderé:») no lo son.
NARRATED = re.compile(r'^(?:Y |Empero |Después |Entonces |Mas |Díjoles|Dícele|Díceles)'
                      r'|Yavé|Jesús|Moisés|Dios')
PSALM_TITLE = re.compile(r'^((?:Salmo|Al Músico|Cántico|Masquil|Mictam|Oración)[^.]*\.)\s+(.)')


def split_intro(text: str) -> list:
    """«Y dijo Yavé a Abram: Vete…» → narrador hasta los dos puntos, luego la promesa."""
    for m in re.finditer(r':(?=\s)', text):
        at = m.end()
        if at > 0.7 * len(text):
            break
        if introduces(text, at) and NARRATED.search(text[:at]):
            return [[text[:at].strip(), False], [text[at:].strip(), True]]
    return [[text, True]]


def verse_parts(book: str, verse: int, text: str) -> list:
    """El título del salmo («Salmo de David.») lo lee el narrador."""
    m = PSALM_TITLE.match(text) if book == 'Salmos' and verse == 1 else None
    if m:
        rest = m.group(2).upper() + text[m.end():]
        return [[m.group(1), False]] + split_intro(rest)
    return split_intro(text)


def main():
    bible = load_bible()
    promises = []

    def p(ref, speaker, recipient, situation, problem, explanation, application, prayer, cats):
        assert prayer.rstrip().endswith('Amén.'), ref
        assert all(c in CATEGORIES_BY_ID for c in cats), ref
        promises.append(locals())

    exec(compile((HERE / 'promesas.py').read_text(encoding='utf-8'), 'promesas.py', 'exec'),
         {'p': p})

    passages = []
    seen = set()
    for i, x in enumerate(promises, 1):
        m = re.match(r'^(.+) (\d+):(\d+)(?:-(\d+))?$', x['ref'])
        book, ch, a = m.group(1), int(m.group(2)), int(m.group(3))
        b = int(m.group(4) or a)
        source, era = BOOKS[book]
        verses = []
        for v in range(a, b + 1):
            parts = verse_parts(book, v, bible[(source, ch, v)])
            verses.append([v, [[t, 1 if g else 0] for t, g in parts]])
        quote = ' '.join(t for _, parts in verses for t, g in parts if g)
        uid = f'p-{source.lower().replace(" ", "")}-{ch}-{a}'
        assert uid not in seen, uid
        seen.add(uid)
        people = [n for n in KNOWN_PEOPLE + NT_PEOPLE
                  if re.search(rf'\b{n}\b', x['recipient'] + ' ' + x['speaker'] + ' ' + x['situation'])]
        passages.append({
            'id': uid, 'order': i, 'era': era, 'reference': x['ref'], 'book': book,
            'speaker': x['speaker'], 'quote': quote, 'recipient': x['recipient'],
            'people': list(dict.fromkeys(people))[:6], 'historicalContext': CONTEXT[era],
            'situation': x['situation'], 'problem': x['problem'],
            'explanation': x['explanation'], 'application': x['application'],
            'prayer': x['prayer'], 'categories': x['cats'],
            'topics': ['promesas'] + [CAT_WORD[c] for c in x['cats']],
            'problems': [], 'curated': True, 'verses': verses, 'fullReference': x['ref'],
        })
    eras = [e for e in ERAS if any(p['era'] == e[0] for p in passages)]
    assert [p['era'] for p in passages] == sorted((p['era'] for p in passages),
                                                  key=[e[0] for e in ERAS].index), 'fuera de orden'
    used = {c for p in passages for c in p['categories']}
    out = {
        'version': CONTENT_VERSION,
        'translation': 'Reina-Valera 1909 (dominio público), heredera de la Biblia del Oso de '
                       'Casiodoro de Reina (1569), con ortografía actualizada y el nombre divino '
                       '«Yavé». Las promesas de Dios, de Génesis a Apocalipsis.',
        'eras': [dict(id=a, title=b, subtitle=c, period=d) for a, b, c, d in eras],
        'categories': [dict(id=a, title=t, headline=h, description=CATEGORY_DESC.get(a, d),
                            icon=e, color='FF' + f)
                       for a, t, h, d, e, f in CATEGORIES if a in used],
        'passages': passages,
    }
    OUT.write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    print(f'Edición Promesas: {len(passages)} promesas, '
          f'{sum(len(p["verses"]) for p in passages)} versículos; {OUT.stat().st_size // 1024} KB')


if __name__ == '__main__':
    main()
