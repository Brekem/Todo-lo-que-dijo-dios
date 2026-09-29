"""Genera assets/data/content.json: todas las palabras de Yavé en orden cronológico.

Une dos fuentes:
  1. tool/content/part*.py  — 71 palabras explicadas a mano (curated: true).
  2. tool/corpus/units.json — cada discurso de Yavé en la RV1909 (curated: false),
     con contexto por libro y capítulo, y explicación, aplicación y oración
     generadas a partir de su tema.

Uso:
  python3 tool/corpus/extract.py      # si cambió el extractor
  python3 tool/build_content.py
"""
import json
import re
import sys
import unicodedata
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'tool' / 'corpus'))

from books import BOOK_ORDER, CONTEXT, DEFAULT_RECIPIENT, era  # noqa: E402
from chapters_1 import CH as CH1  # noqa: E402
from chapters_2 import CH as CH2  # noqa: E402
from chapters_3 import CH as CH3  # noqa: E402
from chapters_4 import CH as CH4  # noqa: E402
from chapters_5 import CH as CH5  # noqa: E402
from voz import VOZ_CH  # noqa: E402
from extract import BOOKS as OT_BOOKS, SOURCE, fix_caps, modernize  # noqa: E402
from segment import (NARRATOR_ONLY, QUOTE_OK, START_SPEAKING,  # noqa: E402
                     apply_fixes, god_text, segment)

# Increméntala cada vez que publiques contenido nuevo en Firestore.
CONTENT_VERSION = 4

CH = {**CH1, **CH2, **CH3, **CH4, **CH5}
OUT = ROOT / 'assets' / 'data' / 'content.json'

ERAS = [
    ('adan', 'Adán', 'La creación y el principio', 'El principio'),
    ('noe', 'Noé', 'El diluvio y el primer pacto', 'Tiempos antiguos'),
    ('abraham', 'Abraham', 'El llamado y la promesa', 'c. 2000 a. C.'),
    ('isaac', 'Isaac', 'El hijo de la promesa', 'c. 1900 a. C.'),
    ('jacob', 'Jacob', 'De Betel a Egipto', 'c. 1850 a. C.'),
    ('moises', 'Moisés', 'Liberación, ley y desierto', 'c. 1450 a. C.'),
    ('josue', 'Josué', 'La tierra prometida y los jueces', 'c. 1400–1100 a. C.'),
    ('profetas', 'Profetas', 'Reyes, salmistas y profetas', 'c. 1050–587 a. C.'),
    ('israel', 'Israel', 'Exilio en Babilonia y regreso', 'c. 597–430 a. C.'),
    ('evangelios', 'Evangelios', 'Dios hecho hombre en Jesús', 'c. 27–30 d. C.'),
    ('iglesia', 'La Iglesia', 'El Resucitado guía a los apóstoles', 'c. 34–56 d. C.'),
    ('apocalipsis', 'Apocalipsis', 'La revelación final', 'c. 95 d. C.'),
]

CATEGORIES = [
    ('miedo', 'Dios libera el miedo', 'Dios habla sobre el miedo', 'Cuando el temor te paraliza, Dios dice «no temas» y te recuerda que Él está contigo.', 'shield', '2F4A7A'),
    ('ansiedad', 'Dios libera la ansiedad', 'Dios habla sobre la ansiedad', 'Palabras para aquietar la mente, soltar el mañana y descansar en su cuidado.', 'spa', '3E5C8A'),
    ('culpa', 'Dios libera la culpa', 'Dios habla sobre la culpa', 'Dios no te busca para condenarte, sino para limpiarte y darte una vida nueva.', 'water_drop', '8E3B46'),
    ('tristeza', 'Dios libera la tristeza', 'Dios habla sobre la tristeza', 'En el duelo, el agotamiento y las lágrimas, Dios consuela y promete hacer nuevas todas las cosas.', 'sentiment', '5A6A8F'),
    ('soledad', 'Dios libera la soledad', 'Dios habla sobre la soledad', 'Nunca estás solo: Dios promete estar contigo todos los días.', 'group', '6B5A86'),
    ('fe', 'Dios fortalece la fe', 'Dios habla sobre la fe', 'Promesas que parecen imposibles y un Dios para quien nada es difícil.', 'anchor', 'B08A3E'),
    ('obediencia', 'Dios enseña obediencia', 'Dios habla sobre la obediencia', 'Llamados a salir, a caminar y a confiar cuando Dios dice «ve».', 'route', '7A6A3A'),
    ('amor', 'Dios enseña amor', 'Dios habla sobre el amor', 'Un amor eterno que te busca, te llama por tu nombre y te enseña a amar.', 'favorite', 'A3424C'),
    ('perdon', 'Dios enseña perdón', 'Dios habla sobre el perdón', 'Dios borra, olvida y restaura; y te enseña a soltar las deudas de otros.', 'handshake', '9A6A3A'),
    ('esperanza', 'Dios enseña esperanza', 'Dios habla sobre la esperanza', 'Pensamientos de paz, caminos en el desierto y una historia que termina bien.', 'sunny', 'C29B45'),
    ('arrepentimiento', 'Dios llama al arrepentimiento', 'Dios habla sobre volver a Él', 'Advertencias de un Dios que confronta el pecado porque quiere que su pueblo regrese.', 'undo', '6E4B3A'),
    ('justicia', 'Dios defiende al oprimido', 'Dios habla sobre la justicia', 'Dios se pone del lado del pobre, la viuda, el huérfano y el extranjero.', 'balance', '3A5A6E'),
    ('voz', 'La voz de Yavé', 'La voz de Yavé', 'Cada lugar donde la Escritura habla de oír y obedecer la voz de Yavé.', 'record_voice', '8A6D2E'),
]

# ---------------------------------------------------------------------------
# Clasificación por temas
# ---------------------------------------------------------------------------

def norm(s: str) -> str:
    s = unicodedata.normalize('NFD', s.lower())
    return ''.join(c for c in s if unicodedata.category(c) != 'Mn')


KEYWORDS = {
    'miedo': [r'no temas', r'no temais', r'no tengas temor', r'no tengais temor', r'no desmayes',
              r'esfuerzate', r'esforzaos', r'se valiente', r'no te espantes', r'no temeras'],
    'ansiedad': [r'descans', r'reposo', r'\bpaz\b', r'quietud', r'estad quietos', r'no se turbe', r'afan'],
    'culpa': [r'pecado', r'iniquidad', r'rebelion', r'prevaric', r'culpa', r'maldad'],
    'tristeza': [r'consol', r'lagrima', r'enjuga', r'no llores', r'quebrantados de corazon', r'en lugar de luto',
                 r'tornare su lloro', r'alegria'],
    'soledad': [r'no te dejare', r'yo sere contigo', r'estare contigo', r'yo soy contigo', r'contigo estoy',
                r'no me olvidare', r'desamparad', r'abandonad', r'desolada'],
    'fe': [r'\bcre[eyi]', r'confia', r'confianza', r'esperad', r'cosa dificil', r'yo soy yave', r'yo yave',
           r'\bfe\b', r'fiel'],
    'obediencia': [r'guardad', r'guardareis', r'mandamiento', r'estatuto', r'\bley\b', r'oid mi voz', r'obedec',
                   r'habla a los hijos de israel', r'ordenanza', r'\bve\b', r'\bheme aqui\b'],
    'amor': [r'\bamor\b', r'\bamare\b', r'\bamado', r'misericordia', r'compasion', r'\bpiedad\b', r'\bmiseraciones'],
    'perdon': [r'perdon', r'no me acordare', r'borro', r'borrare', r'limpiare', r'sanare', r'volveos a mi', r'tornaos a mi'],
    'esperanza': [r'restaur', r'volvere la cautividad', r'hare volver', r'\bnuevo\b', r'edificare', r'plantare',
                  r'dias vienen', r'en aquel dia', r'juntare', r'reunire', r'renuevo', r'multiplicare'],
    'arrepentimiento': [r'volveos', r'convertios', r'arrepent', r'\bay de\b', r'castigare', r'visitare',
                        r'destruire', r'\bira\b', r'furor', r'espada', r'idolos', r'dioses ajenos', r'\bbaal\b',
                        r'abominacion', r'no oyeron', r'no escucharon', r'rebelde', r'hambre', r'castigo',
                        r'pestilencia', r'asolar', r'asolacion', r'desolacion', r'meter[eé] fuego', r'cuchillo'],
    'justicia': [r'huerfano', r'\bviuda', r'\bpobre', r'afligido', r'opresi', r'oprim', r'justicia', r'extranjero',
                 r'menesteroso', r'injust'],
    'voz': [r'voz de yave'],
}
KEYWORDS_RE = {k: [re.compile(p) for p in v] for k, v in KEYWORDS.items()}

LAW_BOOKS = ('exo', 'lev', 'num')
LAW_RE = [re.compile(p) for p in (
    r'\bharas\b', r'\bsantos? sereis\b', r'\bsantificare', r'\bdiles\b', r'sacerdote',
    r'si alguno', r'cuando alguna persona', r'estatuto perpetuo',
)]

PROBLEMS = {
    'miedo': ['miedo'], 'ansiedad': ['ansiedad', 'falta de paz'], 'culpa': ['culpa', 'pecado'],
    'tristeza': ['tristeza', 'dolor'], 'soledad': ['soledad', 'abandono'], 'fe': ['duda', 'incredulidad'],
    'obediencia': ['desobediencia'], 'amor': ['falta de amor'], 'perdon': ['culpa', 'rencor'],
    'esperanza': ['desesperanza'], 'arrepentimiento': ['rebeldía', 'alejamiento de Dios'],
    'justicia': ['injusticia', 'opresión'], 'voz': ['no escuchar a Dios'],
}
EXTRA_PROBLEMS = [
    (r'idolo|dioses ajenos|\bbaal\b|imagen de fundicion|escultura', 'idolatría'),
    (r'soberbi|altivez|enaltec|orgull|te engrandeciste', 'orgullo'),
    (r'mentira|enga[nñ]|falsos? profeta|profetizan mentira', 'engaño'),
    (r'murmur|queja', 'queja'),
    (r'sangre inocente|violencia|robo|rapi[nñ]a', 'violencia'),
]

TOPIC_WORDS = [
    (r'\bpacto\b|alianza', 'pacto'), (r'templo|\bcasa de yave\b|santuario|tabernaculo', 'templo'),
    (r'sabado', 'sábado'), (r'holocausto|sacrifici|ofrenda', 'ofrendas'),
    (r'renuevo|mi siervo|ungido|belen|mi hijo eres tu', 'Mesías'),
    (r'cautiv|babilonia|destierro', 'exilio'), (r'naciones|gentes', 'naciones'),
    (r'fiesta|pascua', 'fiestas'), (r'tierra que os doy|heredad|poseer la tierra', 'tierra prometida'),
    (r'\bpastor', 'pastores'), (r'espiritu', 'Espíritu'), (r'corazon', 'corazón'),
    (r'profeta', 'profetas'), (r'\brey\b', 'reyes'), (r'sion|jerusalem', 'Jerusalén'),
]

KNOWN_PEOPLE = [
    'Adán', 'Eva', 'Caín', 'Noé', 'Abram', 'Abraham', 'Sara', 'Agar', 'Isaac', 'Rebeca', 'Jacob', 'Israel',
    'José', 'Moisés', 'Aarón', 'María', 'Faraón', 'Balaam', 'Josué', 'Caleb', 'Gedeón', 'Samuel', 'Elí',
    'Saúl', 'David', 'Natán', 'Nathán', 'Gad', 'Salomón', 'Roboam', 'Jeroboam', 'Elías', 'Eliseo', 'Acab',
    'Jezabel', 'Jehú', 'Ezequías', 'Isaías', 'Josías', 'Jeremías', 'Baruc', 'Ezequiel', 'Daniel',
    'Oseas', 'Joel', 'Amós', 'Jonás', 'Miqueas', 'Habacuc', 'Sofonías', 'Hageo', 'Zacarías', 'Zorobabel',
    'Malaquías', 'Job', 'Satán', 'Ciro', 'Sedequías', 'Manasés', 'Hulda',
]
PROPHET_OF_BOOK = {'isa': 'Isaías', 'jer': 'Jeremías', 'eze': 'Ezequiel', 'ose': 'Oseas', 'joe': 'Joel',
                   'amo': 'Amós', 'abd': 'Abdías', 'jon': 'Jonás', 'miq': 'Miqueas', 'nah': 'Nahúm',
                   'hab': 'Habacuc', 'sof': 'Sofonías', 'hag': 'Hageo', 'zac': 'Zacarías', 'mal': 'Malaquías'}


def classify(book: str, text: str, formulas: list[str]) -> list[str]:
    t = norm(text)
    law = book in LAW_BOOKS
    scores = Counter()
    for cat, pats in KEYWORDS_RE.items():
        for p in pats:
            # En la Ley, «abominación» califica alimentos y prácticas impuras,
            # no anuncia juicio.
            if law and p.pattern == r'abominacion':
                continue
            scores[cat] += len(p.findall(t))
    if law:
        # Instrucciones dadas a Moisés: Dios enseña a su pueblo a vivir.
        scores['obediencia'] += 4 + sum(len(p.findall(t)) for p in LAW_RE)
    else:
        # Un anuncio de juicio pesa más que palabras sueltas de otros temas.
        scores['arrepentimiento'] *= 1.5
    if book == 'job':
        # Dios responde a un hombre que sufre mostrándole su grandeza.
        scores['fe'] += 4
        scores['tristeza'] += 2
    if 'voz-de-yave' in formulas:
        scores['voz'] += 5
    ranked = [c for c, s in scores.most_common() if s > 0]
    if not ranked:
        ranked = ['obediencia'] if book in ('exo', 'lev', 'num', 'deu') else ['fe']
    return ranked[:3]


# ---------------------------------------------------------------------------
# Textos generados por tema
# ---------------------------------------------------------------------------

EXPLAIN = {
    'miedo': 'Yavé se presenta como quien acompaña y protege. Sus palabras quitan el temor recordando quién es él y lo que ha prometido.',
    'ansiedad': 'Yavé ofrece descanso y paz. Sus palabras invitan a dejar de sostenerlo todo con las propias fuerzas y confiar en su cuidado.',
    'culpa': 'Yavé llama al pecado por su nombre, pero no para dejar a nadie hundido en la culpa: quiere limpiar y restaurar a su pueblo.',
    'tristeza': 'Yavé ve el dolor de su pueblo y responde con consuelo. Sus palabras muestran que las lágrimas no tienen la última palabra.',
    'soledad': 'Yavé promete su presencia. Sus palabras recuerdan que quien le pertenece nunca está verdaderamente solo.',
    'fe': 'Yavé se revela tal como es: fiel, poderoso y soberano. Sus palabras invitan a confiar en él más que en lo que se ve.',
    'obediencia': 'Yavé enseña a su pueblo cómo vivir. Sus instrucciones, aunque sean de otra época, muestran su santidad y su deseo de que su pueblo viva bien delante de él.',
    'amor': 'Yavé muestra su amor fiel y su misericordia. Sus palabras revelan un corazón que se compadece y no abandona a los suyos.',
    'perdon': 'Yavé ofrece perdón y un nuevo comienzo. Sus palabras muestran que él está dispuesto a borrar el pecado de quien vuelve a él.',
    'esperanza': 'Yavé anuncia restauración. Aun en medio de la ruina, sus palabras abren un futuro de esperanza para su pueblo.',
    'arrepentimiento': 'Yavé confronta con claridad la infidelidad de su pueblo. No lo hace para destruir, sino para que se vuelvan a él: detrás de cada advertencia hay una invitación a regresar.',
    'justicia': 'Yavé se pone del lado del débil. Sus palabras denuncian la injusticia y muestran que a él le importa cómo se trata al pobre, a la viuda, al huérfano y al extranjero.',
    'voz': 'La Escritura insiste en oír la voz de Yavé. Escucharla y obedecerla trae vida; ignorarla trae ruina.',
}

APPLY = {
    'miedo': ['no tengas miedo de dar el paso que Dios te pide: él va delante de ti. Nombra hoy lo que temes y ponlo en sus manos.',
              'recuerda que el temor no decide tu camino; Dios sí. Repite su promesa cuando el miedo vuelva.'],
    'ansiedad': ['detente un momento, respira y entrega a Dios lo que te agobia. Haz hoy solo lo que te toca y deja el resto en sus manos.',
                 'busca un tiempo de quietud delante de Dios. Su paz no depende de que todo esté resuelto.'],
    'culpa': ['confiesa con sinceridad lo que hiciste y acepta el perdón de Dios. Si puedes reparar un daño, da hoy un paso para hacerlo.',
              'no te escondas de Dios por tu pecado: acércate a él. Él confronta para sanar.'],
    'tristeza': ['lleva tus lágrimas a Dios sin fingir. Busca hoy a alguien de confianza y permite que te acompañe.',
                 'recuerda que Dios ve tu dolor y promete consuelo. Escribe una de sus promesas y léela cuando te duela.'],
    'soledad': ['recuerda que Dios está contigo ahora mismo. Da un paso hacia otros: escribe a alguien o acércate a tu comunidad.',
                'habla con Dios como con alguien presente. Su compañía es real aunque no la sientas.'],
    'fe': ['escribe esta palabra y colócala donde la veas. Actúa hoy como alguien que cree que Dios cumple lo que dice.',
           'mira más allá de lo que ves. Pregúntate qué harías hoy si confiaras plenamente en Dios, y hazlo.'],
    'obediencia': ['identifica una cosa concreta que Dios te pide y hazla hoy, aunque sea pequeña. La obediencia se aprende caminando.',
                   'lee estas instrucciones buscando el corazón de Dios detrás de ellas y pregúntate cómo honrarlo hoy en tu vida.'],
    'amor': ['recibe el amor de Dios sin condiciones y muéstralo hoy con un gesto concreto hacia alguien.',
             'recuerda que Dios te ama con amor fiel. Deja que ese amor cambie cómo tratas a los demás.'],
    'perdon': ['acepta que el perdón de Dios es real. Y si guardas rencor a alguien, decide hoy soltar esa deuda delante de él.',
               'vuelve a Dios sin miedo: él espera para perdonar. Luego extiende ese mismo perdón a otros.'],
    'esperanza': ['no des por terminada tu historia. Pide a Dios ojos para ver lo nuevo que está haciendo y agradécele por adelantado.',
                  'aférrate a la promesa de restauración. Da hoy un pequeño paso de esperanza.'],
    'arrepentimiento': ['examina tu corazón con honestidad: ¿hay algo que ocupa el lugar de Dios? Vuelve hoy a él; su advertencia es una invitación.',
                        'no endurezcas tu corazón. Si te alejaste, da hoy un paso concreto de regreso a Dios.'],
    'justicia': ['mira a tu alrededor: ¿quién necesita que alguien actúe con justicia y compasión? Haz hoy algo concreto por esa persona.',
                 'revisa cómo tratas a los más débiles. A Dios le importa, y también debe importarte a ti.'],
    'voz': ['busca hoy un momento para escuchar a Dios en su Palabra, y pon por obra lo que te muestre.',
            'no dejes que otras voces apaguen la de Dios. Lee, escucha y obedece.'],
}

PRAY = {
    'miedo': 'Hoy renuncio al miedo. Tú estás conmigo y vas delante de mí.',
    'ansiedad': 'Hoy renuncio a la ansiedad y descanso en tu cuidado.',
    'culpa': 'Te confieso mi pecado. Hoy renuncio a la culpa y recibo tu limpieza.',
    'tristeza': 'Te entrego mi tristeza. Consuélame y seca mis lágrimas.',
    'soledad': 'Hoy renuncio a la mentira de que estoy solo. Tú estás conmigo.',
    'fe': 'Fortalece mi fe. Decido confiar en ti más que en lo que veo.',
    'obediencia': 'Enséñame tus caminos y dame un corazón dispuesto a obedecerte.',
    'amor': 'Gracias por tu amor fiel. Enséñame a amar como tú amas.',
    'perdon': 'Gracias por tu perdón. Ayúdame a perdonar como tú me perdonas.',
    'esperanza': 'Renueva mi esperanza. Creo que tú haces nuevas todas las cosas.',
    'arrepentimiento': 'Examina mi corazón. Hoy me vuelvo a ti y dejo todo lo que me aparta de ti.',
    'justicia': 'Dame un corazón justo y compasivo con los que sufren.',
    'voz': 'Abre mis oídos para oír tu voz y mi corazón para obedecerla.',
}

APPLY_INTRO = {
    'miedo': 'el miedo', 'ansiedad': 'la ansiedad o el agobio', 'culpa': 'la culpa',
    'tristeza': 'la tristeza o el duelo', 'soledad': 'la soledad', 'fe': 'la duda',
    'obediencia': 'la duda sobre qué camino seguir', 'amor': 'la sensación de no ser amado',
    'perdon': 'la culpa o el rencor', 'esperanza': 'la desesperanza',
    'arrepentimiento': 'la sensación de haberte alejado de Dios', 'justicia': 'la injusticia',
    'voz': 'el ruido de muchas voces',
}


def key_phrase(words: str, limit: int = 150) -> str:
    """Primera frase de las palabras de Dios, para citarla en explicación y oración."""
    m = re.search(r'^(.{20,%d}?[.;!?])(?:\s|$)' % limit, words)
    phrase = m.group(1) if m else words[:limit].rsplit(' ', 1)[0] + '…'
    return phrase.rstrip(';:,')


INTRO_PREFIX = re.compile(r'^(?P<intro>[^:]{0,220}?(?:Yavé|Dios|palabra|diciendo|dijo|díjole|habló|respondió)[^:]{0,80}):\s*')


def god_words(text: str) -> str:
    m = INTRO_PREFIX.match(text)
    if m and len(text) - m.end() > 20:
        return text[m.end():]
    return text


RECIPIENT_RE = [
    re.compile(r'(?:dijo|habló|respondió|díjole|dijo luego)\s+(?:Yavé|Dios)(?: Dios)?\s+a\s+([A-ZÁÉÍÓÚ][\wáéíóúñ]+(?:(?:,| y) (?:a )?[A-ZÁÉÍÓÚ][\wáéíóúñ]+)*)'),
    re.compile(r'(?:Yavé|Dios)\s+(?:dijo|habló|respondió)\s+a\s+([A-ZÁÉÍÓÚ][\wáéíóúñ]+(?:(?:,| y) (?:a )?[A-ZÁÉÍÓÚ][\wáéíóúñ]+)*)'),
    re.compile(r'palabra de Yavé a ([A-ZÁÉÍÓÚ][\wáéíóúñ]+)'),
]


def recipient_for(unit: dict, chapter_recipient: str) -> str:
    head = unit['text'][:220]
    for rx in RECIPIENT_RE:
        m = rx.search(head)
        if m:
            name = m.group(1).replace(' y a ', ' y ').replace(', a ', ', ')
            if name.split()[0] not in chapter_recipient:
                return name
            break
    return chapter_recipient


def people_in(text: str, recipient: str) -> list[str]:
    found = []
    for name in KNOWN_PEOPLE:
        if re.search(rf'\b{name}\b', recipient) or re.search(rf'\b{name}\b', text[:400]):
            canon = {'Abram': 'Abraham', 'Nathán': 'Natán'}.get(name, name)
            if canon not in found:
                found.append(canon)
    return found[:6]


ARTICLES = ('El ', 'La ', 'Los ', 'Las ', 'Un ', 'Una ', 'Todo ', 'Toda ', 'Todos ', 'Quien ', 'Quienes ')


def lower_first(s: str) -> str:
    """Minúscula solo en artículos iniciales («El pueblo» → «el pueblo»), no en nombres."""
    return s[:1].lower() + s[1:] if s.startswith(ARTICLES) else s


def to(recipient: str) -> str:
    """«a» + destinatario, con contracción «al»."""
    r = lower_first(recipient)
    return 'al ' + r[3:] if r.startswith('el ') else 'a ' + r


def among(recipient: str) -> str:
    r = lower_first(recipient)
    return 'en el ' + r[3:] if r.startswith('el ') else 'en ' + r


def generated_fields(uid: str, book: str, text: str, words: str, recipient: str,
                     situation: str, formulas: list[str]):
    cats = classify(book, text, formulas)
    primary = cats[0]
    t = norm(text)
    problems = []
    for c in cats:
        for p in PROBLEMS[c]:
            if p not in problems:
                problems.append(p)
    for pattern, tag in EXTRA_PROBLEMS:
        if re.search(pattern, t) and tag not in problems:
            problems.append(tag)
    problems = problems[:4]
    topics = []
    for pattern, tag in TOPIC_WORDS:
        if re.search(pattern, t) and tag not in topics:
            topics.append(tag)
    topics = topics[:5] or [CAT_WORD[primary]]

    variant = sum(map(ord, uid)) % 2
    listed = ', '.join(problems[:-1]) + ' y ' + problems[-1] if len(problems) > 1 else problems[0]
    problem = f'Dios estaba tratando {listed} {among(recipient)}. {PROBLEM_GLOSS[primary]}'
    explanation = f'Aquí Yavé habla {to(recipient)}. {EXPLAIN[primary]}'
    application = f'Si hoy estás enfrentando {APPLY_INTRO[primary]}, {APPLY[primary][variant]}'
    prayer = (f'Señor, así como hablaste {to(recipient)}, háblame hoy a mí. '
              f'{PRAY[primary]} Que tu palabra sea viva en mí. Amén.')
    return {
        'categories': cats, 'problems': problems, 'topics': topics,
        'problem': problem, 'explanation': explanation, 'application': application, 'prayer': prayer,
    }


CATEGORIES_BY_ID = {c[0]: c for c in CATEGORIES}

CAT_WORD = {'miedo': 'miedo', 'ansiedad': 'ansiedad', 'culpa': 'culpa', 'tristeza': 'consuelo',
            'soledad': 'presencia de Dios', 'fe': 'fe', 'obediencia': 'obediencia', 'amor': 'amor de Dios',
            'perdon': 'perdón', 'esperanza': 'esperanza', 'arrepentimiento': 'arrepentimiento',
            'justicia': 'justicia', 'voz': 'la voz de Yavé'}

PROBLEM_GLOSS = {
    'miedo': 'El temor amenazaba con paralizar a quienes Dios quería guiar.',
    'ansiedad': 'Faltaba descanso y confianza en medio de la presión.',
    'culpa': 'El pecado estaba dañando la relación con Dios y con los demás.',
    'tristeza': 'El dolor y la pérdida pesaban sobre el corazón.',
    'soledad': 'Había una sensación de abandono y de estar solos.',
    'fe': 'Hacía falta confiar en Dios más que en lo que se veía.',
    'obediencia': 'El pueblo necesitaba aprender a caminar según la voluntad de Dios.',
    'amor': 'Hacía falta recordar el amor fiel de Dios.',
    'perdon': 'Hacía falta recibir el perdón de Dios y volver a él.',
    'esperanza': 'La ruina y la espera hacían difícil creer en un futuro.',
    'arrepentimiento': 'El pueblo se había apartado de Dios y necesitaba volver a él.',
    'justicia': 'Los débiles estaban siendo oprimidos y olvidados.',
    'voz': 'Se había dejado de escuchar la voz de Dios.',
}

# ---------------------------------------------------------------------------
# Palabras explicadas a mano
# ---------------------------------------------------------------------------

BOOK_IDS = {
    'Génesis': 'gen', 'Éxodo': 'exo', 'Levítico': 'lev', 'Números': 'num', 'Deuteronomio': 'deu',
    'Josué': 'jos', 'Jueces': 'jue', '1 Samuel': '1sa', '2 Samuel': '2sa', '1 Reyes': '1re',
    '2 Reyes': '2re', '1 Crónicas': '1cr', '2 Crónicas': '2cr', 'Job': 'job', 'Salmos': 'sal',
    'Isaías': 'isa', 'Jeremías': 'jer', 'Ezequiel': 'eze', 'Joel': 'joe', 'Zacarías': 'zac',
    'Malaquías': 'mal',
}


WRITTEN = ROOT / 'tool' / 'content' / 'written'


def load_written():
    """Cita corta y textos escritos a mano para cada discurso (tool/content/written)."""
    W = {}

    def w(id, quote, problem, explanation, application, prayer, cats=None):
        assert id not in W, f'repetida: {id}'
        assert prayer.rstrip().endswith('Amén.'), f'oración sin «Amén.»: {id}'
        if cats:
            assert all(c in CATEGORIES_BY_ID for c in cats), f'categoría desconocida: {id}'
        W[id] = dict(quote=quote, problem=problem, explanation=explanation,
                     application=application, prayer=prayer, cats=cats)

    def skip(id, reason):
        """El extractor lo tomó por un discurso, pero no es Dios hablando."""
        assert id not in W, f'repetida: {id}'
        W[id] = dict(skip=reason)

    for f in sorted(WRITTEN.glob('*.py')):
        exec(compile(f.read_text(encoding='utf-8'), str(f), 'exec'), {'w': w, 'skip': skip})
    return W


def _plain(s: str) -> str:
    return re.sub(r'\s+', ' ', re.sub(r'[^\w\s]', ' ', s.lower())).strip()


def check_quote(pid: str, quote: str, source: str):
    """La cita corta debe estar palabra por palabra en la RV1909 (se permite «…»)."""
    text = _plain(source)
    for piece in re.split(r'…', quote):
        piece = _plain(piece)
        assert piece and piece in text, f'{pid}: la cita no está en el texto: «{piece}»'


def apply_written(p: dict, source: str, W: dict):
    x = W.get(p['id'])
    if x is None:
        return
    if 'skip' in x:
        p['_skip'] = True
        return
    check_quote(p['id'], x['quote'], source)
    p.update(quote=x['quote'], problem=x['problem'], explanation=x['explanation'],
             application=x['application'], prayer=x['prayer'], curated=True)
    if x['cats']:
        p['categories'] = x['cats']


def load_curated():
    P = []

    def add(id, era_, ref, book, speaker, quote, recipient, people, ctx, sit, problem, expl, app,
            prayer, cats, topics, problems):
        P.append(dict(id=id, era=era_, reference=ref, book=book, speaker=speaker, quote=quote,
                      recipient=recipient, people=people, historicalContext=ctx, situation=sit,
                      problem=problem, explanation=expl, application=app, prayer=prayer,
                      categories=cats, topics=topics, problems=problems, curated=True))

    env = {'add': add, 'P': P}
    for part in ('part1.py', 'part2.py', 'part3.py'):
        code = (ROOT / 'tool' / 'content' / part).read_text(encoding='utf-8')
        exec(code.replace('P = []\n', ''), env)
    for p in P:
        p['curated'] = True
        m = re.match(r'^(.+?) (\d+):(\d+)', p['reference'])
        p['_book'] = BOOK_IDS.get(m.group(1)) if m else None
        p['_chapter'] = int(m.group(2)) if m else 0
        p['_verse'] = int(m.group(3)) if m else 0
        last = re.findall(r'\d+', p['reference'].split(':', 1)[1]) if m else []
        p['_to'] = int(last[-1]) if last else p['_verse']
    return P


# ---------------------------------------------------------------------------
# Versículos completos: narración y palabras de Dios
# ---------------------------------------------------------------------------

NT_BOOKS = {
    'Matthew': ('mat', 'Mateo'), 'Mark': ('mar', 'Marcos'), 'Luke': ('luc', 'Lucas'),
    'John': ('jua', 'Juan'), 'Acts': ('hch', 'Hechos'), 'II Corinthians': ('2co', '2 Corintios'),
    'Revelation of John': ('apo', 'Apocalipsis'),
}


def load_bible():
    """(libro en español, capítulo) → {versículo: texto actualizado}."""
    import csv
    names = {**OT_BOOKS, **NT_BOOKS}
    bible = {}
    with SOURCE.open(encoding='utf-8') as f:
        for r in csv.DictReader(f):
            if r['Book'] not in names:
                continue
            key = (names[r['Book']][1], int(r['Chapter']))
            text = fix_caps(r['Text'], r['Verse'])
            bible.setdefault(key, {})[int(r['Verse'])] = modernize(text)
    return bible


def verse_numbers(ref: str) -> tuple[str, int, list[int]]:
    """«Génesis 6:14, 18» → ('Génesis', 6, [14, 18]); «Juan 11:25-26» → [25, 26]."""
    m = re.match(r'^(.+?) (\d+):(.+)$', ref)
    nums = []
    for part in m.group(3).split(','):
        a, _, b = part.strip().partition('-')
        nums.extend(range(int(a), int(b or a) + 1))
    return m.group(1), int(m.group(2)), nums


# Palabras explicadas a mano: la conversación completa en la que están (el
# pasaje por sí solo corta el diálogo). Libro y capítulo son los de la cita.
CONVERSATION = {
    'mat-3-17': (16, 17), 'mat-6-34': (33, 34), 'jua-8-11': (10, 11),
    'jua-11-25': (23, 27), 'mat-11-28': (28, 30), 'jua-12-28': (27, 30),
    'jua-13-34': (33, 35), 'mat-14-27': (26, 29), 'jua-14-27': (27, 27),
    'mat-17-5': (5, 7), 'mat-18-22': (21, 22), 'jua-21-17': (15, 17),
    'luc-23-43': (42, 43), 'mat-28-20': (18, 20), 'hch-9-4': (3, 6),
    'hch-10-15': (13, 16), '2co-12-9': (8, 9), 'hch-13-2': (2, 2),
    'hch-18-9': (9, 10), 'apo-1-17': (17, 18), 'apo-3-20': (20, 20),
    'apo-21-5': (5, 6), 'apo-22-20': (20, 20),
}

# Dentro de estos libros habla Jesús o se oye la voz del Padre.
NT_INTRO = re.compile(
    r'(?:Jesús|el Señor|[Ll]a voz|una voz[^:]{0,30})[^:.;]{0,60}\b(?:dijo|díjole|díjoles|respondió|'
    r'decía|diciendo|dice)\b[^:.;?]{0,60}:|(?:díjole|díjoles|dijo|respondió) (?:Jesús|el Señor)[^:.;]{0,40}:'
    r'|oí una voz[^:]{0,40}:|dijo el Espíritu Santo:|el Señor en visión:')


def segment_free(verses, book_id):
    """Versículos fuera de los discursos del corpus (Nuevo Testamento, Salmos…)."""
    seg, _ = segment(verses, speaking=False, book=book_id)
    if not god_text(seg):
        seg, _ = segment(verses, speaking=True, book=book_id)
    return seg


def segment_nt(verses):
    """Jesús habla tras «Jesús le dijo:»; lo demás es narración."""
    out = []
    speaking = False
    for verse in verses:
        text = verse['text']
        parts = []
        pos = 0
        for m in NT_INTRO.finditer(text):
            if m.start() < pos:
                continue
            chunk = text[pos:m.start()].strip()
            if chunk:
                parts.append([chunk, speaking])
            parts.append([m.group(0).strip(), False])
            pos = m.end()
            speaking = True
        rest = text[pos:].strip()
        # «Y él dijo: Señor…»: vuelve a hablar otro.
        reply = re.search(r'\s(?=(?:Y|Entonces|Mas) (?:él|ella|ellos|Pedro|Pablo|Simón|Marta|Saulo)'
                          r'[^:]{0,40}(?:dijo|respondió|dijeron)[^:]*:)', rest)
        if speaking and reply:
            parts.append([rest[:reply.start()].strip(), True])
            parts.append([rest[reply.start():].strip(), False])
            speaking = False
        elif rest:
            parts.append([rest, speaking])
        merged = []
        for t, g in parts:
            if not t:
                continue
            if merged and merged[-1][1] == g:
                merged[-1][0] += ' ' + t
            else:
                merged.append([t, g])
        out.append([verse['v'], merged])
    return out


def _plain_words(s: str) -> str:
    return re.sub(r'\s+', ' ', re.sub(r'[^\w\s]', ' ', s.lower())).strip()


FAILED = []


def check_verses(p: dict):
    """Lo que la cita corta dice de Dios tiene que sonar con la voz de Dios."""
    if p['id'] in QUOTE_OK or p['id'] in NARRATOR_ONLY or p['id'].startswith('v-'):
        return
    god = _plain_words(' '.join(t for _, parts in p['verses'] for t, g in parts if g))
    for piece in p['quote'].split('…'):
        piece = _plain_words(piece)
        if p['curated'] and not p['id'].startswith('y-'):
            # Las citas escritas a mano no siempre copian la RV1909 letra por letra.
            words = piece.split()
            if sum(w in god.split() for w in words) >= 0.8 * len(words):
                continue
        if piece not in god:
            FAILED.append(f"{p['id']}: la cita no queda en la voz de Dios: «{piece}»")


# ---------------------------------------------------------------------------
# Ensamblado
# ---------------------------------------------------------------------------

def reference(book_name, chapter, v1, v2):
    return f'{book_name} {chapter}:{v1}' if v1 == v2 else f'{book_name} {chapter}:{v1}-{v2}'


def main():
    corpus = json.loads((ROOT / 'tool' / 'corpus' / 'units.json').read_text(encoding='utf-8'))
    curated = load_curated()
    written = load_written()
    used = set()
    era_ids = [e[0] for e in ERAS]

    def overlaps(u):
        for p in curated:
            if p['_book'] == u['book'] and p['_chapter'] == u['chapter']:
                inter = min(p['_to'], u['to']) - max(p['_verse'], u['from']) + 1
                if inter > 0 and inter * 2 >= (u['to'] - u['from'] + 1):
                    return True
        return False

    items = []
    for p in curated:
        key = (era_ids.index(p['era']),
               BOOK_ORDER.index(p['_book']) if p['_book'] in BOOK_ORDER else 99,
               p['_chapter'], p['_verse'])
        items.append((key, {k: v for k, v in p.items() if not k.startswith('_')}))

    def trim(u):
        """Quita los versículos que ya cubre una palabra explicada a mano."""
        covered = {v for p in curated if p['_book'] == u['book'] and p['_chapter'] == u['chapter']
                   for v in range(p['_verse'], p['_to'] + 1)}
        keep = [v for v in u['verses'] if v['v'] not in covered]
        if len(keep) == len(u['verses']):
            return [u]
        parts, block = [], []
        for v in keep:
            if block and v['v'] != block[-1]['v'] + 1:
                parts.append(block)
                block = []
            block.append(v)
        if block:
            parts.append(block)
        # «Y respondió Yavé a Job…, y dijo:» sin las palabras (ya están en la
        # palabra explicada a mano) no es una palabra por sí sola.
        parts = [b for b in parts
                 if not (len(b) == 1 and b[0]['text'].rstrip().endswith(':'))]
        return [{**u, 'from': b[0]['v'], 'to': b[-1]['v'], 'verses': b,
                 'text': ' '.join(x['text'] for x in b)} for b in parts]

    skipped = 0
    units = []
    for u in corpus['units']:
        pieces = trim(u)
        skipped += len(pieces) != 1 or pieces[0] is not u
        units.extend(pieces)
    for u in units:
        chap_key = f"{u['book']} {u['chapter']}"
        ch_recipient, situation = CH[chap_key]
        recipient = recipient_for(u, ch_recipient)
        words = god_words(u['text'])
        uid = f"y-{u['book']}-{u['chapter']}-{u['from']}"
        head = u['text'][:160]
        speaker = 'El ángel de Yavé' if 'ángel de Yavé' in head else (
            'Dios' if 'Dios' in head.split(':')[0] and 'Yavé' not in head.split(':')[0] else 'Yavé')
        e = era(u['book'], u['chapter'])
        fields = generated_fields(uid, u['book'], u['text'], words, recipient, situation, u['formulas'])
        items.append(((era_ids.index(e), BOOK_ORDER.index(u['book']), u['chapter'], u['from']), {
            'id': uid, 'era': e,
            'reference': reference(u['bookName'], u['chapter'], u['from'], u['to']),
            'book': u['bookName'], 'speaker': speaker, 'quote': u['text'], 'recipient': recipient,
            'people': people_in(u['text'], recipient),
            'historicalContext': CONTEXT[u['book']], 'situation': situation,
            **fields, 'curated': False,
        }))
        apply_written(items[-1][1], u['text'], written)
        used.add(uid)

    # «La voz de Yavé» fuera de los discursos: se agrupan versículos seguidos.
    in_units = lambda v: any(x['book'] == v['book'] and x['chapter'] == v['chapter']
                             and x['from'] <= v['verse'] <= x['to'] for x in corpus['units']) \
        or any(p['_book'] == v['book'] and p['_chapter'] == v['chapter']
               and p['_verse'] <= v['verse'] <= p['_to'] for p in curated)
    groups = []
    for v in corpus['voz']:
        if in_units(v):
            continue
        last = groups[-1] if groups else None
        if last and last['book'] == v['book'] and last['chapter'] == v['chapter'] \
                and v['verse'] - last['to'] <= 2:
            last['to'] = v['verse']
            last['texts'].append(v['text'])
        else:
            groups.append({**v, 'from': v['verse'], 'to': v['verse'], 'texts': [v['text']]})
    for g in groups:
        key = f"{g['book']} {g['chapter']}"
        recipient, situation = VOZ_CH.get(key) or CH[key]
        text = ' '.join(g['texts'])
        uid = f"v-{g['book']}-{g['chapter']}-{g['from']}"
        fields = generated_fields(uid, g['book'], text, text, recipient, situation, ['voz-de-yave'])
        fields['categories'] = ['voz'] + [c for c in fields['categories'] if c != 'voz'][:2]
        fields['explanation'] = (f'Este pasaje habla de la voz de Yavé. {EXPLAIN["voz"]} '
                                 f'Aquí se dirige {to(recipient)}.')
        e = era(g['book'], g['chapter'])
        items.append(((era_ids.index(e), BOOK_ORDER.index(g['book']), g['chapter'], g['from']), {
            'id': uid, 'era': e,
            'reference': reference(g['bookName'], g['chapter'], g['from'], g['to']),
            'book': g['bookName'], 'speaker': 'La voz de Yavé', 'quote': text,
            'recipient': recipient, 'people': people_in(text, recipient),
            'historicalContext': CONTEXT[g['book']], 'situation': situation,
            **fields, 'curated': False,
        }))
        apply_written(items[-1][1], text, written)
        used.add(uid)

    stale = set(written) - used
    assert not stale, f'textos escritos para palabras que ya no existen: {sorted(stale)}'
    items = [kv for kv in items if not kv[1].pop('_skip', False)]

    # Versículos completos, separados en narración y palabras de Dios.
    bible = load_bible()
    book_id = {name: i for i, name in {**OT_BOOKS, **NT_BOOKS}.values()}
    seg = {}
    for u in corpus['units']:
        uid0 = f"y-{u['book']}-{u['chapter']}-{u['from']}"
        parts, _ = segment(u['verses'], book=u['book'],
                           speaking=uid0 in START_SPEAKING or u['kind'] not in ('intro', 'asi-dice'))
        for v, vp in apply_fixes(uid0, parts, u['verses']):
            seg[(u['bookName'], u['chapter'], v)] = vp
    in_pieces = {(p['book'], *verse_numbers(p['reference'])[1:2], v)
                 for _, p in items if p['id'].startswith('y-')
                 for v in verse_numbers(p['reference'])[2]}
    for _, p in items:
        book, ch, nums = verse_numbers(p['reference'])
        if p['id'] in CONVERSATION:
            a, b = CONVERSATION[p['id']]
            nums = list(range(a, b + 1))
        else:
            nums = list(range(min(nums), max(nums) + 1))
        texts = bible[(book, ch)]
        if p['id'].startswith('v-'):
            verses = [[v, [[texts[v], False]]] for v in nums]
        else:
            if not p['id'].startswith('y-'):
                # «Y habló Dios todas estas palabras, diciendo:» quedó sin palabra propia.
                while (book, ch, nums[0] - 1) in seg and (book, ch, nums[0] - 1) not in in_pieces \
                        and texts[nums[0] - 1].rstrip().endswith(':'):
                    nums.insert(0, nums[0] - 1)
            if all((book, ch, v) in seg for v in nums):
                verses = [[v, seg[(book, ch, v)]] for v in nums]
            elif book_id[book] in {i for i, _ in NT_BOOKS.values()}:
                verses = segment_nt([{'v': v, 'text': texts[v]} for v in nums])
            else:
                verses = segment_free([{'v': v, 'text': texts[v]} for v in nums], book_id[book])
        verses = apply_fixes(p['id'], verses, [{'v': v, 'text': texts[v]} for v in nums])
        p['verses'] = [[v, [[t, 1 if g else 0] for t, g in vp]] for v, vp in verses]
        p['fullReference'] = reference(book, ch, nums[0], nums[-1])
        check_verses(p)
    items.sort(key=lambda kv: kv[0])
    assert not FAILED, '\n'.join(FAILED)
    passages = []
    seen = set()
    for i, (_, p) in enumerate(items, 1):
        assert p['id'] not in seen, p['id']
        seen.add(p['id'])
        p['order'] = i
        passages.append(p)

    out = {
        'version': CONTENT_VERSION,
        'translation': 'Reina-Valera 1909 (dominio público), heredera de la Biblia del Oso de '
                       'Casiodoro de Reina (1569), con ortografía actualizada y el nombre divino «Yavé».',
        'eras': [dict(id=a, title=b, subtitle=c, period=d) for a, b, c, d in ERAS],
        'categories': [dict(id=a, title=b, headline=c, description=d, icon=e, color='FF' + f)
                       for a, b, c, d, e, f in CATEGORIES],
        'passages': passages,
    }
    OUT.write_text(json.dumps(out, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    print(f'{len(passages)} palabras ({sum(p["curated"] for p in passages)} explicadas a mano, '
          f'{skipped} discursos cubiertos por ellas, {len(groups)} de «la voz de Yavé»); '
          f'{OUT.stat().st_size // 1024} KB')
    print(Counter(c for p in passages for c in p['categories']).most_common())
    print(Counter(p['era'] for p in passages))


if __name__ == '__main__':
    main()
