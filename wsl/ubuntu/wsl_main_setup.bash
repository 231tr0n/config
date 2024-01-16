#!/bin/bash

cd ~

touch /home/zeltron/.hushlogin

sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y --purge
sudo apt install -y git curl wget neofetch openssl ssh sshfs man-db htop jq vim tmux

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
curl https://raw.githubusercontent.com/231tr0n/config/main/lang-setup-conf/java/java-test.bash -o ~/scripts/java-test.bash
curl https://raw.githubusercontent.com/231tr0n/config/main/lang-setup-conf/go/go-install.bash -o ~/scripts/go-install.bash
curl https://raw.githubusercontent.com/231tr0n/config/main/lang-setup-conf/lua/lua-lsp.bash -o ~/scripts/lua-lsp.bash
curl https://raw.githubusercontent.com/231tr0n/config/main/lang-setup-conf/xml/xml-lsp.bash -o ~/scripts/xml-lsp.bash

chmod +x ~/scripts/java-debug.bash
chmod +x ~/scripts/java-lsp.bash
chmod +x ~/scripts/java-test.bash
chmod +x ~/scripts/go-install.bash
chmod +x ~/scripts/lua-lsp.bash
chmod +x ~/scripts/xml-lsp.bash

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
export PATH=$PATH:$HOME/.cargo/bin
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo bash -
sudo apt-add-repository -y ppa:fish-shell/release-3
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y fish

sudo apt install -y python-is-python3 python3-pip python3-venv nodejs clang clang-tools gcc make cmake meson maven ninja-build openjdk-11-source openjdk-21-source openjdk-17-source openjdk-21-jdk openjdk-17-jdk openjdk-11-jdk luajit luarocks
sudo update-java-alternatives -s java-1.21.0-openjdk-amd64
sudo npm install -g npm@latest
sudo npm install -g typescript@latest
cd ~/scripts
./go-install.bash
export PATH=$PATH:/usr/local/go/bin
cd ~

sudo apt install -y clangd
pip install pyright
go install -v golang.org/x/tools/gopls@latest
sudo npm install -g vscode-langservers-extracted@latest
sudo npm install -g yaml-language-server@latest
sudo npm install -g bash-language-server@latest
sudo npm install -g typescript-language-server@latest
cd ~/scripts
./java-lsp.bash
./lua-lsp.bash
./xml-lsp.bash
cd ~

sudo apt install -y gdb lldb
go install -v github.com/go-delve/delve/cmd/dlv@latest
cd ~/scripts
./java-debug.bash
./java-test.bash
cd ~

sudo apt install -y clang-tidy shellcheck checkstyle checkstyle-doc
sudo luarocks install luacheck
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b ~/.local/bin
pip install pylint yamllint
sudo npm install -g jsonlint@latest
sudo npm install -g eslint@latest

sudo apt install -y clang-format jq libxml2-utils
pip install black
sudo npm install -g google-java-format@latest
sudo npm install -g prettier@latest
go install github.com/google/yamlfmt/cmd/yamlfmt@latest
go install mvdan.cc/gofumpt@latest
go install mvdan.cc/sh/v3/cmd/shfmt@latest
cargo install stylua
cargo install stylua --features lua52
cargo install stylua --features lua53
cargo install stylua --features lua54
cargo install stylua --features luau

cargo install git-delta ripgrep fd-find bob-nvim bat

bob use latest

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

chsh -s /usr/bin/fish
ssh-keygen -t rsa

echo -e "\e[32mOpen neovim and run the command ':PaqSync'\e[0m"
echo -e "\e[32mRun the scripts under ~/scripts folder if required\e[0m"
