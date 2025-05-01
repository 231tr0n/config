#!/bin/bash

set -xe

DEFAULT_USERNAME="zeltron"
DEFAULT_USER_PASSWORD="zeltron"
ROOT_PASSWORD="$DEFAULT_USER_PASSWORD"
SSH_KEY_PASSWORD="$DEFAULT_USER_PASSWORD"
WSL_CONFIG_CHANGED="No"

while getopts 's:r:u:p:h' opt; do
  case "$opt" in
  r)
    ROOT_PASSWORD="$OPTARG"
    ;;
  p)
    DEFAULT_USER_PASSWORD="$OPTARG"
    ;;
  u)
    DEFAULT_USERNAME="$OPTARG"
    ;;
  s)
    SSH_KEY_PASSWORD="$OPTARG"
    ;;
  h | ?)
    printf "Help\n
    -s: ssh-key password
    -r: root password
    -u: system username
    -p: system password
    -h: print help
    \n"
    exit
    ;;
  esac
done

function info_log {
  echo -ne "[\e[1;36mINFO\e[1;0m] "
  echo -e "$1"
}

if [ "$(id -u)" -ne 0 ]; then
  info_log "Please run this script as super user"
  exit 1
fi

if grep "default=" /etc/wsl.conf &>/dev/null && grep "guiApplications=" /etc/wsl.conf &>/dev/null && grep "interop" /etc/wsl.conf &>/dev/null; then
  WSL_CONFIG_CHANGED="Yes"
fi

if [ "$WSL_CONFIG_CHANGED" = "No" ]; then
  if ! grep "default=" /etc/wsl.conf &>/dev/null; then
    WSL_CONFIG_CHANGED="Yes"
    printf "\n[user]\ndefault=%s" "$DEFAULT_USERNAME" >>/etc/wsl.conf
  fi
  if ! grep "guiApplications=" /etc/wsl.conf &>/dev/null; then
    WSL_CONFIG_CHANGED="Yes"
    printf "\n\n[wsl2]\nguiApplications=true" >>/etc/wsl.conf
  fi
  if ! grep "interop" /etc/wsl.conf &>/dev/null; then
    WSL_CONFIG_CHANGED="Yes"
    printf "\n\n[interop]\nenabled=true" >>/etc/wsl.conf
  fi

  sed -i 's/#Color/Color/g' /etc/pacman.conf
  sed -i 's/NoProgressBar/#NoProgressBar/g' /etc/pacman.conf

  pacman -Syu --noconfirm --needed reflector
  if ! [ -f "/etc/pacman.d/mirrorlist.bak" ]; then
    mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
  fi
  reflector --fastest 5 --protocol https --country India --sort rate --save /etc/pacman.d/mirrorlist

  pacman -Syu --noconfirm --needed sudo fish

  echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)

  echo '%wheel ALL=(ALL:ALL) ALL' | (EDITOR='tee -a' visudo)

  echo "$ROOT_PASSWORD" | passwd -s

  useradd -m -s /usr/bin/fish -G wheel "$DEFAULT_USERNAME"

  passwd -s "$DEFAULT_USERNAME" <<<"$DEFAULT_USER_PASSWORD"
fi

function default_user_cmd {
  local args=""
  for arg in "$@"; do
    args="$args $arg"
  done
  args=${args# }
  su - "$DEFAULT_USERNAME" -c "$args"
}

echo "$DEFAULT_USERNAME $(echo $HOSTNAME)= NOPASSWD: /usr/bin/pacman,/usr/sbin/pacman" | (EDITOR='tee -a' visudo)

reflector --fastest 5 --protocol https --country India --sort rate --save /etc/pacman.d/mirrorlist

if ! command -v yay &>/dev/null; then
  pacman -Syu --noconfirm --needed git base-devel
  default_user_cmd rm -rf '$HOME/yay-bin'
  default_user_cmd git clone https://aur.archlinux.org/yay-bin.git '$HOME/yay-bin'
  default_user_cmd cd '$HOME/yay-bin' '&&' makepkg -sic --noconfirm
  default_user_cmd rm -rf '$HOME/yay-bin'
fi

default_user_cmd mkdir -p '$HOME/.config'
default_user_cmd mkdir -p '$HOME/.config/nvim'
default_user_cmd mkdir -p '$HOME/.config/fish'
default_user_cmd mkdir -p '$HOME/.config/fish/functions'
default_user_cmd mkdir -p '$HOME/.config/tmux'

default_user_cmd curl https://raw.githubusercontent.com/231tr0n/config/main/git/.gitconfig -o '$HOME/.gitconfig'
default_user_cmd curl https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.lua -o '$HOME/.config/nvim/init.lua'
default_user_cmd curl https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.vim -o '$HOME/.vimrc'
default_user_cmd curl https://raw.githubusercontent.com/231tr0n/config/main/tmux/tmux.conf -o '$HOME/.config/tmux/tmux.conf'
default_user_cmd curl https://raw.githubusercontent.com/231tr0n/config/main/fish/config.fish -o '$HOME/.config/fish/config.fish'
default_user_cmd curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_prompt.fish -o '$HOME/.config/fish/functions/fish_prompt.fish'
default_user_cmd curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_user_key_bindings.fish -o '$HOME/.config/fish/functions/fish_user_key_bindings.fish'
default_user_cmd curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_mode_prompt.fish -o '$HOME/.config/fish/functions/fish_mode_prompt.fish'
default_user_cmd curl https://raw.githubusercontent.com/231tr0n/config/main/wsl/archlinux/wsl.bash -o '$HOME/wsl.bash'

default_user_cmd "yay -Syu --noconfirm --needed glibc-locales git base-devel fish sudo reflector go jdk8-openjdk jdk11-openjdk jdk17-openjdk jdk21-openjdk jdk-openjdk python python-pip python-pipx curl wget ca-certificates openssl openssh inxi htop man-db jq vim neovim tree-sitter-cli tmux tmate libgit2 fuse rustup docker docker-buildx docker-compose bat fzf fd ripgrep lsd fastfetch nodejs-lts npm clang gcc typescript luajit texlive ts-node delve python-debugpy lldb gdb make cmake meson maven gradle ninja luarocks woff2 ctags ffmpeg mpv zoxide evince net-tools sysstat axel tldr ncdu firefox chromium bash-completion shellcheck checkstyle luacheck python-pylint yamllint sqlfluff coursier java-debug jdtls metals pyright basedpyright-bin yaml-language-server sql-language-server svelte-language-server eslint-language-server lua-language-server typescript-language-server bash-language-server dockerfile-language-server vim-language-server lemminx vtsls marksman vscode-html-languageserver vscode-css-languageserver vscode-json-languageserver vscode-js-debug-bin tidy libxml2 golangci-lint-langserver-bin golangci-lint-bin eslint python-black yamlfmt gofumpt golines shfmt stylua yamlfix google-java-format git-delta hurl cargo-update diff-so-fancy gup lazygit python-pylatexenc nodejs-nodemon ollama kubectl minikube helm"

default_user_cmd rustup update stable

default_user_cmd coursier setup -y

groupadd -f docker
usermod -aG docker "$DEFAULT_USERNAME"

systemctl enable docker
systemctl enable ollama

if ! [ -d "$HOME/.ssh" ]; then
  default_user_cmd "printf '\n%s\n%s\n' $SSH_KEY_PASSWORD $SSH_KEY_PASSWORD | ssh-keygen -t rsa"
fi

default_user_cmd nvim --headless -c "'+lua MiniDeps.update(nil, { force = true })'" "'+TSUpdateSync'" "'+qa'"

sed -i "/\/usr\/sbin\/pacman/d" /etc/sudoers

info_log "Run 'wsl --terminate archlinux' to apply all changes\n"
