#!/bin/sh
# Claude Code statusLine command
# Inspired by starship.toml: directory + git_branch + git_status + time + model + context

input=$(cat)

# --- directory ---
cwd=$(echo "$input" | jq -r '.cwd // empty')
if [ -z "$cwd" ]; then
  cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
fi
short_dir=$(echo "$cwd" | sed "s|$HOME|~|")

# --- git branch & status ---
git_branch=""
git_status_str=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  ahead=$(git -C "$cwd" --no-optional-locks rev-list --count '@{u}..HEAD' 2>/dev/null || echo "")
  behind=$(git -C "$cwd" --no-optional-locks rev-list --count 'HEAD..@{u}' 2>/dev/null || echo "")
  dirty=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  extra=""
  [ -n "$ahead" ] && [ "$ahead" -gt 0 ] && extra="${extra}⇡${ahead}"
  [ -n "$behind" ] && [ "$behind" -gt 0 ] && extra="${extra}⇣${behind}"
  [ "$dirty" -gt 0 ] && extra="${extra}*"
  [ -n "$extra" ] && git_status_str=" $extra"
fi

# --- time ---
time_str=$(date +%H:%M)

# --- model ---
model=$(echo "$input" | jq -r '.model.display_name // empty')

# --- context usage ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- build output ---
# Colors: use dim ANSI since statusLine renders with dimmed colors
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

line=""

# directory segment
line="${line}$(printf "${CYAN}%s${RESET}" "$short_dir")"

# git segment
if [ -n "$git_branch" ]; then
  line="${line} $(printf "${BLUE} %s${RESET}" "$git_branch")$(printf "${YELLOW}%s${RESET}" "$git_status_str")"
fi

# time segment
line="${line} $(printf "${GREEN} %s${RESET}" "$time_str")"

# model segment
if [ -n "$model" ]; then
  line="${line} | ${model}"
fi

# context segment
if [ -n "$used_pct" ]; then
  printf_pct=$(printf "%.0f" "$used_pct")
  line="${line} ctx:${printf_pct}%"
fi

printf "%b\n" "$line"
