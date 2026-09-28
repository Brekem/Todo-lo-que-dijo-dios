"""Contexto histórico de cada libro y su etapa en el «Recorrido de la Voz de Dios».

`era(book, chapter)` devuelve la etapa; `CONTEXT[book]` el contexto histórico.
El orden de BOOK_ORDER dentro de cada etapa es aproximadamente cronológico.
"""

CONTEXT = {
    'gen': 'Génesis narra los orígenes: la creación, la caída, el diluvio y la historia de los patriarcas Abraham, Isaac, Jacob y José, entre Mesopotamia, Canaán y Egipto (hasta c. 1800 a. C.).',
    'exo': 'Éxodo relata cómo Yavé liberó a Israel de la esclavitud en Egipto por medio de Moisés (c. siglo XV–XIII a. C.) y selló con él un pacto en el monte Sinaí.',
    'lev': 'Levítico recoge las instrucciones que Yavé dio a Moisés al pie del Sinaí para que un pueblo recién liberado aprendiera a vivir en santidad: sacrificios, sacerdocio, pureza y fiestas.',
    'num': 'Números narra los cuarenta años de Israel en el desierto, desde el Sinaí hasta las llanuras de Moab, con sus censos, rebeliones y el cuidado constante de Yavé.',
    'deu': 'Deuteronomio contiene los últimos discursos de Moisés en las llanuras de Moab, frente a la tierra prometida, donde recuerda al pueblo las palabras que Yavé les habló.',
    'jos': 'Josué narra la entrada de Israel en Canaán tras la muerte de Moisés, la conquista de la tierra y su reparto entre las tribus (c. 1400–1200 a. C.).',
    'jue': 'Jueces cubre el periodo entre Josué y la monarquía: Israel caía una y otra vez en idolatría, era oprimido y Yavé levantaba libertadores.',
    'rut': 'Rut se sitúa en tiempos de los jueces y cuenta la fidelidad de una extranjera moabita incorporada al pueblo de Dios.',
    '1sa': '1 Samuel narra el paso de los jueces a la monarquía: el profeta Samuel, el rey Saúl y el ascenso de David (c. 1100–1010 a. C.).',
    '2sa': '2 Samuel relata el reinado de David en Jerusalén (c. 1010–970 a. C.), sus victorias, su pecado y la promesa de un reino eterno.',
    '1re': '1 Reyes narra el reinado de Salomón, la construcción del templo, la división del reino y el ministerio del profeta Elías (c. 970–850 a. C.).',
    '2re': '2 Reyes cubre los reinos de Israel y Judá hasta su caída ante Asiria (722 a. C.) y Babilonia (586 a. C.), con los profetas Eliseo e Isaías.',
    '1cr': '1 Crónicas, escrito tras el exilio, vuelve a contar la historia de David subrayando su amor por la adoración y el templo.',
    '2cr': '2 Crónicas recorre la historia de Judá desde Salomón hasta el exilio, destacando la fidelidad o infidelidad de sus reyes a Yavé.',
    'esd': 'Esdras narra el regreso de los judíos desde Babilonia y la reconstrucción del templo (c. 538–458 a. C.).',
    'neh': 'Nehemías relata la reconstrucción de los muros de Jerusalén y la renovación del pacto (c. 445 a. C.).',
    'job': 'Job, situado por la tradición en la época de los patriarcas, en la tierra de Uz, trata el sufrimiento del justo y termina con Yavé hablando desde un torbellino.',
    'sal': 'Los Salmos son el libro de oración y canto de Israel, escritos en su mayoría por David y otros salmistas; en algunos, Dios mismo toma la palabra.',
    'isa': 'Isaías profetizó en Jerusalén c. 740–700 a. C., bajo los reyes Uzías, Jotam, Acaz y Ezequías, ante la amenaza asiria; sus capítulos 40–66 consuelan al pueblo que iría al exilio.',
    'jer': 'Jeremías profetizó en Judá c. 627–580 a. C., durante los últimos reyes, el asedio babilonio, la destrucción de Jerusalén y el exilio.',
    'lam': 'Lamentaciones llora la destrucción de Jerusalén por Babilonia en el 586 a. C.',
    'eze': 'Ezequiel, sacerdote deportado a Babilonia en el 597 a. C., profetizó entre los exiliados junto al río Quebar, antes y después de la caída de Jerusalén.',
    'dan': 'Daniel vivió en la corte de Babilonia y Persia durante el exilio (c. 605–530 a. C.).',
    'ose': 'Oseas profetizó en el reino del norte (Israel) c. 750–722 a. C., comparando la infidelidad del pueblo con un matrimonio roto.',
    'joe': 'Joel habló a Judá tras una devastadora plaga de langostas, llamando al arrepentimiento y anunciando el derramamiento del Espíritu.',
    'amo': 'Amós, un pastor de Tecoa, profetizó en el reino del norte c. 760 a. C., denunciando la injusticia social en tiempos de prosperidad.',
    'abd': 'Abdías anuncia el juicio sobre Edom por alegrarse de la caída de Jerusalén.',
    'jon': 'Jonás fue enviado a Nínive, capital de Asiria, en el siglo VIII a. C., y descubrió la misericordia de Dios hacia sus enemigos.',
    'miq': 'Miqueas profetizó en Judá c. 735–700 a. C., contemporáneo de Isaías, contra la injusticia y anunciando un rey nacido en Belén.',
    'nah': 'Nahúm anuncia la caída de Nínive, la cruel capital asiria, que ocurrió en el 612 a. C.',
    'hab': 'Habacuc dialogó con Dios poco antes de la invasión babilonia (c. 605 a. C.) sobre por qué permite la injusticia.',
    'sof': 'Sofonías profetizó en tiempos del rey Josías (c. 630 a. C.) sobre el día de Yavé y la restauración de un remanente humilde.',
    'hag': 'Hageo habló en el 520 a. C. a los judíos que regresaron del exilio y habían dejado sin terminar la reconstrucción del templo.',
    'zac': 'Zacarías, contemporáneo de Hageo (520 a. C.), animó a reconstruir el templo con visiones sobre el futuro de Jerusalén y del Mesías.',
    'mal': 'Malaquías es el último profeta del Antiguo Testamento (c. 430 a. C.) y habla a un pueblo restaurado pero caído en la rutina y la tibieza.',
}

# Recipiente por defecto del libro cuando el texto no dice a quién habló Yavé.
DEFAULT_RECIPIENT = {
    'lev': 'Moisés, para el pueblo de Israel', 'num': 'Moisés, en el desierto',
    'deu': 'Moisés y el pueblo de Israel', 'isa': 'Judá y Jerusalén, por medio de Isaías',
    'jer': 'Judá, por medio del profeta Jeremías', 'lam': 'Jerusalén',
    'eze': 'Los exiliados de Israel, por medio de Ezequiel', 'ose': 'Israel, por medio de Oseas',
    'joe': 'Judá, por medio de Joel', 'amo': 'Israel, por medio de Amós',
    'abd': 'Edom, por medio de Abdías', 'jon': 'El profeta Jonás',
    'miq': 'Judá e Israel, por medio de Miqueas', 'nah': 'Nínive, por medio de Nahúm',
    'hab': 'El profeta Habacuc', 'sof': 'Judá, por medio de Sofonías',
    'hag': 'Los que volvieron del exilio, por medio de Hageo',
    'zac': 'Los que volvieron del exilio, por medio de Zacarías',
    'mal': 'El pueblo restaurado, por medio de Malaquías', 'sal': 'El pueblo de Dios, en los Salmos',
    'job': 'Job',
}


def era(book: str, chapter: int) -> str:
    if book == 'gen':
        if chapter <= 5:
            return 'adan'
        if chapter <= 11:
            return 'noe'
        if chapter <= 24:
            return 'abraham'
        if chapter <= 26:
            return 'isaac'
        return 'jacob'
    if book == 'job':
        return 'abraham'
    if book in ('exo', 'lev', 'num', 'deu'):
        return 'moises'
    if book in ('jos', 'jue', 'rut'):
        return 'josue'
    if book == 'isa' and chapter >= 40:
        return 'israel'
    if book in ('eze', 'dan', 'esd', 'neh', 'hag', 'zac', 'mal'):
        return 'israel'
    if book == 'jer' and chapter in (29,):
        return 'israel'
    return 'profetas'


# Orden aproximado de composición/acontecimientos dentro de cada etapa.
BOOK_ORDER = [
    'gen', 'job', 'exo', 'lev', 'num', 'deu', 'jos', 'jue', 'rut',
    '1sa', '2sa', '1cr', 'sal', '1re', '2cr', 'jon', 'joe', 'amo', 'ose',
    'isa', 'miq', '2re', 'nah', 'sof', 'hab', 'jer', 'lam', 'abd',
    'eze', 'dan', 'esd', 'hag', 'zac', 'neh', 'mal',
]
