# Dotfiles リポジトリ固有ルール

このファイルは Codex がこのリポジトリで作業するときに読み込むルールです。
Claude Code でも同じルールを適用するため、内容を変更した場合は `CLAUDE.md` と同期してください。

## シンボリックリンク構成

このリポジトリのファイルは `mise run link` により本番パスにシンボリックリンクされている。
**ファイルの編集は即座にシステムに反映される**ことを常に意識すること。

- 設定ファイルの追加・移動・削除時は、必ず `symlinks.txt` を確認・更新する。
- ファイルをリネームした場合、古いシンボリックリンクが残るため `mise run unlink && mise run link` が必要になることを伝える。
- ディレクトリ単位でリンクされているものは、配下へのファイル追加だけでリンク先に反映される。

## 変更時に連動して更新が必要なもの

- キーバインド追加・変更時 → `docs/CHEATSHEET.md` を同時に更新する。
- 新しいツール導入時 → `homebrew/Brewfile` にパッケージを追加する（`mise run brew-add` を使用）。
- 言語ランタイムのバージョン変更時 → `mise/config.toml` を更新する。
- シンボリックリンク対象の追加・変更時 → `symlinks.txt` を更新する。
- Neovim プラグイン追加時 → `nvim/lua/extensions/` 配下に設定ファイルを作成する。

## ファイル編集時の注意

- Lua ファイルは selene を通過させ、Neovim の設定は `lua/extensions/` 配下の構造に従う。
- シェルスクリプトは shellcheck を通過させる。
- Markdown は markdownlint を通過させ、コードブロックには言語指定を付ける。
- Brewfile の追加は `mise run brew-add <名前>` または `mise run brew-add-cask <名前>` を使用する。

## 検証

変更後は、変更内容に応じた lint・設定ファイルの検証・動作確認を行う。
コミット前には pre-commit フック（typos、selene、shellcheck、jsonlint、markdownlint、gitleaks など）が通ることを確認する。
