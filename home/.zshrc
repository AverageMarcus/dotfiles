DISABLE_AUTO_UPDATE="true"

PATH_DIRS=(
  "${HOME}/.bin"
  "${KREW_ROOT:-${HOME}/.krew}/bin"
  "${GOPATH:-${HOME}/goworkspace}/bin"
  "${HOME}/.cargo/bin"
  "/home/linuxbrew/.linuxbrew/bin"
  "/opt/homebrew/bin/"
  "${HOME}/Library/Python/3.11/bin"
  "/usr/local/bin"
  "/usr/bin"
  "/bin"
  "/usr/sbin"
  "/sbin"
  "${PATH}"
)
export PATH=${"${PATH_DIRS[*]}"// /:}
export FPATH="$FPATH:/opt/homebrew/share/zsh/site-functions"

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

macchina --config ~/.macchina/config.toml --theme ~/.macchina/theme
