#!/usr/bin/env bash
# agents submodule を agents リポジトリの最新 main に更新する。
# dotfiles に記録された参照コミットは更新しない (.gitmodules の ignore = all で差分も表示しない) ため、常にこのスクリプトで追従する。
set -euo pipefail

# worktree の agents はメインの作業ツリーとは別物のため対象外
[ "$(git rev-parse --git-dir)" = "$(git rev-parse --git-common-dir)" ] || exit 0

cd "$(git rev-parse --show-toplevel)"

# 既存の submodule に submodule update を実行すると記録された古いコミットに戻るため、未取得のときだけ実行する
[ -e agents/.git ] || git submodule update --init agents

branch=$(git -C agents symbolic-ref --short -q HEAD || true)
# 取得直後は記録コミットで detached HEAD になっている
if [ -z "$branch" ]; then
  git -C agents checkout -q main
  branch=main
fi
if [ "$branch" != "main" ]; then
  echo "⏭️  agents は $branch ブランチで作業中のため更新をスキップしました"
  exit 0
fi

git -C agents pull -q --ff-only
echo "📥 agents を最新の main に更新しました"
