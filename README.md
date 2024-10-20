# dotfiles

## before clone

```
mkdir -p ~/.config
sudo vim /etc/zshenv
ZDOTDIR=$HOME/.config/zsh
cd .config
```

## after clone

homebrew の install

```
brew update && brew upgrade
brew install git fzf ghq startship neovim lazygit
# fzfのショートカットコマンドインストール
$(brew --prefix)/opt/fzf/install
```
