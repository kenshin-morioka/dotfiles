#!/bin/bash
# SessionStart hook: ~/.claude/settings.json は dotfiles/claude/settings.json への
# シンボリックリンクである想定だが、Claude Code 自身が設定変更時 (例: /model) に
# atomic write (一時ファイル書き込み→rename) で settings.json を書き戻すことがあり、
# その rename でシンボリックリンクが実体ファイルに置き換わってしまう。
# 起動のたびにこれを検知し、実体ファイルになっていたら symlink に戻す。
#
# 実体ファイル化で失われる差分（CC 実行時に自動追加された timeout デフォルト値等）は
# 事前に手動で dotfiles 側へ反映しておくこと。ここでは無条件に symlink を張り直す。

set -euo pipefail

TARGET="$HOME/.claude/settings.json"
SOURCE="$HOME/src/github.com/kenshin-morioka/dotfiles/claude/settings.json"

if [ -L "$TARGET" ]; then
  exit 0
fi

if [ ! -f "$SOURCE" ]; then
  exit 0
fi

if [ -f "$TARGET" ]; then
  backup="${SOURCE%.json}.broken-symlink-backup-$(date +%Y%m%d%H%M%S).json"
  cp "$TARGET" "$backup"
  echo "{\"systemMessage\": \"~/.claude/settings.json のsymlinkが切れていたため復元しました（旧内容は $backup にバックアップ）\"}"
fi

rm -f "$TARGET"
ln -s "$SOURCE" "$TARGET"
