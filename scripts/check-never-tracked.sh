#!/usr/bin/env bash
# 絶対に追跡してはいけないファイルが、.gitignore から外れていたり追跡されていたらエラーにする
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

NEVER_TRACK=(
  claude.json
  agents/claude/CLAUDE.md
  agents/claude/settings.json
  agents/codex/dotfiles.config.toml
  agents/checklists/
  git/.gitconfig.local
)

status=0
for path in "${NEVER_TRACK[@]}"; do
  if ! git check-ignore -q --no-index "$path"; then
    echo "ERROR: $path が .gitignore に含まれていません" >&2
    status=1
  fi
  if [ -n "$(git ls-files --cached -- "$path")" ]; then
    echo "ERROR: $path が追跡されています (git rm --cached $path で外してください)" >&2
    status=1
  fi
done

exit "$status"
