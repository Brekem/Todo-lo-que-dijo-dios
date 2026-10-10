"""Versículos con palabras de Jesús (las «letras rojas» de la World English Bible).

La RV1909 no marca quién habla; la WEB (dominio público) sí, con <wj>. De ahí
sale, por versículo, cuánto dice Jesús y si hay narración antes o después.

Uso (una vez; el resultado se guarda en tool/jesus/red_letters.json):
  git clone --depth 1 https://github.com/seven1m/open-bibles /tmp/open-bibles
  python3 tool/jesus/red_letters.py /tmp/open-bibles/eng-web.usfx.xml
"""
import json
import re
import sys
from pathlib import Path

BOOKS = {'MAT': 'Matthew', 'MRK': 'Mark', 'LUK': 'Luke', 'JHN': 'John', 'ACT': 'Acts',
         '1CO': 'I Corinthians', '2CO': 'II Corinthians', 'REV': 'Revelation of John'}
OUT = Path(__file__).with_name('red_letters.json')

TOKEN = re.compile(r'<(/?)(\w+)([^>]*?)(/?)>|([^<]+)')


def main(path):
    xml = Path(path).read_text(encoding='utf-8')
    out = {}
    for m in re.finditer(r'<book id="(\w+)">(.*?)</book>', xml, re.S):
        if m.group(1) not in BOOKS:
            continue
        book = BOOKS[m.group(1)]
        chapter = verse = 0
        wj = skip = 0
        para = True
        cur = None
        for t in TOKEN.finditer(m.group(2)):
            close, tag, attrs, selfclose, text = t.groups()
            if text is not None:
                if cur is not None and not skip:
                    words = re.sub(r'\s+', ' ', text)
                    cur['parts'].append([words, bool(wj)])
                continue
            if tag in ('f', 'x') and not selfclose:
                skip += -1 if close else 1
            elif tag == 'wj':
                wj += -1 if close else 1
            elif tag == 'c' and selfclose:
                chapter = int(re.search(r'id="(\d+)"', attrs).group(1))
                para = True
            elif tag == 'p' and not close:
                para = True
            elif tag == 'v' and selfclose:
                verse = int(re.search(r'id="(\d+)"', attrs).group(1))
                cur = {'parts': [], 'p': para}
                para = False
                out.setdefault(book, {}).setdefault(str(chapter), {})[str(verse)] = cur
            elif tag == 've':
                cur = None
    result = {}
    for book, chapters in out.items():
        for ch, verses in chapters.items():
            for v, d in verses.items():
                runs = []
                for words, j in d['parts']:
                    if runs and runs[-1][1] == j:
                        runs[-1][0] += words
                    else:
                        runs.append([words, j])
                runs = [[w.strip(), j] for w, j in runs if re.search(r'\w', w)]
                said = sum(len(w) for w, j in runs if j)
                if not said:
                    continue
                total = sum(len(w) for w, _ in runs)
                # Tramos [hasta qué fracción del versículo, habla Jesús].
                spans, at = [], 0
                for w, j in runs:
                    at += len(w)
                    spans.append([round(at / total, 3), int(j)])
                result.setdefault(book, {}).setdefault(ch, {})[v] = {
                    'share': round(said / total, 2), 'runs': spans,
                }
            # Párrafos de los versículos sin palabras de Jesús también sirven
            # para cortar: se guardan aparte.
            paras = [int(v) for v, d in verses.items() if d['p']]
            result.setdefault(book, {}).setdefault(ch, {})['_p'] = paras
    OUT.write_text(json.dumps(result, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    n = sum(len([k for k in c if k != '_p']) for b in result.values() for c in b.values())
    print(f'{n} versículos con palabras de Jesús → {OUT}')


if __name__ == '__main__':
    main(sys.argv[1])
