for filename in ~/.dotfiles/*; do
  source $filename
done

eval "$(starship init zsh)"
