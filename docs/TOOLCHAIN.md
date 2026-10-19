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
| Vite+ の `vp` コマンド | 自分（マシンに 1 つ） | Homebrew | `homebrew/Brewfile` |
| プロジェクトの開発ツール（vite, Vite+ 本体, linter 等） | プロジェクト | プロジェクトのパッケージマネージャ | `package.json` の devDependencies |
| 言語製のグローバル CLI | 自分 | mise の `npm:` / `go:` / `gem:` / `cargo:` 等のバックエンド | `mise/config.toml` |

## やらないこと

- **Homebrew で言語ランタイムを入れない**: `brew upgrade` で勝手に上がり、プロジェクトごとに切り替えられないため
  - 例外: `jsonlint` / `markdownlint-cli` / `prettier` の依存として入る Homebrew の node は残る。PATH では mise が優先される（[シェルへの反映](#シェルへの反映)）
- **`pnpm add -g` / `npm i -g` を使わない**: dotfiles に宣言が残らず、別マシンで再現できないため。mise の `npm:` バックエンドで入れる
- **Vite+ に node / pnpm を管理させない**: `vp env` を `system_first` のままにし、node / pnpm は mise が決める。`vp` 自体はグローバルに入れる（ai-os など `vp` 前提のプロジェクトがあるため）

## シェルへの反映

どの起動方法でも mise 管理のツールが Homebrew より優先されるよう、3 箇所で PATH を通している。

| ファイル | 対象 | 内容 |
| ---- | ---- | ---- |
| `zsh/.zshenv` | 全シェル（非対話・PATH を継承しない起動を含む） | mise の shims を PATH に追加 |
| `zsh/.zprofile` | ログインシェル（`zsh -lc` 等） | `/etc/zprofile` の path_helper が `/opt/homebrew/bin` を先頭に移すため、その後に shims を再度先頭に置く |
| `zsh/.zshrc` | 対話シェル | `mise activate` でディレクトリごとのバージョン切り替えを有効化 |

Vite+ は `~/.config/vite-plus/env` を `.zshenv` / `.zshrc` から読む。`vp` を PATH の先頭に、node / pnpm 等の shim を末尾（fallback）に置くので、mise の node / pnpm と競合しない。

## 背景

2026-10 時点で node 系が 3 つの仕組みから重複して入っていた。

- Homebrew: node（複数バージョン）, nodenv, node-build, vite-plus
- mise: node, pnpm, bun
- Vite+: node / npm / pnpm / bun / yarn の shim

旧版の Vite+ は shim が PATH の先頭にあり、mise の node / pnpm が使われていなかった。これを機に Vite+ を外して整理したが、`vp` 前提のプロジェクトで `vp` が使えなくなったため、`vp` だけ Homebrew で入れ直した。現行版は shim が PATH の末尾なので競合しない。
