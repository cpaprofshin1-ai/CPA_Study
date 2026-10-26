# 目次（index.html）を作る。科目フォルダ → （あれば）章・単元フォルダ → 問題ファイル
import os, re, unicodedata, html as H

# ファイル名とフォルダ名の全角英数字を半角に直す
for root, dirs, files in os.walk(".", topdown=False):
    for name in files + dirs:
        if name.startswith(".") or name == "node_modules": continue
        if name in files and not name.endswith(".html"): continue
        new = unicodedata.normalize("NFKC", name)
        if new != name: os.rename(os.path.join(root, name), os.path.join(root, new))

def keys(t):
    t = unicodedata.normalize("NFKC", t)
    return [int(c) if c.isdigit() else c for c in re.split(r"(\d+)", t)]
def label(name):  # 表示名：並べ替え用の「01_」と「_短答QA」を外す
    name = re.sub(r"\.html$", "", name)
    name = re.sub(r"^\d+_", "", name)
    return re.sub(r"_短答QA$", "", name)

out = ["""<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>短答対策 Web問題集</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif; padding: 20px; background-color: #f5f7f9; }
        .container { max-width: 900px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        h1 { font-size: 1.8em; border-bottom: 3px solid #3498db; padding-bottom: 10px; color: #2c3e50; margin-bottom: 30px;}
        .subject-title { font-size: 1.4em; color: #3498db; border-bottom: 2px solid #e2e8f0; padding-bottom: 8px; margin-top: 40px; margin-bottom: 20px; font-weight: bold; }
        .section-list { list-style: none; padding-left: 25px; margin: 0 0 10px 0; }
        /* 章・単元（押すと中の節・章が開く）。見た目は章のリンクと同じ枠 */
        details.group { margin: 0 0 10px 25px; }
        details.group > summary { list-style: none; cursor: pointer; color: #333; padding: 12px 15px; background: #f8fafc; border-radius: 8px; border: 1px solid #e2e8f0; border-left: 4px solid #3498db; transition: background 0.2s; }
        details.group > summary::-webkit-details-marker { display: none; }
        details.group > summary:hover { background: #e2e8f0; }
        details.group > summary::after { content: "＋"; float: right; color: #94a3b8; }
        details.group[open] > summary::after { content: "－"; }
        details.group > .section-list { margin-top: 10px; padding-left: 25px; }
        .section-list li { margin-bottom: 10px; }
        .section-list a { text-decoration: none; color: #333; display: block; padding: 12px 15px; background: #f8fafc; border-radius: 8px; border: 1px solid #e2e8f0; border-left: 4px solid #3498db; transition: background 0.2s; }
        .section-list a:hover { background: #e2e8f0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>短答対策 Web問題集</h1>
"""]
for subject in sorted(next(os.walk("."))[1], key=keys):
    if subject.startswith(".") or subject == "node_modules": continue
    out.append(f'<div class="subject-title">{H.escape(subject)}</div>\n')
    for root, dirs, files in os.walk(subject):
        dirs.sort(key=keys)
        fs = sorted([f for f in files if f.endswith(".html")], key=keys)
        if not fs: continue
        rel = os.path.relpath(root, subject)
        if rel != ".":
            out.append(f'<details class="group"><summary>{H.escape(label(rel.replace(os.sep, " ／ ")))}</summary>\n')
        out.append('<ul class="section-list">\n')
        for f in fs:
            out.append(f'<li><a href="{H.escape(os.path.join(root, f))}">{H.escape(label(f))}</a></li>\n')
        out.append('</ul>\n')
        if rel != ".": out.append('</details>\n')
out.append("</div></body></html>")
open("index.html", "w", encoding="utf-8").write("".join(out))
