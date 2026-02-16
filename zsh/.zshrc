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
alias -g lb='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'
alias de='docker exec -it $(docker ps | peco | cut -d " " -f 1) /bin/bash'

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
# Peco
# ====================
# shellcheck disable=SC2034,SC2153
function peco-select-history() {
  BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

function peco-get-destination-from-cdr() {
  cdr -l |
    sed -e 's/^[[:digit:]]*[[:blank:]]*//' |
    peco --query "$LBUFFER"
}

# shellcheck disable=SC2034
function peco-cdr() {
  local destination
  destination="$(peco-get-destination-from-cdr)"
  if [ -n "$destination" ]; then
    BUFFER="cd $destination"
    zle accept-line
  else
    zle reset-prompt
  fi
}
zle -N peco-cdr
bindkey '^u' peco-cdr

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
