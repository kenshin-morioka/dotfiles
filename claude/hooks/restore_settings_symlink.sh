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
# バックアップの保持世代数。これを超えた古いものは削除する (無制限に堆積させない)
BACKUP_KEEP=3
BACKUP_PREFIX="${SOURCE%.json}.broken-symlink-backup-"

if [ -L "$TARGET" ]; then
  exit 0
fi

if [ ! -f "$SOURCE" ]; then
  exit 0
fi

if [ -f "$TARGET" ]; then
  backup="${BACKUP_PREFIX}$(date +%Y%m%d%H%M%S).json"
  cp "$TARGET" "$backup"

  # ローテーション: ファイル名のタイムスタンプ順 (= glob の名前順) に並ぶので、古いものから削る
  shopt -s nullglob
  backups=("${BACKUP_PREFIX}"*.json)
  shopt -u nullglob
  if [ "${#backups[@]}" -gt "$BACKUP_KEEP" ]; then
    for old in "${backups[@]:0:${#backups[@]}-BACKUP_KEEP}"; do
      rm -f "$old"
    done
  fi

  echo "{\"systemMessage\": \"~/.claude/settings.json のsymlinkが切れていたため復元しました（旧内容は $backup にバックアップ、最新 ${BACKUP_KEEP} 世代のみ保持）\"}"
fi

rm -f "$TARGET"
ln -s "$SOURCE" "$TARGET"
