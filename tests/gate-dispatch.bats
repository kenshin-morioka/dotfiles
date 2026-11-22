#!/usr/bin/env bats
# 全リポジトリ共通ゲート (git/hooks/gate-dispatch.sh) のテスト
# PATH にスタブ (pre-commit / typos / shellcheck) を置き、呼び出しをログファイルで検証する。
# hook エントリ (symlink) を直接実行する形にしているため、
# gate-dispatch.sh の実行権限が欠けている場合もテスト失敗として検出できる。

setup() {
  GATE_DIR="$BATS_TEST_TMPDIR/gate"
  HOOK_BIN="$BATS_TEST_TMPDIR/hookbin"
  STUB_BIN="$BATS_TEST_TMPDIR/stubbin"
  REPO="$BATS_TEST_TMPDIR/repo"
  export GATE_STUB_LOG="$BATS_TEST_TMPDIR/stub.log"

  # gate の配置を再現する (hooks/ のあるディレクトリの親に設定ファイル2点がある構成)
  mkdir -p "$GATE_DIR/hooks" "$HOOK_BIN" "$STUB_BIN"
  cp -p "$BATS_TEST_DIRNAME/../git/hooks/gate-dispatch.sh" "$GATE_DIR/hooks/"
  cp "$BATS_TEST_DIRNAME/../git/pre-commit-global.yaml" "$GATE_DIR/"
  cp "$BATS_TEST_DIRNAME/../git/typos-global.toml" "$GATE_DIR/"
  ln -s "$GATE_DIR/hooks/gate-dispatch.sh" "$HOOK_BIN/pre-commit"
  ln -s "$GATE_DIR/hooks/gate-dispatch.sh" "$HOOK_BIN/post-merge"
  ln -s "$GATE_DIR/hooks/gate-dispatch.sh" "$HOOK_BIN/post-checkout"

  # スタブ: 呼び出しをログに残して成功する
  for tool in pre-commit typos shellcheck; do
    cat > "$STUB_BIN/$tool" <<'EOS'
#!/usr/bin/env bash
echo "$(basename "$0") $*" >> "$GATE_STUB_LOG"
EOS
    chmod +x "$STUB_BIN/$tool"
  done
  : > "$GATE_STUB_LOG"
  export PATH="$STUB_BIN:$PATH"

  # テスト用リポジトリ (初期コミットは hook を介さずに作る)
  git init -q "$REPO"
  git -C "$REPO" config user.email "test@example.com"
  git -C "$REPO" config user.name "test"
  echo "hello" > "$REPO/README.md"
  git -C "$REPO" add README.md
  git -C "$REPO" commit --no-verify -qm "init"
  cd "$REPO"
}

# 変更を stage する
stage_change() {
  echo "change" >> "$REPO/README.md"
  git -C "$REPO" add README.md
}

# ローカル hook (.git/hooks/<name>) を作る
make_local_hook() {
  local name="$1" body="$2"
  printf '#!/usr/bin/env bash\n%s\n' "$body" > "$REPO/.git/hooks/$name"
  chmod +x "$REPO/.git/hooks/$name"
}

@test "素のリポジトリでグローバル suite が呼ばれる" {
  stage_change
  run "$HOOK_BIN/pre-commit"
  [ "$status" -eq 0 ]
  grep -q "pre-commit run --config $GATE_DIR/pre-commit-global.yaml" "$GATE_STUB_LOG"
  grep -q "^typos " "$GATE_STUB_LOG"
}

@test ".git/hooks/pre-commit のローカル hook が連鎖実行される" {
  make_local_hook pre-commit 'echo "local-pre-commit" >> "$GATE_STUB_LOG"'
  stage_change
  run "$HOOK_BIN/pre-commit"
  [ "$status" -eq 0 ]
  grep -q "local-pre-commit" "$GATE_STUB_LOG"
  grep -q "pre-commit run --config" "$GATE_STUB_LOG"
}

@test "gate.skip=true でグローバル suite は呼ばれないが連鎖はされる" {
  git config gate.skip true
  make_local_hook pre-commit 'echo "local-pre-commit" >> "$GATE_STUB_LOG"'
  stage_change
  run "$HOOK_BIN/pre-commit"
  [ "$status" -eq 0 ]
  grep -q "local-pre-commit" "$GATE_STUB_LOG"
  ! grep -q "pre-commit run" "$GATE_STUB_LOG"
}

@test "gitleaks と pre-commit-hooks を含むリポジトリ設定があると suite がスキップされる" {
  cat > "$REPO/.pre-commit-config.yaml" <<'EOF'
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.30.1
    hooks:
      - id: gitleaks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: trailing-whitespace
EOF
  git add .pre-commit-config.yaml
  stage_change
  run "$HOOK_BIN/pre-commit"
  [ "$status" -eq 0 ]
  # リポジトリ側の設定は (install 忘れ対策で) 代わりに実行される
  grep -q "^pre-commit run$" "$GATE_STUB_LOG"
  # グローバル suite と typos は重複するためスキップされる
  ! grep -q "pre-commit run --config" "$GATE_STUB_LOG"
  ! grep -q "^typos " "$GATE_STUB_LOG"
}

@test "pre-commit が PATH に無いと警告して 0 で終わる" {
  stage_change
  mkdir -p "$BATS_TEST_TMPDIR/emptybin"
  run env PATH="$BATS_TEST_TMPDIR/emptybin:/usr/bin:/bin" "$HOOK_BIN/pre-commit"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pre-commit が見つからない"* ]]
}

@test "ローカル hook が失敗すると全体が非ゼロになる" {
  make_local_hook pre-commit 'exit 1'
  stage_change
  run "$HOOK_BIN/pre-commit"
  [ "$status" -ne 0 ]
}

@test "post-merge は連鎖のみで suite は呼ばれない" {
  make_local_hook post-merge 'echo "local-post-merge" >> "$GATE_STUB_LOG"'
  run "$HOOK_BIN/post-merge"
  [ "$status" -eq 0 ]
  grep -q "local-post-merge" "$GATE_STUB_LOG"
  ! grep -q "pre-commit" "$GATE_STUB_LOG"
}
