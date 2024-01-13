#!/bin/bash
set -e

rm -rf lua-lsp
mkdir -p lua-lsp
cd lua-lsp

VERSION=$(curl -sL https://api.github.com/repos/LuaLS/lua-language-server/tags | jq -r '.[0].name')

wget "https://github.com/LuaLS/lua-language-server/releases/download/$VERSION/lua-language-server-$VERSION-linux-x64.tar.gz" -O lua-language-server.tar.gz
cat > wrapper << 'EOL'
#!/usr/bin/env sh
TMPPATH="/tmp/lua-language-server-$(id -u)"
mkdir -p "$TMPPATH"
INSTANCEPATH=$(mktemp -d "$TMPPATH/instance.XXXX")
DEFAULT_LOGPATH="$INSTANCEPATH/log"
DEFAULT_METAPATH="$INSTANCEPATH/meta"

exec /usr/lib/lua-language-server/bin/lua-language-server -E /usr/lib/lua-language-server/main.lua \
  --logpath="$DEFAULT_LOGPATH" --metapath="$DEFAULT_METAPATH" \
  "$@"
EOL

tar -zxvf lua-language-server.tar.gz

sudo install -D wrapper /usr/bin/lua-language-server
sudo install -Dt /usr/lib/lua-language-server/bin bin/lua-language-server
sudo install -m644 -t /usr/lib/lua-language-server/bin bin/main.lua
sudo install -m644 -t /usr/lib/lua-language-server {debugger,main}.lua

cd ..
rm -rf lua-lsp
