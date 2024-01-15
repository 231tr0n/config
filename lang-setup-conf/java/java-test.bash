#!/bin/bash
set -e
rm -rf vscode-java-test
git clone https://github.com/microsoft/vscode-java-test.git
cd vscode-java-test
npm install
npm run build-plugin
sudo rsync -r --exclude=.git server/*.jar /usr/share/java-test
cd ..
rm -rf vscode-java-test
