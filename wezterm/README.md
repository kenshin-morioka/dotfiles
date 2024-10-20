# 自分専用の wezterm の設定

## 準備

- wezterm と NeoVim をインストール(homebrew)
- 以下を`~/.zshrc`に追記して wezterm バイナリを使用できるようにする

```
PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
export PATH
```

- `mkdir ~/.config`を実行して、`cd ~/.config`で移動
- 本リポジトリをクローン
- `font/Firge35NerdConsole-Regular.ttf`を開いてインストール

## 参考サイト

- https://wezfurlong.org/wezterm/config/lua/general.html
- https://coralpink.github.io/commentary/wezterm/configuration.html
- https://zenn.dev/botamotch/articles/e7960f0dc84d8b
