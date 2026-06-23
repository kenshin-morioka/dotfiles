# shellcheck shell=bash
# Go (PATH で ${GOPATH}/bin を参照するため PATH より前に定義する)
export GOPATH="${HOME}/go"

# PATH
export PATH="${HOME}/.local/bin:/usr/local/sbin:${GOPATH}/bin:${PATH}"

# Locale
export LANGUAGE="en_US.UTF-8"
export LANG="${LANGUAGE}"
export LC_ALL="${LANGUAGE}"

# Editor
export EDITOR=vim
export GIT_EDITOR="${EDITOR}"

# History
export HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/zsh/history"
[ -d "$(dirname "${HISTFILE}")" ] || mkdir -p "$(dirname "${HISTFILE}")"
export HISTSIZE=1000
export SAVEHIST=100000
export HISTFILESIZE=100000

# zplugに移行予定
export _ANTIGEN_INSTALL_DIR=${HOME}/.local/bin
