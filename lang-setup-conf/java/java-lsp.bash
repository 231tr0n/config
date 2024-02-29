#!/bin/bash
set -e
rm -rf java-lsp
mkdir -p java-lsp
cd java-lsp
wget https://www.eclipse.org/downloads/download.php?file=/jdtls/snapshots/jdt-language-server-latest.tar.gz -O jdtls.tar.gz
tar -zxvf jdtls.tar.gz
sudo rm -rf /usr/share/java/jdtls
sudo mkdir -p /usr/share/java/jdtls
sudo cp -R config_* features plugins bin /usr/share/java/jdtls
sudo mkdir -p /usr/bin
cd ..
rm -rf java-lsp
sudo ln -s --relative /usr/share/java/jdtls/bin/jdtls /usr/bin/jdtls
