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
| `tmux/` | tmux config (TPM, resurrect, continuum, vim-tmux-navigator) |
| `zsh/` | Zsh config (.zshrc, .zprofile) |
| `homebrew/` | Brewfile (package management) |
| `mise/` | mise version manager config |
| `starship.toml` | Starship prompt config |
| `claude/` | Claude Code config (self-review checklists: general, Rails, test/RSpec) |
| `act/` | GitHub Actions local runner config |
| `macos/` | AppleScript source for macOS launcher .app |

## Setup

1. Clone: `ghq get git@github.com:kenshin-morioka/dotfiles.git`
2. Install Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
3. Install packages: `make brew`
4. Create symlinks: `make link`
5. Apply macOS defaults: `make macos-defaults`
6. Install fzf keybindings: `$(brew --prefix)/opt/fzf/install`
7. Install tmux plugin manager: `make tmux-init` (then launch tmux and press `Ctrl-b I` to fetch plugins)
8. Create self-review checklist: `make claude-init` (customize the content yourself)
9. (Optional) Build the Finder-double-click → Neovim launcher .app: `make macos-app` — creates `~/Applications/OpenInNeovim.app`. Assign it as the default opener via Finder → `Cmd+I` → "Open with" → "Change All...". If TCC prompts get annoying across folders (Desktop / Documents / etc.), add `OpenInNeovim.app` to System Settings → Privacy & Security → Full Disk Access.

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
| `make tmux-init` | Install TPM (Tmux Plugin Manager) |
| `make nvim-update` | Run `:Lazy sync` headlessly and commit & push `lazy-lock.json` |
| `make lazy-commit` | Commit & push `lazy-lock.json` only (after updating in nvim) |
| `make macos-app` | Build the Finder-double-click → Neovim launcher .app into `~/Applications` |
| `make macos-defaults` | Apply macOS defaults (disable press-and-hold for WezTerm to avoid IME freeze) |

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
| `tmux/` | tmux設定（TPM、resurrect、continuum、vim-tmux-navigator） |
| `zsh/` | Zsh設定（.zshrc、.zprofile） |
| `homebrew/` | Brewfile（パッケージ管理） |
| `mise/` | miseバージョン管理設定 |
| `starship.toml` | Starshipプロンプト設定 |
| `claude/` | Claude Code設定（セルフレビューチェックリスト: 汎用、Rails、テスト/RSpec） |
| `act/` | GitHub Actions ローカル実行設定 |
| `macos/` | macOS 用ランチャー .app の AppleScript ソース |

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

### 5. macOS defaults の適用

```bash
make macos-defaults
```

### 6. fzfキーバインドのインストール

```bash
$(brew --prefix)/opt/fzf/install
```

### 7. tmux プラグインマネージャ (TPM) のインストール

```bash
make tmux-init
```

その後 tmux を起動し、`Ctrl-b I` (Shift+i) を押すとプラグイン (resurrect / continuum / vim-tmux-navigator 等) が取得されます。

### 8. セルフレビューチェックリストの作成

```bash
make claude-init
```

※ 中身は自分でカスタマイズしてください

### 9. (任意) Finder ダブルクリックで Neovim を起動するランチャー .app を生成

```bash
make macos-app
```

`~/Applications/OpenInNeovim.app` が生成されます。Finder で対象ファイルを選択 → `Cmd+I` → 「このアプリケーションで開く」を `OpenInNeovim` に変更 → 「すべてを変更...」で拡張子ごとに固定できます。

複数フォルダ (デスクトップ / 書類 等) で毎回 TCC プロンプトが出るのが煩わしい場合は、システム設定 → プライバシーとセキュリティ → フルディスクアクセスに `OpenInNeovim.app` を追加してください。

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
| `make tmux-init` | TPM (Tmux Plugin Manager) をインストール |
| `make nvim-update` | ヘッドレスで `:Lazy sync` を実行し `lazy-lock.json` をコミット & push |
| `make lazy-commit` | nvim で更新後、`lazy-lock.json` のみをコミット & push |
| `make macos-app` | Finder ダブルクリックで Neovim を開くランチャー .app を `~/Applications` に生成 |
| `make macos-defaults` | macOS defaults を適用（WezTerm の IME フリーズ回避のため press-and-hold を無効化） |

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
- **tmux** - ターミナルマルチプレクサ（ペイン分割・セッション永続化）
- **Starship** - カスタマイズ可能なプロンプト
- **Zsh + Antigen** - シェル環境

#### tmux 主要キーバインド

prefix キーは `Ctrl-b` (デフォルト)。以下は prefix を押した後のキー。

| キー | 動作 |
| ---- | ---- |
| `\|` | ペイン縦分割（カレントディレクトリ引き継ぎ） |
| `-` | ペイン横分割（カレントディレクトリ引き継ぎ） |
| `c` | 新規ウィンドウ（カレントディレクトリ引き継ぎ） |
| `H` / `J` / `K` / `L` | ペインを5セル分リサイズ |
| `r` | 設定リロード |
| `I` | TPM プラグインインストール |
| `Ctrl-s` | tmux-resurrect でセッション保存 |
| `Ctrl-r` | tmux-resurrect でセッション復元 |
| `[` | コピーモード開始（vi キーバインド、`v` で選択 `y` でコピー） |

prefix 不要のキー (vim-tmux-navigator):

| キー | 動作 |
| ---- | ---- |
| `Ctrl-h/j/k/l` | Neovim split と tmux ペインをシームレス移動 |

#### シェル関数 / abbreviation

| コマンド | 展開先 / 動作 |
| -------- | ------------- |
| `cl` | `clear` |
| `t` | `tmux` (素の起動) |
| `tm` | 既存セッションがあれば fzf で選択して attach、なければ新規作成 |
| `tma` | 全 tmux セッションを WezTerm の新しいタブで一気に attach |
| `tk` | `tmux kill-session` |
| `tka` | `tmux kill-server` |
| `tkr` | tmux-resurrect の `last` リンクを削除（次回起動時の自動復元を断つ） |

### 開発ツール

- **mise** - 複数言語のバージョン管理
- **lazygit** - TUI Git クライアント
- **fzf** - ファジーファインダー
- **ripgrep** - 高速テキスト検索
- **ghq** - リポジトリ管理

### リンター / フォーマッター

- **selene** - Lua
- **shellcheck** - Shell
- **jsonlint** - JSON
- **markdownlint** - Markdown
- **typos** - スペルチェック（全ファイル）
- **gitleaks** - シークレット検出（全ファイル）
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
