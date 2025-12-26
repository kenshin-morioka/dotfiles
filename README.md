# dotfiles

## after clone

homebrew の install

```
brew update && brew upgrade
brew install git fzf ghq startship neovim lazygit peco act direnv bash
# fzfのショートカットコマンドインストール
$(brew --prefix)/opt/fzf/install

# antigenのインストール
mkdir -p ~/.local/bin
curl -L git.io/antigen > ~/.local/bin/antigen.zsh

# makeコマンド
make link
```
