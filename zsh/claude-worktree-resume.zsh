# shellcheck shell=bash disable=SC1036,SC1058,SC1072,SC1073,SC1009
# claude-worktree-resume.zsh
#
# Claude Code の --worktree セッションをインタラクティブに選択して復元する
#
# 依存: git, jq, peco or fzf
# 使い方: claude-worktree-resume
# 環境変数: CLAUDE_WORKTREE_SELECTOR (default: peco)

function claude-worktree-resume() {
  local selector_cmd="${CLAUDE_WORKTREE_SELECTOR:-peco}"

  if ! command -v jq &>/dev/null; then
    echo "Error: jq が必要です (brew install jq)" >&2
    return 1
  fi

  if ! command -v "$selector_cmd" &>/dev/null; then
    echo "Error: $selector_cmd が必要です (brew install $selector_cmd)" >&2
    return 1
  fi

  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$repo_root" ]]; then
    echo "Error: gitリポジトリ内で実行してください" >&2
    return 1
  fi

  local claude_projects_dir="$HOME/.claude/projects"
  local escaped_repo
  escaped_repo=$(echo "$repo_root" | sed 's|/|-|g; s|\.|-|g')

  local display_lines=()
  local data_lines=()
  local seen_session_dirs=()

  # 1. git worktree list から実在するworktreeを収集
  while IFS= read -r line; do
    local wt_path
    wt_path=$(echo "$line" | awk '{print $1}')

    if [[ "$wt_path" == "$repo_root" ]]; then
      continue
    fi

    local escaped_wt
    escaped_wt=$(echo "$wt_path" | sed 's|/|-|g; s|\.|-|g')
    local session_dir="$claude_projects_dir/$escaped_wt"
    seen_session_dirs+=("$session_dir")

    if [[ -d "$session_dir" ]]; then
      for jsonl in "$session_dir"/*.jsonl(N); do
        local session_id original_branch modified
        session_id=$(basename "$jsonl" .jsonl)
        original_branch=$(head -1 "$jsonl" | jq -r '.worktreeSession.originalBranch // empty' 2>/dev/null)

        if [[ -z "$original_branch" ]]; then
          continue
        fi

        modified=$(stat -f "%Sm" -t "%m/%d %H:%M" "$jsonl" 2>/dev/null)
        display_lines+=("${modified}  ${original_branch}")
        data_lines+=("${wt_path}	${session_id}")
      done
    else
      local wt_branch
      wt_branch=$(echo "$line" | sed 's/.*\[//;s/\]//')
      display_lines+=("(no session)  ${wt_branch}")
      data_lines+=("${wt_path}	-")
    fi
  done < <(git worktree list)

  # 2. 孤立セッション（worktreeは削除済みだがセッションJSONLが残っているもの）を収集
  for session_dir in "$claude_projects_dir/${escaped_repo}"--claude-worktrees-*(N/); do
    local already_seen=false
    for seen in "${seen_session_dirs[@]}"; do
      if [[ "$seen" == "$session_dir" ]]; then
        already_seen=true
        break
      fi
    done

    if [[ "$already_seen" == "true" ]]; then
      continue
    fi

    for jsonl in "$session_dir"/*.jsonl(N); do
      local session_id original_branch wt_path_from_session modified
      session_id=$(basename "$jsonl" .jsonl)
      original_branch=$(head -1 "$jsonl" | jq -r '.worktreeSession.originalBranch // empty' 2>/dev/null)
      wt_path_from_session=$(head -1 "$jsonl" | jq -r '.worktreeSession.worktreePath // empty' 2>/dev/null)

      if [[ -z "$original_branch" ]]; then
        continue
      fi

      modified=$(stat -f "%Sm" -t "%m/%d %H:%M" "$jsonl" 2>/dev/null)
      display_lines+=("${modified}  [archived] ${original_branch}")
      data_lines+=("${wt_path_from_session:-$repo_root}	${session_id}")
    done
  done

  if [[ ${#display_lines[@]} -eq 0 ]]; then
    echo "worktreeセッションが見つかりません" >&2
    return 1
  fi

  # セレクタで選択
  local selected
  selected=$(printf '%s\n' "${display_lines[@]}" | "$selector_cmd" --prompt "CLAUDE WORKTREE>")

  if [[ -z "$selected" ]]; then
    return 0
  fi

  # 選択された行のインデックスを特定
  local selected_index
  local i
  for (( i=1; i<=${#display_lines[@]}; i++ )); do
    if [[ "${display_lines[$i]}" == "$selected" ]]; then
      selected_index=$i
      break
    fi
  done

  if [[ -z "$selected_index" ]]; then
    echo "Error: 選択の解析に失敗しました" >&2
    return 1
  fi

  local target_path session_id
  target_path=$(echo "${data_lines[$selected_index]}" | cut -f1)
  session_id=$(echo "${data_lines[$selected_index]}" | cut -f2)

  # アーカイブセッション（worktreeディレクトリが存在しない）の場合はリポジトリルートで復元
  if [[ ! -d "$target_path" ]]; then
    echo "worktreeディレクトリが存在しないため、リポジトリルートで復元します" >&2
    target_path="$repo_root"
  fi

  cd "$target_path" || return 1

  if [[ "$session_id" != "-" ]]; then
    claude --resume "$session_id"
  else
    claude --resume
  fi
}
