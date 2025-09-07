#!/usr/bin/env bash

export PATH="/home/linuxbrew/.linuxbrew/bin:/opt/homebrew/bin/:$PATH"

[ -d ~/.additional_dotfiles ] || (mkdir -p ~/.additional_dotfiles && touch ~/.additional_dotfiles/credentials)
[ -d /usr/local/share/zsh/site-functions ] || (sudo mkdir -p /usr/local/share/zsh/site-functions && sudo chmod 777 /usr/local/share/zsh/site-functions)

# Install homebrew
echo ""
echo "🔵  Installing homebrew"
which brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "✅"

# Install oh-my-zsh
echo ""
echo "🔵  Setting up zsh"
printf "Cloning oh-my-zsh..."
[ -d ${HOME}/.oh-my-zsh ] || sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
printf " ✅\n"
# Install ZSH plugins
printf "Cloning zsh plugins..."
[ -d ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ] || git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
printf " ✅\n"

# Set correct permissions on compinit dir
sudo chmod -R 755 /usr/local/share/zsh/site-functions

# Install tools
BREW_TOOLS=(
  git argocd bandwhich bat danielfoehrkn/switch/switch derailed/k9s/k9s
  dive doggo duf dust eza fd fzf git-delta go helm htop jq kind krew curl
  kubectl kustomize node procs progress ripgrep rs/tap/curlie rust starship
  tektoncd/tools/tektoncd-cli tldr tailscale yq tabby vale jless macchina tz viddy
  homeassistant-cli act dnsmasq gh kubebuilder golangci-lint gnu-sed s3cmd
  pulumi/tap/pulumi kubeseal fluxcd/tap/flux ical-buddy baobab
  watch crane openssh siderolabs/talos/talosctl civo/tools/civo raspberry-pi-imager
  gron ssup2/tap/kpexec opentofu visual-studio-code 1password-cli scw smartmontools
  firefox signal slack ffmpeg openscad tsh colima docker docker-buildx nordvpn
  1password tailscale-app
  )
# Brew tools only available / needed on Mac
MAC_BREW_TOOLS=(
  pinentry-mac gpg gawk coreutils wget stats font-open-dyslexic-nerd-font
  hiddenbar dimentium/autoraise/autoraiseapp the-unarchiver rar mas capcut
  mqtt-explorer raycast bettertouchtool calibre kdenlive royal-tsx tableplus
  homebrew/cask/todoist ultimaker-cura webtorrent pika pearcleaner spotmenu
  )
CARGO_TOOLS=( bottom )
NODE_TOOLS=( git-split-diffs )
KREW_TOOLS=( outdated tree stern explore blame access-matrix cert-manager rbac-tool resource-capacity view-secret )
APT_TOOLS=( zsh gcc )
MAS_TOOLS=(
  1263070803 # Lungo
  1470584107 # Dato
  1351639930 # Gifski
)

# Tools removed to be cleaned up
REMOVED_BREW_TOOLS=(
  exa karabiner-elements kubectx
)
REMOVED_KREW_TOOLS=( gs )

echo ""
echo "🔵  Installing / updating tools"

# Install Debian/Ubuntu specific packages if apt exists
if command -v apt &>/dev/null; then
  echo "'apt' found on system, assuming Ubuntu/Debian and installing pre-requisites..."
  sudo apt install -y ${APT_TOOLS}
fi

# Homebrew
echo ""
echo "🔵  Homebrew tools"
export HOMEBREW_NO_INSTALL_CLEANUP=true
for tool in "${BREW_TOOLS[@]}"
do
  printf "${tool}..."
  brew upgrade ${tool} &>/dev/null || brew install ${tool} &>/dev/null
  if [ $? -eq 0 ]; then
    printf " ✅\n"
  else
    printf " ❌\n"
  fi
done

# Cargo
echo ""
echo "🔵  Cargo tools"
for tool in "${CARGO_TOOLS[@]}"
do
  printf "${tool}..."
  cargo install ${tool} &>/dev/null
  if [ $? -eq 0 ]; then
    printf " ✅\n"
  else
    printf " ❌\n"
  fi
done

# Krew
echo ""
echo "🔵  Krew tools"
kubectl-krew update &>/dev/null
for tool in "${KREW_TOOLS[@]}"
do
  printf "${tool}..."
  kubectl-krew upgrade ${tool} &>/dev/null || kubectl-krew install ${tool} &>/dev/null
  if [ $? -eq 0 ]; then
    printf " ✅\n"
  else
    printf " ❌\n"
  fi
done

fulllink() {
  if [ ! -z `which greadlink` ]
  then
    greadlink -f $1
  else
    readlink -f $1
  fi
}

echo ""
echo "🔵  OS Specific setup"
echo "Detected OS type: ${OSTYPE}"

case "${OSTYPE}" in
  *linux*)
    # Do stuff
    ;;
  *darwin*)
    # Mac specific setup
    echo ""
    echo "Instaling Mac-specific Brew tools..."
    for tool in "${MAC_BREW_TOOLS[@]}"
    do
      printf "${tool}..."
      brew upgrade ${tool} &>/dev/null || brew install ${tool} &>/dev/null
      if [ $? -eq 0 ]; then
        printf " ✅\n"
      else
        printf " ❌\n"
      fi
    done

    # Mac App Store
    echo ""
    echo "Instaling Mac-specific App Store tools..."
    for tool in "${MAS_TOOLS[@]}"
    do
      printf "MAS ID: ${tool}..."
      mas install ${tool} &>/dev/null
      if [ $? -eq 0 ]; then
        printf " ✅\n"
      else
        printf " ❌\n"
      fi
    done

    echo ""
    echo "Setting up config files"
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
    echo ""
    echo "🔵  Handiling non-standard files:"
    # 1. Tabby config
    mkdir -p "/Users/${USER}/Library/Application Support/tabby"
    f=$(fulllink "./other-files/tabby/config.yaml")
    dst="/Users/${USER}/Library/Application Support/tabby/config.yaml"
    printf "Linking ${f}=>${dst}"
    ln -sfn "${f}" "${dst}"
    printf " ✅\n"

    # 2. dnsmasq
    f=$(fulllink "./other-files/dnsmasq/dnsmasq.conf")
    dst="$(brew --prefix)/etc/dnsmasq.conf"
    printf "Copying ${f}=>${dst}"
    cp ${f} ${dst}
    printf " ✅\n"
    printf "Setting DNS server for 'Wi-Fi' interface to use dnsmasq"
    sudo networksetup -setdnsservers "Wi-Fi" 127.0.0.1
    printf " ✅\n"

    ;;
esac

echo ""
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


echo ""
echo "🔵  Updating installed tools..."
brew upgrade
mas upgrade

echo ""
echo "🔵  Removing old Homebrew tools"
export HOMEBREW_NO_INSTALL_CLEANUP=true
for tool in "${REMOVED_BREW_TOOLS[@]}"
do
  printf "${tool}..."
  brew uninstall ${tool} &>/dev/null
  if [ $? -eq 0 ]; then
    printf " ✅\n"
  else
    printf " ❌\n"
  fi
done

echo ""
echo "🔵  Removing old Krew tools"
for tool in "${REMOVED_KREW_TOOLS[@]}"
do
  printf "${tool}..."
  kubectl-krew uninstall ${tool} &>/dev/null
  if [ $? -eq 0 ]; then
    printf " ✅\n"
  else
    printf " ❌\n"
  fi
done
