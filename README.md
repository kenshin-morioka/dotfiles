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
brew install git fzf ghq startship neovim lazygit peco act
# fzfのショートカットコマンドインストール
$(brew --prefix)/opt/fzf/install

rm ~/.zsh_history
rm ~/.zsh_history
rm .zprofile

# antigenのインストール
mkdir -p ~/.local/bin
curl -L git.io/antigen > ~/.local/bin/antigen.zsh
```
