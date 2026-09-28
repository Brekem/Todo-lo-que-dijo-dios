import json, sys

# Increméntala cada vez que publiques contenido nuevo en Firestore.
CONTENT_VERSION = 1
exec(open('part1.py').read()); exec(open('part2.py').read()); exec(open('part3.py').read())

eras = [
 ("adan", "Adán", "La creación y el principio", "El principio"),
 ("noe", "Noé", "El diluvio y el primer pacto", "Tiempos antiguos"),
 ("abraham", "Abraham", "El llamado y la promesa", "c. 2000 a. C."),
 ("isaac", "Isaac", "El hijo de la promesa", "c. 1900 a. C."),
 ("jacob", "Jacob", "De Betel a Egipto", "c. 1850 a. C."),
 ("moises", "Moisés", "Liberación y pacto en el Sinaí", "c. 1450 a. C."),
 ("josue", "Josué", "La tierra prometida y los jueces", "c. 1400–1100 a. C."),
 ("profetas", "Profetas", "Reyes, salmistas y profetas", "c. 1050–587 a. C."),
 ("israel", "Israel", "Exilio en Babilonia y regreso", "c. 597–430 a. C."),
 ("evangelios", "Evangelios", "Dios hecho hombre en Jesús", "c. 27–30 d. C."),
 ("iglesia", "La Iglesia", "El Resucitado guía a los apóstoles", "c. 34–56 d. C."),
 ("apocalipsis", "Apocalipsis", "La revelación final", "c. 95 d. C."),
]
cats = [
 ("miedo", "Dios libera el miedo", "Dios habla sobre el miedo", "Cuando el temor te paraliza, Dios dice «no temas» y te recuerda que Él está contigo.", "shield", "2F4A7A"),
 ("ansiedad", "Dios libera la ansiedad", "Dios habla sobre la ansiedad", "Palabras para aquietar la mente, soltar el mañana y descansar en su cuidado.", "spa", "3E5C8A"),
 ("culpa", "Dios libera la culpa", "Dios habla sobre la culpa", "Dios no te busca para condenarte, sino para limpiarte y darte una vida nueva.", "water_drop", "8E3B46"),
 ("tristeza", "Dios libera la tristeza", "Dios habla sobre la tristeza", "En el duelo, el agotamiento y las lágrimas, Dios consuela y promete hacer nuevas todas las cosas.", "sentiment", "5A6A8F"),
 ("soledad", "Dios libera la soledad", "Dios habla sobre la soledad", "Nunca estás solo: Dios promete estar contigo todos los días.", "group", "6B5A86"),
 ("fe", "Dios fortalece la fe", "Dios habla sobre la fe", "Promesas que parecen imposibles y un Dios para quien nada es difícil.", "anchor", "B08A3E"),
 ("obediencia", "Dios enseña obediencia", "Dios habla sobre la obediencia", "Llamados a salir, a caminar y a confiar cuando Dios dice «ve».", "route", "7A6A3A"),
 ("amor", "Dios enseña amor", "Dios habla sobre el amor", "Un amor eterno que te busca, te llama por tu nombre y te enseña a amar.", "favorite", "A3424C"),
 ("perdon", "Dios enseña perdón", "Dios habla sobre el perdón", "Dios borra, olvida y restaura; y te enseña a soltar las deudas de otros.", "handshake", "9A6A3A"),
 ("esperanza", "Dios enseña esperanza", "Dios habla sobre la esperanza", "Pensamientos de paz, caminos en el desierto y una historia que termina bien.", "sunny", "C29B45"),
]
era_ids = [e[0] for e in eras]
cat_ids = [c[0] for c in cats]
# Orden cronológico: por etapa y, dentro de ella, en el orden en que se escribieron.
ordered = sorted(P, key=lambda p: era_ids.index(p['era']))  # sort estable
ids = set()
for i, p in enumerate(ordered, 1):
    p['order'] = i
    assert p['id'] not in ids, p['id']; ids.add(p['id'])
    for c in p['categories']: assert c in cat_ids, (p['id'], c)
    assert p['application'].startswith('Si hoy estás enfrentando'), p['id']
    assert p['prayer'].rstrip().endswith('Amén.'), p['id']
out = {
 "version": CONTENT_VERSION,
 "translation": "Reina-Valera 1909 (dominio público), heredera de la Biblia del Oso de Casiodoro de Reina (1569), con ortografía actualizada y el nombre divino «Yavé».",
 "eras": [dict(id=a, title=b, subtitle=c, period=d) for a, b, c, d in eras],
 "categories": [dict(id=a, title=b, headline=c, description=d, icon=e, color="FF"+f) for a, b, c, d, e, f in cats],
 "passages": [{k: p[k] for k in ["id","order","era","reference","book","speaker","quote","recipient","people","historicalContext","situation","problem","explanation","application","prayer","categories","topics","problems"]} for p in ordered],
}
json.dump(out, open(sys.argv[1], 'w'), ensure_ascii=False, indent=1)
from collections import Counter
print(len(ordered), Counter(c for p in ordered for c in p['categories']))
