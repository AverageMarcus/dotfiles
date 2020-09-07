# pre-reqs
if [ ! -f ~/.shell-prereqs-installed ];
then
  echo "Installing prereqs"
  which brew > /dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  [ -d ~/.oh-my-zsh ] || sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  which fzf > /dev/null || brew install fzf
  which bat > /dev/null || brew install bat
  which curlie > /dev/null | brew install rs/tap/curlie
  which exa > /dev/null || brew install exa
  which kubectl > /dev/null || brew install kubectl
  which tkn > /dev/null || brew install tektoncd/tools/tektoncd-cli
  brew list --cask homebrew/cask-fonts/font-open-dyslexic-nerd-font > /dev/null || brew install homebrew/cask-fonts/font-open-dyslexic-nerd-font
  which starship > /dev/null || brew install starship

  touch ~/.shell-prereqs-installed
fi

for filename in ~/.dotfiles/*; do
  source $filename
done

eval "$(starship init zsh)"
