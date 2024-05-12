#!/bin/bash
set -e

rm -rf xml-lsp
mkdir -p xml-lsp
cd xml-lsp

wget "https://www.eclipse.org/downloads/download.php?file=/lemminx/snapshots/org.eclipse.lemminx-uber.jar" -O lemminx.jar
cat >wrapper <<'EOL'
#!/bin/sh

java \
    -noverify \
    -Xms1G \
    -jar /usr/share/java/lemminx/lemminx.jar
EOL

sudo install -Dm644 lemminx.jar /usr/share/java/lemminx/lemminx.jar
sudo install -Dm755 wrapper /usr/bin/lemminx

cd ..
rm -rf xml-lsp
