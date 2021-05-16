SHELL := bash

.PHONY: Install
install: pre-reqs dotfiles ## Installs all dotfiles and associated.

.PHONY: pre-reqs
pre-reqs: ## Install all required binaries.
	which brew > /dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"; \
	[ -d ~/.oh-my-zsh ] || sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	brew list --cask homebrew/cask-fonts/font-open-dyslexic-nerd-font > /dev/null || brew install homebrew/cask-fonts/font-open-dyslexic-nerd-font; \
	which fzf > /dev/null || brew install fzf; \
	which bat > /dev/null || brew install bat; \
	which curlie > /dev/null || brew install rs/tap/curlie; \
	which exa > /dev/null || brew install exa; \
	which kubectl > /dev/null || brew install kubectl; \
	which tkn > /dev/null || brew install tektoncd/tools/tektoncd-cli; \
	which k9s > /dev/null || brew install k9s; \
	which helm > /dev/null || brew install helm; \
	which go > /dev/null || brew install go; \
	which jq > /dev/null || brew install jq; \
	which kind > /dev/null || brew install kind; \
	which kubectx > /dev/null || brew install kubectx; \
	which tldr > /dev/null || brew install tldr; \
	which progress > /dev/null || brew install progress; \
	which htop > /dev/null || brew install htop; \
	which starship > /dev/null || brew install starship

.PHONY: upgrade
upgrade: ## Upgrade all required binaries.
	brew list --cask homebrew/cask-fonts/font-open-dyslexic-nerd-font > /dev/null && brew upgrade homebrew/cask-fonts/font-open-dyslexic-nerd-font; \
	which fzf > /dev/null && brew upgrade fzf; \
	which bat > /dev/null && brew upgrade bat; \
	which curlie > /dev/null && brew upgrade rs/tap/curlie; \
	which exa > /dev/null && brew upgrade exa; \
	which kubectl > /dev/null && brew upgrade kubectl; \
	which tkn > /dev/null && brew upgrade tektoncd/tools/tektoncd-cli; \
	which k9s > /dev/null && brew upgrade k9s; \
	which helm > /dev/null && brew upgrade helm; \
	which go > /dev/null && brew upgrade go; \
	which jq > /dev/null && brew upgrade jq; \
	which kind > /dev/null && brew upgrade kind; \
	which kubectx > /dev/null && brew upgrade kubectx; \
	which tldr > /dev/null && brew upgrade tldr; \
	which progress > /dev/null && brew upgrade progress; \
	which htop > /dev/null && brew upgrade htop; \
	which starship > /dev/null && brew upgrade starship

.PHONY: dotfiles
dotfiles: ## Installs the dotfiles.
	@GITEMAIL=$$(git config --get user.email); \
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".k9s" -not -name ".github" -not -name ".*.swp" -not -name ".gnupg"); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/$$f; \
	done; \
	git config --system --add user.email $$GITEMAIL; \
	mkdir -p $(HOME)/.additional_dotfiles; touch $(HOME)/.additional_dotfiles/credentials; \
	mkdir -p $(HOME)/.config; \
	for file in $(shell find $(CURDIR)/.config -type f); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/.config/$$f; \
	done; \
	mkdir -p $(HOME)/.k9s; \
	for file in $(shell find $(CURDIR)/.k9s -type f); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/.k9s/$$f; \
	done; \

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
