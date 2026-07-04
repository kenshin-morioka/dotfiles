# 参考リンク
# - [Makefileを自己文書化する | POSTD](https://postd.cc/auto-documented-makefile/)
# - [タスク・ランナーとしてのMake \#Makefile - Qiita](https://qiita.com/shakiyam/items/cdd3c11eba978202a628)
# - [Makefile の関数一覧 | 晴耕雨読](https://tex2e.github.io/blog/makefile/functions)
# - [Makefileでシェルスクリプトを便利にする.ONESHELL](https://zenn.dev/mirablue/articles/20241208-make-oneshell)

SHELL := /usr/bin/env bash
.SHELLFLAGS := -o errexit -o nounset -o pipefail -o posix -c
.DEFAULT_GOAL := help
# Makefile 自身の位置からリポジトリのルートを解決する (CI 等、checkout 先が異なる環境でも動くように)
DOTFILES_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# 全ターゲットをphonyに設定
.PHONY: $(shell grep -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | sed 's/:.*//')

help:  ## ヘルプを表示
	@echo '使い方: make [target]'
	@echo ''
	@echo 'ターゲット一覧:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# --------------------------------------
# 一括セットアップ
#
install:  ## 新マシンのセットアップを一括実行（冪等・再実行可）
	@echo "🚀 セットアップを開始します..."
	@# Homebrew は前提条件。未インストールなら明確に案内して中断する（自動インストールはしない）
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "❌ Homebrew がインストールされていません"; \
		echo "   以下を実行してから再度 make install を実行してください:"; \
		echo '   /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'; \
		exit 1; \
	fi
	@$(MAKE) brew
	@$(MAKE) link
	@$(MAKE) macos-defaults
	@# fzf キーバインド: install スクリプトは ~/.fzf.zsh を同内容で再生成するだけなので再実行しても安全（冪等）。
	@# --no-update-rc により rc ファイルへの追記を抑止する（.zshrc はリポジトリへのシンボリックリンクのため、書き換えられると差分が発生する）。
	@echo "🔑 fzf キーバインドをセットアップ中..."
	@"$$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
	@$(MAKE) tmux-init
	@$(MAKE) claude-init
	@# pre-commit フックを設定（既に設定済みでも同じフックを上書きするだけで冪等）
	@echo "🪝 pre-commit フックを設定中..."
	@cd $(DOTFILES_DIR) && pre-commit install
	@# mise の設定ファイルを信頼（trust 済みでも成功する。mise 未セットアップ等での失敗は || true で無視）
	@echo "🤝 mise 設定を信頼中..."
	@mise trust $(DOTFILES_DIR)/mise/config.toml || true
	@echo "✅ セットアップが完了しました！"

# リンク定義 (リンク先:元ファイル)
LINKS := \
	$(HOME)/.zshrc:$(DOTFILES_DIR)/zsh/.zshrc \
	$(HOME)/.zshenv:$(DOTFILES_DIR)/zsh/.zshenv \
	$(HOME)/.config/nvim:$(DOTFILES_DIR)/nvim \
	$(HOME)/.config/starship.toml:$(DOTFILES_DIR)/starship.toml \
	$(HOME)/.config/wezterm:$(DOTFILES_DIR)/wezterm \
	$(HOME)/.config/tmux/tmux.conf:$(DOTFILES_DIR)/tmux/tmux.conf \
	$(HOME)/.config/mise:$(DOTFILES_DIR)/mise \
	$(HOME)/.config/atuin:$(DOTFILES_DIR)/atuin \
	$(HOME)/.config/act:$(DOTFILES_DIR)/act \
	$(HOME)/.claude/CLAUDE.md:$(DOTFILES_DIR)/claude/CLAUDE.md \
	$(HOME)/.claude/settings.json:$(DOTFILES_DIR)/claude/settings.json \
	$(HOME)/.claude/checklists:$(DOTFILES_DIR)/claude/checklists \
	$(HOME)/.claude/skills:$(DOTFILES_DIR)/claude/skills \
	$(HOME)/.claude/agents:$(DOTFILES_DIR)/claude/agents \
	$(HOME)/.claude/commands:$(DOTFILES_DIR)/claude/commands \
	$(HOME)/.claude/hooks:$(DOTFILES_DIR)/claude/hooks \
	$(HOME)/.claude/statusline-command.sh:$(DOTFILES_DIR)/claude/statusline-command.sh \
	$(HOME)/.config/flipper:$(DOTFILES_DIR)/flipper \
	$(HOME)/.config/github-copilot:$(DOTFILES_DIR)/github-copilot \
	$(HOME)/.cowsay:$(DOTFILES_DIR)/cowsay \
	$(HOME)/.gitconfig:$(DOTFILES_DIR)/git/.gitconfig \
	$(HOME)/.gitconfig.local:$(DOTFILES_DIR)/git/.gitconfig.local

# --------------------------------------
# シンボリックリンク
#
# LINKS の各要素から リンク先(dst) と 元ファイル(src) を取り出す共通処理
define split_pair
dst="$${pair%%:*}"; src="$${pair##*:}"
endef

link:  ## シンボリックリンクを作成
	@echo "🔗 シンボリックリンクを作成中..."
	@for pair in $(LINKS); do \
		$(split_pair); \
		if [ ! -e "$$src" ]; then \
			echo "  skip: $$src (not found)"; \
			continue; \
		fi; \
		mkdir -p "$$(dirname "$$dst")"; \
		ln -snf "$$src" "$$dst"; \
		echo "  リンク作成: $$dst -> $$src"; \
	done

unlink:  ## シンボリックリンクを削除
	@echo "❌ シンボリックリンクを削除中..."
	@for pair in $(LINKS); do \
		$(split_pair); \
		if [ -L "$$dst" ]; then \
			rm "$$dst"; \
			echo "  リンク削除: $$dst"; \
		fi \
	done

# --------------------------------------
# Homebrew
#
BREWFILE := $(DOTFILES_DIR)/homebrew/Brewfile

brew:  ## 全パッケージをインストール
	@echo "🍺 パッケージをインストール中..."
	brew bundle --file=$(BREWFILE)

# brew-add / brew-add-cask は共通レシピ。違いは Brewfile の行種別と install フラグのみ
brew-add:  ## パッケージを追加 (PKG=パッケージ名)
brew-add: BREW_ENTRY := brew
brew-add: BREW_INSTALL_FLAGS :=

brew-add-cask:  ## Caskを追加 (PKG=パッケージ名)
brew-add-cask: BREW_ENTRY := cask
brew-add-cask: BREW_INSTALL_FLAGS := --cask

brew-add brew-add-cask:
	@if [ -z "$(PKG)" ]; then \
		echo "❌ 使い方: make $@ PKG=<パッケージ名>"; \
		exit 1; \
	fi
	@if grep -q "^$(BREW_ENTRY) \"$(PKG)\"" "$(BREWFILE)"; then \
		echo "⚠️  $(PKG) は既にBrewfileに存在します"; \
	else \
		brew install $(BREW_INSTALL_FLAGS) $(PKG); \
		echo "$(BREW_ENTRY) \"$(PKG)\"" >> "$(BREWFILE)"; \
		echo "✅ $(PKG) を追加・インストールしました"; \
	fi

brew-sync:  ## 現在のパッケージをBrewfileに同期
	@echo "🔄 インストール済みパッケージをBrewfileに同期中..."
	@brew bundle dump --force --file=$(BREWFILE)
	@echo "✅ Brewfileを更新しました"

brew-list:  ## Brewfileの内容を表示
	@echo "📦 Brewfileのパッケージ一覧:"
	@cat "$(BREWFILE)"

# --------------------------------------
# Neovim
#
nvim-update:  ## Neovim プラグインを更新してコミット & push まで実行
	@echo "🔄 Neovim プラグインを更新中..."
	@nvim --headless "+Lazy! sync" +qa
	@$(MAKE) lazy-commit

lazy-commit:  ## nvim/lazy-lock.json の変更だけをコミット & push
	@cd $(DOTFILES_DIR) && { \
		other_changes=$$(git status --porcelain | grep -v 'nvim/lazy-lock.json' || true); \
		if [ -n "$$other_changes" ]; then \
			echo "❌ lazy-lock.json 以外の変更があります:"; \
			echo "$$other_changes"; \
			exit 1; \
		fi; \
		if git diff --quiet -- nvim/lazy-lock.json && git diff --cached --quiet -- nvim/lazy-lock.json; then \
			echo "✅ lazy-lock.json に変更なし"; \
			exit 0; \
		fi; \
		git add nvim/lazy-lock.json; \
		git commit -m "lazy update"; \
		git push origin HEAD; \
		echo "✅ lazy update を push しました"; \
	}

# --------------------------------------
# tmux
#
TPM_DIR := $(HOME)/.config/tmux/plugins/tpm

tmux-init:  ## TPM (Tmux Plugin Manager) をインストール
	@if [ -d "$(TPM_DIR)" ]; then \
		echo "⚠️  TPM は既にインストール済みです: $(TPM_DIR)"; \
	else \
		echo "📦 TPM をクローン中..."; \
		git clone https://github.com/tmux-plugins/tpm "$(TPM_DIR)"; \
		echo "✅ TPM をインストールしました。tmux 起動後に prefix + I でプラグインを取得してください"; \
	fi

# --------------------------------------
# macOS Launcher App (Finder ダブルクリック → Neovim)
#
MACOS_APP_NAME := OpenInNeovim
MACOS_APP_DST := $(HOME)/Applications/$(MACOS_APP_NAME).app
MACOS_APP_SRC := $(DOTFILES_DIR)/macos/$(MACOS_APP_NAME).applescript
MACOS_APP_ICON_SRC := $(DOTFILES_DIR)/macos/icons/$(MACOS_APP_NAME).png
MACOS_APP_ID := com.kenshin-morioka.openinneovim
LSREGISTER := /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister

macos-app:  ## Finder ダブルクリックで Neovim を開く .app を ~/Applications に生成
	@echo "🛠  $(MACOS_APP_NAME).app をビルド中..."
	@mkdir -p "$(HOME)/Applications"
	@rm -rf "$(MACOS_APP_DST)"
	@osacompile -o "$(MACOS_APP_DST)" "$(MACOS_APP_SRC)"
	@# osacompile 既定では CFBundleIdentifier が空で Launch Services がデフォルトハンドラ登録を拒否するため埋める
	@plist="$(MACOS_APP_DST)/Contents/Info.plist"; \
		/usr/libexec/PlistBuddy -c "Delete :CFBundleIdentifier" "$$plist" 2>/dev/null || true; \
		/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $(MACOS_APP_ID)" "$$plist"
	@# Neovim ロゴ PNG をマルチ解像度 .icns にして差し替え。
	@# osacompile の `on open` ハンドラ付き .app は droplet 扱いで CFBundleIconFile=droplet なので droplet.icns を上書きする。
	@# また Assets.car (compiled icon catalog) が .icns より優先されるため削除する。
	@iconset="$$(mktemp -d)/$(MACOS_APP_NAME).iconset"; mkdir -p "$$iconset"; \
		for size in 16 32 64 128 256 512; do \
			sips -z $$size $$size "$(MACOS_APP_ICON_SRC)" --out "$$iconset/icon_$${size}x$${size}.png" >/dev/null; \
		done; \
		iconutil -c icns "$$iconset" -o "$(MACOS_APP_DST)/Contents/Resources/droplet.icns"; \
		cp "$(MACOS_APP_DST)/Contents/Resources/droplet.icns" "$(MACOS_APP_DST)/Contents/Resources/applet.icns"
	@rm -f "$(MACOS_APP_DST)/Contents/Resources/Assets.car"
	@codesign --force --deep --sign - "$(MACOS_APP_DST)"
	@$(LSREGISTER) -f "$(MACOS_APP_DST)"
	@echo "✅ $(MACOS_APP_DST) を生成しました (bundle id: $(MACOS_APP_ID))"
	@echo "   Finder で対象ファイルを右クリック → 情報を見る → このアプリケーションで開く → $(MACOS_APP_NAME) → すべてを変更"

macos-defaults:  ## macOS の defaults を適用 (WezTerm の PressAndHold 無効化等)
	@bash "$(DOTFILES_DIR)/macos/defaults.sh"

# --------------------------------------
# Claude Code
#
CHECKLIST_DIR := $(DOTFILES_DIR)/claude/checklists

claude-init:  ## セルフレビューチェックリストディレクトリを生成
	@if [ -d "$(CHECKLIST_DIR)" ]; then \
		echo "⚠️  $(CHECKLIST_DIR) は既に存在します"; \
	else \
		mkdir -p "$(CHECKLIST_DIR)"; \
		echo "<!-- セルフレビューチェックリストを作成してください -->" > "$(CHECKLIST_DIR)/SELF_REVIEW_CHECKLIST.md"; \
		echo "✅ $(CHECKLIST_DIR) を作成しました"; \
	fi
