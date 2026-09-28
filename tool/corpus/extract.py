"""Extrae de la Reina-Valera 1909 cada lugar donde Yavé habla directamente.

Salida: tool/corpus/units.json — una lista de «discursos» (unidades), cada uno con
libro, capítulo, versículos, texto (ortografía actualizada, nombre «Yavé») y las
fórmulas detectadas («Así dice Yavé», «dice Yavé», «la voz de Yavé», …).

Uso:  python3 tool/corpus/extract.py
"""
import csv
import json
import re
from collections import Counter
from pathlib import Path

HERE = Path(__file__).parent
SOURCE = HERE / 'source' / 'SpaRV1909.csv'
OUT = HERE / 'units.json'

# Libros del Antiguo Testamento: nombre en la fuente → (id, nombre en español).
BOOKS = {
    'Genesis': ('gen', 'Génesis'), 'Exodus': ('exo', 'Éxodo'),
    'Leviticus': ('lev', 'Levítico'), 'Numbers': ('num', 'Números'),
    'Deuteronomy': ('deu', 'Deuteronomio'), 'Joshua': ('jos', 'Josué'),
    'Judges': ('jue', 'Jueces'), 'Ruth': ('rut', 'Rut'),
    'I Samuel': ('1sa', '1 Samuel'), 'II Samuel': ('2sa', '2 Samuel'),
    'I Kings': ('1re', '1 Reyes'), 'II Kings': ('2re', '2 Reyes'),
    'I Chronicles': ('1cr', '1 Crónicas'), 'II Chronicles': ('2cr', '2 Crónicas'),
    'Ezra': ('esd', 'Esdras'), 'Nehemiah': ('neh', 'Nehemías'),
    'Esther': ('est', 'Ester'), 'Job': ('job', 'Job'), 'Psalms': ('sal', 'Salmos'),
    'Proverbs': ('pro', 'Proverbios'), 'Ecclesiastes': ('ecl', 'Eclesiastés'),
    'Song of Solomon': ('can', 'Cantares'), 'Isaiah': ('isa', 'Isaías'),
    'Jeremiah': ('jer', 'Jeremías'), 'Lamentations': ('lam', 'Lamentaciones'),
    'Ezekiel': ('eze', 'Ezequiel'), 'Daniel': ('dan', 'Daniel'),
    'Hosea': ('ose', 'Oseas'), 'Joel': ('joe', 'Joel'), 'Amos': ('amo', 'Amós'),
    'Obadiah': ('abd', 'Abdías'), 'Jonah': ('jon', 'Jonás'), 'Micah': ('miq', 'Miqueas'),
    'Nahum': ('nah', 'Nahúm'), 'Habakkuk': ('hab', 'Habacuc'),
    'Zephaniah': ('sof', 'Sofonías'), 'Haggai': ('hag', 'Hageo'),
    'Zechariah': ('zac', 'Zacarías'), 'Malachi': ('mal', 'Malaquías'),
}

PROPHETS = {'isa', 'jer', 'lam', 'eze', 'ose', 'joe', 'amo', 'abd', 'jon',
            'miq', 'nah', 'hab', 'sof', 'hag', 'zac', 'mal'}

J = r'Jehov[aá]'
GOD = rf'(?:{J}(?: Dios)?(?: de los ej[eé]rcitos)?|el Señor {J}|Dios)'
SPEECH_VERB = r'(?:d[ií]jo|habl[oó]|respondi[oó]|llam[oó]|mand[oó]|jur[oó])'

# Introducciones narrativas: «Y dijo Yavé…», «Y habló Yavé a Moisés, diciendo:»,
# «Fue palabra de Yavé a…», «Díjole Yavé…». Abren un discurso nuevo.
INTRO = re.compile('|'.join([
    rf'\b{SPEECH_VERB}(?:le|les|me)? {GOD}\b',
    rf'\b(?:{J}|Dios)(?: Dios)? (?:le |les |me |te |[aá] \w+ )?{SPEECH_VERB}\b',
    rf'(?:fu[eé]|vino)(?: pues)?(?: [aá] (?:m[ií]|\w+))? (?:la )?palabra de {J}',
    rf'palabra de {J}(?: que fu[eé])? [aá] \w+',
    rf'[Oo][ií]d (?:la )?palabra de {J}',
    # «tentó Dios a Abraham, y le dijo:», «apareciósele Yavé, y díjole:»
    rf'\b(?:{J}|Dios)\b[^:.;?]{{0,60}}\b(?:y )?(?:le |les |me )?(?:d[ií]jo|d[ií]jole|d[ií]jome|habl[oó]|respondi[oó])\b',
]))

# Pasajes de Salmos donde Dios habla en primera persona sin fórmula narrativa.
EXTRA = [
    ('sal', 2, 7, 9), ('sal', 12, 5, 5), ('sal', 32, 8, 9), ('sal', 46, 10, 10),
    ('sal', 50, 7, 15), ('sal', 50, 16, 23), ('sal', 81, 6, 16), ('sal', 89, 3, 4),
    ('sal', 89, 19, 37), ('sal', 91, 14, 16), ('sal', 95, 8, 11), ('sal', 110, 1, 1),
    ('sal', 110, 4, 4),
]

# Fórmula profética: cada «Así dice Yavé» abre un oráculo propio.
ASI_DICE = re.compile(rf'[Aa]s[ií] (?:dice|ha dicho|dijo|habl[oó]) (?:el Señor )?{J}')
# Fórmula de cierre o intermedia: pertenece al discurso en curso.
DICE = re.compile(rf'(?:dice|ha dicho|dijo|habl[oó]) (?:el Señor )?{J}')
VOZ = re.compile(rf'[Vv]oz de {J}|[Vv]oz del Señor|[Vv]oz de Dios')

# Señales de que vuelve la narración con otro personaje hablando o actuando.
NARRATIVE = re.compile(
    r'^(?:Y |Entonces |Mas |Después |Luego |Y aconteció|Aconteció)?'
    r'(?:respondi[oó]|dijo|habl[oó]|clam[oó]|or[oó]|hizo|fu[eé]se|fu[eé]ron|'
    r'levant[oó]se|tom[oó]|sali[oó]|vino|vinieron|subi[oó]|descendi[oó]|'
    r'edific[oó]|puso|envi[oó])\s+(?!(?:le |les )?' + GOD + r')'
    r'(?:[A-ZÁÉÍÓÚ]\w+|el pueblo|los hijos|todo el pueblo|el rey|el ángel)'
)
HUMAN_SPEAKS_FIRST = re.compile(
    r'^(?:Y |Entonces |Mas )?(?:[A-ZÁÉÍÓÚ]\w+ )?(?:respondi[oó]|dijo) (?:[A-ZÁÉÍÓÚ]\w+)(?: a {J})?'
)

# Una persona que se dirige a Dios (oración): ya no habla Yavé.
PRAYER = re.compile(
    rf'\boh {J}\b|\boh (?:Dios|Señor)\b|\btu siervo\b|\b[Tt]ú oirás\b|'
    r'\b[Oo]ye (?:pues )?(?:la oración|tú)\b|\bruégote\b', re.IGNORECASE)

MAX_VERSES = 12

# Capítulos que empiezan a mitad de un discurso de Yavé que viene del capítulo
# anterior (revisados a mano): la Ley dada a Moisés y la respuesta a Job.
CARRY = {
    ('exo', 21), ('exo', 22), ('exo', 23), ('exo', 26), ('exo', 27),
    ('exo', 28), ('exo', 29), ('exo', 30), ('lev', 2), ('lev', 3),
    ('lev', 5), ('lev', 7), ('lev', 26), ('num', 29), ('job', 39),
    ('job', 41),
}

# Ortografía actualizada (RV1909 usa tildes antiguas).
WORD_FIXES = {
    'á': 'a', 'Á': 'A', 'é': 'e', 'ó': 'o', 'fué': 'fue', 'Fué': 'Fue',
    'fuí': 'fui', 'dió': 'dio', 'Dió': 'Dio', 'vió': 'vio', 'Vió': 'Vio',
    'fuése': 'fuese', 'fuéron': 'fueron', 'dí': 'di', 'ví': 'vi', 'fuíste': 'fuiste',
}
WORD_RE = re.compile(r'\b(' + '|'.join(map(re.escape, WORD_FIXES)) + r')\b')


def modernize(text: str) -> str:
    text = WORD_RE.sub(lambda m: WORD_FIXES[m.group(1)], text)
    text = re.sub(r'JEHOV[AÁ]', 'YAVÉ', text)
    text = re.sub(r'Jehov[aá]', 'Yavé', text)
    text = text.replace('EN el principio', 'En el principio')
    return re.sub(r'\s+', ' ', text).strip()


CAPS = re.compile(r'\b[A-ZÁÉÍÓÚÑ]{2,}\b')


def uncap(text: str) -> str:
    """«Y HABLÓ Jehová…», «Y JEHOVÁ dijo…»: la RV1909 escribe en mayúsculas la
    primera palabra de cada capítulo. Se normaliza para detectar los discursos."""
    def fix(m):
        word = m.group(0)
        first = not re.search(r'\w', text[:m.start()])
        return word.capitalize() if first or word.startswith('JEHOV') else word.lower()
    return CAPS.sub(fix, text, count=1)


def load():
    with SOURCE.open(encoding='utf-8') as f:
        rows = [r for r in csv.DictReader(f) if r['Book'] in BOOKS]
    chapters: dict[tuple[str, int], list[dict]] = {}
    for r in rows:
        key = (r['Book'], int(r['Chapter']))
        chapters.setdefault(key, []).append(
            {'v': int(r['Verse']), 'text': uncap(r['Text'])})
    return chapters


def is_speech_start(text: str) -> str | None:
    m = ASI_DICE.search(text)
    if m and ':' in text[m.end():m.end() + 40]:
        return 'asi-dice'
    for m in INTRO.finditer(text):
        # «dijo X a Yavé» es una persona hablando a Dios, no al revés.
        if re.search(rf'(?:^|\s)[aá] {J}\s*$', text[:m.start()]):
            continue
        # «lo que le mandó Yavé», «del cual habló Yavé»: narración, no discurso.
        if re.search(r'(?:que|cual|como|según|conforme [aá])\s+(?:le |les |me |lo |nos |os )?$',
                     text[:m.start()]):
            continue
        # «se volvió a Yavé, y dijo», «varón de Dios, el cual dijo»: Dios es
        # el destinatario o un complemento, no quien habla.
        if re.search(r'(?:^|\s)(?:[aá]|al|de|del|con|contra|ante|por|delante de|en)\s+$', text[:m.start()]):
            continue
        # «Bendito sea Yavé…, que habló de su boca»: alguien cita a Dios.
        if re.search(r'\bque (?:le |les |me )?(?:habl|d[ií]j)', m.group(0)):
            continue
        # Las palabras de Dios empiezan tras dos puntos en ese mismo versículo.
        if ':' in text[m.end():]:
            return 'intro'
    return None


# Discursos en primera persona en los profetas: «Yo Yavé», «yo soy Yavé».
FIRST_PERSON = re.compile(rf'\b[Yy]o (?:soy )?{J}\b')

# Verbo en pretérito de tercera persona al comenzar el versículo: vuelve la narración.
PRETERITE = re.compile(
    r'^(?:(?:Y|E|Entonces|Mas|Luego|Así|Después|Pero)\s+)?(?:\w+\s+){0,2}?'
    r'(?:[a-záéíóúñ]+(?:ó|ió|aron|ieron)(?:se|le|les|lo|la|los|las|me|nos)?|'
    r'fue|fueron|hizo|hicieron|vino|vinieron|puso|pusieron|tuvo|anduvo)\b',
    re.IGNORECASE,
)


def extract():
    chapters = load()
    units = []
    voz = []

    def close(unit, book_id, book_es, chapter):
        """Guarda el discurso, partiéndolo si es muy largo."""
        verses = unit['verses']
        parts = [verses[i:i + MAX_VERSES] for i in range(0, len(verses), MAX_VERSES)]
        for n, part in enumerate(parts):
            units.append({
                'book': book_id,
                'bookName': book_es,
                'chapter': chapter,
                'from': part[0]['v'],
                'to': part[-1]['v'],
                'kind': unit['kind'] if n == 0 else 'continuacion',
                'part': n,
                'parts': len(parts),
                'raw': [x['text'] for x in part],
            })

    carry = None  # libro cuyo discurso seguía abierto al acabar el capítulo
    for (book, chapter), verses in chapters.items():
        book_id, book_es = BOOKS[book]
        # Un discurso que no terminó sigue en el capítulo siguiente (p. ej. Yavé
        # responde a Job desde el torbellino en Job 38–41).
        current = {'kind': 'continuacion', 'verses': []} \
            if carry == book and (book_id, chapter) in CARRY else None
        for idx, verse in enumerate(verses):
            text = verse['text']
            kind = is_speech_start(text)
            if VOZ.search(text):
                voz.append({'book': book_id, 'bookName': book_es, 'chapter': chapter,
                            'verse': verse['v'], 'raw': text})
            if kind is not None:
                # «Fue palabra de Yavé a Natán, diciendo:» + «Así ha dicho Yavé: …»
                # forman un solo discurso.
                if current and len(current['verses']) == 1 \
                        and current['verses'][0]['text'].rstrip().endswith(':'):
                    current['verses'].append(verse)
                    continue
                if current:
                    close(current, book_id, book_es, chapter)
                current = {'kind': kind, 'verses': [verse]}
                continue
            if current is not None:
                narrative = (NARRATIVE.search(text) or HUMAN_SPEAKS_FIRST.search(text)
                             or PRETERITE.search(text) or PRAYER.search(text)) \
                    and not DICE.search(text) and not FIRST_PERSON.search(text)
                # Tras «…, diciendo:» siempre vienen las palabras de Dios.
                if current['verses'] and current['verses'][-1]['text'].rstrip().endswith(':'):
                    narrative = False
                if narrative:
                    close(current, book_id, book_es, chapter)
                    current = None
                else:
                    current['verses'].append(verse)
            elif book_id not in PROPHETS and re.search(rf'\bdice {J}', text):
                # «Por mí mismo he jurado, dice Yavé» fuera de los profetas.
                current = {'kind': 'oraculo', 'verses': [verse]}
            elif book_id in PROPHETS and (DICE.search(text) or FIRST_PERSON.search(text)):
                # Oráculo que continúa del capítulo anterior («…, dice Yavé»):
                # incluye algunos versículos previos del mismo oráculo.
                start = idx
                while start > 0 and idx - start < 4 \
                        and not HUMAN_SPEAKS_FIRST.search(verses[start - 1]['text']) \
                        and not any(u['book'] == book_id and u['chapter'] == chapter
                                    and u['to'] >= verses[start - 1]['v'] for u in units[-3:]):
                    start -= 1
                current = {'kind': 'oraculo', 'verses': verses[start:idx + 1]}
        carry = book if current and current['verses'] else None
        if current:
            close(current, book_id, book_es, chapter)

    # Salmos y otros pasajes añadidos a mano (sin solapar los ya detectados).
    ids = {v: k for k, v in BOOKS.items()}
    by_id = {k: v for k, v in BOOKS.values()}
    for book_id, chapter, v1, v2 in EXTRA:
        src = [b for b, (i, _) in BOOKS.items() if i == book_id][0]
        if any(u['book'] == book_id and u['chapter'] == chapter
               and not (u['to'] < v1 or u['from'] > v2) for u in units):
            continue
        verses = [x for x in chapters[(src, chapter)] if v1 <= x['v'] <= v2]
        units.append({'book': book_id, 'bookName': by_id[book_id], 'chapter': chapter,
                      'from': v1, 'to': v2, 'kind': 'salmo', 'part': 0, 'parts': 1,
                      'raw': [x['text'] for x in verses]})
    order = {b[0]: i for i, b in enumerate(BOOKS.values())}
    units.sort(key=lambda u: (order[u['book']], u['chapter'], u['from']))

    # «…Y fue a mí palabra de Yavé, diciendo:» al final de un discurso introduce
    # el siguiente: se traslada a él.
    for a, b in zip(units, units[1:]):
        if len(a['raw']) > 1 and a['raw'][-1].rstrip().endswith(':') \
                and (a['book'], a['chapter']) == (b['book'], b['chapter']) \
                and b['from'] == a['to'] + 1:
            b['raw'].insert(0, a['raw'].pop())
            a['to'] -= 1
            b['from'] -= 1
    # Si lo que queda es solo la presentación («Mas fue palabra de Yavé a
    # Semeías, diciendo:»), va entera con el discurso que sigue.
    for i in range(len(units) - 1, 0, -1):
        a, b = units[i - 1], units[i]
        if a['raw'] and a['raw'][-1].rstrip().endswith(':') \
                and (a['book'], a['chapter']) == (b['book'], b['chapter']) \
                and b['from'] == a['to'] + 1 and len(a['raw']) <= 2:
            b['raw'][:0] = a['raw']
            b['from'] = a['from']
            b['kind'] = a['kind']
            del units[i - 1]

    # Une discursos contiguos y cortos del mismo capítulo (p. ej. los días de la
    # creación). Cada «Así dice Yavé» se conserva como palabra propia.
    merged = []
    for u in units:
        prev = merged[-1] if merged else None
        if prev and (prev['book'], prev['chapter']) == (u['book'], u['chapter']) \
                and u['from'] == prev['to'] + 1 and u['kind'] != 'asi-dice' \
                and len(prev['raw']) + len(u['raw']) <= 6:
            prev['raw'].extend(u['raw'])
            prev['to'] = u['to']
        else:
            merged.append(u)
    units[:] = merged

    for u in units:
        joined = ' '.join(u['raw'])
        u['formulas'] = sorted({
            name for name, rx in (('asi-dice', ASI_DICE), ('dice-yave', DICE), ('voz-de-yave', VOZ))
            if rx.search(joined)
        })
        u['text'] = modernize(joined)
        u['verses'] = [{'v': u['from'] + i, 'text': modernize(t)} for i, t in enumerate(u['raw'])]
        del u['raw']
    for v in voz:
        v['text'] = modernize(v.pop('raw'))
    return units, voz


if __name__ == '__main__':
    units, voz = extract()
    OUT.write_text(json.dumps({'units': units, 'voz': voz}, ensure_ascii=False, indent=1),
                   encoding='utf-8')
    print(len(units), 'discursos;', sum(u['to'] - u['from'] + 1 for u in units), 'versículos;',
          len(voz), 'menciones de «la voz de Yavé»')
    print(Counter(u['kind'] for u in units))
    print(Counter(u['book'] for u in units).most_common())
