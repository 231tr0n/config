#!/bin/bash
set -e
rm -rf java-format
mkdir -p java-format
cd java-format
VERSION=$(curl -sL https://api.github.com/repos/google/google-java-format/releases | jq -r '.[0].name')

wget "https://github.com/google/google-java-format/releases/download/$VERSION/google-java-format_linux-x86-64" -O google-java-format
sudo install -D google-java-format /usr/bin/google-java-format

cd ..
rm -rf java-format
