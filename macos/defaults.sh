#!/bin/bash
set -euo pipefail

# macOS の defaults を適用するスクリプト。冪等なので何度実行してもよい。
# NSGlobalDomain 系はアプリの再起動 (確実なのは再ログイン) 後に反映される。

# --------------------------------------
# キーボード
#
# キーリピートを最速化 (システム設定のスライダー最速値より速い)
# KeyRepeat: リピート間隔 (2 = 30ms)
defaults write NSGlobalDomain KeyRepeat -int 2
# InitialKeyRepeat: リピート開始までの待ち (15 = 225ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# キー長押し時のアクセント文字ポップアップ (PressAndHold) を全アプリで無効化し、
# 長押し = キーリピートにする (vim のカーソル移動等に必要)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# WezTerm: PressAndHold 無効化 (グローバル設定に加えて個別にも明示)。
# macOS 26.5 以降、PressAndHold と WezTerm の IME 連携 (use_ime = true) が競合し、
# キー長押し (例: nvim で j 押しっぱなし) 後にそのウィンドウ全体で文字入力が
# 効かなくなるため必須 (発生時は入力ソース切替で復旧可能)。
defaults write com.github.wez.wezterm ApplePressAndHoldEnabled -bool false

# --------------------------------------
# Finder
#
# すべてのファイルの拡張子を表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# パスバーを表示
defaults write com.apple.finder ShowPathbar -bool true
# ステータスバーを表示
defaults write com.apple.finder ShowStatusBar -bool true
# 検索のデフォルト対象を Mac 全体ではなくカレントフォルダにする
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# 拡張子変更時の警告を無効化
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# --------------------------------------
# スクリーンショット
#
# 保存先を ~/Screenshots に変更 (デスクトップが散らからないように)
mkdir -p "${HOME}/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
# ウィンドウ撮影時の影を無効化
defaults write com.apple.screencapture disable-shadow -bool true
# 保存形式を png に固定
defaults write com.apple.screencapture type -string "png"

# --------------------------------------
# .DS_Store
#
# ネットワークドライブ / USB ドライブに .DS_Store を作らない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --------------------------------------
# Dock
#
# 自動的に隠す
defaults write com.apple.dock autohide -bool true
# 表示までの待ち時間をなくす
defaults write com.apple.dock autohide-delay -float 0
# 表示アニメーションを高速化
defaults write com.apple.dock autohide-time-modifier -float 0.4

# --------------------------------------
# 反映
#
# defaults の変更を反映するため対象プロセスを再起動する
for app in Finder Dock SystemUIServer; do
  killall "${app}" >/dev/null 2>&1 || true
done

echo "✅ macOS defaults を適用しました (キーボード系は再ログイン後に完全反映)"
