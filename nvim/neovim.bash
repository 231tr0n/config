#!/bin/bash
set -e

mkdir -p $HOME/.local/bin
wget https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.appimage -O $HOME/.local/bin/nvim
chmod +x $HOME/.local/bin/nvim
