# ツールの管理責務

## 原則

- **「そのコマンドのバージョンを誰が決めるか」で管理元を決める**
- **1 コマンド 1 管理元**。複数の仕組みが同じコマンドの shim を PATH に置くと、どれが動いているか分からなくなる

## 管理元の割り当て

| 対象 | バージョンを決めるのは | 管理元 | 宣言場所 |
| ---- | ---- | ---- | ---- |
| プロジェクト非依存の CLI・GUI アプリ・mise 本体 | 自分（マシンに 1 つ） | Homebrew | `homebrew/Brewfile` |
| 言語ランタイム（node, ruby, go, bun 等） | プロジェクト | mise | 既定は `mise/config.toml`、各プロジェクトの `mise.toml` / `.node-version` / `.ruby-version` 等 |
| パッケージマネージャ（pnpm 等） | プロジェクトの `package.json` の `packageManager` | mise は初期の 1 本を入れるだけ。切り替えは pnpm 自身が行う | `package.json` |
| プロジェクトの開発ツール（vite, Vite+, linter 等） | プロジェクト | プロジェクトのパッケージマネージャ | `package.json` の devDependencies |
| 言語製のグローバル CLI | 自分 | mise の `npm:` / `go:` / `gem:` / `cargo:` 等のバックエンド | `mise/config.toml` |

## やらないこと

- **Homebrew で言語ランタイムを入れない**: `brew upgrade` で勝手に上がり、プロジェクトごとに切り替えられないため
  - 例外: `jsonlint` / `markdownlint-cli` / `prettier` の依存として入る Homebrew の node は残る。PATH では mise が優先される
- **`pnpm add -g` / `npm i -g` を使わない**: dotfiles に宣言が残らず、別マシンで再現できないため。mise の `npm:` バックエンドで入れる
- **Vite+ をグローバルに入れない**: node / pnpm 等の shim を PATH の先頭に置き、mise とランタイム管理が重複するため

## 背景

2026-10 時点で node 系が 3 つの仕組みから重複して入っていた。

- Homebrew: node（複数バージョン）, nodenv, node-build, vite-plus
- mise: node, pnpm, bun
- Vite+: node / npm / pnpm / bun / yarn の shim

Vite+ の shim が PATH の先頭にあったため mise の node / pnpm は使われておらず、`pnpm add -g` のエラー調査で初めて実際に動いている pnpm が Vite+ 経由の別バージョンだと分かった。これを機に上記の原則で整理した。
