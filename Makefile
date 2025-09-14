SHELL := /usr/bin/env bash

DOTFILES_DIR := $(HOME)/src/github.com/kenshin-morioka/dotfiles

# リンク定義 (link先:元ファイル)
LINKS := \
	$(HOME)/.zshrc:$(DOTFILES_DIR)/zsh/.zshrc \
	$(HOME)/.zprofile:$(DOTFILES_DIR)/zsh/.zprofile \
	$(HOME)/.config/nvim:$(DOTFILES_DIR)/nvim \
	$(HOME)/.config/starship.toml:$(DOTFILES_DIR)/starship.toml \
	$(HOME)/.config/wezterm:$(DOTFILES_DIR)/wezterm \
	$(HOME)/.config/mise:$(DOTFILES_DIR)/mise \
	$(HOME)/.config/act:$(DOTFILES_DIR)/act \
	$(HOME)/.config/flipper:$(DOTFILES_DIR)/flipper \
	$(HOME)/.config/github-copilot:$(DOTFILES_DIR)/github-copilot

default: help

## Create all symlinks
link:
	@echo "🔗 Creating symlinks..."
	@for pair in $(LINKS); do \
		dst="$${pair%%:*}"; \
		src="$${pair##*:}"; \
		mkdir -p "$$(dirname "$$dst")"; \
		ln -snf "$$src" "$$dst"; \
		echo "  Linked $$dst -> $$src"; \
	done

## Remove all symlinks
unlink:
	@echo "❌ Removing symlinks..."
	@for pair in $(LINKS); do \
		dst="$${pair%%:*}"; \
		if [ -L "$$dst" ]; then \
			rm "$$dst"; \
			echo "  Unlinked $$dst"; \
		fi \
	done

## Show available commands
help:
	@echo "Available make commands:"
	@grep -E '^##' Makefile | sed -E 's/^## (.*)/  \1/' | awk 'NR % 2 == 1 {printf "%-15s", $$0} NR % 2 == 0 {print $$0}'
