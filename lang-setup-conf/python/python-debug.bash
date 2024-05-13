#!/bin/bash

set -e

mkdir -p ~/.local/share
rm -rf ~/.local/share/debugpy
cd ~/.local/share
python -m venv debugpy
~/.local/share/debugpy/bin/python -m pip install debugpy
