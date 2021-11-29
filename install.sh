#!/usr/bin/env bash

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

GITEMAIL=$(git config --get user.email)

[ -d ~/.additional_dotfiles ] || (mkdir -p ~/.additional_dotfiles && touch ~/.additional_dotfiles/credentials)

# Install homebrew
which brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "🔵  Setting up zsh"

# Install oh-my-zsh
printf "Cloning oh-my-zsh..."
[ -d ~/.oh-my-zsh ] || sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
printf " ✅\n"

# Install ZSH plugins
printf "Cloning zsh plugins..."
[ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ] || git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
printf " ✅\n"

# Install tools
BREW_TOOLS=(
  argocd bandwhich bat danielfoehrkn/switch/switch derailed/k9s/k9s dive dog duf dust exa fd fzf
  git-delta git-delta go helm homebrew/cask-fonts/font-open-dyslexic-nerd-font htop jq kind krew
  kubectl kubectx kustomize node procs progress ripgrep rs/tap/curlie rust starship
  tektoncd/tools/tektoncd-cli tldr tailscale
  )
CARGO_TOOLS=( macchina bottom )
NODE_TOOLS=( git-split-diffs )
KREW_TOOLS=( gs )

echo "🔵  Installing / updating tools"

# Homebrew
export HOMEBREW_NO_INSTALL_CLEANUP=true
for tool in "${BREW_TOOLS[@]}"
do
  printf "${tool}..."
  brew upgrade ${tool} &>/dev/null || brew install ${tool} &>/dev/null
  printf " ✅\n"
done

# Cargo
for tool in "${CARGO_TOOLS[@]}"
do
  printf "${tool}..."
  cargo install ${tool} &>/dev/null
  printf " ✅\n"
done

# Krew
kubectl-krew update &>/dev/null
for tool in "${KREW_TOOLS[@]}"
do
  printf "${tool}..."
  kubectl-krew upgrade ${tool} &>/dev/null || kubectl-krew install ${tool} &>/dev/null
  printf " ✅\n"
done

echo "🔵  Adding configuration"
FILES=$(find ./home -maxdepth 1 -mindepth 1 -printf '%f ')
for file in $FILES
do
  f=$(readlink -f "./home/${file}")
  printf "Linking ${f}..."
  ln -sfn ${f} ~/$(basename "./home/${file}")
  printf " ✅\n"
done


echo "🔵  OS Specific setup"
echo "Detected OS type: ${OSTYPE}"

case "${OSTYPE}" in
  *linux*)
    # Do stuff
    ;;
  *darwin*)
    # Mac specific setup
    BREW_TOOLS=( pinentry-mac gpg gawk coreutils )
    for tool in "${MAC_BREW_TOOLS[@]}"
    do
      printf "${tool}..."
      brew upgrade ${tool} &>/dev/null || brew install ${tool} &>/dev/null
      printf " ✅\n"
    done

    FILES=$(find ./os-specific/darwin/home -maxdepth 1 -mindepth 1 -printf '%f ')
    for file in $FILES
    do
      f=$(readlink -f "./os-specific/darwin/home/${file}")
      printf "Linking ${f}..."
      ln -sfn ${f} ~/$(basename "./os-specific/darwin/home/${file}")
      printf " ✅\n"
    done
    ;;
esac
