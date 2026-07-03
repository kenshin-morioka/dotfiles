# shellcheck shell=bash
# Go (PATH で ${GOPATH}/bin を参照するため PATH より前に定義する)
export GOPATH="${HOME}/go"

# PATH (非対話シェルでも通す必要があるものはここに集約する)
export PATH="${HOME}/.local/bin:/usr/local/sbin:${GOPATH}/bin:${PATH}"
export PATH="/Applications/WezTerm.app/Contents/MacOS:${PATH}"
export PATH="${HOME}/.cargo/bin:${PATH}"

# Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Editor
export EDITOR=vim
export GIT_EDITOR="${EDITOR}"

# History
export HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/zsh/history"
[ -d "$(dirname "${HISTFILE}")" ] || mkdir -p "$(dirname "${HISTFILE}")"
export HISTSIZE=100000
export SAVEHIST=100000
