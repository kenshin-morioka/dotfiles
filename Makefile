# 参考リンク
# - [Makefileを自己文書化する | POSTD](https://postd.cc/auto-documented-makefile/)
# - [タスク・ランナーとしてのMake \#Makefile - Qiita](https://qiita.com/shakiyam/items/cdd3c11eba978202a628)
# - [Makefile の関数一覧 | 晴耕雨読](https://tex2e.github.io/blog/makefile/functions)
# - [Makefileでシェルスクリプトを便利にする.ONESHELL](https://zenn.dev/mirablue/articles/20241208-make-oneshell)

SHELL := /usr/bin/env bash
.SHELLFLAGS := -o errexit -o nounset -o pipefail -o posix -c
.DEFAULT_GOAL := help
DOTFILES_DIR := $(HOME)/src/github.com/kenshin-morioka/dotfiles

# 全ターゲットをphonyに設定
.PHONY: $(grep -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | sed 's/://')

help:  ## ヘルプを表示
	@echo '使い方: make [target]'
	@echo ''
	@echo 'ターゲット一覧:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# リンク定義 (リンク先:元ファイル)
LINKS := \
	$(HOME)/.zshrc:$(DOTFILES_DIR)/zsh/.zshrc \
	$(HOME)/.zprofile:$(DOTFILES_DIR)/zsh/.zprofile \
	$(HOME)/.config/nvim:$(DOTFILES_DIR)/nvim \
	$(HOME)/.config/starship.toml:$(DOTFILES_DIR)/starship.toml \
	$(HOME)/.config/wezterm:$(DOTFILES_DIR)/wezterm \
	$(HOME)/.config/mise:$(DOTFILES_DIR)/mise \
	$(HOME)/.config/act:$(DOTFILES_DIR)/act \
	$(HOME)/.claude/CLAUDE.md:$(DOTFILES_DIR)/claude/CLAUDE.md \
	$(HOME)/.claude/SELF_REVIEW_CHECKLIST.md:$(DOTFILES_DIR)/claude/SELF_REVIEW_CHECKLIST.md \
	$(HOME)/.config/flipper:$(DOTFILES_DIR)/flipper \
	$(HOME)/.config/github-copilot:$(DOTFILES_DIR)/github-copilot \
	$(DOTFILES_DIR)/.git/hooks/pre-push:$(DOTFILES_DIR)/git-hooks/pre-push \
	$(HOME)/.cowsay:$(DOTFILES_DIR)/cowsay \
	$(HOME)/.gitconfig:$(DOTFILES_DIR)/git/.gitconfig \
	$(HOME)/.gitconfig.local:$(DOTFILES_DIR)/git/.gitconfig.local

# --------------------------------------
# シンボリックリンク
#
link:  ## シンボリックリンクを作成
	@echo "🔗 シンボリックリンクを作成中..."
	@for pair in $(LINKS); do \
		dst="$${pair%%:*}"; \
		src="$${pair##*:}"; \
		mkdir -p "$$(dirname "$$dst")"; \
		ln -snf "$$src" "$$dst"; \
		echo "  リンク作成: $$dst -> $$src"; \
	done

unlink:  ## シンボリックリンクを削除
	@echo "❌ シンボリックリンクを削除中..."
	@for pair in $(LINKS); do \
		dst="$${pair%%:*}"; \
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

brew-add:  ## パッケージを追加 (PKG=パッケージ名)
	@if [ -z "$(PKG)" ]; then \
		echo "❌ 使い方: make brew-add PKG=<パッケージ名>"; \
		exit 1; \
	fi
	@if grep -q "^brew \"$(PKG)\"" "$(BREWFILE)"; then \
		echo "⚠️  $(PKG) は既にBrewfileに存在します"; \
	else \
		echo "brew \"$(PKG)\"" >> "$(BREWFILE)"; \
		brew install $(PKG); \
		echo "✅ $(PKG) を追加・インストールしました"; \
	fi

brew-add-cask:  ## Caskを追加 (PKG=パッケージ名)
	@if [ -z "$(PKG)" ]; then \
		echo "❌ 使い方: make brew-add-cask PKG=<パッケージ名>"; \
		exit 1; \
	fi
	@if grep -q "^cask \"$(PKG)\"" "$(BREWFILE)"; then \
		echo "⚠️  $(PKG) は既にBrewfileに存在します"; \
	else \
		echo "cask \"$(PKG)\"" >> "$(BREWFILE)"; \
		brew install --cask $(PKG); \
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
# Claude Code
#
CHECKLIST_FILE := $(DOTFILES_DIR)/claude/SELF_REVIEW_CHECKLIST.md

claude-init:  ## セルフレビューチェックリストを生成
	@if [ -f "$(CHECKLIST_FILE)" ]; then \
		echo "⚠️  $(CHECKLIST_FILE) は既に存在します"; \
	else \
		mkdir -p "$$(dirname "$(CHECKLIST_FILE)")"; \
		echo "<!-- セルフレビューチェックリストを作成してください -->" > "$(CHECKLIST_FILE)"; \
		echo "✅ $(CHECKLIST_FILE) を作成しました"; \
	fi
