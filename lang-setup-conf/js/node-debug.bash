#!/bin/bash
set -e

rm -rf node-debug
mkdir -p node-debug
cd node-debug

NODE_PWD=$(pwd)

VERSION=$(curl -sL https://api.github.com/repos/microsoft/vscode-js-debug/releases | jq -r '.[0].name')

wget "https://github.com/microsoft/vscode-js-debug/releases/download/$VERSION/js-debug-dap-$VERSION.tar.gz" -O node-debug.tar.gz

sudo rm -rf /usr/share/js-debug
sudo mv node-debug.tar.gz /usr/share

cd /usr/share

sudo tar -zxvf node-debug.tar.gz
sudo rm -rf node-debug.tar.gz

cd "$NODE_PWD"

cd ..
rm -rf node-debug
