"""Genera assets/data/content_jesus.json: todo lo que dijo Jesús, en la RV1909.

Los versículos salen de las «letras rojas» de la WEB (tool/jesus/red_letters.json);
el texto es el de la RV1909 con ortografía actualizada. Cada versículo se
separa en narración y palabras de Jesús siguiendo la proporción de la WEB, y
los versículos seguidos forman pasajes (las conversaciones completas).

Uso:
  python3 tool/jesus/build_jesus.py
"""
import csv
import json
import re
import sys
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(ROOT / 'tool' / 'corpus'))
sys.path.insert(0, str(ROOT / 'tool'))
sys.path.insert(0, str(HERE))

from extract import SOURCE, fix_caps, modernize  # noqa: E402
from build_content import (APPLY, APPLY_INTRO, CATEGORIES, CONTENT_VERSION,  # noqa: E402
                           PROBLEM_GLOSS, PROBLEMS, among, load_curated, norm, to)
from capitulos import CAPITULOS  # noqa: E402

OUT = ROOT / 'assets' / 'data' / 'content_jesus.json'
RED = json.loads((HERE / 'red_letters.json').read_text(encoding='utf-8'))

# Nombre en la fuente → (id, nombre en español, era).
BOOKS = {
    'Matthew': ('mat', 'Mateo', 'mateo'), 'Mark': ('mar', 'Marcos', 'marcos'),
    'Luke': ('luc', 'Lucas', 'lucas'), 'John': ('jua', 'Juan', 'juan'),
    'Acts': ('hch', 'Hechos', 'iglesia'), 'I Corinthians': ('1co', '1 Corintios', 'iglesia'),
    'II Corinthians': ('2co', '2 Corintios', 'iglesia'),
    'Revelation of John': ('apo', 'Apocalipsis', 'apocalipsis'),
}

ERAS = [
    ('mateo', 'Mateo', 'El Rey prometido y su reino', 'c. 27–30 d. C.'),
    ('marcos', 'Marcos', 'El Hijo de Dios vino a servir', 'c. 27–30 d. C.'),
    ('lucas', 'Lucas', 'El Salvador de los perdidos', 'c. 27–30 d. C.'),
    ('juan', 'Juan', 'El Verbo hecho carne: «Yo soy»', 'c. 27–30 d. C.'),
    ('iglesia', 'La Iglesia', 'El Resucitado habla a los suyos', 'c. 30–56 d. C.'),
    ('apocalipsis', 'Apocalipsis', 'Jesucristo glorificado', 'c. 95 d. C.'),
]

CONTEXT = {
    'mat': 'Mateo, el recaudador de impuestos que lo dejó todo para seguir a Jesús, escribió para '
           'lectores judíos. Muestra a Jesús como el Mesías prometido, el Hijo de David, que cumple la '
           'Ley y los Profetas y anuncia el reino de los cielos. Jesús habló en la Galilea y la Judea '
           'del siglo I, bajo el dominio de Roma.',
    'mar': 'Marcos, compañero de Pedro, escribió el evangelio más breve y ágil, probablemente para '
           'creyentes en Roma. Presenta a Jesús como el Hijo de Dios, que no vino para ser servido, '
           'sino para servir y dar su vida en rescate por muchos.',
    'luc': 'Lucas, médico y compañero de Pablo, lo investigó todo con diligencia desde el principio. '
           'Muestra a Jesús como el Salvador de todos: de los pobres, las mujeres, los extranjeros y '
           'los pecadores que nadie quería.',
    'jua': 'Juan, el discípulo amado, escribió para que creamos que Jesús es el Cristo, el Hijo de '
           'Dios, y para que creyendo tengamos vida en su nombre. Recoge largas conversaciones de '
           'Jesús y sus grandes «Yo soy».',
    'hch': 'Lucas continúa su relato: Jesús resucitado sube al cielo, envía el Espíritu Santo y '
           'sigue hablando a sus apóstoles mientras el evangelio se extiende desde Jerusalén hasta '
           'Roma.',
    '1co': 'Pablo escribe a la iglesia de Corinto, dividida incluso en la Cena del Señor, y le '
           'recuerda las palabras que Jesús dijo la noche en que fue entregado.',
    '2co': 'Pablo defiende su ministerio ante los corintios y cuenta cómo, en medio de una '
           'debilidad que no se le quitó, el Señor le habló.',
    'apo': 'Hacia el año 95, desterrado en la isla de Patmos por causa del evangelio, el apóstol '
           'Juan ve a Jesucristo glorificado. Jesús habla a siete iglesias de Asia y revela que él '
           'vence y hace nuevas todas las cosas.',
}

# Las categorías de la app, dichas por Jesús.
CATEGORY_TEXT = {
    'miedo': ('Jesús libera el miedo', 'Jesús habla sobre el miedo',
              'Cuando el temor te paraliza, Jesús dice «no temáis» y «tened ánimo; yo soy».'),
    'ansiedad': ('Jesús libera la ansiedad', 'Jesús habla sobre la ansiedad',
                 'No os congojéis por el día de mañana: palabras para descansar en el cuidado del Padre.'),
    'culpa': ('Jesús libera la culpa', 'Jesús habla sobre la culpa',
              'Jesús no vino a condenar, sino a salvar: «Ni yo te condeno; vete, y no peques más».'),
    'tristeza': ('Jesús libera la tristeza', 'Jesús habla sobre la tristeza',
                 'Bienaventurados los que lloran: Jesús consuela, llora con los suyos y vence a la muerte.'),
    'soledad': ('Jesús libera la soledad', 'Jesús habla sobre la soledad',
                'No os dejaré huérfanos: Jesús promete estar con los suyos todos los días.'),
    'fe': ('Jesús fortalece la fe', 'Jesús habla sobre la fe',
           'Al que cree todo es posible: Jesús enseña a confiar en el Padre.'),
    'obediencia': ('Jesús enseña a seguirlo', 'Jesús habla sobre seguirlo',
                   '«Sígueme»: Jesús llama a oír sus palabras y hacerlas, a tomar la cruz y caminar tras él.'),
    'amor': ('Jesús enseña amor', 'Jesús habla sobre el amor',
             'Que os améis unos a otros como yo os he amado: el mandamiento nuevo.'),
    'perdon': ('Jesús enseña perdón', 'Jesús habla sobre el perdón',
               'Tus pecados te son perdonados: Jesús perdona y enseña a perdonar setenta veces siete.'),
    'esperanza': ('Jesús enseña esperanza', 'Jesús habla sobre la esperanza',
                  'Yo soy la resurrección y la vida: el reino de Dios, la vida eterna y su regreso.'),
    'arrepentimiento': ('Jesús llama al arrepentimiento', 'Jesús habla sobre volver a Dios',
                        'Arrepentíos, que el reino de los cielos se ha acercado.'),
    'justicia': ('Jesús defiende al pobre', 'Jesús habla sobre la justicia',
                 'Jesús anuncia buenas nuevas a los pobres y libertad a los oprimidos.'),
}

KEYWORDS = {
    'miedo': [r'no temas', r'no temais', r'no tengais miedo', r'tened animo', r'no se turbe',
              r'por que temeis', r'no tengas miedo', r'cobrad animo', r'no se espante'],
    'ansiedad': [r'congoj', r'afan', r'\bpaz\b', r'descanso', r'hago descansar', r'carga', r'\bafan'],
    'culpa': [r'pecado', r'pecador', r'iniquidad', r'condeno', r'condenar'],
    'tristeza': [r'llor', r'consol', r'triste', r'lagrima', r'gozo', r'duelo', r'angusti'],
    'soledad': [r'con vosotros estoy', r'no os dejare', r'huerfanos', r'estoy con vosotros',
                r'vendre a vosotros', r'morada', r'permaneced en mi', r'permanece en mi'],
    'fe': [r'\bfe\b', r'\bcre[eyi]', r'cosa imposible', r'son posibles', r'no seas incredulo',
           r'confia', r'\bduda', r'yo soy el', r'yo soy la', r'pedid'],
    'obediencia': [r'sigueme', r'seguidme', r'mandamiento', r'guarda', r'hace la voluntad',
                   r'haced', r'\bid\b', r'tome su cruz', r'oye estas mis palabras', r'discipul',
                   r'\bley\b', r'siervo', r'servir', r'sirve'],
    'amor': [r'\bamor\b', r'\bama', r'\bamad', r'amaos', r'amado', r'misericordia', r'projimo',
             r'compasion', r'amigos'],
    'perdon': [r'perdon', r'remision', r'deudas', r'setenta veces'],
    'esperanza': [r'vida eterna', r'resucit', r'reino de los cielos', r'reino de dios',
                  r'vendre', r'gloria', r'bienaventurado', r'vida', r'herencia', r'galardon'],
    'arrepentimiento': [r'arrepent', r'\bay de\b', r'hipocrita', r'fuego', r'infierno', r'juicio',
                        r'perecer', r'tinieblas de afuera', r'convert', r'generacion mala'],
    'justicia': [r'\bpobre', r'\bviuda', r'hambre', r'\bjusticia', r'enfermo', r'carcel',
                 r'cautivo', r'oprimid', r'pequenitos', r'menor de'],
}
KEYWORDS_RE = {k: [re.compile(p) for p in v] for k, v in KEYWORDS.items()}

EXPLAIN = {
    'miedo': 'Jesús no niega lo que da miedo, pero se pone en medio: él está presente y tiene '
             'autoridad sobre la tormenta, la enfermedad y la muerte. Por eso su «no temáis» no es '
             'un consejo vacío.',
    'ansiedad': 'Jesús enseña a vivir confiando en un Padre que sabe lo que necesitamos. Invita a '
                'soltar lo que no podemos cargar y a buscar primero su reino.',
    'culpa': 'Jesús llama al pecado por su nombre, pero vino a buscar y a salvar lo que se había '
             'perdido. Con él la culpa no tiene la última palabra: hay perdón y una vida nueva.',
    'tristeza': 'Jesús se acerca al que sufre. No pasa de largo ante las lágrimas: consuela, '
                'promete gozo y muestra que la muerte no tiene la última palabra.',
    'soledad': 'Jesús promete su presencia y la del Espíritu. Quien lo sigue no camina solo: él '
               'permanece con los suyos todos los días.',
    'fe': 'Jesús revela quién es y llama a creer en él. La fe que pide no es saberlo todo, sino '
          'confiar en su palabra aunque todavía no se vea.',
    'obediencia': 'Jesús no solo enseña, también llama: seguirlo es oír sus palabras y ponerlas por '
                  'obra. Sus mandamientos muestran cómo es la vida en el reino de Dios.',
    'amor': 'Jesús muestra el amor del Padre y enseña a amar como él ama: a Dios con todo el corazón '
            'y al prójimo, incluso al enemigo.',
    'perdon': 'Jesús perdona con autoridad y enseña a perdonar. Quien recibe tanto perdón aprende a '
              'soltar las deudas de los demás.',
    'esperanza': 'Jesús anuncia el reino de Dios y la vida eterna. Sus palabras abren un futuro que '
                 'ni el sufrimiento ni la muerte pueden cerrar.',
    'arrepentimiento': 'Jesús advierte con claridad porque ama: confronta la hipocresía y el pecado '
                       'para que la gente se vuelva a Dios mientras hay tiempo.',
    'justicia': 'Jesús se pone del lado del pobre, del enfermo y del despreciado. Lo que se hace por '
                'el más pequeño, a él se le hace.',
}

PRAY = {
    'miedo': 'Hoy renuncio al miedo. Tú estás conmigo y tienes autoridad sobre todo lo que temo.',
    'ansiedad': 'Hoy renuncio a la ansiedad. Busco primero tu reino y descanso en tu cuidado.',
    'culpa': 'Te confieso mi pecado. Gracias porque viniste a salvar y no a condenar.',
    'tristeza': 'Te entrego mi tristeza. Consuélame y dame tu gozo.',
    'soledad': 'Hoy renuncio a la mentira de que estoy solo. Tú estás conmigo todos los días.',
    'fe': 'Creo; ayuda mi incredulidad. Decido confiar en tu palabra.',
    'obediencia': 'Quiero seguirte. Dame fuerzas para oír tus palabras y hacerlas.',
    'amor': 'Gracias por amarme primero. Enséñame a amar como tú me amas.',
    'perdon': 'Gracias por tu perdón. Ayúdame a perdonar como tú me perdonas.',
    'esperanza': 'Renueva mi esperanza. Creo que tú eres la resurrección y la vida.',
    'arrepentimiento': 'Examina mi corazón. Hoy me vuelvo a ti y dejo todo lo que me aparta de ti.',
    'justicia': 'Dame un corazón compasivo con los pobres y los que sufren, como el tuyo.',
}

TOPIC_WORDS = [
    (r'reino de (?:los cielos|dios)', 'reino de Dios'), (r'\bpadre\b', 'el Padre'),
    (r'espiritu', 'Espíritu Santo'), (r'vida eterna', 'vida eterna'), (r'parabola|semejante',
                                                                    'parábolas'),
    (r'oracion|orad|\bora\b|pedid', 'oración'), (r'sabado', 'sábado'), (r'templo', 'templo'),
    (r'cruz|crucific', 'la cruz'), (r'resucit', 'resurrección'), (r'yo soy', '«Yo soy»'),
    (r'sanad|sano|enferm', 'sanidad'), (r'discipul', 'discipulado'), (r'fariseo', 'fariseos'),
    (r'iglesia', 'iglesia'), (r'\bpan\b', 'pan de vida'), (r'pastor|ovejas', 'buen pastor'),
]

KNOWN_PEOPLE = [
    'Pedro', 'Simón', 'Andrés', 'Jacobo', 'Juan', 'Felipe', 'Natanael', 'Tomás', 'Mateo', 'Judas',
    'María', 'Marta', 'Lázaro', 'Nicodemo', 'Zaqueo', 'Pilato', 'Herodes', 'Caifás', 'Saulo',
    'Pablo', 'Ananías', 'Satanás', 'Moisés', 'Elías', 'Abraham', 'Jonás', 'Salomón', 'David',
    'Juan el Bautista', 'Barrabás', 'Legión', 'Bartimeo', 'Cleofas',
]

# Destinatarios que se nombran al contar quién le hablaba o a quién.
RECIPIENTS = [
    ('sus discípulos', 'sus discípulos'), ('los discípulos', 'sus discípulos'),
    ('los doce', 'los doce'), ('los once', 'los once'), ('Pedro', 'Pedro'),
    ('Simón', 'Simón Pedro'), ('los fariseos', 'los fariseos'),
    ('los escribas', 'los escribas'), ('los principales sacerdotes', 'los principales sacerdotes'),
    ('los judíos', 'los judíos'), ('las gentes', 'la multitud'), ('la gente', 'la multitud'),
    ('las compañías', 'la multitud'), ('la compañía', 'la multitud'), ('el pueblo', 'el pueblo'),
    ('la mujer', 'una mujer'), ('Marta', 'Marta'), ('María', 'María'), ('Tomás', 'Tomás'),
    ('Felipe', 'Felipe'), ('Natanael', 'Natanael'), ('Nicodemo', 'Nicodemo'), ('Judas', 'Judas'),
    ('Pilato', 'Pilato'), ('Zaqueo', 'Zaqueo'), ('Saulo', 'Saulo'), ('Ananías', 'Ananías'),
    ('Pablo', 'Pablo'), ('el centurión', 'un centurión'), ('el leproso', 'un leproso'),
    ('el ciego', 'un ciego'), ('el paralítico', 'un paralítico'), ('Satanás', 'Satanás'),
    ('el diablo', 'el diablo'), ('el tentador', 'el diablo'), ('el mancebo', 'un joven rico'),
    ('el hombre', 'un hombre'),
]
SAID_TO = re.compile(r'(?:dijo|díjole|díjoles|dice|dícele|díceles|respondió|respondiendo|habló|'
                     r'enseñaba|decía|llamando|preguntó|preguntaba)[^:.;]{0,50}?\b(?:a|á)\s+(.{0,40})')


def classify(text: str) -> list[str]:
    t = norm(text)
    scores = Counter()
    for cat, pats in KEYWORDS_RE.items():
        for p in pats:
            scores[cat] += len(p.findall(t))
    scores['arrepentimiento'] *= 1.2
    scores['esperanza'] *= 0.8
    ranked = [c for c, s in scores.most_common() if s > 0]
    return (ranked or ['fe'])[:3]


# ---------------------------------------------------------------------------
# Narración y palabras de Jesús dentro de cada versículo
# ---------------------------------------------------------------------------

def cuts(text: str, marks: str) -> list[int]:
    """Posiciones justo después de la puntuación [marks] (antes del espacio)."""
    return [m.end() for m in re.finditer(r'[%s](?=\s)' % re.escape(marks), text)]


SPEECH = re.compile(r'\b(?:dij|dic|díc|díj|respond|habl|decía|clam|pregunt|exclam|enseñ|voz)\w*', re.I)


def introduces(text: str, colon: int) -> bool:
    """¿El «:» en [colon] cierra un «…le dijo:»?"""
    start = max(text.rfind(c, 0, colon - 1) for c in '.:;?!')
    return bool(SPEECH.search(text[start + 1:colon]))


def snap(text: str, target: float, starts: bool, lo: int) -> int | None:
    """Lleva un cambio de quien habla (fracción del versículo en la WEB) a la
    puntuación más cercana de la RV1909. [starts]: empieza a hablar Jesús."""
    n = len(text)
    best = None
    if starts:
        kinds = [(':', 0.0), ('.?!;', 0.15), (',', 0.25)]
    else:
        kinds = [('.?!;:', 0.0), (',', 0.12)]
    for marks, penalty in kinds:
        for pos in cuts(text, marks):
            if pos <= lo:
                continue
            score = abs(pos / n - target) + penalty
            if starts and marks == ':' and not introduces(text, pos):
                score += 0.15
            if score <= 0.4 and (best is None or score < best[0]):
                best = (score, pos)
    return best[1] if best else None


# Donde la RV1909 tiene otro texto que la WEB (el Texto Recibido añade
# palabras), se separa a mano.
FIXES = {
    # La WEB dice «¡Llamadle!»; la RV1909 lo cuenta: «mandó llamarle».
    ('Mark', 10, 49): [['Entonces Jesús parándose, mandó llamarle: y llaman al ciego, '
                        'diciéndole: Ten confianza: levántate, te llama.', False]],
    ('Acts', 9, 5): [['Y él dijo: ¿Quién eres, Señor? Y él dijo:', False],
                     ['Yo soy Jesús a quien tú persigues: dura cosa te es dar coces contra el '
                      'aguijón.', True]],
    ('Acts', 9, 6): [['El, temblando y temeroso, dijo: Señor, ¿qué quieres que haga? Y el '
                      'Señor le dice:', False],
                     ['Levántate y entra en la ciudad, y se te dirá lo que te conviene hacer.',
                      True]],
}


def split_verse(text: str, runs: list) -> list:
    """[[texto, esJesús], …] según los tramos de la WEB."""
    # Lo que se cita de Jesús dentro de la narración («cuando Jesús le dijo:
    # Tu hijo vive; y creyó») lo sigue leyendo el narrador.
    spans, start = [], 0.0
    for end, j in runs:
        spans.append([start, end, j])
        start = end
    for i, (a, b, j) in enumerate(spans):
        if j and 0 < i < len(spans) - 1 and b - a < 0.2 and a > 0.5:
            spans[i][2] = 0
    merged = []
    for a, b, j in spans:
        if merged and merged[-1][2] == j:
            merged[-1][1] = b
        else:
            merged.append([a, b, j])
    if not any(j for _, _, j in merged):
        return [[text, False]]
    parts, pos = [], 0
    for a, b, j in merged:
        if b >= 0.999:
            parts.append([text[pos:].strip(), bool(j)])
            break
        at = snap(text, b, starts=not j, lo=pos)
        if at is None:
            # Sin puntuación donde cortar: se queda con quien dice más.
            continue
        parts.append([text[pos:at].strip(), bool(j)])
        pos = at
    out = []
    for t, j in parts:
        if not t:
            continue
        if out and out[-1][1] == j:
            out[-1][0] += ' ' + t
        else:
            out.append([t, j])
    if len(out) == 1:
        share = sum(b - a for a, b, j in merged if j)
        out[0][1] = share >= 0.5
    return out


# ---------------------------------------------------------------------------
# Pasajes
# ---------------------------------------------------------------------------

MAX_VERSES = 14


def load_bible():
    bible = {}
    with SOURCE.open(encoding='utf-8') as f:
        for r in csv.DictReader(f):
            if r['Book'] in BOOKS:
                text = modernize(fix_caps(r['Text'], r['Verse']))
                bible.setdefault((r['Book'], int(r['Chapter'])), {})[int(r['Verse'])] = text
    return bible


def chunks(nums: list[int], paras: set[int]) -> list[list[int]]:
    """Parte un discurso largo en trozos de hasta MAX_VERSES, por párrafos."""
    if len(nums) <= MAX_VERSES:
        return [nums]
    pieces = -(-len(nums) // 11)
    size = len(nums) / pieces
    out, start = [], 0
    for k in range(1, pieces):
        ideal = round(k * size)
        options = [i for i in range(max(start + 4, ideal - 4), min(len(nums) - 4, ideal + 4) + 1)
                   if nums[i] in paras]
        cut = min(options, key=lambda i: abs(i - ideal)) if options else ideal
        if cut - start > MAX_VERSES + 3:
            cut = start + MAX_VERSES
        out.append(nums[start:cut])
        start = cut
    out.append(nums[start:])
    return out


def groups(bible):
    """(libro, capítulo, [versículos]) de cada pasaje, en orden de la Biblia."""
    for book in BOOKS:
        for ch_s, verses in RED[book].items():
            ch = int(ch_s)
            texts = bible[(book, ch)]
            said = {}
            for v_s, d in verses.items():
                if v_s == '_p' or int(v_s) not in texts:
                    continue
                fixed = FIXES.get((book, ch, int(v_s)))
                if fixed:
                    assert ' '.join(t for t, _ in fixed) == texts[int(v_s)], (book, ch, v_s)
                parts = fixed or split_verse(texts[int(v_s)], d['runs'])
                if any(j for _, j in parts):
                    said[int(v_s)] = parts
            if not said:
                continue
            paras = set(verses.get('_p', []))
            runs = []
            for v in sorted(said):
                # Hasta dos versículos de narración en medio siguen siendo la
                # misma conversación.
                if runs and v - runs[-1][-1] <= 3:
                    runs[-1].extend(range(runs[-1][-1] + 1, v + 1))
                else:
                    runs.append([v])
            for run in runs:
                # «…y les dijo:» al final del versículo anterior.
                if run[0] - 1 in texts and run[0] - 1 not in said \
                        and texts[run[0] - 1].rstrip().endswith(':'):
                    run.insert(0, run[0] - 1)
                for piece in chunks(run, paras):
                    yield book, ch, piece, said


def recipient_for(narration: str, default: str) -> str:
    for m in SAID_TO.finditer(narration):
        tail = m.group(1)
        for key, name in RECIPIENTS:
            if tail.startswith(key):
                return name
    return default


def people_in(text: str, recipient: str) -> list[str]:
    found = []
    for name in KNOWN_PEOPLE:
        if re.search(rf'\b{name}\b', recipient + ' ' + text[:600]) and name not in found:
            found.append(name)
    return found[:6]


def key_phrase(words: str, limit: int = 160) -> str:
    m = re.search(r'^(.{20,%d}?[.;!?])(?:\s|$)' % limit, words)
    phrase = m.group(1) if m else words[:limit].rsplit(' ', 1)[0] + '…'
    return phrase.rstrip(';:,')


def reference(name, ch, a, b):
    return f'{name} {ch}:{a}' if a == b else f'{name} {ch}:{a}-{b}'


def main():
    bible = load_bible()
    passages = []
    missing = set()
    for book, ch, nums, said in groups(bible):
        bid, name, era = BOOKS[book]
        texts = bible[(book, ch)]
        verses = [[v, said.get(v) or [[texts[v], False]]] for v in nums]
        jesus = [v for v in nums if v in said]
        words = ' '.join(t for _, parts in verses for t, j in parts if j)
        narration = ' '.join(t for _, parts in verses for t, j in parts if not j)
        key = f'{bid} {ch}'
        if key not in CAPITULOS:
            missing.add(key)
            continue
        ch_recipient, situation = CAPITULOS[key]
        recipient = recipient_for(narration, ch_recipient)
        uid = f'j-{bid}-{ch}-{nums[0]}'
        cats = classify(words)
        primary = cats[0]
        problems = []
        for c in cats:
            for p in PROBLEMS[c]:
                if p not in problems:
                    problems.append(p)
        problems = problems[:4]
        t = norm(words)
        topics = [tag for pattern, tag in TOPIC_WORDS if re.search(pattern, t)][:5]
        variant = sum(map(ord, uid)) % 2
        listed = ', '.join(problems[:-1]) + ' y ' + problems[-1] if len(problems) > 1 else problems[0]
        gloss = PROBLEM_GLOSS[primary]
        passages.append({
            'id': uid, 'era': era,
            'reference': reference(name, ch, jesus[0], jesus[-1]),
            'book': name, 'speaker': 'Jesús', 'quote': words, 'recipient': recipient,
            'people': people_in(narration + ' ' + words, recipient),
            'historicalContext': CONTEXT[bid], 'situation': situation,
            'problem': f'Jesús estaba tratando {listed} {among(recipient)}. {gloss}',
            'explanation': f'Aquí Jesús habla {to(recipient)}. {EXPLAIN[primary]} '
                           f'«{key_phrase(words)}»',
            'application': f'Si hoy estás enfrentando {APPLY_INTRO[primary]}, '
                           f'{APPLY[primary][variant]}',
            'prayer': f'Señor Jesús, así como hablaste {to(recipient)}, háblame hoy a mí. '
                      f'{PRAY[primary]} Que tu palabra sea viva en mí. Amén.',
            'categories': cats, 'problems': problems,
            'topics': topics or [primary],
            'curated': False,
            'verses': [[v, [[t, 1 if j else 0] for t, j in parts]] for v, parts in verses],
            'fullReference': reference(name, ch, nums[0], nums[-1]),
        })
    assert not missing, f'capítulos sin contexto en capitulos.py: {sorted(missing)}'

    # Las palabras de Jesús explicadas a mano en la edición completa.
    by_book = {name: [p for p in passages if p['book'] == name] for _, name, _ in BOOKS.values()}
    taken = set()
    for c in load_curated():
        if c['speaker'] not in ('Jesús', 'Jesús resucitado', 'Jesús glorificado', 'El Señor',
                                'La voz del Señor'):
            continue
        for p in by_book.get(c['book'], []):
            m = re.match(r'^.+ (\d+):(\d+)(?:-(\d+))?$', p['fullReference'])
            ch, a, b = int(m.group(1)), int(m.group(2)), int(m.group(3) or m.group(2))
            if ch == c['_chapter'] and a <= c['_verse'] <= b and p['id'] not in taken:
                taken.add(p['id'])
                p.update(quote=c['quote'], problem=c['problem'], explanation=c['explanation'],
                         application=c['application'], prayer=c['prayer'],
                         categories=[x for x in c['categories'] if x != 'voz'] or p['categories'],
                         curated=True)
                break

    for i, p in enumerate(passages, 1):
        p['order'] = i
    used = {c for p in passages for c in p['categories']}
    out = {
        'version': CONTENT_VERSION,
        'translation': 'Reina-Valera 1909 (dominio público), heredera de la Biblia del Oso de '
                       'Casiodoro de Reina (1569), con ortografía actualizada. Las palabras de '
                       'Jesús, de Mateo a Apocalipsis.',
        'eras': [dict(id=a, title=b, subtitle=c, period=d) for a, b, c, d in ERAS],
        'categories': [dict(id=a, title=CATEGORY_TEXT[a][0], headline=CATEGORY_TEXT[a][1],
                            description=CATEGORY_TEXT[a][2], icon=e, color='FF' + f)
                       for a, _, _, _, e, f in CATEGORIES if a in used],
        'passages': passages,
    }
    OUT.write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    print(f'Edición Jesús: {len(passages)} pasajes ({len(taken)} explicados a mano), '
          f'{sum(len(p["verses"]) for p in passages)} versículos; {OUT.stat().st_size // 1024} KB')
    print(Counter(c for p in passages for c in p['categories']).most_common())
    print(Counter(p['era'] for p in passages))


if __name__ == '__main__':
    main()
