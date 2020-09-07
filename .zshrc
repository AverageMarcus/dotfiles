# pre-reqs
if [ ! -f ~/.shell-prereqs-installed ];
then
  echo "Installing prereqs"
  which brew > /dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  brew list --cask homebrew/cask-fonts/font-open-dyslexic-nerd-font > /dev/null || brew install homebrew/cask-fonts/font-open-dyslexic-nerd-font
  which starship > /dev/null || brew install starship

  touch ~/.shell-prereqs-installed
fi

for filename in ~/.dotfiles/*; do
  source $filename
done

eval "$(starship init zsh)"
