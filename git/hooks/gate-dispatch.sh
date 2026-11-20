#!/usr/bin/env bash
# 全リポジトリ共通ゲート (core.hooksPath) のディスパッチャ。
# ~/.config/git/hooks/{pre-commit,post-merge,post-checkout} から symlink で呼ばれ、
# $0 の名前で hook 種別を判定する。
#
# 役割:
# - リポジトリ固有の hook (.git/hooks/<name>) へ連鎖する。core.hooksPath を設定すると
#   git は .git/hooks を見なくなるため、この連鎖が無いと既存の pre-commit shim や
#   relink (post-merge / post-checkout) が無言で止まってしまう
# - pre-commit では共通チェック (git/pre-commit-global.yaml + typos + shellcheck) を実行する
#
# 共通チェックの opt-out (いずれか):
# - 環境変数 GLOBAL_GATE_SKIP=1
# - git config gate.skip true (リポジトリの local 設定)
# - .git/GATE_DISABLED ファイル (git-common-dir 直下) の存在
#
# 終了コードは各ステップの結果を集計し、1つでも失敗していれば非ゼロで終わる。

hook_name=$(basename "$0")

# 自身の実パスを解決し、設定ファイル (pre-commit-global.yaml / typos-global.toml) のある
# gate_home (= 実ファイルのあるディレクトリの親) を求める。
# macOS の readlink は -f 非対応のため、symlink を1つずつ辿る
self_path=$0
while [ -L "$self_path" ]; do
  link_dir=$(dirname "$self_path")
  target=$(readlink "$self_path")
  case $target in
    /*) self_path=$target ;;
    *) self_path="$link_dir/$target" ;;
  esac
done
gate_home=$(cd "$(dirname "$self_path")/.." && pwd)

# git リポジトリ外では何もしない
common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || exit 0
case $common_dir in
  /*) ;;
  *) common_dir="$PWD/$common_dir" ;;
esac

status=0
chained=0

# リポジトリ固有の hook へ連鎖する (サンプルファイルは実行権限が無いため自然に除外される)
local_hook="$common_dir/hooks/$hook_name"
if [ -x "$local_hook" ]; then
  chained=1
  "$local_hook" "$@" || status=$?
fi

# post-merge / post-checkout は連鎖のみで終了する (dotfiles の relink 維持が目的)
if [ "$hook_name" != "pre-commit" ]; then
  exit "$status"
fi

# --- ここから pre-commit の共通チェック ---

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit "$status"
repo_config="$repo_root/.pre-commit-config.yaml"

# opt-out 判定 (共通チェックのみスキップし、連鎖の結果で終了する)
skip=0
if [ "${GLOBAL_GATE_SKIP:-}" = "1" ]; then
  skip=1
elif [ "$(git config --bool gate.skip 2>/dev/null || true)" = "true" ]; then
  skip=1
elif [ -e "$common_dir/GATE_DISABLED" ]; then
  skip=1
fi
if [ "$skip" -eq 1 ]; then
  exit "$status"
fi

# pre-commit が無い環境では共通チェックを丸ごと止めず、警告して素通りする (fail-open)。
# セットアップ直後のマシン等で全リポジトリのコミットが詰まる事故を避けるため
has_pre_commit=0
if command -v pre-commit >/dev/null 2>&1; then
  has_pre_commit=1
else
  echo "⚠️ pre-commit が見つからないため、共通ゲートのチェックをスキップしました" >&2
fi

# リポジトリ自身の pre-commit 設定があり、ローカル hook が install されていない場合は
# 代わりに実行する (pre-commit install し忘れ対策)
if [ "$has_pre_commit" -eq 1 ] && [ "$chained" -eq 0 ] && [ -f "$repo_config" ]; then
  (cd "$repo_root" && pre-commit run) || status=$?
fi

# 共通分 (gitleaks + pre-commit-hooks) を内包する設定があるリポジトリでは、
# グローバル suite は重複するためスキップする (dotfiles 自身が該当する)
if [ -f "$repo_config" ] \
  && grep -q "gitleaks/gitleaks" "$repo_config" \
  && grep -q "pre-commit/pre-commit-hooks" "$repo_config"; then
  exit "$status"
fi

# グローバル suite (pre-commit 本体)
if [ "$has_pre_commit" -eq 1 ]; then
  (cd "$repo_root" && pre-commit run --config "$gate_home/pre-commit-global.yaml") || status=$?
fi

# staged ファイル一覧 (typos / shellcheck の対象)
staged_files=()
while IFS= read -r -d '' file; do
  staged_files+=("$file")
done < <(git -C "$repo_root" diff --cached --name-only --diff-filter=ACM -z)

if [ "${#staged_files[@]}" -gt 0 ]; then
  # typos (共通の許可語リストを指定する)
  if command -v typos >/dev/null 2>&1; then
    (cd "$repo_root" && typos --config "$gate_home/typos-global.toml" "${staged_files[@]}") || status=$?
  fi

  # シェルスクリプトのみを対象に shellcheck を実行する
  shell_files=()
  for file in "${staged_files[@]}"; do
    case $file in
      *.sh | *.bash) shell_files+=("$file") ;;
    esac
  done
  if [ "${#shell_files[@]}" -gt 0 ] && command -v shellcheck >/dev/null 2>&1; then
    (cd "$repo_root" && shellcheck "${shell_files[@]}") || status=$?
  fi
fi

exit "$status"
