# dotfiles

macOS向けの個人用dotfiles設定ファイル集です。

## 含まれる設定

| ディレクトリ | 説明 |
| ------------- | ------ |
| `nvim/` | Neovim設定（lazy.nvim、LSP、Telescope、NeoTree等） |
| `wezterm/` | WezTermターミナル設定 |
| `zsh/` | Zsh設定（.zshrc、.zprofile） |
| `homebrew/` | Brewfile（パッケージ管理） |
| `mise/` | miseバージョン管理設定 |
| `starship.toml` | Starshipプロンプト設定 |
| `claude/` | Claude Code設定 |
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
