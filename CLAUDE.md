# Dotfiles リポジトリ固有ルール

## シンボリックリンク構成

このリポジトリのファイルは `make link` により本番パスにシンボリックリンクされている。
**ファイルの編集は即座にシステムに反映される**ことを常に意識すること。

### シンボリックリンク対応を忘れてはいけない操作

- **設定ファイルの追加・移動・削除**時は、必ず `Makefile` の `LINKS` 変数を確認・更新すること
- ファイルをリネームした場合、古いシンボリックリンクが残るため `make unlink && make link` が必要になることを伝えること
- ディレクトリ単位でリンクされているもの（nvim, wezterm, mise, act, flipper, github-copilot, cowsay, checklists）は、配下にファイルを追加するだけで自動的にリンク先に反映される

## pre-commit フック

このリポジトリには以下の pre-commit フックが設定されている。コミット前に自動実行される。

- **typos**: スペルチェック（`.typos.toml` で除外設定あり）
- **selene**: Lua リンター（nvim 配下の `.lua` ファイル対象）
- **shellcheck**: シェルスクリプトリンター
- **jsonlint**: JSON バリデーション
- **markdownlint**: Markdown リンター（`.markdownlint.json` でルール設定あり）
- **trailing-whitespace / end-of-file-fixer**: 空白・改行修正
- **check-yaml**: YAML バリデーション
- **check-added-large-files**: 大きなファイルの混入防止

## .gitignore で管理対象外のファイル

以下のファイルは意図的にgit追跡対象外にしている。**絶対に .gitignore から除外しないこと。**

- `claude/CLAUDE.md` — グローバルClaude Code設定（全プロジェクト共通ルール）
- `claude/checklists/` — セルフレビューチェックリスト
- `git/.gitconfig.local` — Git認証情報等のローカル設定

## 変更時に連動して更新が必要なもの

以下の対応を忘れないこと。関連する変更を行った場合は、必ずセットで更新すること。

- **キーバインド追加・変更時** → `docs/CHEATSHEET.md` を必ず同時に更新する
- **新しいツール導入時** → `homebrew/Brewfile` にパッケージを追加する（`make brew-add` 使用）
- **言語ランタイムのバージョン変更時** → `mise/config.toml` を更新する
- **シンボリックリンク対象の追加・変更時** → `Makefile` の `LINKS` 変数を更新する
- **zsh エイリアス・abbreviation 追加時** → `docs/CHEATSHEET.md` への記載を検討する
- **Neovim プラグイン追加時** → `nvim/lua/extensions/` 配下に設定ファイルを作成し、キーバインドがあれば `docs/CHEATSHEET.md` に追記する

## ファイル編集時の注意

### Lua ファイル（nvim/, wezterm/）

- selene リンターを通過すること
- nvim の設定は lazy.nvim のプラグイン管理構造（`lua/extensions/` 配下）に従うこと

### シェルスクリプト（zsh/, git-hooks/）

- shellcheck を通過すること

### Markdown ファイル

- markdownlint を通過すること
- コードブロックには言語指定を付けること（MD040）
- コードブロックの前後には空行を入れること（MD031）
- リストのインデントは2スペース（MD007）

### Brewfile（homebrew/Brewfile）

- パッケージ追加は `make brew-add PKG=<名前>` または `make brew-add-cask PKG=<名前>` を使用すること
- 直接 Brewfile を手動編集した場合は `brew bundle --file=homebrew/Brewfile` で整合性を確認すること
