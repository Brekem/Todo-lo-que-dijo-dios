P = []
def add(id, era, ref, book, speaker, quote, recipient, people, ctx, sit, problem, expl, app, prayer, cats, topics, problems):
    P.append(dict(id=id, era=era, reference=ref, book=book, speaker=speaker, quote=quote, recipient=recipient,
                  people=people, historicalContext=ctx, situation=sit, problem=problem, explanation=expl,
                  application=app, prayer=prayer, categories=cats, topics=topics, problems=problems))

# ---------------------------------------------------------------- ADÁN
add("gen-1-3", "adan", "Génesis 1:3", "Génesis", "Dios",
 "Sea la luz.",
 "La creación entera", ["Dios creador"],
 "Es el principio de todo. Antes de que existiera el ser humano, Dios habla por primera vez en la Biblia y su palabra crea.",
 "La tierra estaba desordenada y vacía, y las tinieblas cubrían el abismo. No había forma, ni vida, ni luz.",
 "El caos y la oscuridad. Dios no deja la creación en tinieblas: su primera palabra trae orden y claridad.",
 "La primera vez que Dios habla, lo que dice sucede. Su voz no solo informa: transforma. Donde había oscuridad, su palabra pone luz.",
 "Si hoy estás enfrentando una etapa oscura, confusa o sin forma, recuerda que Dios empezó la historia hablando luz sobre el caos. Tu vida no es demasiado desordenada para que su voz la ilumine. Empieza el día leyendo una sola palabra suya y pídele luz para el siguiente paso.",
 "Señor, hoy traigo ante ti la oscuridad que hay en mí. Tú que dijiste «sea la luz», habla sobre mi confusión y mi desorden. Renuncio a creer que mi vida no tiene arreglo. Pon tu luz donde yo solo veo tinieblas. Amén.",
 ["esperanza", "fe"], ["creación", "luz", "poder de Dios", "nuevo comienzo"], ["confusión", "oscuridad", "desorden"])

add("gen-2-18", "adan", "Génesis 2:18", "Génesis", "Yavé",
 "No es bueno que el hombre esté solo; haréle ayuda idónea para él.",
 "Adán (el primer ser humano)", ["Adán", "Eva"],
 "En el jardín del Edén, recién creado el ser humano, todo lo que Dios había hecho era «bueno». Esta es la primera cosa que Dios declara «no buena».",
 "Adán vivía en un lugar perfecto y tenía comunión con Dios, pero no tenía a nadie como él con quien compartir la vida.",
 "La soledad. Dios mismo reconoce que el ser humano no fue hecho para vivir aislado.",
 "Dios diseñó al ser humano para la relación. La soledad no es un defecto tuyo ni un castigo: es una necesidad que Dios mismo vio y quiso llenar. Por eso creó a Eva y, con ella, la familia y la comunidad.",
 "Si hoy estás enfrentando soledad, no te avergüences: Dios mismo dijo que no es bueno estar solo. Pídele que te conduzca a personas con quienes caminar. Da un paso pequeño: escribe a alguien, acepta una invitación, acércate a una comunidad de fe.",
 "Señor, tú ves mi soledad y no la desprecias. Hoy renuncio a la mentira de que no le importo a nadie. Tú dijiste que no es bueno que esté solo; trae a mi vida compañía verdadera y hazme también compañía para otros. Amén.",
 ["soledad", "amor"], ["relaciones", "familia", "matrimonio", "comunidad"], ["soledad", "aislamiento"])

add("gen-3-9", "adan", "Génesis 3:9", "Génesis", "Yavé",
 "¿Dónde estás tú?",
 "Adán, escondido junto a Eva", ["Adán", "Eva"],
 "Tras la creación, Adán y Eva desobedecieron a Dios comiendo del árbol prohibido. Es el relato de la caída y el origen del pecado en el mundo.",
 "Al oír la voz de Dios que se paseaba en el huerto, Adán y Eva se escondieron entre los árboles, avergonzados y con miedo.",
 "La culpa y la vergüenza que empujan a esconderse de Dios. Él no se esconde del pecador: lo busca.",
 "Dios sabía perfectamente dónde estaba Adán. La pregunta no era para informarse, sino para invitarlo a salir. Después de fallar, la primera palabra de Dios no es un grito de condena, sino una búsqueda.",
 "Si hoy estás enfrentando culpa por algo que hiciste y sientes ganas de alejarte de Dios, escucha esta pregunta como una invitación. No sigas escondido. Dile con honestidad dónde estás y qué pasó. Dios te busca para restaurarte, no para destruirte.",
 "Señor, aquí estoy. Ya no quiero esconderme de ti. Te confieso lo que hice y la vergüenza que siento. Hoy renuncio a la culpa que me aleja de ti y acepto que tú me buscas porque me amas. Cúbreme con tu misericordia. Amén.",
 ["culpa", "perdon"], ["pecado", "vergüenza", "búsqueda de Dios", "restauración"], ["culpa", "vergüenza", "miedo", "desobediencia"])

add("gen-4-6", "adan", "Génesis 4:6-7", "Génesis", "Yavé",
 "¿Por qué te has ensañado, y por qué se ha inmutado tu rostro? Si bien hicieres, ¿no serás ensalzado? y si no hicieres bien, el pecado está a la puerta: con todo esto, a ti será su deseo, y tú te enseñorearás de él.",
 "Caín", ["Caín", "Abel"],
 "Primera generación fuera del Edén. Caín, labrador, y Abel, pastor, eran hijos de Adán y Eva y presentaron ofrendas a Dios.",
 "Dios miró con agrado la ofrenda de Abel, pero no la de Caín. Caín se llenó de enojo y envidia contra su hermano.",
 "La ira, la envidia y la tentación de hacer daño. Dios advierte a Caín antes de que el enojo se convierta en pecado.",
 "Dios habla a Caín antes de que cometa el crimen. Le muestra que su enojo es como una fiera agazapada a la puerta, pero que él todavía puede dominarlo. Dios siempre da una oportunidad para elegir el bien.",
 "Si hoy estás enfrentando enojo, envidia o resentimiento hacia alguien, detente y escucha esta advertencia. Pon nombre a lo que sientes y no dejes que gobierne tus decisiones. Aléjate de la situación, ora y busca hacer lo correcto antes de actuar.",
 "Señor, reconozco el enojo y la envidia que hay en mi corazón. Hoy renuncio a dejar que la ira me domine. Ayúdame a enseñorearme de ella antes de que haga daño. Dame un corazón en paz con mi hermano. Amén.",
 ["obediencia", "culpa"], ["ira", "envidia", "tentación", "dominio propio"], ["ira", "envidia", "resentimiento"])

# ---------------------------------------------------------------- NOÉ
add("gen-6-14", "noe", "Génesis 6:14, 18", "Génesis", "Yavé",
 "Hazte un arca de madera de Gopher… Mas estableceré mi pacto contigo, y entrarás en el arca tú, y tus hijos y tu mujer, y las mujeres de tus hijos contigo.",
 "Noé", ["Noé"],
 "Generaciones después de Adán, la maldad humana se había multiplicado sobre la tierra y la violencia llenaba el mundo.",
 "Noé era un hombre justo en medio de una generación corrompida. Dios le anuncia el diluvio y le da instrucciones precisas para salvar a su familia.",
 "La corrupción del mundo y la presión de vivir distinto. Dios llama a Noé a obedecer aunque nadie más lo haga.",
 "Dios le pidió a Noé algo que parecía absurdo: construir un barco enorme lejos del mar. Junto con la orden le dio una promesa: «estableceré mi pacto contigo». La obediencia de Noé salvó a su familia.",
 "Si hoy estás enfrentando la presión de un entorno que va en otra dirección, recuerda a Noé. Obedecer a Dios puede parecer extraño a otros, pero su instrucción siempre viene con su protección. Sigue construyendo lo que Dios te pidió, paso a paso.",
 "Señor, dame la fe de Noé para obedecerte aunque nadie a mi alrededor lo entienda. Hoy renuncio al miedo al qué dirán. Guarda a mi familia dentro de tu pacto y ayúdame a construir lo que tú me pides. Amén.",
 ["obediencia", "fe"], ["obediencia", "familia", "pacto", "protección"], ["presión social", "desobediencia", "corrupción"])

add("gen-9-13", "noe", "Génesis 9:13, 15", "Génesis", "Yavé",
 "Mi arco pondré en las nubes, el cual será por señal de convenio entre mí y la tierra… y no serán más las aguas por diluvio para destruir toda carne.",
 "Noé y sus hijos", ["Noé", "Sem", "Cam", "Jafet"],
 "Después del diluvio, Noé y su familia salen del arca a un mundo completamente nuevo. Es el primer pacto explícito de Dios con toda la humanidad.",
 "Tras meses de encierro y destrucción, la familia de Noé debía empezar de cero. Podían temer que otra catástrofe volviera a ocurrir.",
 "El temor a que el desastre se repita. Dios da una señal visible para que la humanidad viva con seguridad.",
 "Dios pone el arco iris como recordatorio de su promesa. Después de la tormenta, Dios no solo deja de juzgar: se compromete. Cada vez que aparece el arco en las nubes, Dios dice: «me acuerdo de mi pacto».",
 "Si hoy estás enfrentando las consecuencias de una tormenta —una pérdida, una crisis, un fracaso—, mira las promesas de Dios como ese arco en las nubes. Escribe una promesa suya y colócala donde la veas. Empieza de nuevo sabiendo que Dios se acuerda de ti.",
 "Señor, después de mis tormentas, tú pones señales de esperanza. Hoy renuncio al miedo de que todo vuelva a derrumbarse. Recuerda tu pacto conmigo y ayúdame a empezar de nuevo, confiando en tu fidelidad. Amén.",
 ["esperanza", "miedo"], ["pacto", "promesa", "nuevo comienzo", "fidelidad"], ["miedo", "trauma", "incertidumbre"])

# ---------------------------------------------------------------- ABRAHAM
add("gen-12-1", "abraham", "Génesis 12:1-2", "Génesis", "Yavé",
 "Vete de tu tierra y de tu parentela, y de la casa de tu padre, a la tierra que te mostraré; y haré de ti una nación grande, y bendecirte he, y engrandeceré tu nombre, y serás bendición.",
 "Abram (Abraham)", ["Abraham", "Abram", "Sara"],
 "Hacia el año 2000 a. C., en Harán, Mesopotamia. Abram venía de Ur de los caldeos, una región de muchos dioses.",
 "Abram tenía 75 años, estaba casado con Sarai, que era estéril, y vivía cómodamente con su familia. Dios le pide dejarlo todo sin decirle adónde irá.",
 "La seguridad de lo conocido y el miedo a lo desconocido. Dios llama a Abram a confiar más en su promesa que en su comodidad.",
 "Dios le pide a Abram salir sin mapa, solo con una promesa. No le explica el destino, pero le asegura que lo bendecirá y que, por medio de él, bendecirá a otros. Así empieza la historia del pueblo de Dios.",
 "Si hoy estás enfrentando una decisión que te obliga a dejar algo conocido —un lugar, un trabajo, una relación, un hábito—, recuerda que Dios no siempre muestra todo el camino, pero siempre acompaña. Da el primer paso que tengas claro y confía el resto.",
 "Señor, como a Abraham, me llamas a salir de lo conocido. Hoy renuncio al miedo a lo que no puedo ver. Muéstrame la tierra que tienes para mí y hazme bendición para otros. Camino confiando en tu promesa. Amén.",
 ["obediencia", "fe"], ["llamado", "propósito", "promesa", "bendición"], ["miedo al cambio", "inseguridad", "duda"])

add("gen-15-1", "abraham", "Génesis 15:1", "Génesis", "Yavé",
 "No temas, Abram; yo soy tu escudo, y tu galardón sobremanera grande.",
 "Abram", ["Abraham", "Abram"],
 "Abram vivía como extranjero en Canaán. Acababa de rescatar a su sobrino Lot en una batalla contra cuatro reyes.",
 "Después de la victoria, Abram podía temer represalias de sus enemigos. Además, seguía sin tener el hijo que Dios le había prometido.",
 "El miedo a los enemigos y la inquietud por las promesas que aún no se cumplen.",
 "Dios no le promete a Abram una vida sin enemigos, sino ser él mismo su escudo. Y no solo le da recompensas: Dios mismo es su recompensa. Es la primera vez que la Biblia registra «no temas».",
 "Si hoy estás enfrentando miedo a lo que otros puedan hacerte o a que tus sueños no se cumplan, escucha esta palabra: Dios es tu escudo. Cuando llegue el temor, repítelo en voz alta y recuerda que lo más valioso que tienes es a Dios mismo.",
 "Señor, hoy renuncio al miedo. Tú eres mi escudo cuando me siento atacado y mi mayor recompensa cuando mis sueños tardan. Guárdame y enséñame a descansar en ti. Amén.",
 ["miedo", "fe"], ["protección", "promesa", "recompensa"], ["miedo", "inseguridad", "espera"])

add("gen-15-5", "abraham", "Génesis 15:5", "Génesis", "Yavé",
 "Mira ahora a los cielos, y cuenta las estrellas, si las puedes contar… Así será tu simiente.",
 "Abram", ["Abraham", "Abram"],
 "Misma noche que la visión anterior. Abram le había dicho a Dios que, sin hijos, su heredero sería un siervo llamado Eliezer.",
 "Abram estaba desanimado: los años pasaban y la promesa de descendencia parecía imposible. Dios lo saca de la tienda a mirar el cielo.",
 "La duda y el desánimo ante una promesa que parece imposible.",
 "Dios responde a la duda de Abram con una imagen: las estrellas. El versículo siguiente dice que Abram creyó a Dios y le fue contado por justicia. La fe no es ver el cumplimiento, sino confiar en quien promete.",
 "Si hoy estás enfrentando dudas porque lo que esperas no llega, sal a mirar el cielo como Abram. Cambia la mirada de tus limitaciones a la grandeza de Dios. Escribe lo que esperas y entrégaselo, confiando en su tiempo.",
 "Señor, a veces tus promesas me parecen imposibles. Hoy renuncio a la duda que me encierra en mi tienda. Llévame a mirar tu grandeza, y como Abraham, decido creerte. Amén.",
 ["fe", "esperanza"], ["promesa", "fe", "descendencia", "espera"], ["duda", "desánimo", "impaciencia"])

add("gen-18-14", "abraham", "Génesis 18:14", "Génesis", "Yavé",
 "¿Hay para Dios alguna cosa difícil? Al tiempo señalado volveré a ti, según el tiempo de la vida, y Sara tendrá un hijo.",
 "Abraham y Sara", ["Abraham", "Sara"],
 "Abraham tenía casi 100 años y Sara unos 90. Yavé se les aparece en el encinar de Mamre en forma de tres visitantes.",
 "Al oír que tendría un hijo, Sara se rió dentro de sí, pensando que era imposible por su edad.",
 "La incredulidad y la resignación ante lo que parece humanamente imposible.",
 "Dios escucha la risa incrédula de Sara y responde con una pregunta que atraviesa toda la Biblia: ¿hay algo difícil para Dios? Un año después nació Isaac, cuyo nombre significa «risa».",
 "Si hoy estás enfrentando una situación que ya diste por perdida, deja que esta pregunta te desafíe. Nombra esa situación delante de Dios y pregúntate: ¿es demasiado difícil para Él? Ora con fe renovada, aunque te cueste creer.",
 "Señor, confieso que me he resignado ante lo imposible. Hoy renuncio a la incredulidad. Para ti no hay nada difícil. Cambia mi risa de duda en risa de alegría, en tu tiempo señalado. Amén.",
 ["fe", "esperanza"], ["milagros", "imposible", "promesa"], ["incredulidad", "resignación", "duda"])

add("job-38-4", "abraham", "Job 38:2, 4", "Job", "Yavé",
 "¿Quién es ése que oscurece el consejo con palabras sin sabiduría?… ¿Dónde estabas cuando yo fundaba la tierra? Házme saber, si tienes inteligencia.",
 "Job", ["Job"],
 "La tradición sitúa a Job en la época de los patriarcas, en la tierra de Uz. Era un hombre íntegro y muy próspero.",
 "Job lo perdió todo: hijos, bienes y salud. Tras largos discursos con sus amigos, reclama a Dios una explicación. Dios le responde desde un torbellino.",
 "El dolor sin explicación y la tentación de exigirle cuentas a Dios.",
 "Dios no le da a Job una explicación de su sufrimiento, sino una revelación de sí mismo. Le muestra que su sabiduría sostiene el universo. Job no recibe todas las respuestas, pero encuentra a Dios, y eso le basta.",
 "Si hoy estás enfrentando un dolor que no entiendes, está bien llevarle a Dios tus preguntas. Pero, como Job, permite que Él te muestre su grandeza. A veces la paz no llega con la respuesta, sino con la presencia de Dios.",
 "Señor, no entiendo lo que estoy viviendo. Hoy renuncio a exigir que me expliques todo. Tú fundaste la tierra y sostienes mi vida. Aunque no comprenda, decido confiar en tu sabiduría. Amén.",
 ["fe", "tristeza"], ["sufrimiento", "soberanía de Dios", "sabiduría"], ["sufrimiento", "tristeza", "duda", "enojo con Dios"])

# ---------------------------------------------------------------- ISAAC
add("gen-26-24", "isaac", "Génesis 26:24", "Génesis", "Yavé",
 "Yo soy el Dios de Abraham tu padre; no temas, que yo soy contigo, y yo te bendeciré, y multiplicaré tu simiente por amor de Abraham mi siervo.",
 "Isaac", ["Isaac"],
 "Isaac, el hijo de la promesa, vivía como extranjero entre los filisteos tras la muerte de su padre Abraham.",
 "Los filisteos le envidiaban, le cegaban los pozos y le obligaban a mudarse una y otra vez. Esa noche, en Beerseba, Yavé se le aparece.",
 "El miedo y el agotamiento de vivir en conflicto constante con otros.",
 "Isaac había cedido pozo tras pozo para evitar peleas. Dios le recuerda que no está solo: el mismo Dios fiel de su padre está con él. La bendición no dependía de ganar las discusiones, sino de la presencia de Dios.",
 "Si hoy estás enfrentando conflictos que te desgastan —en el trabajo, con vecinos, en la familia—, escucha: Dios está contigo. No necesitas ganar cada pelea. Busca la paz, sigue adelante y confía en que Dios te bendice.",
 "Señor, estoy cansado de los conflictos. Hoy renuncio al miedo y a la necesidad de defenderme siempre. Tú estás conmigo como estuviste con mis padres en la fe. Bendíceme y dame paz. Amén.",
 ["miedo", "fe"], ["presencia de Dios", "conflictos", "bendición", "fidelidad"], ["miedo", "conflictos", "agotamiento"])

# ---------------------------------------------------------------- JACOB
add("gen-28-15", "jacob", "Génesis 28:15", "Génesis", "Yavé",
 "Y he aquí, yo soy contigo, y te guardaré por donde quiera que fueres, y te volveré a esta tierra; porque no te dejaré hasta tanto que haya hecho lo que te he dicho.",
 "Jacob", ["Jacob"],
 "Jacob, nieto de Abraham, había engañado a su padre Isaac para quitarle la bendición a su hermano Esaú.",
 "Jacob huía de Esaú, que quería matarlo. Solo, de noche y con una piedra por almohada, soñó una escalera que unía la tierra con el cielo.",
 "La soledad, el miedo y la culpa de quien huye de sus propios errores.",
 "Jacob no merecía esta visita: acababa de mentir y huía. Aun así, Dios se le presenta con una promesa completa: estar con él, guardarlo, traerlo de vuelta y no dejarlo. La gracia de Dios llega antes que nuestro cambio.",
 "Si hoy estás enfrentando soledad o sientes que tus errores te alejaron de todo, recuerda la noche de Jacob. Dios puede encontrarte en el lugar más solitario. Hoy, en tu «piedra de almohada», háblale con sinceridad y recibe su promesa.",
 "Señor, como Jacob, a veces huyo solo y cargado de errores. Hoy renuncio a creer que me has abandonado. Tú prometiste no dejarme. Guárdame por dondequiera que vaya y termina lo que empezaste en mí. Amén.",
 ["soledad", "miedo"], ["presencia de Dios", "promesa", "protección", "gracia"], ["soledad", "miedo", "culpa"])

add("gen-31-3", "jacob", "Génesis 31:3", "Génesis", "Yavé",
 "Vuélvete a la tierra de tus padres, y a tu parentela; que yo seré contigo.",
 "Jacob", ["Jacob", "Labán"],
 "Jacob llevaba veinte años trabajando para su tío Labán en Harán. Se había casado con Lea y Raquel y tenía muchos hijos.",
 "Labán lo había engañado y cambiado su salario muchas veces. La relación se había vuelto hostil. Volver a casa significaba también enfrentar a Esaú.",
 "El estancamiento en un lugar de abuso y el miedo a enfrentar el pasado.",
 "Dios le dice a Jacob que es momento de volver, y le da la misma garantía de siempre: «yo seré contigo». A veces Dios nos saca de lugares donde ya no debemos estar, aunque el camino de regreso implique sanar viejas heridas.",
 "Si hoy estás enfrentando una situación donde te sientes usado o estancado, pregúntale a Dios si es tiempo de moverte. Y si volver implica reconciliarte con alguien, no lo harás solo: Él va contigo.",
 "Señor, dame valor para salir de donde ya no debo estar y para enfrentar lo que dejé pendiente. Hoy renuncio al miedo al pasado. Tú estás conmigo en el camino de regreso. Amén.",
 ["obediencia", "miedo"], ["dirección", "reconciliación", "presencia de Dios"], ["estancamiento", "abuso", "miedo al pasado"])

add("gen-46-3", "jacob", "Génesis 46:3-4", "Génesis", "Dios",
 "Yo soy Dios, el Dios de tu padre; no temas de descender a Egipto, porque yo te pondré allí en gran gente. Yo descenderé contigo a Egipto, y yo también te volveré: y José pondrá su mano sobre tus ojos.",
 "Jacob (Israel), ya anciano", ["Jacob", "Israel", "José"],
 "Hubo una gran hambruna en Canaán. José, el hijo que Jacob creía muerto, estaba vivo y gobernaba Egipto.",
 "Jacob, con 130 años, debía dejar la tierra prometida y mudarse a un país extranjero con toda su familia. Estaba lleno de emoción, pero también de temor.",
 "El miedo a los grandes cambios en la vejez y la tristeza de años de duelo.",
 "Dios tranquiliza a Jacob: Egipto no sería el fin de la promesa, sino el lugar donde su familia se convertiría en nación. Y le da un consuelo tierno: José, el hijo que lloró por años, estaría a su lado al final de su vida.",
 "Si hoy estás enfrentando un cambio grande que te asusta —mudanza, jubilación, una nueva etapa—, escucha: Dios desciende contigo. Lo que parece un destierro puede ser el lugar donde Él te multiplique. Ve con Él.",
 "Señor, este cambio me da miedo. Hoy renuncio al temor de lo desconocido. Tú desciendes conmigo y me harás volver. Consuela mis duelos antiguos y guíame en esta nueva etapa. Amén.",
 ["miedo", "tristeza"], ["cambios", "vejez", "familia", "providencia"], ["miedo al cambio", "duelo", "tristeza"])

# ---------------------------------------------------------------- MOISÉS
add("exo-3-7", "moises", "Éxodo 3:7-8", "Éxodo", "Yavé",
 "Bien he visto la aflicción de mi pueblo que está en Egipto, y he oído su clamor a causa de sus exactores; pues tengo conocidas sus angustias: y he descendido para librarlos de mano de los egipcios.",
 "Moisés, ante la zarza ardiente", ["Moisés"],
 "Hacia el siglo XV a. C. Los descendientes de Jacob llevaban unos 400 años en Egipto y habían sido reducidos a esclavitud.",
 "Moisés, que había huido de Egipto cuarenta años antes, pastoreaba ovejas en el desierto de Madián cuando vio una zarza que ardía sin consumirse.",
 "La opresión, el sufrimiento prolongado y la sensación de que Dios no escucha.",
 "Dios usa cuatro verbos llenos de ternura: he visto, he oído, conozco y he descendido. El sufrimiento de su pueblo no le era indiferente. Dios no solo se compadece: actúa para liberar.",
 "Si hoy estás enfrentando una situación de opresión o dolor que parece no terminar, recuerda que Dios ve, oye y conoce tus angustias. Clama a Él con sinceridad; tu clamor no se pierde en el aire.",
 "Señor, tú ves mi aflicción y oyes mi clamor. Hoy renuncio a pensar que no te importa lo que sufro. Desciende a mi situación y líbrame. Confío en que tú conoces mis angustias. Amén.",
 ["tristeza", "esperanza"], ["liberación", "compasión de Dios", "sufrimiento", "clamor"], ["opresión", "sufrimiento", "desesperanza"])

add("exo-3-14", "moises", "Éxodo 3:14", "Éxodo", "Yavé",
 "YO SOY EL QUE SOY… Así dirás a los hijos de Israel: YO SOY me ha enviado a vosotros.",
 "Moisés", ["Moisés"],
 "En la zarza ardiente, Dios envía a Moisés a liberar a Israel. Moisés pregunta qué nombre debe decir si el pueblo le pregunta quién lo envía.",
 "Moisés se sentía inseguro y temía que nadie le creyera. Necesitaba saber quién respaldaba su misión.",
 "La inseguridad y la necesidad de un fundamento firme en medio de la incertidumbre.",
 "Dios revela su nombre: «YO SOY». De esa expresión viene el nombre Yavé. Significa que Dios existe por sí mismo, que no cambia y que siempre está presente. La misión de Moisés no se apoyaba en su capacidad, sino en quién era Dios.",
 "Si hoy estás enfrentando inseguridad sobre tu futuro o tu capacidad, apóyate en el nombre de Dios. Él es el que es: fiel, presente y suficiente. Completa esta frase delante de Él: «Tú eres… lo que yo necesito hoy».",
 "Yavé, tú eres el que eres. Hoy renuncio a apoyarme en mis fuerzas. Tú me envías y me respaldas. Sé tú mi fundamento cuando todo lo demás tiembla. Amén.",
 ["fe"], ["nombre de Dios", "identidad de Dios", "llamado", "Yavé"], ["inseguridad", "duda", "incertidumbre"])

add("exo-4-11", "moises", "Éxodo 4:11-12", "Éxodo", "Yavé",
 "¿Quién dio la boca al hombre? ¿o quién hizo al mudo y al sordo, al que ve y al ciego? ¿no soy yo Yavé? Ahora pues, ve, que yo seré en tu boca, y te enseñaré lo que hayas de hablar.",
 "Moisés", ["Moisés", "Aarón"],
 "Continúa el diálogo en la zarza. Dios ya le ha dado a Moisés señales milagrosas para que el pueblo le crea.",
 "Moisés sigue poniendo excusas: dice que no es hombre de palabras, que es «tardo en el habla y torpe de lengua».",
 "La sensación de incapacidad, el complejo de inferioridad y las excusas que nacen del miedo.",
 "Dios no niega la debilidad de Moisés, pero le recuerda quién lo creó. El mismo que hizo su boca estaría en ella. Dios no llama a los capacitados; capacita a los que llama.",
 "Si hoy estás enfrentando un reto para el que te sientes incapaz —hablar, liderar, empezar algo nuevo—, deja de enumerar tus limitaciones. Preséntalas a Dios y pídele que esté en tu boca y en tus manos. Luego da el paso.",
 "Señor, tú me hiciste y conoces mis debilidades. Hoy renuncio a las excusas y al complejo de incapacidad. Sé tú en mi boca y enséñame lo que debo decir y hacer. Amén.",
 ["miedo", "fe"], ["llamado", "capacitación", "debilidad", "propósito"], ["inseguridad", "complejo de inferioridad", "miedo a hablar"])

add("exo-14-15", "moises", "Éxodo 14:15", "Éxodo", "Yavé",
 "¿Por qué clamas a mí? Di a los hijos de Israel que marchen.",
 "Moisés, frente al mar Rojo", ["Moisés"],
 "Tras diez plagas, el faraón dejó salir a Israel. Pero luego cambió de opinión y persiguió al pueblo con su ejército.",
 "Israel quedó atrapado entre el mar y los carros egipcios. El pueblo gritaba aterrado y Moisés clamaba a Dios.",
 "El pánico que paraliza cuando parece que no hay salida.",
 "Hay momentos para clamar y momentos para avanzar. Dios le dice a Moisés que es hora de moverse: Él abriría el mar. La fe no es quedarse quieto esperando, sino caminar hacia donde Dios indica, aunque todavía no se vea el camino.",
 "Si hoy estás enfrentando una situación sin salida aparente, ora, pero también pregunta a Dios cuál es tu siguiente paso. A veces el mar se abre cuando empiezas a caminar. Identifica una acción concreta de fe y hazla hoy.",
 "Señor, estoy entre el mar y el enemigo. Hoy renuncio al pánico que me paraliza. Dame valor para marchar cuando tú lo dices, confiando en que abrirás camino donde no lo hay. Amén.",
 ["fe", "miedo"], ["milagros", "liberación", "acción", "fe"], ["pánico", "parálisis", "miedo"])

add("exo-20-2", "moises", "Éxodo 20:2-3", "Éxodo", "Yavé",
 "Yo soy Yavé tu Dios, que te saqué de la tierra de Egipto, de casa de siervos. No tendrás dioses ajenos delante de mí.",
 "Todo el pueblo de Israel, al pie del monte Sinaí", ["Moisés", "Israel"],
 "Tres meses después de salir de Egipto, Israel acampa frente al monte Sinaí. Dios desciende con truenos, fuego y humo para hablar con su pueblo.",
 "El pueblo, recién liberado, necesitaba aprender a vivir como pueblo libre. Dios les da los Diez Mandamientos.",
 "La idolatría y la tendencia a poner la confianza en cualquier cosa menos en Dios.",
 "Antes de dar un solo mandamiento, Dios recuerda lo que ya hizo: «te saqué». Los mandamientos no son el precio para ganarse su amor, sino la respuesta a su liberación. El primero es el fundamento de todos: que nada ocupe el lugar de Dios.",
 "Si hoy estás enfrentando una vida dispersa, donde el dinero, el trabajo, una persona o una adicción ocupan el centro, escucha este mandamiento como una invitación a la libertad. Pregúntate qué ocupa el lugar de Dios y entrégaselo.",
 "Yavé, tú me sacaste de mi esclavitud. Hoy renuncio a todo ídolo que he puesto en tu lugar. Ocupa el centro de mi corazón. Quiero vivir como alguien que ha sido liberado. Amén.",
 ["obediencia", "amor"], ["mandamientos", "idolatría", "libertad", "ley"], ["idolatría", "adicción", "desobediencia"])

add("exo-33-14", "moises", "Éxodo 33:14", "Éxodo", "Yavé",
 "Mi rostro irá contigo, y te haré descansar.",
 "Moisés", ["Moisés"],
 "Después del pecado del becerro de oro, Dios había dicho que enviaría un ángel delante del pueblo, pero que Él no iría en medio de ellos.",
 "Moisés intercede y le dice a Dios que no quiere avanzar sin su presencia. Estaba cansado de guiar a un pueblo rebelde.",
 "El agotamiento del liderazgo y la ansiedad de avanzar sin la presencia de Dios.",
 "Dios responde a la súplica de Moisés con dos regalos: su presencia y su descanso. Moisés entendió que lo más importante no era llegar a la tierra prometida, sino ir con Dios.",
 "Si hoy estás enfrentando agotamiento o ansiedad por todo lo que tienes que llevar, recuerda que el descanso verdadero no es la ausencia de tareas, sino la presencia de Dios en ellas. Antes de empezar tu día, pídele: «que tu rostro vaya conmigo».",
 "Señor, no quiero dar un paso sin ti. Hoy renuncio a la ansiedad y al cansancio de cargar todo solo. Que tu rostro vaya conmigo y hazme descansar. Amén.",
 ["ansiedad", "soledad"], ["presencia de Dios", "descanso", "liderazgo"], ["ansiedad", "agotamiento", "estrés"])

add("exo-34-6", "moises", "Éxodo 34:6-7", "Éxodo", "Yavé",
 "¡Yavé, Yavé, fuerte, misericordioso, y piadoso; tardo para la ira, y grande en benignidad y verdad; que guarda la misericordia en millares, que perdona la iniquidad, la rebelión, y el pecado!",
 "Moisés, en el monte Sinaí", ["Moisés"],
 "Moisés había roto las primeras tablas de la ley al ver la idolatría del pueblo. Dios lo llama de nuevo al monte para renovar el pacto.",
 "Moisés le había pedido: «Muéstrame tu gloria». Dios pasa delante de él y proclama su propio nombre y carácter.",
 "La culpa de un pueblo que había traicionado a Dios y el temor de que Él los rechazara para siempre.",
 "Cuando Dios describe quién es, lo primero que dice es: misericordioso, piadoso, lento para enojarse, lleno de amor fiel y dispuesto a perdonar. Después del peor pecado del pueblo, Dios revela su corazón perdonador.",
 "Si hoy estás enfrentando la culpa de haber fallado de nuevo, lee despacio esta descripción de Dios. Él no es como tu culpa te lo pinta. Acércate a Él tal como es: misericordioso y perdonador.",
 "Yavé, tú eres misericordioso y lento para la ira. Hoy renuncio a la imagen de un Dios que solo espera castigarme. Perdona mi rebelión y mi pecado. Gracias porque tu amor es más grande que mi falta. Amén.",
 ["perdon", "culpa", "amor"], ["carácter de Dios", "misericordia", "perdón", "gloria"], ["culpa", "miedo al castigo", "vergüenza"])

add("lev-19-18", "moises", "Levítico 19:18", "Levítico", "Yavé",
 "No te vengarás, ni guardarás rencor a los hijos de tu pueblo: mas amarás a tu prójimo como a ti mismo: Yo Yavé.",
 "Moisés, para todo Israel", ["Moisés", "Israel"],
 "En el desierto del Sinaí, Dios da a su pueblo leyes para vivir en santidad en la vida diaria: en el trabajo, en la familia y con los vecinos.",
 "Israel era un pueblo numeroso que convivía en campamentos. Los conflictos, las ofensas y los deseos de venganza eran parte de la vida cotidiana.",
 "La venganza y el rencor que destruyen la convivencia.",
 "Dios une dos cosas: dejar el rencor y amar al prójimo. Jesús citaría este mandamiento como el segundo más importante de toda la ley. Y lo firma con su nombre, «Yo Yavé», porque amar así refleja su propio carácter.",
 "Si hoy estás enfrentando rencor hacia alguien que te hizo daño, no alimentes la venganza en tu mente. Decide delante de Dios soltar la deuda y busca una forma concreta de desearle el bien, aunque sea en oración.",
 "Señor, tú conoces el rencor que guardo. Hoy renuncio a la venganza. Enséñame a amar a mi prójimo como a mí mismo, como tú me amas a mí. Amén.",
 ["amor", "perdon"], ["amor al prójimo", "rencor", "santidad", "convivencia"], ["rencor", "venganza", "resentimiento"])

add("num-6-24", "moises", "Números 6:24-26", "Números", "Yavé",
 "Yavé te bendiga, y te guarde: haga resplandecer Yavé su rostro sobre ti, y haya de ti misericordia: Yavé alce a ti su rostro, y ponga en ti paz.",
 "Aarón y sus hijos, los sacerdotes, para bendecir a Israel", ["Aarón", "Moisés"],
 "En el desierto, Dios organiza la vida del pueblo alrededor del tabernáculo. Los sacerdotes eran los encargados de bendecir al pueblo.",
 "Israel estaba a punto de emprender un largo camino por el desierto. Dios mismo dicta las palabras exactas con que quiere bendecirlos.",
 "La inquietud y la falta de paz en medio de un camino incierto.",
 "Es Dios quien redacta su propia bendición. Quiere que su pueblo escuche que Él los guarda, que su rostro brilla sobre ellos con favor, que los mira con misericordia y que les da paz. Dios desea bendecir.",
 "Si hoy estás enfrentando inquietud o te cuesta sentir paz, lee esta bendición en voz alta, poniendo tu nombre. Pronúnciala también sobre las personas que amas. Dios quiere que vivas bajo la luz de su rostro.",
 "Yavé, bendíceme y guárdame. Haz resplandecer tu rostro sobre mí y ten misericordia de mí. Alza tu rostro hacia mí y pon en mí tu paz. Hoy renuncio a la inquietud y recibo tu bendición. Amén.",
 ["esperanza", "ansiedad"], ["bendición", "paz", "protección", "rostro de Dios"], ["ansiedad", "inquietud", "falta de paz"])

# ---------------------------------------------------------------- JOSUÉ
add("jos-1-9", "josue", "Josué 1:9", "Josué", "Yavé",
 "Mira que te mando que te esfuerces y seas valiente: no temas ni desmayes, porque Yavé tu Dios será contigo en donde quiera que fueres.",
 "Josué", ["Josué"],
 "Moisés acababa de morir. Tras cuarenta años en el desierto, Israel estaba a las puertas de la tierra prometida, al otro lado del río Jordán.",
 "Josué debía reemplazar al gran líder Moisés y conducir a todo un pueblo a conquistar una tierra con ciudades amuralladas.",
 "El miedo y el desánimo ante una responsabilidad enorme.",
 "Dios repite tres veces a Josué «esfuérzate y sé valiente». La valentía que Dios pide no se basa en la fuerza de Josué, sino en una promesa: «Yavé tu Dios será contigo». El valor nace de la compañía de Dios.",
 "Si hoy estás enfrentando una responsabilidad que te supera —un nuevo trabajo, cuidar a alguien, liderar—, escucha esta orden como una promesa. No tienes que sentirte valiente para actuar con valentía. Dios va contigo a cada lugar al que vayas hoy.",
 "Señor, esta tarea me queda grande. Hoy renuncio al miedo y al desánimo. Tú me mandas ser valiente porque vas conmigo. Esfuérzame y acompáñame a dondequiera que vaya. Amén.",
 ["miedo", "fe"], ["valentía", "liderazgo", "presencia de Dios"], ["miedo", "desánimo", "responsabilidad"])

add("jue-6-14", "josue", "Jueces 6:14, 16", "Jueces", "Yavé",
 "Ve con esta tu fortaleza, y salvarás a Israel de la mano de los madianitas. ¿No te envío yo?… Porque yo seré contigo, y herirás a los madianitas como a un solo hombre.",
 "Gedeón", ["Gedeón"],
 "Época de los jueces, después de Josué. Israel caía una y otra vez en idolatría y sufría la opresión de pueblos vecinos.",
 "Los madianitas saqueaban las cosechas de Israel desde hacía siete años. Gedeón trillaba trigo escondido en un lagar, por miedo.",
 "El miedo, la baja autoestima y la sensación de ser el menos capaz.",
 "El ángel de Yavé saluda a Gedeón como «varón esforzado» mientras está escondido. Gedeón responde que su familia es la más pobre y él el menor. Dios no discute: le dice que vaya con la fuerza que tiene, porque Él lo envía y estará con él.",
 "Si hoy estás enfrentando la sensación de ser demasiado pequeño o débil, recuerda que Dios te ve de manera distinta a como te ves tú. Ofrécele «esta tu fortaleza», la poca que tengas, y confía en que Él pondrá el resto.",
 "Señor, me siento pequeño y sin fuerzas. Hoy renuncio a la mentira de que no sirvo. Tomo lo poco que tengo y te lo entrego. Envíame tú, y ve conmigo. Amén.",
 ["fe", "miedo"], ["llamado", "autoestima", "valentía", "propósito"], ["miedo", "baja autoestima", "inseguridad"])
