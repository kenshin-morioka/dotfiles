# Ruby LSP セットアップガイド

Neovim で ruby-lsp を使用するための環境構築手順。

## 前提条件

- Neovim (0.11+)
- mise でインストールされた Ruby
- Homebrew

## 1. Homebrew パッケージのインストール

mysql2 gem のビルドに必要なライブラリをインストールする。

```bash
brew install mysql-client zstd
```

> mysql-client: mysql2 gem の native extensions ビルドに必要
> zstd: mysql2 のリンク時に必要な圧縮ライブラリ

## 2. mysql2 gem のインストール

mysql-client のライブラリパスを指定してインストールする。

```bash
gem install mysql2 -- --with-ldflags="-L/opt/homebrew/opt/zstd/lib"
```

> `ld: library 'zstd' not found` エラーが出る場合はこのフラグが必要。

## 3. Ruby LSP の確認

Neovim で Ruby ファイルを開き、以下のコマンドで ruby-lsp が起動しているか確認する。

```vim
:lua print(vim.inspect(vim.lsp.get_clients({name = 'ruby_lsp'})))
```

## 設定のポイント

### root_markers の設定

`lspconfig.lua` で `root_markers = { '.git', 'Gemfile' }` を設定している。

```lua
vim.lsp.config('ruby_lsp', {
  root_markers = { '.git', 'Gemfile' },
  -- ...
})
```

`.git` を `Gemfile` より優先することで、Rails エンジン（サブディレクトリに独自の gemspec を持つ構造）内のファイルを開いた際に、親プロジェクトのルートが root_dir として使用される。これにより、プロジェクト全体のファイルがインデックスされ、別ファイルへの定義ジャンプが正しく動作する。

### conform.nvim との連携

フォーマッタは conform.nvim で管理している。ruby-lsp の LSP フォーマットと重複しないよう、conform 側で rubocop を指定している。

```lua
-- conform.lua
ruby = { 'rubocop' },
```

## 使用できる LSP 機能

| キー | 機能 |
| --- | --- |
| `gd` | 定義ジャンプ（別ファイルへのジャンプも可能） |
| `gr` | 参照一覧 |
| `gt` | 型定義ジャンプ |
| `<leader>K` | ホバー情報（ドキュメント表示） |
| `<C-k>` | シグネチャヘルプ |
| `<leader>rn` | リネーム |
| `<leader>ca` | コードアクション |
| `[d` / `]d` | 診断（エラー/警告）移動 |

> `gD`（宣言ジャンプ）と `gi`（実装ジャンプ）は ruby-lsp では未サポート。

## トラブルシューティング

### ruby-lsp が起動しない（exit code 1）

LSP ログを確認する。

```bash
tail -50 ~/.local/state/nvim/lsp.log
```

### "Ignoring prism-X.X.X because its extensions are not built"

native extensions が壊れている。以下で修復する。

```bash
gem uninstall prism --all --force
gem uninstall rbs --all --force
gem install prism
gem install rbs
```

### "Could not find prism/rbs in locally installed gems"

`.ruby-lsp` キャッシュが壊れている可能性がある。

```bash
# プロジェクトルート（およびサブディレクトリ）の .ruby-lsp を削除
rm -rf .ruby-lsp
rm -rf <サブディレクトリ>/.ruby-lsp
```

bundler が古い場合も原因になる。

```bash
gem update bundler
```

### mysql2 のビルドエラー

#### "mysql client is missing"

```bash
brew install mysql-client
```

#### "library 'zstd' not found"

```bash
brew install zstd
gem install mysql2 -- --with-ldflags="-L/opt/homebrew/opt/zstd/lib"
```

### 定義ジャンプで "no locations found"

1. root_dir が正しいか確認する。

```vim
:lua print(vim.inspect(vim.lsp.get_clients({name = 'ruby_lsp'})[1].config.root_dir))
```

1. ワークスペースシンボルが見つかるか確認する。

```vim
:lua vim.lsp.buf.workspace_symbol('ClassName')
```

- シンボルが見つからない場合: root_dir が正しくない、またはインデクサが完了していない可能性がある
- Rails のマジック（`has_many`, `scope` 等）で生成されるメソッドは静的解析では追えない場合がある
