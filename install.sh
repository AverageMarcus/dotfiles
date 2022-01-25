#!/usr/bin/env bash

export PATH="/home/linuxbrew/.linuxbrew/bin:/opt/homebrew/bin/:$PATH"

GITEMAIL=$(git config --get user.email)

[ -d ~/.additional_dotfiles ] || (mkdir -p ~/.additional_dotfiles && touch ~/.additional_dotfiles/credentials)
[ -d /usr/local/share/zsh/site-functions ] || (sudo mkdir -p /usr/local/share/zsh/site-functions && sudo chmod 777 /usr/local/share/zsh/site-functions)

# Install homebrew
which brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "🔵  Setting up zsh"

# Install oh-my-zsh
printf "Cloning oh-my-zsh..."
[ -d ${HOME}/.oh-my-zsh ] || sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
printf " ✅\n"

# Install ZSH plugins
printf "Cloning zsh plugins..."
[ -d ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ] || git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
printf " ✅\n"

# Install tools
BREW_TOOLS=(
  argocd bandwhich bat danielfoehrkn/switch/switch derailed/k9s/k9s dive dog duf dust exa fd fzf
  git-delta go helm homebrew/cask-fonts/font-open-dyslexic-nerd-font htop jq kind krew
  kubectl kubectx kustomize node procs progress ripgrep rs/tap/curlie rust starship
  tektoncd/tools/tektoncd-cli tldr tailscale yq hashicorp/tap/vault stats
  tabby vale
  )
CARGO_TOOLS=( macchina bottom )
NODE_TOOLS=( git-split-diffs )
KREW_TOOLS=( gs outdated tree stern )

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

fulllink() {
  if [ ! -z `which greadlink` ]
  then
    greadlink -f $1
  else
    readlink -f $1
  fi
}

echo "🔵  OS Specific setup"
echo "Detected OS type: ${OSTYPE}"

case "${OSTYPE}" in
  *linux*)
    # Do stuff
    ;;
  *darwin*)
    # Mac specific setup
    MAC_BREW_TOOLS=( pinentry-mac gpg gawk coreutils wget )
    for tool in "${MAC_BREW_TOOLS[@]}"
    do
      printf "${tool}..."
      brew upgrade ${tool} &>/dev/null || brew install ${tool} &>/dev/null
      printf " ✅\n"
    done


    FILES=$(/usr/bin/find ./os-specific/darwin/home -maxdepth 1 -mindepth 1 | tr '\n' ' ')
    for file in $FILES
    do
      f=$(fulllink "${file}")
      dst="${HOME}/$(basename "./os-specific/darwin/home/${file}")"
      printf "Linking ${f}=>${dst}"
      ln -sfn ${f} ${dst}
      printf " ✅\n"
    done

    [ -f "/usr/local/bin/pinentry-mac" ] || sudo ln -s `which pinentry-mac` /usr/local/bin/pinentry-mac
    gpgconf --kill gpg-agent

    if [ $(gpg --list-secret-keys --keyid-format=long 2>/dev/null | wc -l | xargs) -eq 0 ]; then
      echo "⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️"
      echo "⚠️  You'll need to create a new GPG key ⚠️"
      echo "⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️"
    fi


    # Handle other files outside of the user's home directory
    echo "Handiling non-standard files:"
    # 1. Tabby config
    f=$(fulllink "./other-files/tabby/config.yaml")
    dst="/Users/${USER}/Library/Application Support/tabby/config.yaml"
    printf "Linking ${f}=>${dst}"
    ln -sfn ${f} ${dst}
    printf " ✅\n"

    ;;
esac

echo "🔵  Adding configuration"
FILES=$(/usr/bin/find ./home -maxdepth 1 -mindepth 1 | tr '\n' ' ')
for file in $FILES
do
  f=$(fulllink "${file}")
  dst="${HOME}/$(basename "./home/${file}")"
  printf "Linking ${f} => ${dst}"
  ln -sfn ${f} ${dst}
  printf " ✅\n"
done
