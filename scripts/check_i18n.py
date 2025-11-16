#!/usr/bin/env python3
import os, re, json

ROOT = '.'
LOCALES_DIR = 'assets/translations'
TR_RE = re.compile(r"['\"]([a-z0-9_.]+)['\"]\.tr\(")


def find_tr_keys():
    keys = set()
    for dirpath, dirnames, filenames in os.walk('lib'):
        for f in filenames:
            if f.endswith('.dart'):
                path = os.path.join(dirpath, f)
                with open(path, 'r', encoding='utf-8') as fh:
                    content = fh.read()
                for m in TR_RE.finditer(content):
                    keys.add(m.group(1))
    return sorted(keys)


def load_json(lang):
    p = os.path.join(LOCALES_DIR, f'{lang}.json')
    if not os.path.exists(p):
        return {}
    with open(p, 'r', encoding='utf-8') as fh:
        return json.load(fh)


def has_key(data, dotted):
    node = data
    for part in dotted.split('.'):
        if isinstance(node, dict) and part in node:
            node = node[part]
        else:
            return False
    return True


def main():
    keys = find_tr_keys()
    en = load_json('en')
    vi = load_json('vi')
    missing_en = []
    missing_vi = []
    for k in keys:
        if not has_key(en, k):
            missing_en.append(k)
        if not has_key(vi, k):
            missing_vi.append(k)

    print('Found .tr() keys: ', len(keys))
    print('\nMissing in en.json: ', len(missing_en))
    for k in missing_en:
        print('  -', k)

    print('\nMissing in vi.json: ', len(missing_vi))
    for k in missing_vi:
        print('  -', k)


if __name__ == '__main__':
    main()
