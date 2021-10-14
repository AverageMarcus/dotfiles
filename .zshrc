if [ ! -z ~/.additional_dotfiles/credentials ]; then
  source ~/.additional_dotfiles/credentials
fi

for filename in ~/.dotfiles/*; do
  source $filename
done

for filename in ~/.additional_dotfiles/*; do
  source $filename
done

eval "$(starship init zsh)"
