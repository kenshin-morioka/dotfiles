# shellcheck shell=bash
# ログインシェルでは /etc/zprofile の path_helper が /opt/homebrew/bin を先頭に移すため、
# その後に読まれるここで mise の shims を再度先頭に置く (Homebrew の node より優先させる)
export PATH="${HOME}/.local/share/mise/shims:${PATH}"
