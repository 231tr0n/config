#!/bin/bash

set -e

sudo pacman-key --init
sudo pacman-key --populate
sudo pacman -Sy archlinux-keyring --noconfirm
sudo pacman -Syu reflector --noconfirm
cd ~
sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sudo reflector --country India --sort rate --fastest 5 --latest 5 --protocol https --save /etc/pacman.d/mirrorlist
sudo pacman -Syu --needed --noconfirm git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -sic --noconfirm && cd .. && rm -rf yay-bin
yay -Syu --needed --noconfirm git curl wget neofetch openssl openssh sshfs man htop \
	vim neovim fzf tmux fish ripgrep fd git-delta bat \
	python python-pip python-pipx nodejs typescript npm go rust cargo maven jdk17-openjdk jdk-openjdk gcc cmake meson luajit luarocks clang make \
	delve gdb java-debug lldb \
	gopls lua-language-server rust-analyzer jdtls pyright typescript-language-server vscode-langservers-extracted bash-language-server lemminx yaml-language-server \
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
curl https://raw.githubusercontent.com/231tr0n/config/main/lang-setup-conf/java/java-test.bash -o ~/scripts/java-test.bash

chmod +x ~/scripts/java-debug.bash
chmod +x ~/scripts/java-test.bash

cd ~/scripts
./java-test.bash
cd ..

git config --global core.editor "nvim"
chsh -s /usr/bin/fish
ssh-keygen -t rsa

echo -e "\e[32mOpen neovim and run the command ':PaqSync'\e[0m"
echo -e "\e[32mRun the scripts under ~/scripts folder if required\e[0m"
