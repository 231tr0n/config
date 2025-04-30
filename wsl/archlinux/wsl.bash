#!/bin/bash

set -e

# WARNING Don't edit the parameters here
SYSTEM_USERNAME="zeltron"
SYSTEM_PASSWORD="zeltron"
ROOT_PASSWORD="$SYSTEM_PASSWORD"
SSH_KEY_PASSWORD="$SYSTEM_PASSWORD"
WSL_CONFIG_CHANGED="No"

function error_log {
  echo
  echo
  echo -ne "[\e[1;31mERROR\e[1;0m] " >&2
  echo -e "$1" >&2
  echo
  echo
}
function info_log {
  echo
  echo
  echo -ne "[\e[1;36mINFO\e[1;0m] "
  echo -e "$1"
  echo
  echo
}

while getopts 'r:u:p:h' opt; do
  case "$opt" in
  r)
    ROOT_PASSWORD="$OPTARG"
    ;;
  p)
    SYSTEM_PASSWORD="$OPTARG"
    ;;
  u)
    SYSTEM_USERNAME="$OPTARG"
    ;;
  s)
    SSH_KEY_PASSWORD="$OPTARG"
    ;;
  h | ?)
    info_log "Help\n
    -s: ssh-key password
    -r: root password
    -u: system username
    -p: system password
    -h: print help"
    exit
    ;;
  esac
done

if grep "default=" /etc/wsl.conf >/dev/null && grep "guiApplications=" /etc/wsl.conf >/dev/null; then
  WSL_CONFIG_CHANGED="Yes"
fi

if [ "$WSL_CONFIG_CHANGED" = "No" ]; then
  if [ "$(id -u)" -ne 0 ]; then
    error_log "Please run this script as super user"
    exit 1
  fi

  if ! grep "default=" /etc/wsl.conf >/dev/null; then
    WSL_CONFIG_CHANGED="Yes"
    printf "\n\n[user]\ndefault=%s" "$SYSTEM_USERNAME" >>/etc/wsl.conf
  fi
  if ! grep "guiApplications=" /etc/wsl.conf >/dev/null; then
    WSL_CONFIG_CHANGED="Yes"
    printf "\n\n[wsl2]\nguiApplications=true" >>/etc/wsl.conf
  fi

  pacman -Syu --noconfirm --needed
  pacman -Syu --noconfirm --needed sudo fish

  echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)

  echo '%wheel ALL=(ALL:ALL) ALL' | (EDITOR='tee -a' visudo)

  echo "$ROOT_PASSWORD" | passwd -s

  useradd -m -s /usr/bin/fish -G wheel "$SYSTEM_USERNAME"

  echo "$SYSTEM_PASSWORD" | passwd -s "$SYSTEM_USERNAME"

  info_log "WSL config changed. Run 'wsl --terminate archlinux' and restart it again"
  exit
fi

if [ "$(id -u)" -eq 0 ]; then
  error_log "Please don't run this script as super user"
  exit 1
fi

cd ~
sudo pacman -Syu --noconfirm --needed git base-devel reflector

sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sudo reflector --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syu --noconfirm --needed

git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -sic --noconfirm
cd ..
rm -rf yay-bin

mkdir -p ~/.config
mkdir -p ~/.config/nvim
mkdir -p ~/.config/fish
mkdir -p ~/.config/fish/functions
mkdir -p ~/.config/tmux

curl https://raw.githubusercontent.com/231tr0n/config/main/git/.gitconfig -o ~/.gitconfig
curl https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.lua -o ~/.config/nvim/init.lua
curl https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.vim -o ~/.vimrc
curl https://raw.githubusercontent.com/231tr0n/config/main/tmux/tmux.conf -o ~/.config/tmux/tmux.conf
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/config.fish -o ~/.config/fish/config.fish
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_prompt.fish -o ~/.config/fish/functions/fish_prompt.fish
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_user_key_bindings.fish -o ~/.config/fish/functions/fish_user_key_bindings.fish
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_mode_prompt.fish -o ~/.config/fish/functions/fish_mode_prompt.fish

export PATH=$PATH:$HOME/.local/share/coursier/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:/usr/local/go/bin

echo "$SYSTEM_PASSWORD" | yay -Syu --sudoloop --noconfirm --needed go jdk-openjdk python python-pip python-pipx curl wget ca-certificates openssl openssh inxi htop man-db jq vim neovim tree-sitter-cli tmux tmate libgit2 fuse rustup docker docker-buildx docker-compose bat fzf fd ripgrep lsd fastfetch nodejs-lts npm clang gcc typescript luajit texlive ts-node delve python-debugpy lldb gdb make cmake meson maven gradle ninja luarocks woff2 ctags ffmpeg mpv zoxide evince net-tools sysstat axel tldr ncdu firefox chromium bash-completion shellcheck checkstyle luacheck python-pylint yamllint sqlfluff coursier java-debug jdtls metals bloop pyright basedpyright-bin yaml-language-server sql-language-server svelte-language-server eslint-language-server lua-language-server typescript-language-server bash-language-server dockerfile-language-server vim-language-server lemminx vtsls marksman vscode-html-languageserver vscode-css-languageserver vscode-json-languageserver vscode-js-debug-bin tidy libxml2 golangci-lint-langserver-bin golangci-lint-bin eslint python-black yamlfmt gofumpt golines shfmt stylua yamlfix google-java-format git-delta hurl cargo-update diff-so-fancy gup lazygit python-pylatexenc nodejs-nodemon ollama kubectl minikube helm

rustup update stable

cs setup -y

sudo groupadd docker
sudo usermod -aG docker "$USER"

sudo systemctl enable --now docker
sudo systemctl enable --now ollama

if ! test -d "$HOME/.ssh"; then
  printf "\n$SSH_KEY_PASSWORD\n$SSH_KEY_PASSWORD\n" | ssh-keygen -t rsa
fi

nvim --headless -c +'lua MiniDeps.update(nil, { force = true })' +TSUpdateSync +qa
