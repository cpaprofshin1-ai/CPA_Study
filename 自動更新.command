#!/bin/bash
cd "$(dirname "$0")"

# 全角半角の自動修正＆目次（index.html）の作成
python3 _build_index.py

# サーバーへ自動アップロード
git add .
git commit -m "Auto Update"
git push
