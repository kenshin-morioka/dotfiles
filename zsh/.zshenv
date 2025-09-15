# PATH
export PATH="${HOME}/.local/bin:/usr/local/sbin:${GOPATH}/bin:${PATH}"

# Go
export GOPATH="${HOME}/go"

# Locale
export LANGUAGE="en_US.UTF-8"
export LANG="${LANGUAGE}"
export LC_ALL="${LANGUAGE}"

# Editor
export EDITOR=vim
export GIT_EDITOR="${EDITOR}"

# History
export HISTFILE=${XDG_STATE_HOME}/zsh/history
export HISTSIZE=1000
export SAVEHIST=100000
export HISTFILESIZE=100000

# zplugに移行予定
export _ANTIGEN_INSTALL_DIR=${HOME}/.local/bin
