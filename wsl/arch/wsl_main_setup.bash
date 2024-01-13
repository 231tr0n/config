#!/bin/bash

set -e

sudo pacman-key --init
sudo pacman-key --populate
sudo pacman -Sy archlinux-keyring --noconfirm
sudo pacman -Syu reflector --noconfirm
cd ~
sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sudo reflector --country India --sort rate --fastest 5 --latest 5 --protocol https --save /etc/pacman.d/mirrorlist
sudo pacman -Syu --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -sic --noconfirm && cd .. && rm -rf yay-bin
yay -Syu --needed --noconfirm git curl wget neofetch openssl openssh man htop \
  vim neovim fzf tmux fish ripgrep fd git-delta bat \
  python python-pip python-pipx nodejs typescript npm go rust cargo maven jdk17-openjdk jdk-openjdk gcc cmake meson luajit luarocks clang make \
  delve gdb codelldb-bin java-debug \
  gopls lua-language-server rust-analyzer jdtls pyright typescript-language-server vscode-langservers-extracted bash-language-server xml-language-server-git yaml-language-server \
  gofumpt prettier stylua python-black google-java-format shfmt jq libxml2 yamlfmt \
  golangci-lint-bin python-pylint luacheck shellcheck checkstyle yamllint nodejs-jsonlint

mkdir -p ~/.config
mkdir -p ~/.config/nvim
mkdir -p ~/.config/fish
mkdir -p ~/.config/fish/functions
mkdir -p ~/.config/tmux
mkdir -p ~/scripts

curl https://raw.githubusercontent.com/231tr0n/config/main/git/.gitconfig -o ~/.gitconfig
curl https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.lua -o ~/.config/nvim/init.lua
curl https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.vim -o ~/.vimrc
curl https://raw.githubusercontent.com/231tr0n/config/main/tmux/tmux.conf -o ~/.config/tmux/tmux.conf
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/config.fish -o ~/.config/fish/config.fish
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/fish_variables -o ~/.config/fish/fish_variables
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_prompt.fish -o ~/.config/fish/functions/fish_prompt.fish
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_mode_prompt.fish -o ~/.config/fish/functions/fish_mode_prompt.fish
curl https://raw.githubusercontent.com/231tr0n/config/main/lang-setup-conf/java/java-debug.bash -o ~/scripts/java-debug.bash

echo -e "\e[32mRun the command 'chsh' and set fish shell\e[0m"
echo -e "\e[32mRun the command 'ssh-keygen -t rsa' and generate key-pair for ssh and scp\e[0m"
echo -e "\e[32mOpen neovim and run the command ':PaqSync'\e[0m"
