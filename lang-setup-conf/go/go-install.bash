#!/bin/bash

set -e

LATEST_GO_VERSION="$(curl --silent https://go.dev/VERSION?m=text | head -n 1)"
LATEST_GO_DOWNLOAD_URL="https://go.dev/dl/${LATEST_GO_VERSION}.linux-amd64.tar.gz"

wget "$LATEST_GO_DOWNLOAD_URL" -O go.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go.tar.gz
rm -rf go.tar.gz
