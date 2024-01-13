#!/bin/bash

sudo apt update && sudo apt upgrade && sudo apt autoremove --purge
sudo apt install git curl wget neofetch openssl ssh man-db htop \

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
curl https://raw.githubusercontent.com/231tr0n/config/main/lang-setup-conf/java/java-lsp.bash -o ~/scripts/java-lsp.bash

chmod +x ~/scripts/java-debug.bash
chmod +x ~/scripts/java-lsp.bash

echo -e "\e[32mRun the command 'chsh' and set fish shell\e[0m"
echo -e "\e[32mRun the command 'ssh-keygen -t rsa' and generate key-pair for ssh and scp\e[0m"
echo -e "\e[32mRun the scripts under ~/scripts folder if required to setup java lsp and debug\e[0m"
echo -e "\e[32mOpen neovim and run the command ':PaqSync'\e[0m"
