#!/bin/bash
#
# PreToolUse Self-Review Gate Hook
#
# git commit 実行前にセルフレビューが完了しているかを検証する。
# 未完了の場合は permissionDecision: deny でコミットをブロックし、
# Claude に /self-review スキルの実行を促す。
#
# セルフレビュー完了はフラグファイル (<git-dir>/self-review-done) で判定する。
# フラグは /self-review スキルが完了時に作成し、本 hook が許可時に消費する。
# 60 分より古いフラグは無効として破棄する。

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# git commit コマンドかどうか判定（git -C <dir> commit 等のグローバルオプション付きも検知する）
if ! echo "$COMMAND" | grep -qE "(^|&&|;|\|)\s*git(\s+-\S+(\s+[^-[:space:]]\S*)?)*\s+commit"; then
  exit 0
fi

CHECKLIST_DIR="${HOME}/.claude/checklists"

if [ ! -d "${CHECKLIST_DIR}" ]; then
  exit 0
fi

if ! ls "${CHECKLIST_DIR}"/*.md >/dev/null 2>&1; then
  exit 0
fi

# 判定対象のリポジトリを決める。
# hook の cwd は Claude Code 側のセッション cwd であり、`git -C <dir> commit` の場合は
# コマンド側のディレクトリが正。-C 指定があればそれを、無ければ hook 入力の cwd を使う
GIT_C_DIR=$(echo "$COMMAND" | grep -oE "git[[:space:]]+-C[[:space:]]+('[^']+'|\"[^\"]+\"|[^[:space:]]+)" | head -n 1 | sed -E "s/^git[[:space:]]+-C[[:space:]]+//; s/^['\"]//; s/['\"]\$//" || true)
REPO_DIR="${GIT_C_DIR:-$(echo "$INPUT" | jq -r '.cwd // empty')}"
REPO_DIR="${REPO_DIR:-.}"

GIT_DIR=$(git -C "${REPO_DIR}" rev-parse --absolute-git-dir 2>/dev/null || true)

if [ -z "${GIT_DIR}" ]; then
  exit 0
fi

FLAG_FILE="${GIT_DIR}/self-review-done"

if [ -f "${FLAG_FILE}" ]; then
  if [ -n "$(find "${FLAG_FILE}" -mmin -60 2>/dev/null)" ]; then
    rm -f "${FLAG_FILE}"
    exit 0
  fi
  # 60 分より古いフラグは破棄してブロックする
  rm -f "${FLAG_FILE}"
fi

REASON="セルフレビュー未実施のためコミットをブロックしました。/self-review スキルを実行し、チェックリストに照合して違反があれば修正してください。スキル完了後に再度コミットしてください。"

jq -n --arg reason "${REASON}" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
exit 0
