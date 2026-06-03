# shellcheck shell=bash
# ====================
# PATH
# ====================
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/Applications/WezTerm.app/Contents/MacOS:$PATH"
export PATH="/opt/homebrew/opt/imagemagick@6/bin:$PATH"
export COWPATH="$HOME/.cowsay/cows:/opt/homebrew/opt/cowsay/share/cowsay/cows"

# ====================
# Basic Settings
# ====================
umask 022
limit coredumpsize 0

# ====================
# Tools & Environment
# ====================
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(rbenv init -)"
eval "$(mise activate zsh)"
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

# ====================
# Plugins (antigen)
# ====================
# shellcheck source=/dev/null
source "$HOME"/.local/bin/antigen.zsh
antigen use oh-my-zsh
antigen bundles <<EOBUNDLES
    git
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-completions
    rupa/z z.sh
    olets/zsh-abbr@main
EOBUNDLES
antigen apply

# ====================
# Key Bindings
# ====================
bindkey -d
bindkey -e
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line

# ====================
# Aliases
# ====================
alias ls='ls -F --color=auto'
alias vim='nvim'
alias -g lb='`git branch | fzf --prompt "GIT BRANCH> " | head -n 1 | sed -e "s/^\*\s*//g"`'
alias de='docker exec -it $(docker ps | fzf | cut -d " " -f 1) /bin/bash'

if [[ $(uname) = "Darwin" ]]; then
  alias ldd="echo ldd is not on OSX. use otool -L."
  alias strace="echo strace is not on OSX. use dtruss"
fi

# ====================
# Abbreviations
# ====================
{
  abbr -S ll='ls -l'
  abbr -S la='ls -A'
  abbr -S lla='ls -l -A'
  abbr -S v='vim'
  abbr -S g='git'
  abbr -S gco='git checkout'
  abbr -S gst='git status'
  abbr -S gsw='git switch'
  abbr -S gbr='git branch'
  abbr -S gfe='git fetch'
  abbr -S gpl='git pull'
  abbr -S gad='git add'
  abbr -S gcm='git commit'
  abbr -S gmg='git merge --no-ff'
  abbr -S gpoh='git push origin HEAD'
  abbr -S lg='lazygit'
  abbr -S c='claude'
  abbr -S cct='claude --continue'
  abbr -S crs='claude --resume '
  abbr -S cwr='claude-worktree-resume'
  abbr -S cwra='claude-worktree-resume-all'
  abbr -S t='tmux'
  abbr -S tk='tmux kill-session'
  abbr -S tka='tmux kill-server'
} >> /dev/null

# ====================
# Functions
# ====================
function nvim() {
  if command -v gtimeout &>/dev/null; then
    gtimeout 1 cmatrix -u 1
  elif command -v timeout &>/dev/null; then
    timeout 1 cmatrix -u 1
  fi
  command nvim "$@"
}

# ====================
# Claude Worktree Resume
# ====================
function claude-worktree-resume() {
  local worktree_dir=".claude/worktrees"
  if [ ! -d "$worktree_dir" ]; then
    echo "No worktrees found in $worktree_dir"
    return 1
  fi

  local selected
  selected=$(find "$worktree_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | fzf --prompt "WORKTREE> ")
  if [ -n "$selected" ]; then
    (cd "$worktree_dir/$selected" && claude --resume)
  fi
}

function claude-worktree-resume-all() {
  local worktree_dir=".claude/worktrees"
  if [ ! -d "$worktree_dir" ]; then
    echo "No worktrees found in $worktree_dir"
    return 1
  fi

  local worktrees=("$worktree_dir"/*(N/))
  if [ ${#worktrees[@]} -eq 0 ]; then
    echo "No worktrees found in $worktree_dir"
    return 1
  fi

  for wt in "${worktrees[@]}"; do
    local name="${wt:t}"
    wezterm cli spawn --new-window --cwd "$PWD/$wt" -- claude --resume
    echo "Spawned: $name"
  done
}

# ====================
# tmux
# ====================
# 既存セッションがあれば fzf で選択して attach、なければ新規作成
function tm() {
  if ! command -v tmux &>/dev/null; then
    echo "tmux is not installed"
    return 1
  fi

  local sessions
  sessions=$(tmux list-sessions -F '#S' 2>/dev/null)

  if [ -z "$sessions" ]; then
    tmux new
    return
  fi

  local session
  session=$(echo "$sessions" | fzf --height 40% --reverse --prompt='tmux> ')
  [ -n "$session" ] && tmux a -t "$session"
}

# 全 tmux セッションを WezTerm の新しいタブで一気に開く
# 各タブはそのセッションのアクティブペイン cwd で起動するため、
# WezTerm のタブ名 (format.tab_label) がリポジトリ名等を解決できる
function tma() {
  if ! command -v tmux &>/dev/null; then
    echo "tmux is not installed"
    return 1
  fi
  if ! command -v wezterm &>/dev/null; then
    echo "wezterm cli not available"
    return 1
  fi

  local sessions
  sessions=$(tmux list-sessions -F '#S' 2>/dev/null)

  if [ -z "$sessions" ]; then
    echo "No tmux sessions found"
    return 1
  fi

  while IFS= read -r session; do
    local cwd
    cwd=$(tmux display-message -p -t "$session" '#{pane_current_path}' 2>/dev/null)
    if [ -n "$cwd" ] && [ -d "$cwd" ]; then
      wezterm cli spawn --cwd "$cwd" -- tmux attach -t "$session"
    else
      wezterm cli spawn -- tmux attach -t "$session"
    fi
    echo "Spawned tab: $session ($cwd)"
  done <<< "$sessions"
}

# ====================
# fzf
# ====================
# shellcheck disable=SC2034,SC2153
function fzf-select-history() {
  BUFFER=$(\history -n -r 1 | fzf --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N fzf-select-history
bindkey '^r' fzf-select-history

function fzf-get-destination-from-cdr() {
  cdr -l |
    sed -e 's/^[[:digit:]]*[[:blank:]]*//' |
    fzf --query "$LBUFFER"
}

# shellcheck disable=SC2034
function fzf-cdr() {
  local destination
  destination="$(fzf-get-destination-from-cdr)"
  if [ -n "$destination" ]; then
    BUFFER="cd $destination"
    zle accept-line
  else
    zle reset-prompt
  fi
}
zle -N fzf-cdr
bindkey '^u' fzf-cdr

# ====================
# History
# ====================
setopt hist_ignore_dups
setopt EXTENDED_HISTORY
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_no_store
setopt hist_expand
setopt share_history

# ====================
# Other
# ====================
export LISTMAX=50
unsetopt bg_nice
setopt list_packed
setopt no_beep
unsetopt list_types

# ====================
# IDE Integration
# ====================
# shellcheck disable=SC1090
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
