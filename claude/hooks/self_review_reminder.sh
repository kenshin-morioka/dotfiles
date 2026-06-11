#!/bin/bash
#
# PreToolUse Self-Review Reminder Hook
#
# git commit 実行前にセルフレビューチェックリストの確認をリマインドする。
# ~/.claude/checklists/ にチェックリストが存在する場合のみ発火する。
#
# exit 0: 許可（リマインドメッセージを stdout に出力）
# exit 2: ブロック

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# git commit コマンドかどうか判定
if ! echo "$COMMAND" | grep -qE "(^|&&|;|\|)\s*git\s+commit"; then
  exit 0
fi

CHECKLIST_DIR="${HOME}/.claude/checklists"

if [ ! -d "${CHECKLIST_DIR}" ]; then
  exit 0
fi

MD_FILES=$(ls "${CHECKLIST_DIR}"/*.md 2>/dev/null || true)

if [ -z "${MD_FILES}" ]; then
  exit 0
fi

NAMES=$(echo "${MD_FILES}" | xargs -n1 basename | tr '\n' ', ' | sed 's/,$//')

echo "[Self-Review Reminder] コミット前にセルフレビューチェックリストを確認しましたか？ 未確認の場合は /self-review を実行してください（対象: ${NAMES}）"
exit 0
