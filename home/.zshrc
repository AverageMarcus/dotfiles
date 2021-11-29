PATH_DIRS=(
  "${HOME}/.bin"
  "${KREW_ROOT:-${HOME}/.krew}/bin"
  "${GOPATH:-${HOME}/goworkspace}/bin"
  "${HOME}/.cargo/bin"
  "/home/linuxbrew/.linuxbrew/bin"
  "/usr/local/bin"
  "/usr/bin"
  "/bin"
  "/usr/sbin"
  "/sbin"
  "${PATH}"
)
export PATH=${"${PATH_DIRS[*]}"// /:}

if [ ! -z ~/.additional_dotfiles/credentials ]; then
  source ~/.additional_dotfiles/credentials
fi

for filename in ~/.dotfiles/*; do
  source $filename
done

for filename in ~/.additional_dotfiles/*; do
  source $filename
done

rm -f ~/.zcompdump; compinit

eval "$(starship init zsh)"
