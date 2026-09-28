"""Qué estaba pasando y a quién habló Yavé: capítulos añadidos en la 3.1
(discursos que empiezan con mayúsculas en la RV1909 o que siguen del capítulo
anterior: la Ley dada a Moisés y la respuesta a Job)."""

CH = {
    # ----------------------------------------------------------------- Génesis
    'gen 7': ('Noé', 'El arca está terminada. Dios invita a Noé a entrar con su familia y los animales: en siete días empezará a llover.'),
    # ------------------------------------------------------------------ Éxodo
    'exo 13': ('Moisés', 'Recién salidos de Egipto, Dios pide consagrarle todo primogénito y celebrar cada año los panes sin levadura para recordar la liberación.'),
    'exo 21': ('Moisés, para los hijos de Israel', 'En el Sinaí, después de los Diez Mandamientos, Dios da leyes concretas: cómo tratar a los siervos, la violencia y los daños entre vecinos.'),
    'exo 25': ('Moisés, en el monte Sinaí', 'Moisés sube al monte y Dios le pide una ofrenda voluntaria para construir un santuario: «y habitaré en medio de ellos».'),
    'exo 26': ('Moisés, en el monte Sinaí', 'Dios describe el tabernáculo: sus cortinas, tablas y el velo que separa el lugar santísimo.'),
    'exo 27': ('Moisés, en el monte Sinaí', 'Dios describe el altar de los holocaustos, el atrio del tabernáculo y el aceite para la lámpara que arderá siempre.'),
    'exo 28': ('Moisés, en el monte Sinaí', 'Dios aparta a Aarón y a sus hijos como sacerdotes y describe sus vestiduras, con los nombres de las tribus sobre el corazón.'),
    'exo 29': ('Moisés, en el monte Sinaí', 'Dios explica cómo consagrar a los sacerdotes y promete habitar entre los hijos de Israel y ser su Dios.'),
    'exo 31': ('Moisés, en el monte Sinaí', 'Dios llena de su Espíritu a Bezaleel y Aholiab para construir el santuario, y da el sábado como señal perpetua del pacto.'),
    'exo 40': ('Moisés', 'Un año después de salir de Egipto, Dios manda levantar el tabernáculo; al terminar, su gloria llena el lugar.'),
    # --------------------------------------------------------------- Levítico
    'lev 2': ('Moisés, para los hijos de Israel', 'Dios sigue enseñando cómo acercarse a él: la ofrenda de harina, aceite e incienso, sin levadura y con sal.'),
    'lev 3': ('Moisés, para los hijos de Israel', 'Dios enseña el sacrificio de paz, una ofrenda de comunión y gratitud.'),
    'lev 4': ('Moisés, para los hijos de Israel', 'Dios da el camino para el perdón de los pecados cometidos sin querer, desde el sacerdote hasta cualquier persona del pueblo.'),
    'lev 5': ('Moisés, para los hijos de Israel', 'Dios habla de pecados escondidos y juramentos a la ligera, y provee ofrendas incluso para el más pobre.'),
    'lev 7': ('Moisés, para los sacerdotes', 'Dios completa las leyes de las ofrendas por la culpa y de paz, y la parte que corresponde a los sacerdotes.'),
    'lev 8': ('Moisés', 'Ante toda la congregación, Moisés consagra a Aarón y a sus hijos como sacerdotes según la orden de Dios.'),
    'lev 11': ('Moisés y Aarón', 'Dios enseña qué animales son limpios para comer: «Seréis santos, porque yo soy santo».'),
    'lev 12': ('Moisés, para los hijos de Israel', 'Dios da leyes de purificación para la mujer después de dar a luz, con una ofrenda al alcance de los pobres.'),
    'lev 13': ('Moisés y Aarón', 'Dios instruye a los sacerdotes a examinar las enfermedades de la piel para proteger al pueblo.'),
    'lev 15': ('Moisés y Aarón', 'Dios da leyes de limpieza para el cuerpo, para que su pueblo no contamine el tabernáculo que está en medio de ellos.'),
    'lev 17': ('Moisés, para Aarón y el pueblo', 'Dios manda llevar todo sacrificio al tabernáculo y no comer sangre, porque la vida está en la sangre.'),
    'lev 18': ('Moisés, para los hijos de Israel', 'Dios aparta a su pueblo de las costumbres sexuales de Egipto y Canaán: «Yo soy Yavé vuestro Dios».'),
    'lev 19': ('Toda la congregación de Israel', 'Dios llama a todo el pueblo a la santidad en la vida diaria: honrar a los padres, cuidar al pobre y al extranjero y amar al prójimo como a uno mismo.'),
    'lev 20': ('Moisés, para los hijos de Israel', 'Dios advierte contra la idolatría, la brujería y la inmoralidad, y llama a su pueblo a ser santo y apartado para él.'),
    'lev 25': ('Moisés, en el monte Sinaí', 'Dios establece el año de descanso de la tierra y el jubileo: cada cincuenta años se liberan los esclavos y se devuelven las tierras.'),
    'lev 26': ('Moisés, para los hijos de Israel', 'Dios pone delante del pueblo bendición si obedece y disciplina si se rebela, y promete recordar su pacto aun en el destierro.'),
    'lev 27': ('Moisés, para los hijos de Israel', 'Dios da leyes sobre los votos y las cosas consagradas a él.'),
    # ---------------------------------------------------------------- Números
    'num 1': ('Moisés, en el desierto de Sinaí', 'Un año después de salir de Egipto, Dios manda contar a los hombres de guerra de cada tribu y apartar a los levitas para el tabernáculo.'),
    'num 2': ('Moisés y Aarón', 'Dios ordena el campamento: cada tribu junto a su bandera, alrededor del tabernáculo.'),
    'num 10': ('Moisés', 'Dios manda hacer dos trompetas de plata para reunir al pueblo y ponerse en marcha desde el Sinaí.'),
    'num 19': ('Moisés y Aarón', 'Dios da la ley de la vaca roja y del agua de purificación para quien tocó un muerto.'),
    'num 28': ('Moisés, para los hijos de Israel', 'Cerca de entrar en la tierra, Dios recuerda las ofrendas diarias, de cada sábado, de cada mes y de las fiestas.'),
    'num 29': ('Moisés, para los hijos de Israel', 'Dios detalla las fiestas del mes séptimo: las Trompetas, el Día de la Expiación y los Tabernáculos.'),
    # ------------------------------------------------------------------ Josué
    'jos 20': ('Josué', 'Repartida la tierra, Dios manda señalar ciudades de refugio donde pueda huir quien mató a alguien sin querer.'),
    # -------------------------------------------------------------------- Job
    'job 41': ('Job', 'Dios termina su respuesta desde el torbellino describiendo al leviatán, una criatura que ningún hombre puede dominar.'),
    # ------------------------------------------------------------------ Jonás
    'jon 3': ('El profeta Jonás', 'Después de ser salvado del gran pez, Dios envía a Jonás por segunda vez a Nínive.'),
}
