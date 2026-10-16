#!/bin/bash
# PreToolUse (Bash) hook: main / master ブランチへの直接コミットを拒否する。
# グローバル AGENTS.md の「main ブランチでの直接作業は絶対禁止」を指示文ではなく hook で強制する。
#
# stdin: hook event JSON (tool_input.command, cwd)
# exit 0: 続行
# exit 2: ブロック (stderr のメッセージがエージェントにフィードバックされる)

set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# `git commit` を含むコマンドだけ対象 (`git -C <dir> commit`、`&&` で繋いだものも含む)
if ! echo "$command" | grep -qE '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?([[:space:]]+-[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)'; then
  exit 0
fi

# 判定対象のリポジトリ: `git -C <dir>` があればそれ、無ければ hook 入力の cwd
repo_dir=$(echo "$command" | grep -oE "git[[:space:]]+-C[[:space:]]+('[^']+'|\"[^\"]+\"|[^[:space:]]+)" | head -n 1 | sed -E "s/^git[[:space:]]+-C[[:space:]]+//; s/^['\"]//; s/['\"]\$//" || true)
repo_dir="${repo_dir:-$(echo "$input" | jq -r '.cwd // empty')}"
repo_dir="${repo_dir:-.}"

branch=$(git -C "$repo_dir" symbolic-ref --short HEAD 2>/dev/null || true)
case "$branch" in
  main | master)
    echo "[block_main_commit] $branch ブランチへの直接コミットは禁止です。作業ブランチを作成してからコミットしてください (例: git switch -c fix-<内容>)。" >&2
    exit 2
    ;;
esac
exit 0
