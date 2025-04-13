#!/bin/bash

curl -fL "https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz" | gzip -d >~/.local/bin/cs
chmod +x ~/.local/bin/cs
