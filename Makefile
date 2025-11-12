# - [Makefileを自己文書化する | POSTD](https://postd.cc/auto-documented-makefile/)
# - [タスク・ランナーとしてのMake \#Makefile - Qiita](https://qiita.com/shakiyam/items/cdd3c11eba978202a628)
# - [Makefile の関数一覧 | 晴耕雨読](https://tex2e.github.io/blog/makefile/functions)
# - [Makefileでシェルスクリプトを便利にする.ONESHELL](https://zenn.dev/mirablue/articles/20241208-make-oneshell)

SHELL := /usr/bin/env bash
.SHELLFLAGS := -o errexit -o nounset -o pipefail -o posix -c
.DEFAULT_GOAL := help
DOTFILES_DIR := $(HOME)/src/github.com/kenshin-morioka/dotfiles

# all targets are phony
.PHONY: $(grep -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | sed 's/://')

help:  ## print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# リンク定義 (link先:元ファイル)
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
	$(DOTFILES_DIR)/.git/hooks/pre-push:$(DOTFILES_DIR)/git-hooks/pre-push

# --------------------------------------
# Symbolic Links
#
link:  ## make symbolic links
	@echo "🔗 Creating symlinks..."
	@for pair in $(LINKS); do \
		dst="$${pair%%:*}"; \
		src="$${pair##*:}"; \
		mkdir -p "$$(dirname "$$dst")"; \
		ln -snf "$$src" "$$dst"; \
		echo "  Linked $$dst -> $$src"; \
	done

unlink:  ## unlink symbolic links
	@echo "❌ Removing symlinks..."
	@for pair in $(LINKS); do \
		dst="$${pair%%:*}"; \
		if [ -L "$$dst" ]; then \
			rm "$$dst"; \
			echo "  Unlinked $$dst"; \
		fi \
	done
