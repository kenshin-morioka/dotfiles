#!/usr/bin/env bash
# pull (post-merge) / ブランチ切り替え (post-checkout) 後にシンボリックリンクを張り直す。
# agents/skills/* などワイルドカード定義のリンクは、エントリ追加時に link の再実行が必要なため。
set -euo pipefail

# post-checkout のファイル単位チェックアウト (git checkout -- <file>) では不要
[ "${PRE_COMMIT_CHECKOUT_TYPE:-1}" = "0" ] && exit 0

# worktree で実行するとリンク先が worktree に向いてしまうため、メインの作業ツリーでのみ実行する
[ "$(git rev-parse --git-dir)" = "$(git rev-parse --git-common-dir)" ] || exit 0

cd "$(git rev-parse --show-toplevel)"
mise run link >/dev/null
echo "🔗 mise run link を実行しました"
