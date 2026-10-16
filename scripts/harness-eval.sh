#!/bin/bash
# ハーネス設定 (AGENTS.md / skills / MCP / hooks) の変更前後で、同じタスク群の成功率とトークン費用を比較する簡易 evals。
#
# 使い方:
#   scripts/harness-eval.sh <tasks.tsv> [label]
#
#   tasks.tsv: タブ区切りで 1 行 1 タスク「<id>\t<プロンプト>\t<合否判定の正規表現>」。`#` 始まりの行は無視
#              合否は claude の最終出力 (result) に正規表現が grep -E でマッチするかで判定する
#   label:     結果ファイル名と CSV の 1 列目に入る識別子 (省略時は HEAD の短縮ハッシュ)
#
# 環境変数:
#   HARNESS_EVAL_MODEL  使用モデル (省略時は claude の既定)
#   HARNESS_EVAL_ARGS   claude -p に追加で渡す引数 (例: "--allowedTools Read,Grep")
#
# 結果: scripts/harness-eval/<label>-<timestamp>.csv (git 追跡外)
#   列: label,task,pass,input_tokens,cache_creation,cache_read,output_tokens,cost_usd,duration_ms
#   「常時ロード分」は cache_creation + cache_read + input_tokens の合計で比較する
#
# 各タスクはカレントディレクトリで `claude -p` を単発実行するため、通常セッションと同じ CLAUDE.md / skills / MCP が読み込まれる。
# 比較したいリポジトリに cd してから実行すること。

set -euo pipefail

tasks=${1:?tasks.tsv を指定してください}
label=${2:-$(git rev-parse --short HEAD 2>/dev/null || echo run)}
model=${HARNESS_EVAL_MODEL:-}
extra_args=${HARNESS_EVAL_ARGS:-}

outdir="$(cd "$(dirname "$0")" && pwd)/harness-eval"
mkdir -p "$outdir"
out="$outdir/$label-$(date +%Y%m%d%H%M%S).csv"
echo "label,task,pass,input_tokens,cache_creation,cache_read,output_tokens,cost_usd,duration_ms" > "$out"

pass_n=0
total_n=0
while IFS=$'\t' read -r id prompt expect; do
  [[ -z "$id" || "$id" == \#* ]] && continue
  total_n=$((total_n + 1))

  # shellcheck disable=SC2086  # extra_args は意図的に単語分割する
  # </dev/null: claude -p が while ループの stdin (tasks.tsv) を読んでしまうのを防ぐ
  json=$(claude -p "$prompt" --output-format json ${model:+--model "$model"} $extra_args 2>/dev/null </dev/null || echo "{}")
  result=$(echo "$json" | jq -r '.result // ""')

  pass=0
  # jq の // は false も既定値に倒すため、== で判定する
  if [ "$(echo "$json" | jq -r 'if .is_error == false then "ok" else "ng" end')" = "ok" ] && echo "$result" | grep -qE "$expect"; then
    pass=1
    pass_n=$((pass_n + 1))
  fi

  echo "$json" | jq -r --arg l "$label" --arg t "$id" --arg p "$pass" \
    '[$l, $t, $p, (.usage.input_tokens // 0), (.usage.cache_creation_input_tokens // 0), (.usage.cache_read_input_tokens // 0), (.usage.output_tokens // 0), (.total_cost_usd // 0), (.duration_ms // 0)] | @csv' >> "$out"
  echo "[$id] pass=$pass loaded=$(echo "$json" | jq -r '((.usage.input_tokens // 0) + (.usage.cache_creation_input_tokens // 0) + (.usage.cache_read_input_tokens // 0))') cost=$(echo "$json" | jq -r '.total_cost_usd // 0')"
done < "$tasks"

echo "== $label: $pass_n/$total_n passed, 合計 cost $(tail -n +2 "$out" | awk -F, '{s += $8} END {printf "%.4f", s}') USD -> $out"
