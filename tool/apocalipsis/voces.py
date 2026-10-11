"""Quién habla en cada versículo del Apocalipsis.

La WEB (dominio público) pone entre comillas lo que dicen Jesús, Dios, los
ángeles y las voces del cielo; lo demás lo cuenta Juan. De ahí sale, por
versículo, qué parte es voz y qué parte narración, para separarlo en la RV1909.

Uso (una vez; el resultado se guarda en tool/apocalipsis/voces.json):
  git clone --depth 1 https://github.com/seven1m/open-bibles /tmp/open-bibles
  python3 tool/apocalipsis/voces.py /tmp/open-bibles/eng-web.usfx.xml
"""
import json
import re
import sys
from pathlib import Path

OUT = Path(__file__).with_name('voces.json')
TOKEN = re.compile(r'<(/?)(\w+)([^>]*?)(/?)>|([^<]+)')


def main(path):
    xml = Path(path).read_text(encoding='utf-8')
    book = re.search(r'<book id="REV">(.*?)</book>', xml, re.S).group(1)
    verses = {}
    chapter = 0
    cur = None
    skip = 0
    quoted = False
    for t in TOKEN.finditer(book):
        close, tag, attrs, selfclose, text = t.groups()
        if text is not None:
            if cur is None or skip:
                continue
            for ch in text:
                if ch == '“':
                    quoted = True
                    continue
                if ch == '”':
                    cur.append([' ', quoted])
                    quoted = False
                    continue
                cur.append([ch, quoted])
            continue
        if tag in ('f', 'x') and not selfclose:
            skip += -1 if close else 1
        elif tag == 'c' and selfclose:
            chapter = int(re.search(r'id="(\d+)"', attrs).group(1))
            quoted = False
        elif tag == 'v' and selfclose:
            cur = []
            verse = re.search(r'id="(\d+)"', attrs).group(1)
            verses[f'{chapter}:{verse}'] = cur
        elif tag == 've':
            cur = None
    out = {}
    for ref, chars in verses.items():
        runs = []
        for c, q in chars:
            if runs and runs[-1][1] == q:
                runs[-1][0] += c
            else:
                runs.append([c, q])
        runs = [[re.sub(r'\s+', ' ', w).strip(), q] for w, q in runs]
        runs = [r for r in runs if re.search(r'\w', r[0])]
        total = sum(len(w) for w, _ in runs) or 1
        spans, at = [], 0
        for w, q in runs:
            at += len(w)
            spans.append([round(at / total, 3), int(q)])
        if spans:
            spans[-1][0] = 1.0
        out[ref] = spans
    OUT.write_text(json.dumps(out, separators=(',', ':')), encoding='utf-8')
    print(f'{len(out)} versículos; {sum(any(q for _, q in r) for r in out.values())} con voces → {OUT}')


if __name__ == '__main__':
    main(sys.argv[1])
