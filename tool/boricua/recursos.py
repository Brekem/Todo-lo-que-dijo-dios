"""Glosario, Escuela Bíblica y Asistente de la Biblia Boricua, escritos a mano.

t(término, definición sencilla, explicación, referencia, tema)
nivel(número, título, descripción) seguido de sus lecciones:
  leccion(título, lecturas, explicación, reflexión, ejemplo de vida real, oración)
r(pregunta, palabras clave, cita, explicación, aplicación, oración, próximo paso, ayuda=None)
"""

# ---------------------------------------------------------------------------
# Glosario: teología simple
# ---------------------------------------------------------------------------

t('Gracia', 'El favor inmerecido de Dios hacia nosotros.',
  'Es Dios dándonos lo que no merecemos: perdón, amor y vida eterna. No se compra ni se gana; se recibe como un regalo.',
  'Efesios 2:8', 'salvacion')
t('Justificación', 'Dios te declara inocente por medio de Jesucristo, aunque hayas pecado.',
  'Es como un juicio donde el culpable sale absuelto porque otro pagó la deuda. Jesús cargó nuestro castigo, y Dios nos declara justos.',
  'Romanos 3:24', 'salvacion')
t('Santificación', 'El proceso mediante el cual Dios transforma tu vida poco a poco para parecerte más a Cristo.',
  'La justificación pasa en un momento; la santificación dura toda la vida. El Espíritu Santo va cambiando nuestro carácter, nuestras costumbres y nuestra manera de pensar.',
  '1 Tesalonicenses 4:3', 'vida')
t('Redención', 'Jesús pagó el precio para darte libertad espiritual.',
  'En tiempos bíblicos, «redimir» era pagar para liberar a un esclavo. Jesús pagó con su vida para liberarnos del pecado.',
  'Efesios 1:7', 'jesus')
t('Pecado', 'Todo lo que hacemos, pensamos o dejamos de hacer que va en contra de lo que Dios quiere.',
  'No es solo «hacer cosas malas»: es fallar el blanco, vivir apartados de Dios. Todos hemos pecado, y el pecado nos separa de él.',
  'Romanos 3:23', 'salvacion')
t('Arrepentimiento', 'Cambiar de dirección: dejar el pecado y volverse a Dios.',
  'No es solo sentirse mal; es dar media vuelta. Incluye reconocer lo que hice, pedir perdón y decidir caminar diferente con la ayuda de Dios.',
  'Hechos 3:19', 'salvacion')
t('Fe', 'Confiar en Dios y en lo que él dice, aunque todavía no lo veas.',
  'La fe no es creer cualquier cosa, sino poner tu confianza en una persona: Dios, y en lo que hizo Jesús.',
  'Hebreos 11:1', 'salvacion')
t('Perdón', 'Dios cancela la deuda de nuestro pecado, y nos enseña a cancelar la de otros.',
  'Perdonar no es decir que lo que pasó no importa, ni volver a confiar ciegamente. Es soltar el derecho a cobrarle a la otra persona y dejarlo en manos de Dios.',
  'Colosenses 3:13', 'salvacion')
t('Salvación', 'Dios nos rescata del pecado y de sus consecuencias, y nos da vida eterna con él.',
  'Es el regalo completo de Dios: perdón del pasado, vida nueva en el presente y esperanza para el futuro.',
  'Juan 3:16', 'salvacion')
t('Nuevo nacimiento', 'Empezar una vida nueva desde adentro cuando el Espíritu Santo entra en nosotros.',
  'Jesús le dijo a Nicodemo que había que «nacer de nuevo». No es mejorar un poco, es recibir una vida nueva de parte de Dios.',
  'Juan 3:3', 'salvacion')
t('Vida eterna', 'Vivir para siempre con Dios, empezando desde ahora.',
  'No es solo «vivir mucho tiempo»: es conocer a Dios (Juan 17:3). Empieza el día que creemos y no termina nunca.',
  'Juan 17:3', 'salvacion')
t('Evangelio', 'La buena noticia de que Jesús murió por nuestros pecados y resucitó.',
  'La palabra significa «buena noticia». No es un consejo sobre lo que debemos hacer, sino el anuncio de lo que Dios ya hizo en Jesús.',
  '1 Corintios 15:3-4', 'jesus')
t('Pacto', 'Un compromiso solemne que Dios hace con su pueblo y que él siempre cumple.',
  'Dios hizo pactos con Noé, Abraham, Moisés y David. En Jesús hizo el nuevo pacto, escrito en el corazón.',
  'Jeremías 31:33', 'dios')
t('Mesías', 'El Rey prometido que Dios enviaría para salvar a su pueblo. Es lo mismo que «Cristo».',
  '«Mesías» (en hebreo) y «Cristo» (en griego) significan «ungido». Los cristianos creemos que Jesús es ese Mesías.',
  'Juan 4:25-26', 'jesus')
t('Encarnación', 'Dios se hizo ser humano en Jesús.',
  'Jesús es 100 % Dios y 100 % hombre. Nació de María, tuvo hambre, se cansó y lloró, sin dejar de ser Dios.',
  'Juan 1:14', 'jesus')
t('Expiación', 'Jesús cargó con el castigo de nuestro pecado para reconciliarnos con Dios.',
  'En el Antiguo Testamento se ofrecían sacrificios por el pecado. Jesús fue el sacrificio perfecto, una vez y para siempre.',
  'Hebreos 9:28', 'jesus')
t('Resurrección', 'Jesús volvió a la vida al tercer día, con un cuerpo glorificado.',
  'No fue un fantasma ni una idea bonita: la tumba quedó vacía y más de quinientas personas lo vieron. Su resurrección garantiza la nuestra.',
  '1 Corintios 15:20', 'jesus')
t('Ascensión', 'Jesús subió al cielo cuarenta días después de resucitar.',
  'Desde allí reina, intercede por nosotros y envió al Espíritu Santo.',
  'Hechos 1:9-11', 'jesus')
t('Segunda venida', 'Jesús va a volver a la tierra, de forma visible, para juzgar y hacer nuevas todas las cosas.',
  'Nadie sabe el día ni la hora. Lo que nos toca no es calcular fechas, sino vivir preparados y con esperanza.',
  'Hechos 1:11', 'jesus')
t('Espíritu Santo', 'Dios mismo viviendo en los creyentes: nos guía, nos consuela y nos da poder.',
  'No es una fuerza ni una energía, es una persona: la tercera persona de la Trinidad. Jesús lo llamó «el Consolador».',
  'Juan 14:16-17', 'espiritu')
t('Trinidad', 'Un solo Dios en tres personas: Padre, Hijo y Espíritu Santo.',
  'No son tres dioses ni tres máscaras de una sola persona. Es un misterio que la Biblia revela: Dios es comunidad de amor.',
  'Mateo 28:19', 'dios')
t('Santidad', 'Dios es completamente puro, perfecto y apartado de todo mal.',
  'Ser santo es ser «apartado» para Dios. Él es santo y nos llama a vivir de una manera distinta, que lo refleje.',
  '1 Pedro 1:15-16', 'dios')
t('Soberanía', 'Dios tiene el control sobre todo lo que existe.',
  'Nada se le escapa de las manos. Eso no significa que él cause el mal, sino que nada puede impedir que su plan bueno se cumpla.',
  'Salmos 115:3', 'dios')
t('Misericordia', 'Dios no nos da el castigo que merecemos y se compadece de nosotros.',
  'La gracia es recibir lo que no merecemos; la misericordia es no recibir el castigo que sí merecíamos.',
  'Lamentaciones 3:22', 'dios')
t('Fidelidad', 'Dios siempre cumple lo que promete.',
  'Aunque nosotros fallemos, él permanece fiel. Su palabra no vuelve vacía.',
  '2 Timoteo 2:13', 'dios')
t('Reino de Dios', 'Donde Dios reina y se hace su voluntad.',
  'Jesús anunció que el reino de Dios ya llegó con él, crece en el presente y se completará cuando él vuelva.',
  'Marcos 1:15', 'jesus')
t('Iglesia', 'La familia de todos los que siguen a Jesús.',
  'La iglesia no es un edificio: es la gente. Se reúne para adorar, aprender, orar y servir, y es el cuerpo de Cristo en el mundo.',
  '1 Corintios 12:27', 'vida')
t('Bautismo', 'Una señal pública de que hemos muerto a la vida vieja y resucitado con Cristo.',
  'Jesús mandó bautizar a sus discípulos. No es lo que nos salva, pero es un paso de obediencia y un testimonio ante otros.',
  'Romanos 6:4', 'vida')
t('Santa Cena', 'La comida que Jesús nos dejó para recordar su muerte hasta que vuelva.',
  'El pan representa su cuerpo y la copa su sangre. Al tomarla, recordamos, damos gracias y renovamos nuestro compromiso.',
  '1 Corintios 11:23-26', 'vida')
t('Discípulo', 'Alguien que sigue a Jesús, aprende de él y vive como él.',
  'Un discípulo no es solo un creyente: es un aprendiz de por vida. Y Jesús nos manda a hacer otros discípulos.',
  'Mateo 28:19-20', 'discipulado')
t('Fruto del Espíritu', 'El carácter que el Espíritu Santo produce en nosotros: amor, alegría, paz, paciencia, amabilidad, bondad, fidelidad, humildad y dominio propio.',
  'No se fabrica a fuerza de voluntad; crece cuando vivimos conectados a Dios.',
  'Gálatas 5:22-23', 'espiritu')
t('Adoración', 'Darle a Dios el honor que merece, con toda la vida.',
  'Cantar es una forma de adorar, pero la adoración incluye cómo trabajamos, cómo tratamos a otros y cómo usamos lo que tenemos.',
  'Romanos 12:1', 'vida')
t('Ayuno', 'Dejar de comer (o de algo más) por un tiempo para buscar a Dios con más intensidad.',
  'No es una dieta ni una forma de «obligar» a Dios. Es una manera de decir: «Te necesito más que la comida». Si tienes una condición de salud, consulta a tu médico.',
  'Mateo 6:16-18', 'vida')
t('Oración', 'Hablar con Dios y escucharlo.',
  'No hacen falta palabras bonitas. Es una conversación sincera con un Padre que escucha.',
  'Mateo 6:6', 'vida')
t('Tentación', 'La invitación a hacer el mal o a desconfiar de Dios.',
  'Ser tentado no es pecado; Jesús fue tentado y no pecó. El pecado es ceder. Dios siempre da una salida.',
  '1 Corintios 10:13', 'guerra')
t('Discernimiento', 'La capacidad de distinguir lo que viene de Dios de lo que no.',
  'Se desarrolla conociendo la Biblia, orando y buscando el consejo de creyentes maduros.',
  '1 Juan 4:1', 'guerra')
t('Armadura de Dios', 'Los recursos que Dios nos da para resistir el mal: verdad, justicia, evangelio, fe, salvación, Palabra y oración.',
  'Pablo usa la imagen de un soldado romano para enseñar que nuestra fuerza para la lucha espiritual viene de Dios.',
  'Efesios 6:10-18', 'guerra')
t('Idolatría', 'Poner cualquier cosa en el lugar que solo le pertenece a Dios.',
  'Hoy los ídolos no siempre son estatuas: pueden ser el dinero, el éxito, una relación, el placer o la aprobación de la gente.',
  'Éxodo 20:3', 'dios')
t('Reconciliación', 'Volver a tener paz y amistad con Dios (y con otros) después de estar separados.',
  'Por medio de Jesús, Dios nos reconcilió con él, y nos encarga llevar ese mensaje a otros.',
  '2 Corintios 5:18-19', 'salvacion')
t('Intercesión', 'Orar a favor de otra persona.',
  'Jesús intercede por nosotros ante el Padre, y nosotros podemos interceder por otros.',
  'Romanos 8:34', 'vida')

# ---------------------------------------------------------------------------
# Escuela Bíblica
# ---------------------------------------------------------------------------

nivel(1, 'Conociendo a Dios', 'Quién es Dios, cómo es y cómo se da a conocer.')

leccion('Dios existe y se da a conocer', ['Salmos 19:1-4', 'Hebreos 1:1-2'],
  'Dios se da a conocer de dos maneras: por medio de la creación, que «cuenta su gloria», y por medio de su Palabra, que culmina en Jesús. No tenemos que adivinar cómo es Dios: él mismo se ha revelado.',
  '¿Qué cosas de la creación te hacen pensar en Dios? ¿Has leído la Biblia esperando que Dios te hable?',
  'Carmen salía todas las mañanas al balcón de su casa en Cayey a ver la neblina sobre las montañas. Un día se preguntó quién había hecho todo eso. Esa pregunta la llevó a abrir una Biblia que tenía guardada desde su confirmación.',
  'Señor, gracias por darte a conocer en la creación y en tu Palabra. Abre mis ojos para verte y mi corazón para conocerte. Amén.')
leccion('Dios es amor y es santo', ['1 Juan 4:7-10', 'Isaías 6:1-5'],
  'La Biblia dice que «Dios es amor» y también que es «santo, santo, santo». Su amor no es blandengue y su santidad no es fría. Por su santidad, el pecado importa; por su amor, él mismo pagó el precio en la cruz.',
  '¿Te cuesta más creer que Dios te ama o que Dios es santo? ¿Por qué?',
  'José creció con la idea de un Dios que solo castigaba. Cuando leyó 1 Juan 4, entendió que Dios lo había amado primero, y que su santidad no lo alejaba: lo invitaba a una vida limpia.',
  'Dios santo y lleno de amor, gracias por amarme aunque no lo merezco. Enséñame a respetarte y a confiar en tu amor. Amén.')
leccion('Dios es fiel y tiene el control', ['Lamentaciones 3:21-24', 'Romanos 8:28'],
  'La fidelidad de Dios significa que siempre cumple lo que promete. Su soberanía significa que tiene el control, aun cuando nosotros no entendemos lo que pasa. Por eso podemos tener esperanza en medio de las crisis.',
  '¿En qué momento de tu vida viste la fidelidad de Dios? ¿Qué área de tu vida te cuesta dejar bajo su control?',
  'Después del huracán María, la familia Rivera estuvo meses sin luz. Doña Luz contaba cada noche, a la luz de una lámpara, una manera en que Dios los había cuidado ese día. Esa costumbre les sostuvo la esperanza.',
  'Señor, tu fidelidad es grande. Aunque no entienda todo, confío en que tienes el control y en que tus planes son buenos. Amén.')

nivel(2, 'Conociendo a Jesucristo', 'Quién es Jesús, qué hizo y por qué importa.')

leccion('Jesús es Dios hecho hombre', ['Juan 1:1-14', 'Filipenses 2:5-8'],
  'Jesús no es solo un buen maestro o un profeta. La Biblia enseña que es la Palabra eterna de Dios que se hizo ser humano. Esto se llama encarnación. Por eso, cuando miramos a Jesús, vemos cómo es Dios.',
  '¿Quién es Jesús para ti hoy? ¿Qué cambia saber que Dios se hizo uno de nosotros?',
  'Miguel, estudiante en la IUPI, pensaba que Jesús era un personaje histórico más. Leyendo el evangelio de Juan con un compañero, se dio cuenta de que Jesús afirmaba ser mucho más que eso, y tuvo que decidir qué creía.',
  'Señor Jesús, gracias por hacerte uno de nosotros. Quiero conocerte tal como eres. Amén.')
leccion('La cruz: Jesús murió por nosotros', ['Isaías 53:4-6', 'Romanos 5:6-8'],
  'En la cruz, Jesús cargó con el castigo de nuestro pecado. Murió por nosotros cuando todavía éramos pecadores. La cruz es la prueba más grande del amor de Dios.',
  '¿Qué sientes al pensar que Jesús murió por ti, personalmente?',
  'Ana cargaba mucha culpa por un aborto que tuvo a los diecinueve años. En un retiro escuchó Isaías 53 y entendió que Jesús ya había cargado ese peso. Lloró, y por primera vez se sintió libre.',
  'Señor Jesús, gracias por morir por mí. Cargaste lo que me tocaba a mí. Recibo tu perdón. Amén.')
leccion('La resurrección y su regreso', ['1 Corintios 15:3-8', 'Hechos 1:9-11'],
  'Jesús resucitó al tercer día, se apareció a cientos de personas y subió al cielo. Prometió volver. Su resurrección es la base de nuestra esperanza: la muerte no tiene la última palabra.',
  '¿Cómo cambia tu manera de ver la muerte saber que Jesús resucitó?',
  'En el velorio de su abuelo en Mayagüez, Pedro escuchó al pastor leer 1 Corintios 15. Por primera vez el dolor vino acompañado de esperanza: su abuelo había muerto confiando en Jesús.',
  'Señor Jesús, gracias porque resucitaste y vas a volver. Dame esperanza frente a la muerte y ayúdame a vivir preparado. Amén.')

nivel(3, 'La Salvación', 'El pecado, la gracia, la fe y la vida nueva.')

leccion('Todos necesitamos ser salvados', ['Romanos 3:23-24', 'Génesis 3:8-10'],
  'Todos hemos pecado y estamos lejos de Dios. No hay «buenos» que no necesiten a Dios ni «malos» que él no pueda alcanzar. Reconocer nuestra necesidad es el primer paso.',
  '¿Te consideras una persona que necesita a Dios? ¿Por qué?',
  'Roberto siempre fue «buena gente»: trabajador, buen papá, ayudaba en el barrio. Pensaba que no necesitaba a Dios. Cuando su hijo se enfermó y no podía hacer nada, se dio cuenta de cuánto lo necesitaba.',
  'Señor, reconozco que he pecado y que te necesito. Gracias porque no me rechazas. Amén.')
leccion('Salvados por gracia, por medio de la fe', ['Efesios 2:8-10', 'Juan 3:16-17'],
  'La salvación es un regalo. No se gana con buenas obras ni con ir a la iglesia. Se recibe confiando en Jesús. Las buenas obras vienen después, como resultado, no como pago.',
  '¿Has sentido que tienes que ganarte el amor de Dios? ¿Qué te dice este pasaje?',
  'Doña Gloria pasó años tratando de «portarse bien» para que Dios la aceptara. Cuando entendió Efesios 2, dijo: «¡Toda la vida tratando de pagar un regalo!». Esa semana empezó a servir en la iglesia, pero con alegría.',
  'Señor, gracias por salvarme por gracia. Recibo tu regalo por fe. Muéstrame las buenas obras que preparaste para mí. Amén.')
leccion('Arrepentimiento y nuevo nacimiento', ['Lucas 15:20-24', '2 Corintios 5:17'],
  'Arrepentirse es dar media vuelta y volver a Dios. Cuando lo hacemos, él nos recibe como el padre del hijo pródigo y nos da una vida nueva por su Espíritu. En Cristo somos nuevas criaturas.',
  '¿Hay algo de lo que necesitas arrepentirte hoy? ¿Qué parte de tu vida vieja todavía cargas?',
  'Luis estuvo preso por vender drogas. En la cárcel, un capellán le habló del hijo pródigo. Al salir, volvió a casa de su mamá en Bayamón y le pidió perdón. Hoy dirige un grupo de apoyo para jóvenes.',
  'Padre, me arrepiento de mis pecados y vuelvo a ti. Gracias por recibirme y darme una vida nueva. Amén.')

nivel(4, 'El Espíritu Santo', 'Quién es, qué hace y cómo vivir guiados por él.')

leccion('Quién es el Espíritu Santo', ['Juan 14:16-17', 'Juan 16:7-14'],
  'El Espíritu Santo no es una fuerza ni una energía: es Dios mismo, la tercera persona de la Trinidad. Jesús lo llamó «el Consolador», el que está a nuestro lado para ayudarnos, enseñarnos y guiarnos a la verdad.',
  '¿Cómo te imaginabas al Espíritu Santo? ¿Cómo cambia saber que es una persona que vive contigo?',
  'Marisol se sentía sola desde que se mudó a Orlando por trabajo. Al estudiar Juan 14, entendió que el Consolador estaba con ella allá también. Empezó a hablarle en sus mañanas de camino al trabajo.',
  'Espíritu Santo, gracias por vivir en mí. Consuélame, enséñame y guíame a toda la verdad. Amén.')
leccion('El poder del Espíritu', ['Hechos 1:8', 'Hechos 2:1-4'],
  'El Espíritu Santo nos da poder para ser testigos de Jesús, para vivir una vida santa y para servir con los dones que él reparte. No dependemos de nuestra fuerza.',
  '¿En qué área de tu vida necesitas el poder de Dios y no el tuyo?',
  'Héctor era tímido y nunca hablaba de su fe en el taller donde trabajaba. Después de orar pidiendo valor, un compañero le preguntó por qué siempre estaba tranquilo. Esa conversación cambió la vida de los dos.',
  'Espíritu Santo, lléname de tu poder. Dame valor para hablar de Jesús y fuerza para vivir para él. Amén.')
leccion('El fruto del Espíritu', ['Gálatas 5:16-25'],
  'El Espíritu Santo produce en nosotros el carácter de Jesús: amor, alegría, paz, paciencia, amabilidad, bondad, fidelidad, humildad y dominio propio. Es un fruto que crece con el tiempo cuando caminamos con él.',
  '¿Cuál de estas cualidades ves crecer en ti? ¿Cuál necesitas más?',
  'Sonia tenía un temperamento fuerte y peleaba con todo el mundo en el tapón. Empezó a pedirle al Espíritu dominio propio cada mañana. Su esposo fue el primero en notar el cambio.',
  'Espíritu Santo, produce tu fruto en mí. Hazme más paciente, más amable y más parecido a Jesús. Amén.')

nivel(5, 'Cómo Vivir Como Cristiano', 'Oración, Palabra, iglesia, servicio y generosidad.')

leccion('La oración', ['Mateo 6:5-13', 'Filipenses 4:6-7'],
  'Orar es hablar con Dios como con un Padre. Jesús nos enseñó el Padre Nuestro como modelo: adorar, pedir que se haga su voluntad, pedir lo que necesitamos, pedir perdón y perdonar, y pedir protección.',
  '¿Cómo es tu vida de oración? ¿Qué te impide orar más?',
  'Don Ramón, a sus ochenta años, ora cada mañana con el café en la mano, por cada uno de sus nietos, por nombre. Sus nietos dicen que lo que más recuerdan de su abuelo es escucharlo orar.',
  'Padre nuestro, enséñame a orar. Quiero hablar contigo cada día y escuchar tu voz. Amén.')
leccion('La Palabra y la iglesia', ['Salmos 1:1-3', 'Hechos 2:42-47'],
  'Crecemos alimentándonos de la Palabra y viviendo en comunidad. Los primeros cristianos se reunían para aprender, compartir, orar y comer juntos. Nadie crece solo.',
  '¿Tienes un tiempo diario con la Biblia? ¿Tienes una comunidad donde crecer?',
  'Kiara empezó un grupo de estudio bíblico en la sala de su casa con tres amigas. Un año después eran doce, y se ayudaban unas a otras en las enfermedades, los empleos y los problemas de familia.',
  'Señor, dame hambre de tu Palabra. Ayúdame a encontrar una comunidad donde crecer y servir. Amén.')
leccion('Servir y dar', ['Marcos 10:42-45', '2 Corintios 9:6-8'],
  'Jesús no vino a ser servido, sino a servir. Seguirlo es servir a otros con nuestro tiempo, nuestros dones y nuestros recursos. Dios ama al que da con alegría.',
  '¿A quién puedes servir esta semana? ¿Cómo es tu relación con el dinero?',
  'Después del terremoto en el sur, los jóvenes de una iglesia de Ponce organizaron comida para cientos de familias en Guánica y Yauco. Muchos de ellos dijeron que nunca se habían sentido tan cerca de Dios.',
  'Señor Jesús, tú viniste a servir. Hazme un servidor como tú y enséñame a dar con alegría. Amén.')

nivel(6, 'Madurez Espiritual', 'Pruebas, tentación, guerra espiritual y perseverancia.')

leccion('Las pruebas nos forman', ['Santiago 1:2-5', 'Romanos 5:3-5'],
  'Las pruebas no son agradables, pero Dios las usa para formar constancia, carácter y esperanza. Una fe madura no es una fe sin problemas, sino una fe que aprende a confiar en medio de ellos.',
  '¿Qué prueba estás atravesando? ¿Qué crees que Dios quiere formar en ti?',
  'Cuando a Wanda le diagnosticaron cáncer, sus primeras oraciones fueron de coraje. Con el tiempo, mientras pasaba por el tratamiento, aprendió a orar de otra manera. Hoy acompaña a otras mujeres en el mismo proceso.',
  'Señor, en medio de esta prueba, dame constancia y sabiduría. Usa lo difícil para formar en mí el carácter de Cristo. Amén.')
leccion('Tentación y guerra espiritual', ['Efesios 6:10-18', '1 Corintios 10:13'],
  'Hay una lucha espiritual real, pero Dios nos da su armadura. La tentación no es pecado; ceder sí lo es. Dios siempre da una salida, y Jesús venció la tentación con la Palabra.',
  '¿En qué área eres más tentado? ¿Cuál es tu «salida»?',
  'Javier luchaba con la pornografía. Le contó a un hermano de confianza, instaló un filtro en su celular y empezó a memorizar versículos. No fue de la noche a la mañana, pero aprendió a usar las salidas que Dios le daba.',
  'Señor, me pongo tu armadura. Dame fuerzas para resistir la tentación y muéstrame la salida. Amén.')
leccion('Perseverar hasta el final', ['Hebreos 12:1-3', 'Filipenses 1:6'],
  'La vida cristiana es una carrera de resistencia, no un sprint. Corremos con los ojos puestos en Jesús, y confiamos en que el que empezó la buena obra en nosotros la va a terminar.',
  '¿Qué te está pesando en la carrera? ¿Qué necesitas soltar?',
  'Doña Ivonne lleva cuarenta años en la fe. Ha pasado por la muerte de su esposo, una quiebra y la enfermedad de su hija. Cuando le preguntan cómo ha seguido, contesta: «No fui yo; fue él que no me soltó».',
  'Señor Jesús, pongo mis ojos en ti. Ayúdame a correr con paciencia y a no rendirme. Amén.')

nivel(7, 'Cómo Ayudar a Otros a Crecer', 'Compartir la fe, hacer discípulos y servir como Jesús.')

leccion('Compartir tu fe', ['1 Pedro 3:15', 'Hechos 1:8'],
  'Compartir la fe no es ganar discusiones, sino contar con amor y respeto lo que Jesús ha hecho por nosotros. Tu historia es una herramienta poderosa: cómo eras, cómo conociste a Jesús y cómo te ha cambiado.',
  '¿Podrías contar tu historia con Jesús en tres minutos? Escríbela.',
  'Lorna no sabía «predicar», pero cuando su compañera de trabajo le contó que estaba pasando por un divorcio, le contó cómo Dios la había sostenido en el suyo. Esa conversación fue el comienzo de la fe de su amiga.',
  'Señor, dame valor y amor para contar lo que has hecho en mi vida. Prepara los corazones de las personas a mi alrededor. Amén.')
leccion('Hacer discípulos', ['Mateo 28:18-20', '2 Timoteo 2:2'],
  'Jesús no nos mandó a hacer convertidos, sino discípulos: personas que aprenden a obedecerle. Esto se hace acompañando: leyendo juntos, orando juntos y viviendo la fe juntos.',
  '¿Quién te discipuló a ti? ¿A quién podrías acompañar tú?',
  'Ángel se reúne cada sábado a desayunar con dos muchachos de su iglesia. Leen un capítulo, hablan de la semana y oran. Uno de ellos ya está acompañando a otro joven.',
  'Señor Jesús, quiero obedecer tu mandato de hacer discípulos. Muéstrame a quién acompañar y dame paciencia y amor. Amén.')
leccion('Servir como Jesús', ['Juan 13:12-17', 'Mateo 25:34-40'],
  'Jesús lavó los pies de sus discípulos para enseñarnos a servir. Lo que hacemos por el más pequeño (el enfermo, el preso, el que tiene hambre) se lo hacemos a él.',
  '¿Quién es «el más pequeño» a tu alrededor? ¿Cómo puedes servirle esta semana?',
  'Un grupo de jóvenes de Carolina visita todos los meses un hogar de ancianos. Les cantan, les leen la Biblia y los escuchan. «Vamos a servir», dicen, «y salimos siempre más bendecidos».',
  'Señor Jesús, tú lavaste los pies de tus discípulos. Hazme un servidor humilde, que te vea en el más pequeño. Amén.')

# ---------------------------------------------------------------------------
# Asistente cristiano: respuestas sin conexión
# ---------------------------------------------------------------------------

r('¿Por qué sufro?', ['sufro', 'sufrimiento', 'dolor', 'por que me pasa', 'por qué a mí', 'injusto'],
  'Romanos 8:28',
  'La Biblia no esconde el sufrimiento: Job, David, Jeremías y el mismo Jesús sufrieron. Vivimos en un mundo roto por el pecado, y el dolor es parte de esa realidad. Pero Dios no es indiferente: Jesús sufrió con nosotros y por nosotros, y Dios puede usar aun lo más difícil para bien.',
  'No tienes que entenderlo todo hoy. Dile a Dios con honestidad lo que sientes, como hicieron los salmistas. Busca a alguien de confianza para no cargar solo.',
  'Señor, no entiendo por qué estoy sufriendo. Te traigo mi dolor tal como es. Gracias porque tú también sufriste y estás conmigo. Usa esto para bien. Amén.',
  'Lee el Salmo 13 y escribe tu propia oración honesta a Dios.')
r('¿Cómo perdono?', ['perdonar', 'perdono', 'rencor', 'me hirieron', 'me traicionaron', 'resentimiento'],
  'Colosenses 3:13',
  'Perdonar no es decir que lo que te hicieron estuvo bien, ni olvidarlo, ni necesariamente volver a confiar. Es soltar la deuda y entregársela a Dios, que juzga con justicia. Perdonamos porque hemos sido perdonados.',
  'Escribe el nombre de la persona y lo que te hizo. Dile a Dios: «Yo suelto esta deuda». Puede que tengas que hacerlo muchas veces. Si hubo abuso o peligro, perdonar no significa quedarte en riesgo: busca ayuda y protección.',
  'Señor, tú me perdonaste mucho. Hoy decido soltar la deuda de esta persona. Sana mi herida y líbrame del rencor. Amén.',
  'Lee Mateo 18:21-35 y ora por la persona que te hirió, aunque sea con una frase.')
r('¿Cómo oro?', ['orar', 'oro', 'oración', 'no se orar', 'no sé orar', 'como hablo con dios'],
  'Mateo 6:9-13',
  'Orar es hablar con Dios como con un Padre que te ama. No necesitas palabras bonitas ni un lugar especial. Jesús nos dio el Padre Nuestro como modelo: adorar a Dios, pedir su voluntad, pedir lo que necesitamos, pedir perdón y perdonar, y pedir protección.',
  'Empieza con cinco minutos al día. Usa el Padre Nuestro como guía, frase por frase, con tus propias palabras. También puedes orar mientras manejas o caminas.',
  'Padre, enséñame a orar. Quiero hablar contigo cada día y aprender a escucharte. Amén.',
  'Haz el nivel 5 de la Escuela Bíblica: «La oración».')
r('¿Cómo venzo el miedo?', ['miedo', 'temor', 'tengo miedo', 'asustado', 'pánico', 'nervios'],
  'Isaías 41:10',
  'La Biblia repite muchas veces «no temas», casi siempre con la misma razón: «porque yo estoy contigo». El miedo no desaparece porque las circunstancias cambien, sino porque sabemos quién está con nosotros.',
  'Nombra en voz alta lo que temes. Junto a cada miedo, repite Isaías 41:10. Da un paso pequeño de fe hoy. Si el miedo o los ataques de pánico son frecuentes, busca también ayuda profesional.',
  'Señor, tengo miedo. Pero tú estás conmigo, tú eres mi Dios, tú me das fuerzas y me sostienes. Hoy decido confiar en ti. Amén.',
  'Lee el Salmo 27 y el estudio de Josué 1:7-9.')
r('¿Qué hago si estoy triste?', ['triste', 'tristeza', 'deprimido', 'depresión', 'llorar', 'sin ganas', 'desanimado'],
  'Salmos 34:18',
  'La tristeza no es falta de fe. Jesús mismo lloró. Dios está cerca de los que tienen el corazón roto. La Biblia está llena de oraciones de personas tristes que fueron honestas con Dios.',
  'Permítete llorar delante de Dios. Habla con alguien de confianza; no te aísles. Cuida lo básico: dormir, comer, salir a caminar. Si la tristeza dura semanas o tienes pensamientos de hacerte daño, busca ayuda profesional hoy mismo.',
  'Señor, estoy triste. Tú estás cerca de los que tienen el corazón roto. Abrázame, consuélame y dame esperanza. Amén.',
  'Lee el Salmo 42 y habla hoy con una persona de confianza.',
  'Si tienes pensamientos de quitarte la vida, llama o escribe al 988 (Línea de Prevención del Suicidio y Crisis, disponible en Puerto Rico) o a la Línea PAS de ASSMCA: 1-800-981-0023. Si estás en peligro, llama al 911.')
r('¿Cómo venzo una adicción?', ['adicción', 'adicto', 'vicio', 'drogas', 'alcohol', 'pornografía', 'apuestas', 'no puedo dejar'],
  '1 Corintios 10:13',
  'Las adicciones esclavizan, pero Jesús vino a dar libertad. Dios no te rechaza por tu lucha. La libertad casi nunca llega sola: llega con la ayuda de Dios, de otras personas y, muchas veces, de profesionales.',
  'Reconoce la adicción ante Dios y ante alguien de confianza. Busca un grupo de apoyo o un programa de tratamiento. Identifica tus «salidas»: lugares, personas y horas que debes evitar. Si caes, no te rindas: levántate y sigue.',
  'Señor, no puedo solo con esta adicción. Te la entrego. Dame la salida, rodéame de personas que me ayuden y libérame. Amén.',
  'Habla esta semana con un pastor, un consejero o un programa de ayuda.',
  'La Línea PAS de ASSMCA (1-800-981-0023) ofrece orientación gratuita sobre tratamiento de adicciones en Puerto Rico, las 24 horas.')
r('¿Por qué Dios permite pruebas?', ['pruebas', 'prueba', 'por qué dios permite', 'problemas', 'dificultades'],
  'Santiago 1:2-4',
  'Dios no causa el mal, pero permite pruebas que puede usar para formar en nosotros constancia, carácter y madurez. Las pruebas revelan lo que hay en nuestro corazón y nos enseñan a depender de él.',
  'Pregúntale a Dios: «¿Qué quieres formar en mí?». Pídele sabiduría para el próximo paso. Recuerda pruebas pasadas en las que Dios fue fiel.',
  'Señor, no me gusta esta prueba, pero confío en que tú la puedes usar para bien. Dame constancia y sabiduría. Amén.',
  'Haz el nivel 6 de la Escuela Bíblica: «Las pruebas nos forman».')
r('¿Cómo sé que Dios me ama?', ['me ama', 'amor de dios', 'no valgo', 'nadie me quiere', 'rechazo'],
  'Romanos 5:8',
  'La prueba más grande del amor de Dios es la cruz: Cristo murió por nosotros cuando todavía éramos pecadores. Dios no te ama porque seas perfecto, te ama porque él es amor.',
  'Lee Romanos 5:8 y Juan 3:16 con tu nombre. Cuando sientas que no vales nada, recuerda lo que Dios pagó por ti.',
  'Padre, gracias porque me amaste antes de que yo te amara. Ayúdame a creer en tu amor. Amén.',
  'Lee el estudio de Lucas 15:20-24, el padre que corre a abrazar.')
r('¿Cómo empiezo a leer la Biblia?', ['leer la biblia', 'empezar', 'por dónde empiezo', 'no entiendo la biblia'],
  'Salmos 119:105',
  'La Biblia no se lee como una novela, de principio a fin de un tirón. Un buen comienzo es el evangelio de Juan, que presenta a Jesús. Lee poco, pero todos los días, y pregúntate: ¿qué dice?, ¿qué me enseña de Dios?, ¿cómo lo aplico?',
  'Empieza el plan «Conoce a Jesús en 21 días» (un capítulo de Juan por día). Usa la paráfrasis boricua para entender y los estudios para profundizar.',
  'Señor, tu Palabra es lámpara para mis pies. Abre mi entendimiento y dame hambre de leerla. Amén.',
  'Empieza hoy el plan de lectura «Conoce a Jesús en 21 días».')
r('¿Cómo sé si soy salvo?', ['salvo', 'salvación', 'voy al cielo', 'cómo me salvo', 'aceptar a cristo'],
  '1 Juan 5:11-13',
  'La salvación no depende de cuán bueno seas, sino de en quién confías. Dios nos dio vida eterna en su Hijo: el que tiene al Hijo tiene la vida. Puedes estar seguro, no por tus obras, sino por la promesa de Dios.',
  'Si nunca lo has hecho, puedes decirle a Dios que reconoces tu pecado, que crees que Jesús murió y resucitó por ti y que quieres seguirlo. Luego cuéntale a alguien y busca una iglesia donde crecer.',
  'Señor Jesús, reconozco que he pecado. Creo que moriste por mí y resucitaste. Te recibo como mi Salvador y quiero seguirte. Gracias por la vida eterna. Amén.',
  'Haz el nivel 3 de la Escuela Bíblica: «La Salvación».')
r('¿Qué hago con la ansiedad?', ['ansiedad', 'ansioso', 'preocupado', 'estrés', 'estresado', 'no puedo dormir', 'agobiado'],
  'Filipenses 4:6-7',
  'Dios no te regaña por sentir ansiedad. Te invita a cambiar cada preocupación por una oración con gratitud. Su paz no depende de que todo esté resuelto.',
  'Haz una lista de lo que te preocupa y ora por cada cosa, añadiendo un «gracias». Haz hoy solo lo que te toca hoy. Respira despacio. Si la ansiedad es constante, busca también ayuda profesional: Dios usa a los médicos y consejeros.',
  'Señor, te entrego lo que me preocupa. Gracias porque me escuchas. Que tu paz cuide mi corazón y mis pensamientos. Amén.',
  'Lee el estudio de Mateo 6:31-34.')
r('¿Cómo manejo el coraje?', ['coraje', 'ira', 'enojo', 'enojado', 'furia', 'pelear'],
  'Efesios 4:26-27',
  'Sentir coraje no siempre es pecado; Jesús se enojó ante la injusticia. Lo que nos hace pecar es lo que hacemos con el coraje: herir, guardar rencor o vengarnos. La Biblia nos pide no dejar que se ponga el sol sobre nuestro enojo.',
  'Antes de reaccionar, haz una pausa. Pregúntate qué hay detrás de tu coraje (dolor, miedo, injusticia). Habla del problema cuando estés calmado. Pídele al Espíritu dominio propio.',
  'Señor, siento mucho coraje. Ayúdame a no pecar con él. Dame dominio propio y sabiduría para resolver esto de la manera correcta. Amén.',
  'Lee Santiago 1:19-20 y el estudio de Gálatas 5:22-23.')
r('¿Cómo comparto mi fe?', ['compartir', 'evangelizar', 'hablar de dios', 'testificar', 'predicar'],
  '1 Pedro 3:15',
  'Compartir la fe no es ganar discusiones: es contar con amor y respeto lo que Jesús ha hecho por ti. Tu historia personal es poderosa.',
  'Escribe tu historia en tres partes: cómo era tu vida antes, cómo conociste a Jesús y cómo te ha cambiado. Ora por tres personas y busca oportunidades naturales para conversar.',
  'Señor, dame valor y amor para contar lo que has hecho en mí. Prepara los corazones de las personas a mi alrededor. Amén.',
  'Haz el nivel 7 de la Escuela Bíblica: «Compartir tu fe».')
r('Me siento solo', ['solo', 'soledad', 'sola', 'nadie', 'abandonado', 'aislado'],
  'Hebreos 13:5',
  'Dios promete: «No te dejaré ni te abandonaré». Aun cuando la gente falle, él permanece. Y Dios no quiere que vivas aislado: te creó para vivir en comunidad.',
  'Dile a Dios cómo te sientes. Da un paso hacia otros esta semana: llama a alguien, visita una iglesia o un grupo pequeño, ofrécete como voluntario.',
  'Señor, me siento solo. Gracias porque tú no me dejas ni me abandonas. Llévame a personas con quienes pueda crecer. Amén.',
  'Lee el Salmo 23 y busca un grupo pequeño en una iglesia cerca de ti.')
r('¿Cómo sé la voluntad de Dios?', ['voluntad de dios', 'decisión', 'qué hago', 'dirección', 'propósito'],
  'Proverbios 3:5-6',
  'La mayor parte de la voluntad de Dios ya está en la Biblia: amar, obedecer, servir, ser santo. Para las decisiones específicas, Dios nos guía por su Palabra, por la oración, por el consejo de creyentes maduros y por la paz que da su Espíritu.',
  'Ora por la decisión. Pregúntate si alguna opción va en contra de la Biblia. Busca consejo de dos o tres personas maduras en la fe. Da el paso que tengas claro y confía.',
  'Señor, confío en ti de todo corazón. No quiero apoyarme solo en mi propio entendimiento. Muéstrame tu camino y endereza mis pasos. Amén.',
  'Lee el estudio de Proverbios 3:5-6 y Romanos 12:1-2.')
r('¿Qué dice la Biblia del dinero?', ['dinero', 'chavos', 'deudas', 'trabajo', 'finanzas', 'pobreza'],
  'Mateo 6:33',
  'La Biblia habla mucho del dinero: nos advierte contra el amor al dinero, nos enseña a trabajar con honestidad, a ser generosos y a confiar en que Dios provee. El dinero es un buen siervo, pero un mal señor.',
  'Haz un presupuesto sencillo. Prioriza tus necesidades, sé generoso y evita las deudas innecesarias. Pídele a Dios sabiduría y busca orientación financiera si la necesitas.',
  'Señor, todo lo que tengo viene de ti. Ayúdame a administrarlo con sabiduría, a ser generoso y a confiar en que tú provees. Amén.',
  'Lee el estudio de Mateo 6:31-34 y 1 Timoteo 6:6-10.')
r('Problemas en mi matrimonio o familia', ['matrimonio', 'esposo', 'esposa', 'pareja', 'familia', 'hijos', 'divorcio', 'crianza'],
  'Efesios 4:2-3',
  'Dios diseñó la familia y le importa lo que estás viviendo. Las relaciones sanas se construyen con humildad, paciencia, perdón y comunicación. Ninguna familia es perfecta, pero Dios puede sanar y restaurar.',
  'Ora por tu familia cada día, por nombre. Busca un momento tranquilo para hablar, escuchando más que hablando. Considera la consejería pastoral o profesional. Si hay violencia o abuso, tu seguridad es primero: busca ayuda.',
  'Señor, te entrego mi familia. Danos humildad, paciencia y perdón. Sana lo que está roto. Amén.',
  'Lee el estudio de 1 Corintios 13:4-7.',
  'Si vives violencia doméstica, en Puerto Rico puedes llamar a la Línea de Orientación de la Oficina de la Procuradora de las Mujeres (787-722-2977) o al 911 en una emergencia.')
