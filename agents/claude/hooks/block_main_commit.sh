#!/bin/bash
# PreToolUse (Bash) hook: main / master ブランチへの直接コミットを拒否する。
# グローバル AGENTS.md の「main ブランチでの直接作業は絶対禁止」を指示文ではなく hook で強制する。
#
# stdin: hook event JSON (tool_input.command, cwd)
# exit 0: 続行
# exit 2: ブロック (stderr のメッセージがエージェントにフィードバックされる)
#
# 判定方法:
#   コマンドを `&&` `||` `;` `|` で区切った各セグメントについて、
#   - `cd <dir>` なら以降のセグメントの作業ディレクトリを更新する
#   - `git [-C <dir>] ... commit` なら、そのセグメントの `-C <dir>` (無ければその時点の作業ディレクトリ) の
#     ブランチを調べ、main / master ならブロックする
#   `-C <dir>` と `cd <dir>` はクォート付き (空白を含むパス) にも対応する。
#   改行区切り・サブシェル・ヒアドキュメント内の文字列は厳密には追えないため、疑わしい場合は安全側 (ブロック) に倒れる。

set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')
cwd=$(echo "$input" | jq -r '.cwd // empty')
cwd="${cwd:-$PWD}"

# git commit を含まないコマンドは即座に通す (大半のコマンドはここで終わる)
if ! echo "$command" | grep -qE '(^|[^[:alnum:]_-])git([[:space:]]|$)'; then
  exit 0
fi
if ! echo "$command" | grep -qE '(^|[[:space:]])commit([[:space:]]|$)'; then
  exit 0
fi

# クォート付き / 無しのパス 1 つを取り出す ("a b" / 'a b' / a)
unquote() {
  # 置換できたら t で抜ける (順に全部適用すると "a b" → a b → a と空白で切れてしまう)
  sed -E -e 's/^[[:space:]]+//' -e 's/^"([^"]*)".*/\1/;t' -e "s/^'([^']*)'.*/\1/;t" -e 's/^([^[:space:]]+).*/\1/'
}

resolve_dir() {
  # $1: 基準ディレクトリ, $2: 相対または絶対パス
  case "$2" in
    /*) echo "$2" ;;
    \~ | \~/*) echo "${HOME}${2#\~}" ;;
    *) echo "$1/$2" ;;
  esac
}

cur_dir="$cwd"
path_re="(\"[^\"]*\"|'[^']*'|[^[:space:]]+)"

# 改行も区切りとして扱う。`(` `{` で始まるサブシェルは先頭記号を落として同じ流れで見る
while IFS= read -r segment; do
  segment=$(printf '%s' "$segment" | sed -E 's/^[[:space:]]*[({]*[[:space:]]*//')
  [ -z "$segment" ] && continue

  # cd <dir>: 以降のセグメントの作業ディレクトリを更新する
  if printf '%s' "$segment" | grep -qE '^cd([[:space:]]|$)'; then
    target=$(printf '%s' "$segment" | sed -E 's/^cd[[:space:]]*//' | unquote)
    if [ -z "$target" ] || [ "$target" = "~" ]; then
      cur_dir="$HOME"
    else
      cur_dir=$(resolve_dir "$cur_dir" "$target")
    fi
    continue
  fi

  # git [-C <dir>] [options] commit ...
  if ! printf '%s' "$segment" | grep -qE "^git([[:space:]]+-C[[:space:]]+${path_re})?([[:space:]]+-[^[:space:]]+)*[[:space:]]+commit([[:space:]]|$)"; then
    continue
  fi
  c_dir=$(printf '%s' "$segment" | grep -oE "^git[[:space:]]+-C[[:space:]]+${path_re}" | sed -E 's/^git[[:space:]]+-C[[:space:]]+//' | unquote || true)
  if [ -n "$c_dir" ]; then
    repo_dir=$(resolve_dir "$cur_dir" "$c_dir")
  else
    repo_dir="$cur_dir"
  fi

  branch=$(git -C "$repo_dir" symbolic-ref --short HEAD 2>/dev/null || true)
  case "$branch" in
    main | master)
      echo "[block_main_commit] $branch ブランチへの直接コミットは禁止です (対象: $repo_dir)。作業ブランチを作成してからコミットしてください (例: git switch -c fix-<内容>)。" >&2
      exit 2
      ;;
  esac
done < <(printf '%s\n' "$command" | awk '{ gsub(/&&|\|\||;|\|/, "\n"); print }')

exit 0
