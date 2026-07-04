#!/bin/bash
set -euo pipefail

# macOS の defaults (アプリ個別設定) を適用するスクリプト。適用後は対象アプリの再起動が必要。

# WezTerm: キー長押し時のアクセント文字ポップアップ (PressAndHold) を無効化。
# macOS 26.5 以降、PressAndHold と WezTerm の IME 連携 (use_ime = true) が競合し、
# キー長押し (例: nvim で j 押しっぱなし) 後にそのウィンドウ全体で文字入力が
# 効かなくなるため必須 (発生時は入力ソース切替で復旧可能)。
defaults write com.github.wez.wezterm ApplePressAndHoldEnabled -bool false

echo "✅ macOS defaults を適用しました (対象アプリの再起動が必要)"
