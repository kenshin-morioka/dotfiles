# dotfiles

## after clone

homebrew の install

```
brew update && brew upgrade
brew install git fzf ghq startship neovim lazygit peco act direnv bash aws-vault session-manager-plugin
# fzfのショートカットコマンドインストール
$(brew --prefix)/opt/fzf/install

# antigenのインストール
mkdir -p ~/.local/bin
curl -L git.io/antigen > ~/.local/bin/antigen.zsh

# makeコマンド
make link
```

## miseのエラーが出たら

### 起きていること

```
Config files ... are not trusted. Trust them with `mise trust`.
```

mise は .mise.toml や config.toml に 任意コマンドが書けるため、

Git 管理下の設定

他人が書いた可能性のある設定

については、明示的に「これは安全」と宣言しないと読み込まない仕様になっています。

そのため、

```
error parsing config file
```
と出ているが、実際は パース以前にブロックされている状態。

### 対応方法

```
mise trust ~/src/github.com/{profile}/dotfiles/mise/config.toml
```
