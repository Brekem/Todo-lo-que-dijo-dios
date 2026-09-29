"""Separa los versículos completos en narración y palabras de Dios.

La RV1909 no usa comillas: las palabras de Dios empiezan tras los dos puntos
de una introducción («Y dijo Dios:», «Así ha dicho Yavé:», «Y habló Yavé a
Moisés, diciendo:») y terminan cuando vuelve el narrador («y fue así.»,
«Y vio Dios…», «Estas son las palabras que habló Yavé…»).

Cada versículo queda como `[número, [[texto, esDios], …]]`. Las palabras de
Dios nunca se cortan: el narrador solo retoma donde termina lo que Dios dijo.
"""
import re

# Quién habla cuando habla Dios (texto ya actualizado: «Yavé», no «Jehová»).
GOD = (r'(?:el Señor Yavé|Yavé(?: Dios)?(?: de los ejércitos)?|Dios|el ángel de Yavé|'
       r'el ángel de Dios|el Señor|Jesús|una voz(?: del cielo| de los cielos| de la nube)?|'
       r'la voz)')
VERB = (r'(?:d[ií]jo|d[ií]jole|d[ií]jome|d[ií]joles|habl[óo]|respondi[óo]|llam[óo]|mand[óo]|'
        r'jur[óo]|dec[ií]a|clam[óo])')

# Frases que presentan las palabras de Dios; lo que sigue a los dos puntos es
# Dios hablando.
# «Y dijo: …» sin sujeto: en un diálogo, tras la respuesta de la persona,
# vuelve a hablar Dios.
BARE = re.compile(r'^(?:Y |Entonces )?(?:d[ií]jo(?:le|les|me)?|respondi[óo](?:le)?)\s*:')

INTRO = re.compile('|'.join([
    rf'\b{VERB}(?:le|les|me)?(?: entonces| pues| también| luego)? {GOD}\b',
    rf'(?<![Aa] )(?<!\bque )(?<!\bcual )(?<!\bcomo )\b{GOD}(?: Dios)? (?:le |les |me |te |nos |[aá] [\wáéíóúñ-]+ )?{VERB}',
    r'(?:fu[eé]|vino)(?: pues)?(?: [aá] (?:m[ií]|[\wáéíóúñ-]+))? (?:la )?palabra de Yavé',
    r'palabra de Yavé(?: que fu[eé])? [aá] [\wáéíóúñ-]+',
    r'[Oo][ií]d (?:la )?palabra de Yavé',
    r'[Aa]s[ií] (?:dice|ha dicho|dijo|habl[óo]) (?:el Señor )?Yavé',
    rf'\b{GOD}\b[^:.;?]{{0,80}}\b(?:le |les |me )?(?:d[ií]jo|d[ií]jole|d[ií]jome|habl[óo]|respondi[óo]|diciendo)\b',
    r'voz[^:.;]{0,60}\b(?:dec[ií]a|diciendo|que dijo)\b',
]), re.IGNORECASE)

# Mientras Dios habla, un versículo que empieza así devuelve la palabra al
# narrador (y puede traer una nueva introducción).
NARRATOR_AGAIN = re.compile(
    r'^(?:(?:(?:Y|Entonces|Mas|Luego|Después|Así|Pero|E)\s+)?(?:'
    r'(?:fu[eé]|vino)(?: pues)?(?: [aá] (?:m[ií]|[\wáéíóúñ-]+))? (?:la )?palabra de Yavé|'
    rf'{VERB}(?:le|les|me)? {GOD}\b|'
    rf'{GOD} (?:le |les |me |a [\wáéíóúñ-]+ )?{VERB}\b|'
    r'[Ee]stas? (?:pues )?(?:son|fueron) (?:las )?palabras que habl[óo])|'
    r'(?:Y|Entonces) (?:(?:el profeta |el rey |el sacerdote )?[A-ZÁÉÍÓÚ][\wáéíóúñ-]+ '
    r'(?:dijo|respondió|habló)\b(?! Yavé| Dios)|(?:dijo|respondió) (?:el profeta |el rey )?'
    r'(?!Yavé|Dios)[A-ZÁÉÍÓÚ][\wáéíóúñ-]+))')

# Libros de historia: un versículo que empieza contando lo que alguien hizo
# (pretérito en tercera persona) es narración.
PROPHETS = {'isa', 'jer', 'lam', 'eze', 'dan', 'ose', 'joe', 'amo', 'abd', 'jon', 'miq',
            'nah', 'hab', 'sof', 'hag', 'zac', 'mal', 'sal', 'job'}
PRETERITE = re.compile(
    r'^(?:(?:Y|E|Entonces|Mas|Luego|Así|Después|Pero|Asimismo|Empero)\s+)?(?:(?!(?:que|cual|cuales|cuanto|os|me|mí|te|nos)\b)[\wáéíóúñ-]+\s+){0,4}?'
    r'(?:[a-záéíóúñ]+(?:ó|ió|aron|ieron)(?:se|le|les|lo|la|los|las|me|nos)?|'
    r'fue|fueron|hizo|hicieron|vinieron|puso|pusieron|tuvo|anduvo|estuvo|estaba|estaban|'
    r'dio|dieron|vio|vieron|oyó|oyeron|dijeron|dijéronse)\b|^(?:Y|Entonces) vino\b', re.IGNORECASE)
# El profeta le responde a Dios: «Y dije: ¡Ah! Señor Yavé».
FIRST_PERSON_PAST = re.compile(
    r'^(?:(?:Y|Entonces|Mas)\s+)?(?:yo\s+)?(?:dije|respondí)(?: yo)?:\s*¡?(?:Ah|Ay|Oh|Señor|Heme)\b')

HUMAN_REPLY = re.compile(r'^(?:Y|Entonces) (?:él|ella|ellos|[A-ZÁÉÍÓÚ][\wáéíóúñ-]+) (?:respondió|respondieron|dijo)(?! Yavé| Dios)\b[^:]*:[^:]*$')

# Tras un versículo narrado, Dios vuelve a hablar sin fórmula cuando el
# versículo se dirige a alguien («os», «tu») o Dios habla de sí («yo», «mis»).
ADDRESS = re.compile(r'\b(?:os|vosotros|vuestr\w*|te|tú|tu|tus|ti|contigo|yo|mí|mis)\b', re.IGNORECASE)

FUTURE = re.compile(r'\b\w{3,}(?:rá|rán|réis|rás)\b')

# Sin introducción, estas fórmulas muestran que el versículo sigue siendo
# Dios quien habla («…, dice Yavé», «Yo Yavé»).
STILL_GOD = re.compile(r'\bdice (?:el Señor )?Yavé\b|\b[Yy]o (?:soy )?Yavé\b')

# Dentro de un versículo: el narrador retoma tras lo que Dios dijo.
NARRATOR_TAIL = re.compile(
    r'[:;,.]\s+(?=(?:[Yy] fue así(?!,? dice)|[Yy] fue la luz|[Yy] fue la tarde|'
    r'[Yy] (?:vio|hizo|crió|llamó|bendijo|puso|apartó|acabó|reposó|formó|plantó|'
    r'tomó|sacó|echó) (?:Dios|Yavé)\b|'
    r'Y (?:él|ella|ellos|[A-ZÁÉÍÓÚ][\wáéíóúñ-]+) (?:respondió|respondieron|dijo)(?! Yavé| Dios)\b|[Ee]ntonces (?:Moisés|Aarón|Josué|Samuel|David|'
    r'Elías|Abraham|Jacob|Gedeón) )).*$')


def _intro_split(text: str, reply: bool = False):
    """Posición donde empiezan las palabras de Dios en un versículo narrado, o None."""
    if reply:
        m = BARE.match(text)
        if m:
            return m.end()
    for m in INTRO.finditer(text):
        head = text[:m.start()]
        # «dijo Moisés a Yavé»: Dios es a quien se habla.
        if re.search(r'(?:^|\s)(?:[aá]|al|de|del|con|contra|ante|por|en)\s+$', head):
            continue
        # «vino Dios al encuentro de Balaam, y éste le dijo»: habla otro.
        if re.search(r'\b(?:éste|y él|y ella|la cual|los cuales)\b', m.group(0)):
            continue
        colon = text.find(':', m.end())
        if colon < 0:
            continue
        between = text[m.end():colon]
        # Los dos puntos deben cerrar la misma frase de introducción.
        asi = re.match(r'[Aa]s[ií] ', m.group(0))
        if re.search(r'[.?!]' if asi else r'[.;?!]', between) or len(between) > (300 if asi else 140):
            # «…, en el primero del mes segundo, …, diciendo:»
            if not (re.search(r'diciendo$', between.rstrip(', ')) and not re.search(r'[.?!]', between)):
                continue
        return colon + 1
    return None


def _tail_split(text: str):
    """Dónde retoma el narrador dentro de un versículo en que habla Dios."""
    m = NARRATOR_TAIL.search(text)
    return m.start() + 1 if m else None


def _add(parts, text, god):
    text = text.strip()
    if not text:
        return
    if parts and parts[-1][1] == god:
        parts[-1][0] += ' ' + text
    else:
        parts.append([text, god])


# Una persona ora a Dios: «oré a Yavé, diciendo: ¡Oh Señor Yavé!…».
PRAYER = re.compile(r'\bor[eé] a Yavé\b|^¡?[Oo]h,? (?:Señor )?Yavé\b|^¡?[Aa]h,? Señor Yavé\b')


def _narrated(text: str, book: str) -> bool:
    if NARRATOR_AGAIN.search(text) or FIRST_PERSON_PAST.search(text) or PRAYER.search(text):
        return True
    if book in PROPHETS or book == 'lev' or STILL_GOD.search(text):
        return False
    # La ley: «Y si alguno lo empujó…», «Cuando…» son casos, no narración.
    if book in ('exo', 'lev', 'num') and re.match(
            r'^(?:(?:Y|O|Mas|Pero)\s+)?(?:si|cuando|cualquiera)\b', text, re.IGNORECASE):
        return False
    m = PRETERITE.search(text)
    # «…» antes de dos puntos o del verbo: se exige que el verbo esté al
    # principio de la frase (antes de cualquier signo).
    return bool(m) and not re.search(r'[:;,?]', text[:m.end()])


def segment(verses, speaking: bool = False, book: str = ''):
    """verses: [{'v': n, 'text': str}] → [[n, [[texto, esDios], …]], …].

    `speaking` indica si Dios ya estaba hablando al empezar (un discurso que
    continúa del versículo o capítulo anterior).
    """
    out = []
    reply = False  # la persona acaba de responderle a Dios
    hold = False   # habla otra persona (oración, respuesta): Dios no vuelve sin fórmula
    for verse in verses:
        text = verse['text'].strip()
        parts = []
        if (speaking or hold) and _narrated(text, book):
            speaking = False
            reply = bool(HUMAN_REPLY.match(text))
            hold = bool(PRAYER.search(text)
                        or (text.rstrip().endswith(':') and _intro_split(text) is None))
        while text:
            if not speaking:
                at = _intro_split(text, reply and not parts)
                if not parts:
                    reply = False
                if at is not None:
                    hold = False
                if at is None and not parts and not _narrated(text, book) and (
                        STILL_GOD.search(text) or (book in PROPHETS and not hold)
                        or (not hold and (ADDRESS.search(text) or FUTURE.search(text)) and not (
                            book == 'deu' and re.search(r'Yavé|Dios', text)))):
                    at = 0
                if at is None:
                    _add(parts, text, False)
                    break
                _add(parts, text[:at], False)
                text = text[at:].strip()
                speaking = True
            else:
                at = _tail_split(text)
                if at is None:
                    _add(parts, text, True)
                    break
                _add(parts, text[:at], True)
                text = text[at:].strip()
                speaking = False
                reply = bool(HUMAN_REPLY.match(text))
        out.append([verse['v'], parts])
    return out, speaking


def god_text(segments) -> str:
    return ' '.join(t for _, parts in segments for t, g in parts if g)


# ---------------------------------------------------------------------------
# Correcciones a mano (revisadas una por una)
# ---------------------------------------------------------------------------

# Pasajes que hablan de Dios, pero donde Dios no dice palabras (las dice Moisés
# o solo se cuenta que habló): los lee el narrador entero.
NARRATOR_ONLY = {'y-deu-4-12', 'y-deu-5-22', 'y-1sa-3-4', 'y-2cr-33-10'}

# El discurso ya había empezado antes del primer versículo.
START_SPEAKING = {'y-zac-1-4'}

# Citas cortas que incluyen la fórmula del mensajero («Así ha dicho Yavé»,
# «oíd palabra de Yavé») o una frase del profeta: están bien así.
QUOTE_OK = {'y-exo-7-17', 'y-exo-32-27', 'y-2sa-12-7', 'y-1re-13-2', 'y-2re-9-12',
            'y-2re-15-12', 'y-isa-66-5', 'y-eze-36-1', 'y-amo-7-16'}

# Versículos separados a mano: ⟦…⟧ marca lo que dice Dios.
FIXES = {
    # Amós cuenta sus visiones; Dios solo responde «No será».
    'y-amo-7-1': {
        1: 'Así me ha mostrado el Señor Yavé: y he aquí, él criaba langostas al principio que '
           'comenzaba a crecer el heno tardío; y he aquí, era el heno tardío después de las siegas '
           'del rey.',
        2: 'Y acaeció que como acabó de comer la hierba de la tierra, yo dije: Señor Yavé, perdona '
           'ahora; ¿quién levantará a Jacob? porque es pequeño.',
        3: 'Arrepintióse Yavé de esto: ⟦No será,⟧ dijo Yavé.',
        4: 'El Señor Yavé me mostró así: y he aquí, llamaba para juzgar por fuego el Señor Yavé; y '
           'consumió un gran abismo, y consumió una parte de la tierra.',
        5: 'Y dije: Señor Yavé, cesa ahora; ¿quién levantará a Jacob? porque es pequeño.',
        6: 'Arrepintióse Yavé de esto: ⟦No será esto tampoco,⟧ dijo el Señor Yavé.',
    },
    # Palabras explicadas a mano (tool/content/part*.py).
    'gen-12-1': {1: 'Empero Yavé había dicho a Abram: ⟦Vete de tu tierra y de tu parentela, y de la '
                    'casa de tu padre, a la tierra que te mostraré;⟧'},
    'gen-15-5': {5: 'Y sacóle fuera, y dijo: ⟦Mira ahora a los cielos, y cuenta las estrellas, si las '
                    'puedes contar.⟧ Y le dijo: ⟦Así será tu simiente.⟧'},
    'exo-3-14': {14: 'Y respondió Dios a Moisés: ⟦YO SOY EL QUE SOY.⟧ Y dijo: ⟦Así dirás a los hijos '
                     'de Israel: YO SOY me ha enviado a vosotros.⟧'},
    'exo-33-14': {14: 'Y él dijo: ⟦Mi rostro irá contigo, y te haré descansar.⟧'},
    'exo-34-6': {6: 'Y pasando Yavé por delante de él, proclamó: ⟦Yavé, Yavé, fuerte, misericordioso, '
                    'y piadoso; tardo para la ira, y grande en benignidad y verdad;⟧'},
    '1re-19-9': {11: 'Y él le dijo: ⟦Sal fuera, y ponte en el monte delante de Yavé.⟧ Y he aquí Yavé '
                     'que pasaba, y un grande y poderoso viento que rompía los montes, y quebraba las '
                     'peñas delante de Yavé: mas Yavé no estaba en el viento. Y tras el viento un '
                     'terremoto: mas Yavé no estaba en el terremoto.'},
    'isa-6-8': {8: 'Después oí la voz del Señor, que decía: ⟦¿A quién enviaré, y quién nos irá?⟧ '
                   'Entonces respondí yo: Heme aquí, envíame a mí.'},
    'isa-43-1': {1: 'Y ahora, así dice Yavé Criador tuyo, oh Jacob, y Formador tuyo, oh Israel: ⟦No '
                    'temas, porque yo te redimí; te puse nombre, mío eres tú.⟧'},
    'mat-6-34': {33: '⟦Mas buscad primeramente el reino de Dios y su justicia, y todas estas cosas os '
                     'serán añadidas.⟧',
                 34: '⟦Así que, no os congojéis por el día de mañana; que el día de mañana traerá su '
                     'fatiga: basta al día su afán.⟧'},
    'jua-8-11': {11: 'Y ella dijo: Señor, ninguno. Entonces Jesús le dijo: ⟦Ni yo te condeno: vete, '
                     'y no peques más.⟧'},
    'jua-11-25': {23: 'Dícele Jesús: ⟦Resucitará tu hermano.⟧',
                  25: 'Dícele Jesús: ⟦Yo soy la resurrección y la vida: el que cree en mí, aunque '
                      'esté muerto, vivirá.⟧',
                  26: '⟦Y todo aquel que vive y cree en mí, no morirá eternamente. ¿Crees esto?⟧'},
    'mat-11-28': {28: '⟦Venid a mí todos los que estáis trabajados y cargados, que yo os haré '
                      'descansar.⟧',
                  29: '⟦Llevad mi yugo sobre vosotros, y aprended de mí, que soy manso y humilde de '
                      'corazón; y hallaréis descanso para vuestras almas.⟧',
                  30: '⟦Porque mi yugo es fácil, y ligera mi carga.⟧'},
    'jua-12-28': {27: '⟦Ahora está turbada mi alma; ¿y qué diré? Padre, sálvame de esta hora. Mas '
                      'por esto he venido en esta hora.⟧',
                  28: '⟦Padre, glorifica tu nombre.⟧ Entonces vino una voz del cielo: ⟦Y lo he '
                      'glorificado, y lo glorificaré otra vez.⟧'},
    'jua-13-34': {33: '⟦Hijitos, aun un poco estoy con vosotros. Me buscaréis; mas, como dije a los '
                      'Judíos: Donde yo voy, vosotros no podéis venir; así digo a vosotros ahora.⟧',
                  34: '⟦Un mandamiento nuevo os doy: Que os améis unos a otros: como os he amado, '
                      'que también os améis los unos a los otros.⟧',
                  35: '⟦En esto conocerán todos que sois mis discípulos, si tuviereis amor los unos '
                      'con los otros.⟧'},
    'mat-14-27': {28: 'Entonces le respondió Pedro, y dijo: Señor, si tú eres, manda que yo vaya a ti '
                      'sobre las aguas.',
                  29: 'Y él dijo: ⟦Ven.⟧ Y descendiendo Pedro del barco, andaba sobre las aguas para '
                      'ir a Jesús.'},
    'jua-14-27': {27: '⟦La paz os dejo, mi paz os doy: no como el mundo la da, yo os la doy. No se '
                      'turbe vuestro corazón, ni tenga miedo.⟧'},
    'mat-17-5': {6: 'Y oyendo esto los discípulos, cayeron sobre sus rostros, y temieron en gran '
                    'manera.',
                 7: 'Entonces Jesús llegando, los tocó, y dijo: ⟦Levantaos, y no temáis.⟧'},
    'jua-21-17': {15: 'Y cuando hubieron comido, Jesús dijo a Simón Pedro: ⟦Simón, hijo de Jonás, ¿me '
                      'amas más que éstos?⟧ Dícele: Sí, Señor: tú sabes que te amo. Dícele: ⟦Apacienta '
                      'mis corderos.⟧',
                  16: 'Vuélvele a decir la segunda vez: ⟦Simón, hijo de Jonás, ¿me amas?⟧ Respóndele: '
                      'Sí, Señor: tú sabes que te amo. Dícele: ⟦Apacienta mis ovejas.⟧',
                  17: 'Dícele la tercera vez: ⟦Simón, hijo de Jonás, ¿me amas?⟧ Entristecióse Pedro '
                      'de que le dijese la tercera vez: ¿Me amas? y dícele: Señor, tú sabes todas las '
                      'cosas; tú sabes que te amo. Dícele Jesús: ⟦Apacienta mis ovejas.⟧'},
    'hch-9-4': {5: 'Y él dijo: ¿Quién eres, Señor? Y él dijo: ⟦Yo soy Jesús a quien tú persigues: '
                   'dura cosa te es dar coces contra el aguijón.⟧'},
    'hch-10-15': {13: 'Y le vino una voz: ⟦Levántate, Pedro, mata y come.⟧',
                  15: 'Y volvió la voz hacia él la segunda vez: ⟦Lo que Dios limpió, no lo llames '
                      'tú común.⟧'},
    '2co-12-9': {9: 'Y me ha dicho: ⟦Bástate mi gracia; porque mi potencia en la flaqueza se '
                    'perfecciona.⟧ Por tanto, de buena gana me gloriaré más bien en mis flaquezas, '
                    'porque habite en mí la potencia de Cristo.'},
    'apo-1-17': {17: 'Y cuando yo le vi, caí como muerto a sus pies. Y él puso su diestra sobre mí, '
                     'diciéndome: ⟦No temas: yo soy el primero y el último;⟧',
                 18: '⟦Y el que vivo, y he sido muerto; y he aquí que vivo por siglos de siglos, Amén. '
                     'Y tengo las llaves del infierno y de la muerte:⟧'},
    'apo-3-20': {20: '⟦He aquí, yo estoy a la puerta y llamo: si alguno oyere mi voz y abriere la '
                     'puerta, entraré a él, y cenaré con él, y él conmigo.⟧'},
    'apo-21-5': {5: 'Y el que estaba sentado en el trono dijo: ⟦He aquí, yo hago nuevas todas las '
                    'cosas.⟧ Y me dijo: ⟦Escribe; porque estas palabras son fieles y verdaderas.⟧',
                 6: 'Y díjome: ⟦Hecho es. Yo soy Alpha y Omega, el principio y el fin. Al que tuviere '
                    'sed, yo le daré de la fuente del agua de vida gratuitamente.⟧'},
    'apo-22-20': {20: 'El que da testimonio de estas cosas, dice: ⟦Ciertamente, vengo en breve.⟧ '
                      'Amén, sea así. Ven, Señor Jesús.'},
    'y-1re-22-21': {
        21: 'Y salió un espíritu, y púsose delante de Yavé, y dijo: Yo le induciré. '
            'Y Yavé le dijo: ⟦¿De qué manera?⟧',
        22: 'Y él dijo: Yo saldré, y seré espíritu de mentira en boca de todos sus '
            'profetas. Y él dijo: ⟦Inducirlo has, y aun saldrás con ello; sal pues, '
            'y hazlo así.⟧',
    },
}


def apply_fixes(uid, segments, verses):
    """Aplica NARRATOR_ONLY y FIXES; comprueba que el texto no cambie."""
    by_v = {v['v']: v['text'] for v in verses}
    out = []
    for v, parts in segments:
        if uid in NARRATOR_ONLY:
            parts = [[by_v[v], False]]
        fix = FIXES.get(uid, {}).get(v)
        if fix is not None:
            assert fix.replace('⟦', '').replace('⟧', '') == by_v[v], f'{uid} {v}: el texto no coincide'
            parts = []
            for i, chunk in enumerate(re.split(r'⟦|⟧', fix)):
                _add(parts, chunk, i % 2 == 1)
        out.append([v, parts])
    return out
