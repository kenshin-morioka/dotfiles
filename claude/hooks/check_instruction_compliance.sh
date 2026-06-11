#!/bin/bash
# 指示外検出フック: メインエージェントが実行/出力しようとしている内容を、
# 別コンテキスト (claude -p --agent) の検査エージェントに渡して指示外があるか判定する。
#
# PreToolUse (Write/Edit/MultiEdit) と Stop で呼び出される想定。
# stdin: hook event JSON (tool_name, tool_input, transcript_path 等)
# exit 0: 指示通り、続行
# exit 2: 指示外あり、stderr にメッセージを書いてメインエージェントにフィードバック

set -euo pipefail

hook_data=$(cat)

hook_event=$(echo "$hook_data" | jq -r '.hook_event_name // ""')
tool_name=$(echo "$hook_data" | jq -r '.tool_name // ""')
tool_input=$(echo "$hook_data" | jq -c '.tool_input // {}')
transcript_path=$(echo "$hook_data" | jq -r '.transcript_path // ""')

# 直近のユーザー指示メッセージを抽出 (最後 3 件)
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  recent_user_msgs=$(jq -s '
    map(select(.type == "user" and (.message.content | type == "string"))) |
    .[-3:] |
    map(.message.content) |
    join("\n---\n")
  ' "$transcript_path" 2>/dev/null || echo '""')
else
  recent_user_msgs='"(transcript_path 不明)"'
fi

prompt=$(cat <<EOF
【直近のユーザー指示 (最新3件)】
$recent_user_msgs

【メインエージェントの操作】
hook_event: $hook_event
tool_name: $tool_name
tool_input: $tool_input

上記の操作にユーザーの直近指示にない追加要素が含まれていないか判定し、PASS または FAIL: <該当箇所> のみで返答してください。
EOF
)

result=$(echo "$prompt" | claude -p --agent instruction-compliance-checker 2>/dev/null || echo "FAIL: 検査エージェント起動失敗")

if echo "$result" | grep -q "^PASS"; then
  exit 0
else
  echo "[指示外検出フック (別コンテキスト判定)]" >&2
  echo "$result" >&2
  echo "" >&2
  echo "→ 指示にない要素が含まれている可能性があります。指示範囲外の追加を取り除いてから再度実行してください。" >&2
  exit 2
fi
