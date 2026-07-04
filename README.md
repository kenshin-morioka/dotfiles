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

Basically a single `make install` does everything (idempotent — safe to re-run).

1. Clone: `ghq get git@github.com:kenshin-morioka/dotfiles.git`
2. Install Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
3. Run `make install` — this runs `make brew` (packages), `make link` (symlinks), `make macos-defaults`, fzf keybindings install, `make tmux-init` (TPM), `make claude-init` (checklist template), `pre-commit install`, and `mise trust` all at once
4. Post-install manual steps: launch tmux and press `Ctrl-b I` to fetch plugins; customize the generated self-review checklist yourself
5. (Optional) Build the Finder-double-click → Neovim launcher .app: `make macos-app` — creates `~/Applications/OpenInNeovim.app`. Assign it as the default opener via Finder → `Cmd+I` → "Open with" → "Change All...". If TCC prompts get annoying across folders (Desktop / Documents / etc.), add `OpenInNeovim.app` to System Settings → Privacy & Security → Full Disk Access.

Each step can also be run individually (see Make Commands below).

## Make Commands

| Command | Description |
| --- | --- |
| `make install` | One-shot machine setup (idempotent, safe to re-run) |
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

基本は `make install` 一発で完了します（冪等なので何度実行しても安全です）。

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

### 3. 一括セットアップ

```bash
cd ~/src/github.com/kenshin-morioka/dotfiles
make install
```

以下がまとめて実行されます。各ステップは冪等なので、途中で失敗しても再実行するだけで続きから揃います。

| ステップ | 内容 |
| -------- | ---- |
| `make brew` | Brewfile の全パッケージをインストール |
| `make link` | シンボリックリンクを作成 |
| `make macos-defaults` | macOS defaults を適用 |
| fzf キーバインド | `$(brew --prefix)/opt/fzf/install` を rc 非改変オプション付きで実行 |
| `make tmux-init` | TPM (Tmux Plugin Manager) をインストール |
| `make claude-init` | セルフレビューチェックリストの雛形を生成 |
| `pre-commit install` | pre-commit フックをリポジトリに設定 |
| `mise trust` | `mise/config.toml` を信頼 |

セットアップ後の手動作業:

- tmux を起動し `Ctrl-b I` (Shift+i) でプラグイン (resurrect / continuum / vim-tmux-navigator 等) を取得
- `make claude-init` で生成されたチェックリストの中身を自分でカスタマイズ

各ステップは `make brew` / `make link` のように個別にも実行できます（詳細は後述の「Makeコマンド」参照）。

### 4. (任意) Finder ダブルクリックで Neovim を起動するランチャー .app を生成

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
| `make install` | 新マシンのセットアップを一括実行（冪等・再実行可） |
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
`make install` 実行時に自動で trust されますが、個別に実行する場合は以下の通りです。

```bash
mise trust ~/src/github.com/kenshin-morioka/dotfiles/mise/config.toml
```

### pre-commitフックの設定

`make install` 実行時に自動で設定されますが、個別に実行する場合は以下の通りです。

```bash
pre-commit install
```
