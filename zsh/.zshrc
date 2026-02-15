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
source $HOME/.local/bin/antigen.zsh
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
abbr -S ll='ls -l' >>/dev/null
abbr -S la='ls -A' >>/dev/null
abbr -S lla='ls -l -A' >>/dev/null
abbr -S v='vim' >>/dev/null
abbr -S g='git' >>/dev/null
abbr -S gco='git checkout' >>/dev/null
abbr -S gst='git status' >>/dev/null
abbr -S gsw='git switch' >>/dev/null
abbr -S gbr='git branch' >>/dev/null
abbr -S gfe='git fetch' >>/dev/null
abbr -S gpl='git pull' >>/dev/null
abbr -S gad='git add' >>/dev/null
abbr -S gcm='git commit' >>/dev/null
abbr -S gmg='git merge --no-ff' >>/dev/null
abbr -S gpoh='git push origin HEAD' >>/dev/null
abbr -S lg='lazygit' >>/dev/null
abbr -S c='claude' >>/dev/null
abbr -S cct='claude --continue' >>/dev/null
abbr -S crs='claude --resume ' >>/dev/null

# ====================
# Functions
# ====================
# function nvim() {
#   if command -v gtimeout &>/dev/null; then
#     gtimeout 1 cmatrix -u 1
#   elif command -v timeout &>/dev/null; then
#     timeout 1 cmatrix -u 1
#   fi
#   command nvim "$@"
# }

# ====================
# Peco
# ====================
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

function peco-cdr() {
  local destination="$(peco-get-destination-from-cdr)"
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
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
