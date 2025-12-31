# export PATH="/usr/local/opt/curl/bin:$PATH"

# # fnm
# export PATH="/Users/kenshin/Library/Application Support/fnm:$PATH"
# eval "`fnm env`"

# java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# cowsay
export COWPATH="$HOME/.cowsay/cows:/opt/homebrew/opt/cowsay/share/cowsay/cows"

# setting
# 新規ファイル作成時のパーミッション
umask 022
# コアダンプを残さない
limit coredumpsize 0
# キーバインドをemacに
bindkey -d
bindkey -e

# Option + 矢印で単語単位移動
bindkey '^[[1;3D' backward-word   # Option + Left
bindkey '^[[1;3C' forward-word    # Option + Right

# Command + 矢印で行頭/行末移動 (Home/End)
bindkey '^[OH' beginning-of-line  # Home
bindkey '^[OF' end-of-line        # End

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

eval "$(rbenv init -)"

# miseで管理しているのでnodenvは使わない
# eval "$(nodenv init -)"
eval "$(mise activate zsh)"

eval "$(direnv hook zsh)"

# antigen
source $HOME/.local/bin/antigen.zsh

# Load the oh-my-zsh's library
antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
    # Bundles from the default repo (robbyrussell's oh-my-zsh)
    git
    # Syntax highlighting bundle.
    zsh-users/zsh-syntax-highlighting
    # Fish-like auto suggestions
    zsh-users/zsh-autosuggestions
    # Extra zsh completions
    zsh-users/zsh-completions
    # z
    rupa/z z.sh
    # abbr
    olets/zsh-abbr@main
EOBUNDLES

# Tell antigen that you're done
antigen apply

# alias(履歴には変換後が記録)
alias ls='ls -F --color=auto'

function nvim() {
  if command -v gtimeout &>/dev/null; then
    gtimeout 1 cmatrix -u 1
  elif command -v timeout &>/dev/null; then
    timeout 1 cmatrix -u 1
  fi
  command nvim "$@"
}
alias vim='nvim'

## ブランチを簡単切り替え。git checkout lbで実行できる
alias -g lb='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'

## dockerコンテナに入る。deで実行できる
alias de='docker exec -it $(docker ps | peco | cut -d " " -f 1) /bin/bash'

## OSXで使えないコマンドのときにヒントを表示する
if [[ $(uname) = "Darwin" ]]; then
    alias ldd="echo ldd is not on OSX. use otool -L."
    alias strace="echo strace is not on OSX. use dtruss"
fi

# abbr(履歴には変換前が記録)
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

# starship
eval "$(starship init zsh)"

export PATH="/Applications/WezTerm.app/Contents/MacOS:$PATH"
export PATH="/opt/homebrew/opt/imagemagick@6/bin:$PATH"

# peco settings
## 過去に実行したコマンドを選択。ctrl-rにバインド
function peco-select-history() {
  BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

## search a destination from cdr list
function peco-get-destination-from-cdr() {
  cdr -l | \
  sed -e 's/^[[:digit:]]*[[:blank:]]*//' | \
  peco --query "$LBUFFER"
}

### 過去に移動したことのあるディレクトリを選択。ctrl-uにバインド
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

# Historyの設定
## 重複を記録しない
setopt hist_ignore_dups
## 開始と終了を記録
setopt EXTENDED_HISTORY
## ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups
## スペースで始まるコマンド行はヒストリリストから削除
setopt hist_ignore_space
## ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_verify
## 余分な空白は詰めて記録
setopt hist_reduce_blanks
## 古いコマンドと同じものは無視
setopt hist_save_no_dups
## historyコマンドは履歴に登録しない
setopt hist_no_store
## 保管時にヒストリを自動的に展開
setopt hist_expand
## history共有
setopt share_history

# other
## zshの補完候補が画面から溢れ出る時、それでも表示するか確認
export LISTMAX=50
## バックグラウンドジョブの優先度(ionice)をbashと同じ挙動に
unsetopt bg_nice
## 補完候補を詰めて表示
setopt list_packed
## ピープオンを鳴らさない
setopt no_beep
## ファイル種別起動を補完候補の末尾に表示しない
unsetopt list_types

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
