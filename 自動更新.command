#!/bin/bash
cd "$(dirname "$0")"

# 全角半角の自動修正＆目次作成プログラム
python3 -c '
import os, re, unicodedata

# 【新機能】ファイル名とフォルダ名の全角数字を、自動で半角に一括リネームする
for root, dirs, files in os.walk(".", topdown=False):
    for name in files:
        if name.endswith(".html"):
            new_name = unicodedata.normalize("NFKC", name)
            if new_name != name:
                os.rename(os.path.join(root, name), os.path.join(root, new_name))
    for name in dirs:
        if not name.startswith(".") and name != "node_modules":
            new_name = unicodedata.normalize("NFKC", name)
            if new_name != name:
                os.rename(os.path.join(root, name), os.path.join(root, new_name))

# --- ここから下は先ほどと同じ目次作成の処理 ---
def natural_keys(text):
    norm_text = unicodedata.normalize("NFKC", text)
    return [int(c) if c.isdigit() else c for c in re.split(r"(\d+)", norm_text)]

html = """<!DOCTYPE html>
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
        
        /* 折りたたみのデザイン */
        details { margin-top: 15px; margin-bottom: 10px; }
        summary { font-size: 1.1em; color: #2c3e50; font-weight: bold; border-left: 4px solid #f39c12; padding-left: 10px; cursor: pointer; list-style: none; outline: none; }
        summary::-webkit-details-marker { display: none; }
        summary::before { content: "▶ "; color: #f39c12; font-size: 0.8em; vertical-align: middle; display: inline-block; transition: transform 0.2s; margin-right: 5px; }
        details[open] summary::before { transform: rotate(90deg); }
        
        .section-list { list-style: none; padding-left: 25px; margin: 15px 0 0 0; }
        .section-list li { margin-bottom: 10px; }
        .section-list a { text-decoration: none; color: #333; display: block; padding: 12px 15px; background: #f8fafc; border-radius: 8px; border: 1px solid #e2e8f0; border-left: 4px solid #3498db; transition: background 0.2s; }
        .section-list a:hover { background: #e2e8f0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>短答対策 Web問題集</h1>
"""

for subject in sorted(next(os.walk("."))[1], key=natural_keys):
    if subject.startswith(".") or subject == "node_modules": continue
    
    html += f"<div class=\"subject-title\">{subject}</div>\n"
    
    for root, dirs, files in os.walk(subject):
        dirs.sort(key=natural_keys)
        html_files = sorted([f for f in files if f.endswith(".html")], key=natural_keys)
        
        if html_files:
            rel_path = os.path.relpath(root, subject)
            
            if rel_path != ".":
                html += f"<details>\n<summary>{rel_path}</summary>\n"
            
            html += "<ul class=\"section-list\">\n"
            for f in html_files:
                path = os.path.join(root, f)
                name = f.replace(".html", "")
                html += f"<li><a href=\"{path}\">{name}</a></li>\n"
            html += "</ul>\n"
            
            if rel_path != ".":
                html += "</details>\n"

html += "</div></body></html>"

with open("index.html", "w", encoding="utf-8") as f:
    f.write(html)
'

# サーバーへ自動アップロード
git add .
git commit -m "Auto Update"
git push