"""Genera assets/data/biblia_rv1909.json: la Biblia completa para leer sin conexión.

Los 66 libros de la Reina-Valera 1909 (dominio público) con ortografía
actualizada y el nombre «Jehová», el que conocen las iglesias de Puerto Rico.

Formato: {"books": [{"id", "name", "abbr", "testament": "AT"|"NT",
                     "chapters": [["v1", "v2", …], …]}]}

Uso:
  python3 tool/boricua/build_biblia.py
"""
import csv
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(ROOT / 'tool' / 'corpus'))

from extract import SOURCE, fix_caps, modernize  # noqa: E402

OUT = ROOT / 'assets' / 'data' / 'biblia_rv1909.json'

# Nombre en la fuente → (id, nombre, abreviatura)
BOOKS = [
    ('Genesis', 'gen', 'Génesis', 'Gn'), ('Exodus', 'exo', 'Éxodo', 'Éx'),
    ('Leviticus', 'lev', 'Levítico', 'Lv'), ('Numbers', 'num', 'Números', 'Nm'),
    ('Deuteronomy', 'deu', 'Deuteronomio', 'Dt'), ('Joshua', 'jos', 'Josué', 'Jos'),
    ('Judges', 'jue', 'Jueces', 'Jue'), ('Ruth', 'rut', 'Rut', 'Rt'),
    ('I Samuel', '1sa', '1 Samuel', '1 S'), ('II Samuel', '2sa', '2 Samuel', '2 S'),
    ('I Kings', '1re', '1 Reyes', '1 R'), ('II Kings', '2re', '2 Reyes', '2 R'),
    ('I Chronicles', '1cr', '1 Crónicas', '1 Cr'), ('II Chronicles', '2cr', '2 Crónicas', '2 Cr'),
    ('Ezra', 'esd', 'Esdras', 'Esd'), ('Nehemiah', 'neh', 'Nehemías', 'Neh'),
    ('Esther', 'est', 'Ester', 'Est'), ('Job', 'job', 'Job', 'Job'),
    ('Psalms', 'sal', 'Salmos', 'Sal'), ('Proverbs', 'pro', 'Proverbios', 'Pr'),
    ('Ecclesiastes', 'ecl', 'Eclesiastés', 'Ec'), ('Song of Solomon', 'can', 'Cantar de los Cantares', 'Cnt'),
    ('Isaiah', 'isa', 'Isaías', 'Is'), ('Jeremiah', 'jer', 'Jeremías', 'Jer'),
    ('Lamentations', 'lam', 'Lamentaciones', 'Lm'), ('Ezekiel', 'eze', 'Ezequiel', 'Ez'),
    ('Daniel', 'dan', 'Daniel', 'Dn'), ('Hosea', 'ose', 'Oseas', 'Os'), ('Joel', 'joe', 'Joel', 'Jl'),
    ('Amos', 'amo', 'Amós', 'Am'), ('Obadiah', 'abd', 'Abdías', 'Abd'), ('Jonah', 'jon', 'Jonás', 'Jon'),
    ('Micah', 'miq', 'Miqueas', 'Miq'), ('Nahum', 'nah', 'Nahúm', 'Nah'),
    ('Habakkuk', 'hab', 'Habacuc', 'Hab'), ('Zephaniah', 'sof', 'Sofonías', 'Sof'),
    ('Haggai', 'hag', 'Hageo', 'Hag'), ('Zechariah', 'zac', 'Zacarías', 'Zac'),
    ('Malachi', 'mal', 'Malaquías', 'Mal'),
    ('Matthew', 'mat', 'Mateo', 'Mt'), ('Mark', 'mar', 'Marcos', 'Mr'), ('Luke', 'luc', 'Lucas', 'Lc'),
    ('John', 'jua', 'Juan', 'Jn'), ('Acts', 'hch', 'Hechos', 'Hch'), ('Romans', 'rom', 'Romanos', 'Ro'),
    ('I Corinthians', '1co', '1 Corintios', '1 Co'), ('II Corinthians', '2co', '2 Corintios', '2 Co'),
    ('Galatians', 'gal', 'Gálatas', 'Gá'), ('Ephesians', 'efe', 'Efesios', 'Ef'),
    ('Philippians', 'fil', 'Filipenses', 'Fil'), ('Colossians', 'col', 'Colosenses', 'Col'),
    ('I Thessalonians', '1ts', '1 Tesalonicenses', '1 Ts'), ('II Thessalonians', '2ts', '2 Tesalonicenses', '2 Ts'),
    ('I Timothy', '1ti', '1 Timoteo', '1 Ti'), ('II Timothy', '2ti', '2 Timoteo', '2 Ti'),
    ('Titus', 'tit', 'Tito', 'Tit'), ('Philemon', 'flm', 'Filemón', 'Flm'), ('Hebrews', 'heb', 'Hebreos', 'He'),
    ('James', 'stg', 'Santiago', 'Stg'), ('I Peter', '1pe', '1 Pedro', '1 P'), ('II Peter', '2pe', '2 Pedro', '2 P'),
    ('I John', '1jn', '1 Juan', '1 Jn'), ('II John', '2jn', '2 Juan', '2 Jn'), ('III John', '3jn', '3 Juan', '3 Jn'),
    ('Jude', 'jud', 'Judas', 'Jud'), ('Revelation of John', 'apo', 'Apocalipsis', 'Ap'),
]
NT_START = 'Matthew'


# «Salmo de David. jehová es…» → «Salmo de David. Jehová es…»: tras el título
# del salmo empieza la oración con mayúscula.
PSALM_TITLE = re.compile(r'^((?:Salmo|Al Músico|Cántico|Masquil|Mictam|Oración|Michtam)[^.]*\.)\s+([¿¡]?)(\w)')


def capitalize_after_title(text: str) -> str:
    return PSALM_TITLE.sub(lambda m: f'{m.group(1)} {m.group(2)}{m.group(3).upper()}', text)


def jehova(text: str) -> str:
    return text.replace('YAVÉ', 'JEHOVÁ').replace('Yavé', 'Jehová')


def load():
    """(libro, capítulo, versículo) → texto."""
    verses = {}
    with SOURCE.open(encoding='utf-8') as f:
        for r in csv.DictReader(f):
            text = jehova(modernize(fix_caps(r['Text'], r['Verse'])))
            if r['Book'] == 'Psalms' and r['Verse'] == '1':
                text = capitalize_after_title(text)
            verses[(r['Book'], int(r['Chapter']), int(r['Verse']))] = text
    return verses


def main():
    verses = load()
    books = []
    testament = 'AT'
    for source, bid, name, abbr in BOOKS:
        if source == NT_START:
            testament = 'NT'
        chapters = []
        ch = 1
        while (source, ch, 1) in verses:
            chapter = []
            v = 1
            while (source, ch, v) in verses:
                chapter.append(verses[(source, ch, v)])
                v += 1
            chapters.append(chapter)
            ch += 1
        assert chapters, source
        books.append(dict(id=bid, name=name, abbr=abbr, testament=testament, chapters=chapters))
    total = sum(len(c) for b in books for c in b['chapters'])
    assert len(books) == 66, len(books)
    OUT.write_text(json.dumps({'translation': 'Reina-Valera 1909', 'books': books},
                              ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    print(f'{len(books)} libros, {sum(len(b["chapters"]) for b in books)} capítulos, '
          f'{total} versículos; {OUT.stat().st_size // 1024} KB')


if __name__ == '__main__':
    main()
