# dotfiles

macOS向けの個人用dotfiles設定ファイル集です。

<details>
<summary>English</summary>

Personal dotfiles configuration for macOS.

## Contents

| Directory | Description |
| --- | --- |
| `nvim/` | Neovim config (lazy.nvim, LSP, Telescope, NeoTree, etc.) |
| `wezterm/` | WezTerm terminal config |
| `zsh/` | Zsh config (.zshrc, .zprofile) |
| `homebrew/` | Brewfile (package management) |
| `mise/` | mise version manager config |
| `starship.toml` | Starship prompt config |
| `claude/` | Claude Code config (create `SELF_REVIEW_CHECKLIST.md` for quality assurance) |
| `git-hooks/` | Git hooks (pre-push, etc.) |
| `act/` | GitHub Actions local runner config |

## Setup

1. Clone: `ghq get git@github.com:kenshin-morioka/dotfiles.git`
2. Install Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
3. Install packages: `make brew`
4. Create symlinks: `make link`
5. Install fzf keybindings: `$(brew --prefix)/opt/fzf/install`
6. Create self-review checklist: `make claude-init` (customize the content yourself)

## Make Commands

| Command | Description |
| --- | --- |
| `make link` | Create symlinks |
| `make unlink` | Remove symlinks |
| `make brew` | Install all packages from Brewfile |
| `make brew-add PKG=xxx` | Add and install a package |
| `make brew-add-cask PKG=xxx` | Add and install a cask |
| `make brew-sync` | Sync installed packages to Brewfile |
| `make brew-list` | Show Brewfile contents |
| `make claude-init` | Create self-review checklist template |

## Package Management

| Tool | Purpose | Examples |
| ---- | ------- | -------- |
| **Homebrew** | System tools, GUI apps (cask) | git, neovim, mise, claude-code |
| **mise** | Language runtimes, dev tools (version management) | node, ruby, go, pnpm |

- Use **mise** instead of rbenv, nodenv, tfenv for unified version management
- Use Homebrew for tools that don't need per-project versioning

</details>

## 含まれる設定

| ディレクトリ | 説明 |
| ------------- | ------ |
| `nvim/` | Neovim設定（lazy.nvim、LSP、Telescope、NeoTree等） |
| `wezterm/` | WezTermターミナル設定 |
| `zsh/` | Zsh設定（.zshrc、.zprofile） |
| `homebrew/` | Brewfile（パッケージ管理） |
| `mise/` | miseバージョン管理設定 |
| `starship.toml` | Starshipプロンプト設定 |
| `claude/` | Claude Code設定（品質担保のため`SELF_REVIEW_CHECKLIST.md`を作成して配置） |
| `git-hooks/` | Gitフック（pre-push等） |
| `act/` | GitHub Actions ローカル実行設定 |

## セットアップ

### 1. リポジトリのクローン

```bash
ghq get git@github.com:kenshin-morioka/dotfiles.git
# または
git clone git@github.com:kenshin-morioka/dotfiles.git ~/src/github.com/kenshin-morioka/dotfiles
```

### 2. Homebrewのインストール

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. パッケージのインストール

```bash
cd ~/src/github.com/kenshin-morioka/dotfiles
make brew
```

### 4. シンボリックリンクの作成

```bash
make link
```

### 5. fzfキーバインドのインストール

```bash
$(brew --prefix)/opt/fzf/install
```

### 6. セルフレビューチェックリストの作成

```bash
make claude-init
```

※ 中身は自分でカスタマイズしてください

## Makeコマンド

```bash
make help  # 利用可能なコマンド一覧を表示
```

| コマンド | 説明 |
| --------- | ------ |
| `make link` | シンボリックリンクを作成 |
| `make unlink` | シンボリックリンクを削除 |
| `make brew` | Brewfileの全パッケージをインストール |
| `make brew-add PKG=xxx` | パッケージを追加・インストール |
| `make brew-add-cask PKG=xxx` | Caskを追加・インストール |
| `make brew-sync` | インストール済みパッケージをBrewfileに同期 |
| `make brew-list` | Brewfileの内容を表示 |
| `make claude-init` | セルフレビューチェックリストを生成 |

## パッケージ管理の使い分け

| ツール | 用途 | 例 |
| ------ | ---- | --- |
| **Homebrew** | システム基盤ツール、GUIアプリ（cask） | git, neovim, mise, claude-code |
| **mise** | 言語ランタイム、開発ツール（バージョン管理が必要なもの） | node, ruby, go, pnpm |

- rbenv, nodenv, tfenv などの個別バージョンマネージャーは **mise** で統一
- Homebrewは主にシステム全体で1つのバージョンで良いツールに使用

## 主要ツール

### エディタ

- **Neovim** - メインエディタ（lazy.nvimでプラグイン管理）

### ターミナル

- **WezTerm** - GPUアクセラレーション対応ターミナル
- **Starship** - カスタマイズ可能なプロンプト
- **Zsh + Antigen** - シェル環境

### 開発ツール

- **mise** - 複数言語のバージョン管理
- **lazygit** - TUI Git クライアント
- **fzf / peco** - ファジーファインダー
- **ripgrep** - 高速テキスト検索
- **ghq** - リポジトリ管理

### リンター / フォーマッター

- **selene** - Lua
- **shellcheck** - Shell
- **jsonlint** - JSON
- **markdownlint** - Markdown
- **typos** - スペルチェック（全ファイル）
- **stylua** - Lua formatter
- **shfmt** - Shell formatter
- **prettier** - JSON/YAML/Markdown formatter
- **taplo** - TOML formatter

## トラブルシューティング

### miseのtrust エラー

```text
Config files ... are not trusted. Trust them with `mise trust`.
```

miseはセキュリティのため、Git管理下の設定ファイルを明示的に信頼する必要があります。

```bash
mise trust ~/src/github.com/kenshin-morioka/dotfiles/mise/config.toml
```

### pre-commitフックの設定

```bash
pre-commit install
```
