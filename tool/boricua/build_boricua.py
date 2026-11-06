"""Genera el contenido de la Biblia Boricua.

  assets/data/content_boricua.json   — los estudios (formato de la app: pasajes)
  assets/data/boricua_recursos.json  — glosario, Escuela Bíblica, asistente y
                                       planes de lectura

Todo el texto en español boricua está escrito a mano en estudios.py y
recursos.py. El texto bíblico sale de assets/data/biblia_rv1909.json
(python3 tool/boricua/build_biblia.py).

Uso:
  python3 tool/boricua/build_boricua.py
"""
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(ROOT / 'tool' / 'jesus'))
sys.path.insert(0, str(ROOT / 'tool' / 'promesas'))

from build_promesas import split_intro  # noqa: E402  (añade tool/ al path)
from build_jesus import RED, split_verse  # noqa: E402
from build_content import CATEGORIES, CATEGORIES_BY_ID, CONTENT_VERSION  # noqa: E402

BIBLE = json.loads((ROOT / 'assets' / 'data' / 'biblia_rv1909.json').read_text(encoding='utf-8'))
BOOKS = {b['name']: b for b in BIBLE['books']}
BOOK_INDEX = {b['name']: i for i, b in enumerate(BIBLE['books'])}
OUT = ROOT / 'assets' / 'data' / 'content_boricua.json'
OUT_RES = ROOT / 'assets' / 'data' / 'boricua_recursos.json'

# Palabras que no se usan en la Biblia Boricua (fuera del texto bíblico).
ARCHAIC = re.compile(r'\b(?:[Hh]e aquí|[Vv]osotros|[Ee]mpero|[Aa]caec\w*|[Hh]allarse|[Mm]as)\b')

ERAS = [
    ('ley', 'La Ley', 'El principio y el pacto', 'Génesis–Deuteronomio'),
    ('historia', 'La historia', 'Israel en su tierra', 'Josué–Ester'),
    ('poesia', 'Poesía y sabiduría', 'Oraciones y consejos para la vida', 'Job–Cantares'),
    ('profetas', 'Los profetas', 'Dios llama a volver a él', 'Isaías–Malaquías'),
    ('evangelios', 'Los evangelios', 'La vida de Jesús', 'Mateo–Juan'),
    ('iglesia', 'La Iglesia', 'Los primeros cristianos', 'Hechos–Judas'),
    ('apocalipsis', 'Apocalipsis', 'El final de la historia', 'Apocalipsis'),
]


def era_of(book_id):
    order = [b['id'] for b in BIBLE['books']]
    i = order.index(book_id)
    for era, last in (('ley', 'deu'), ('historia', 'est'), ('poesia', 'can'), ('profetas', 'mal'),
                      ('evangelios', 'jua'), ('iglesia', 'jud'), ('apocalipsis', 'apo')):
        if i <= order.index(last):
            return era
    raise ValueError(book_id)


CONTEXT = {
    'ley': 'Los primeros cinco libros de la Biblia cuentan cómo Dios creó el mundo, cómo el pecado lo dañó y cómo Dios empezó su plan de rescate: llamó a Abraham, formó a Israel, lo sacó de Egipto por medio de Moisés y le dio su ley.',
    'historia': 'Estos libros cuentan la historia de Israel en la tierra prometida: la conquista con Josué, los jueces, los reyes como David y Salomón, la división del reino, el exilio en Babilonia y el regreso.',
    'poesia': 'Salmos, Proverbios, Job, Eclesiastés y Cantares son los libros de oración, canto y sabiduría de Israel. Nos enseñan a hablar con Dios en todas las emociones y a vivir con sabiduría en lo diario.',
    'profetas': 'Los profetas hablaron de parte de Dios a un pueblo que se alejaba de él, antes, durante y después del exilio en Babilonia. Junto a sus advertencias, anunciaron la esperanza del Mesías y de un nuevo comienzo.',
    'evangelios': 'Mateo, Marcos, Lucas y Juan cuentan la vida, las enseñanzas, la muerte y la resurrección de Jesús en la tierra de Israel del siglo primero, bajo el dominio del Imperio romano.',
    'iglesia': 'Después de que Jesús resucitó y subió al cielo, el Espíritu Santo vino sobre sus discípulos y la iglesia se extendió por el mundo. Los apóstoles escribieron cartas a esas primeras comunidades para enseñarlas y animarlas.',
    'apocalipsis': 'Hacia el año 95, desterrado en la isla de Patmos por su fe, el apóstol Juan recibe una revelación de Jesucristo. Con imágenes y visiones, el libro anima a una iglesia perseguida: Dios reina, Jesús vence y viene pronto.',
}

DIVINE = ('Dios', 'Jesús', 'Jesús resucitado', 'Dios, sentado en el trono')
# Versículos donde el corte automático de voces falla (letras rojas de la
# WEB que no cuadran con la RV1909, o narración que parece palabra de Dios):
# lo que va hasta este texto lo lee el narrador y lo demás, Dios o Jesús.
# Con '' todo el versículo lo lee el narrador.
VOICE_CUTS = {
    ('Génesis', 1, 27): '',
    ('Génesis', 3, 8): '',
    ('Génesis', 3, 9): 'y le dijo:',
    ('Génesis', 3, 10): '',
    ('Hechos', 9, 6): 'Y el Señor le dice:',
}

# Voces marcadas a mano en los archivos de estudios con voz(cita, texto):
# el texto del versículo con «|» donde cambia la voz. Los tramos impares
# (el 2.º, el 4.º…) los dice Dios; los demás, el narrador. «''» = todo narrador.
VOICES = {}
_SPACES = re.compile(r'\s+')


def voz(ref, marked):
    book, ch, a, b = parse_ref(ref)
    assert a == b, ref
    VOICES[(book, ch, a)] = marked


def marked_parts(text, marked, ref):
    if marked == '':
        return [[text, False]]
    norm = lambda t: _SPACES.sub(' ', t).strip()  # noqa: E731
    assert norm(marked.replace('|', ' ')) == norm(text), f'{ref}: voz no cuadra con el texto'
    return [[seg.strip(), i % 2 == 1] for i, seg in enumerate(marked.split('|')) if seg.strip()]


RED_BOOKS = {'Mateo': 'Matthew', 'Marcos': 'Mark', 'Lucas': 'Luke', 'Juan': 'John',
             'Hechos': 'Acts', 'Apocalipsis': 'Revelation of John'}

CATEGORY_DESC = {
    'miedo': 'Cuando el miedo te tiene paralizado, Dios te dice: «No tengas miedo, yo estoy contigo».',
    'ansiedad': 'Para cuando la mente no para: Dios te invita a soltar la carga y descansar.',
    'culpa': 'Dios no te busca para condenarte, sino para limpiarte y darte una vida nueva.',
    'tristeza': 'En el duelo y las lágrimas, Dios está cerca de los que tienen el corazón roto.',
    'soledad': 'Nunca estás solo: Dios promete estar contigo todos los días.',
    'fe': 'Para cuando cuesta confiar: un Dios fiel, que cumple lo que promete.',
    'obediencia': 'Cómo seguir a Jesús en lo diario: su Palabra, su camino y su propósito.',
    'amor': 'Un amor que te buscó primero y te enseña a amar a otros.',
    'perdon': 'Dios perdona de verdad, y te enseña a soltar las deudas de otros.',
    'esperanza': 'Tu historia no termina aquí: Dios tiene planes de bien para ti.',
    'arrepentimiento': 'Dar media vuelta y volver a casa: Dios recibe al que regresa.',
    'justicia': 'A Dios le importan el pobre, el que sufre y el que es tratado injustamente.',
}


def parse_ref(ref):
    m = re.match(r'^(.+) (\d+):(\d+)(?:-(\d+))?$', ref)
    assert m, ref
    return m.group(1), int(m.group(2)), int(m.group(3)), int(m.group(4) or m.group(3))


def verse_text(book, ch, v):
    return BOOKS[book]['chapters'][ch - 1][v - 1]


def check_language(where, *texts):
    for t in texts:
        m = ARCHAIC.search(t)
        assert not m, f'{where}: palabra antigua «{m.group(0)}» en «{t[:80]}…»'


def build_studies():
    studies = []

    def e(ref, speaker, recipient, cats, paraphrase, que_paso, explicacion, dios, humano, cristo,
          aplico, oracion):
        studies.append(locals())

    for f in sorted(HERE.glob('estudios*.py')):
        exec(compile(f.read_text(encoding='utf-8'), f.name, 'exec'), {'e': e, 'voz': voz})
    passages = []
    used = {}  # cada versículo va, como mucho, en un estudio
    for x in studies:
        book, ch, a, b = parse_ref(x['ref'])
        assert book in BOOKS, book
        for v in range(a, b + 1):
            prev = used.setdefault((book, ch, v), x['ref'])
            assert prev == x['ref'], f'{x["ref"]}: {book} {ch}:{v} ya está en {prev}'
        assert sorted(x['paraphrase']) == list(range(a, b + 1)), f'{x["ref"]}: paráfrasis incompleta'
        assert x['oracion'].rstrip().endswith('Amén.'), x['ref']
        assert all(len(x[k]) > 40 for k in ('que_paso', 'explicacion', 'dios', 'humano',
                                             'cristo', 'aplico')), f'{x["ref"]}: parte muy corta'
        assert all(c in CATEGORIES_BY_ID for c in x['cats']), x['ref']
        check_language(x['ref'], *x['paraphrase'].values(), x['que_paso'], x['explicacion'],
                       x['dios'], x['humano'], x['cristo'], x['aplico'], x['oracion'])
        divine = x['speaker'] in DIVINE
        red = RED.get(RED_BOOKS.get(book, ''), {}).get(str(ch), {})
        verses = []
        for v in range(a, b + 1):
            text = verse_text(book, ch, v)
            if book in RED_BOOKS:
                # Evangelios: solo lo que dice Jesús suena con su voz (letras
                # rojas); lo que dicen los demás lo lee el narrador.
                runs = red.get(str(v), {}).get('runs')
                parts = split_verse(text, runs) if runs else [[text, False]]
            elif divine:
                parts = split_intro(text)
            else:
                parts = [[text, False]]
            cut = VOICE_CUTS.get((book, ch, v))
            marked = VOICES.get((book, ch, v))
            if marked is not None:
                parts = marked_parts(text, marked, f'{book} {ch}:{v}')
            elif cut == '':
                parts = [[text, False]]
            elif cut:
                i = text.index(cut) + len(cut)
                parts = [[text[:i].strip(), False], [text[i:].strip(), True]]
            verses.append([v, [[t, 1 if g else 0] for t, g in parts]])
        bid = BOOKS[book]['id']
        era = era_of(bid)
        passages.append({
            'id': f'b-{bid}-{ch}-{a}', 'era': era, 'reference': x['ref'], 'book': book,
            'speaker': x['speaker'], 'quote': ' '.join(x['paraphrase'][v] for v in range(a, b + 1)),
            'recipient': x['recipient'], 'people': [], 'historicalContext': CONTEXT[era],
            'situation': x['que_paso'], 'problem': x['humano'], 'explanation': x['explicacion'],
            'application': x['aplico'], 'prayer': x['oracion'], 'categories': x['cats'],
            'topics': [], 'problems': [], 'curated': True, 'verses': verses,
            'fullReference': x['ref'],
            'study': {
                'paraphrase': [[v, x['paraphrase'][v]] for v in range(a, b + 1)],
                'aboutGod': x['dios'], 'aboutHumans': x['humano'], 'aboutChrist': x['cristo'],
            },
            '_key': (BOOK_INDEX[book], ch, a),
        })
    passages.sort(key=lambda p: p.pop('_key'))
    for i, p in enumerate(passages, 1):
        p['order'] = i
    return passages


def first_ref_text(ref):
    """Texto RV1909 de una cita «Libro c:v-w» (solo un capítulo)."""
    book, ch, a, b = parse_ref(ref)
    return ' '.join(verse_text(book, ch, v) for v in range(a, b + 1))


def build_resources(studies):
    glossary, levels, answers = [], [], []

    def t(term, short, long, ref, theme):
        check_language(term, short, long)
        parse_ref(ref)
        glossary.append(dict(term=term, short=short, long=long, reference=ref, theme=theme))

    def nivel(n, title, description):
        levels.append(dict(level=n, title=title, description=description, lessons=[]))

    def leccion(title, readings, explanation, reflection, example, prayer):
        check_language(title, explanation, reflection, example, prayer)
        assert prayer.rstrip().endswith('Amén.'), title
        for ref in readings:
            parse_ref(ref)
        levels[-1]['lessons'].append(dict(
            id=f'n{levels[-1]["level"]}-{len(levels[-1]["lessons"]) + 1}', title=title,
            readings=readings, explanation=explanation, reflection=reflection,
            example=example, prayer=prayer))

    def r(question, keywords, ref, explanation, application, prayer, next_step, help=None):
        check_language(question, explanation, application, prayer, next_step, help or '')
        assert prayer.rstrip().endswith('Amén.'), question
        answers.append(dict(question=question, keywords=keywords, reference=ref,
                            text=first_ref_text(ref), explanation=explanation,
                            application=application, prayer=prayer, nextStep=next_step,
                            help=help))

    exec(compile((HERE / 'recursos.py').read_text(encoding='utf-8'), 'recursos.py', 'exec'),
         {'t': t, 'nivel': nivel, 'leccion': leccion, 'r': r})
    assert [lv['level'] for lv in levels] == list(range(1, 8))

    ids = {b['id']: b for b in BIBLE['books']}

    def chapters(book_id, chs=None):
        return [[book_id, c] for c in (chs or range(1, len(ids[book_id]['chapters']) + 1))]

    def spread(items, days):
        out, start = [], 0
        for d in range(days):
            end = round((d + 1) * len(items) / days)
            out.append(items[start:end])
            start = end
        return out

    nt = [x for b in BIBLE['books'] if b['testament'] == 'NT' for x in chapters(b['id'])]
    whole = [x for b in BIBLE['books'] for x in chapters(b['id'])]
    plans = [
        dict(id='juan21', title='Conoce a Jesús en 21 días', description='Un capítulo del evangelio de Juan cada día.',
             days=[[c] for c in chapters('jua')]),
        dict(id='salmos30', title='Salmos para el alma', description='Treinta salmos para orar en todas las emociones.',
             days=[[c] for c in chapters('sal', [1, 4, 8, 16, 19, 23, 27, 30, 32, 34, 37, 40, 42, 46, 51, 62, 63,
                                                 73, 84, 90, 91, 100, 103, 116, 121, 126, 130, 139, 145, 150])]),
        dict(id='proverbios31', title='Proverbios en un mes', description='Un capítulo de sabiduría por cada día del mes.',
             days=[[c] for c in chapters('pro')]),
        dict(id='nt90', title='El Nuevo Testamento en 90 días', description='De Mateo a Apocalipsis, unos tres capítulos al día.',
             days=spread(nt, 90)),
        dict(id='biblia365', title='La Biblia en un año', description='Toda la Biblia, de Génesis a Apocalipsis, en 365 días.',
             days=spread(whole, 365)),
    ]
    themes = [
        dict(id='dios', title='Dios', items=['Amor de Dios', 'Santidad', 'Justicia', 'Misericordia', 'Fidelidad', 'Poder', 'Soberanía']),
        dict(id='jesus', title='Jesucristo', items=['Encarnación', 'Vida de Jesús', 'Enseñanzas', 'Milagros', 'Cruz', 'Resurrección', 'Ascensión', 'Segunda venida']),
        dict(id='espiritu', title='Espíritu Santo', items=['Quién es', 'Su obra', 'Su guía', 'Consolación', 'Fruto del Espíritu']),
        dict(id='salvacion', title='Salvación', items=['Pecado', 'Fe', 'Arrepentimiento', 'Perdón', 'Gracia', 'Nuevo nacimiento', 'Vida eterna']),
        dict(id='vida', title='Vida cristiana', items=['Oración', 'Adoración', 'Ayuno', 'Obediencia', 'Servicio', 'Amor al prójimo', 'Generosidad', 'Perseverancia']),
        dict(id='familia', title='Familia', items=['Matrimonio', 'Crianza', 'Honra a los padres', 'Relaciones saludables']),
        dict(id='emociones', title='Emociones', items=['Ansiedad', 'Miedo', 'Estrés', 'Tristeza', 'Soledad', 'Esperanza', 'Gozo']),
        dict(id='discipulado', title='Discipulado', items=['Cómo seguir a Jesús', 'Cómo crecer', 'Cómo compartir la fe', 'Cómo servir']),
        dict(id='guerra', title='Guerra espiritual', items=['Tentación', 'Discernimiento', 'Armadura de Dios', 'Protección espiritual']),
    ]
    return dict(version=1, glossary=sorted(glossary, key=lambda g: g['term']), school=levels,
                assistant=answers, plans=plans, themes=themes)


def main():
    passages = build_studies()
    used = {c for p in passages for c in p['categories']}
    out = {
        'version': CONTENT_VERSION,
        'translation': 'Reina-Valera 1909 (dominio público), con ortografía actualizada y el '
                       'nombre «Jehová». Paráfrasis y explicaciones en español boricua, escritas a '
                       'mano; no reemplazan una traducción oficial.',
        'eras': [dict(id=a, title=b, subtitle=c, period=d) for a, b, c, d in ERAS
                 if any(p['era'] == a for p in passages)],
        'categories': [dict(id=a, title=t, headline=h, description=CATEGORY_DESC.get(a, d), icon=e,
                            color='FF' + f) for a, t, h, d, e, f in CATEGORIES if a in used],
        'passages': passages,
    }
    OUT.write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    res = build_resources(passages)
    OUT_RES.write_text(json.dumps(res, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    print(f'Biblia Boricua: {len(passages)} estudios, {len(res["glossary"])} términos, '
          f'{sum(len(lv["lessons"]) for lv in res["school"])} lecciones, {len(res["assistant"])} '
          f'respuestas, {len(res["plans"])} planes; '
          f'{OUT.stat().st_size // 1024} + {OUT_RES.stat().st_size // 1024} KB')


if __name__ == '__main__':
    main()
