#!/bin/bash

set -e
set -o pipefail

if [ -t 2 ]; then
	PS4=$'\e[1;36m[RUN]\e[0m '
else
	PS4='[RUN] '
fi

if [ -t 1 ]; then
	INFO_TAG=$'\e[1;36m[INFO]\e[0m '
else
	INFO_TAG='[INFO] '
fi
set -x

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.luarocks/bin:$PATH"

DEFAULT_USERNAME=""
SSH_PASSPHRASE=""

while getopts 'u:s:h' opt; do
	case "$opt" in
	u)
		DEFAULT_USERNAME="$OPTARG"
		;;
	s)
		SSH_PASSPHRASE="$OPTARG"
		;;
	h | ?)
		printf "Help\n
    -u: system username
    -s: SSH key passphrase
    -h: print help
    \n"
		exit
		;;
	esac
done

function info_log {
	{ set +x; } 2>/dev/null
	echo -ne "$INFO_TAG"
	echo -e "$1"
	set -x
}

if [ -z "$DEFAULT_USERNAME" ]; then
	info_log 'Default username is not set.'
	exit 1
fi

mkdir -p "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
	ssh-keygen -t rsa -f "$HOME/.ssh/id_rsa" -N "$SSH_PASSPHRASE"
fi

sudo dnf install -y dnf-plugins-core

sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo --overwrite
sudo install -d -m 755 /etc/pki/rpm-gpg
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor --batch --yes -o /etc/pki/rpm-gpg/RPM-GPG-KEY-google
sudo tee /etc/yum.repos.d/google-chrome.repo >/dev/null <<'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-google
EOF
sudo dnf install -y google-chrome-stable

sudo dnf install -y tree-sitter-cli diff-so-fancy vim neovim tmux fish fzf ripgrep fd-find git jq yq zoxide bat patch unzip ctags
sudo dnf install -y go luajit luarocks delve nodejs npm gcc python3 python3-pip pipx texlive-scheme-basic make gdb meson java maven rustup
sudo dnf install -y shfmt shellcheck gofumpt black pylint golangci-lint gopls clang-format texlive-latexindent clang-tools-extra clangd
sudo dnf install -y texlive-roboto texlive-enumitem texlive-titlesec texlive-wrapfig texlive-xstring texlive-chktex
sudo dnf install -y pkg-config openssl-devel
sudo dnf install -y yt-dlp ffmpeg ImageMagick
sudo dnf install -y htop inxi ncdu btop igt-gpu-tools telnet bleachbit conky
sudo dnf install -y wl-clipboard gnome-tweaks gnome-extensions-app cascadia-code-nf-fonts cascadia-mono-nf-fonts brave-browser
sudo dnf install -y gnome-shell-extension-common gnome-shell-extension-launch-new-instance gnome-shell-extension-user-theme gnome-shell-extension-just-perfection
sudo dnf install -y docker-cli runc toolbox distrobox kubectl
sudo dnf install -y nginx haproxy
sudo dnf install -y mariadb mariadb-server
sudo dnf install -y libva-intel-media-driver libva-utils vulkan-loader vulkan-tools mesa-vulkan-drivers
sudo dnf install -y ocl-icd intel-compute-runtime intel-opencl
sudo dnf install -y intel-level-zero oneapi-level-zero
sudo dnf install -y cmake make gcc-c++ git pkg-config libusb1-devel

LLAMA_DIR="$HOME/.local/share/llama.cpp"
BUILT_TAG_FILE="$LLAMA_DIR/.last_built_release"
NEED_INSTALL=0

info_log 'Checking llama.cpp for updates...'
LLAMA_LATEST_TAG="$(curl -fsSL "https://api.github.com/repos/ggml-org/llama.cpp/releases?per_page=20" 2>/dev/null | jq -r '[.[].tag_name | select(test("^b[0-9]+$"))][0] // empty' || true)"
if [ -z "$LLAMA_LATEST_TAG" ] || [ "$LLAMA_LATEST_TAG" = "null" ]; then
	LLAMA_LATEST_TAG="$(curl -fsSL https://api.github.com/repos/ggml-org/llama.cpp/tags 2>/dev/null | jq -r '.[0].name' 2>/dev/null | head -1 || true)"
fi

LLAMA_BIN="$(find "$LLAMA_DIR" -maxdepth 2 -name llama-server -type f 2>/dev/null | head -1 || true)"
if [ -z "$LLAMA_BIN" ]; then
	NEED_INSTALL=1
else
	LLAMA_BUILT_TAG=""
	if [ -f "$BUILT_TAG_FILE" ]; then
		IFS= read -r LLAMA_BUILT_TAG <"$BUILT_TAG_FILE" 2>/dev/null || LLAMA_BUILT_TAG=""
		LLAMA_BUILT_TAG="${LLAMA_BUILT_TAG#"${LLAMA_BUILT_TAG%%[![:space:]]*}"}"
		LLAMA_BUILT_TAG="${LLAMA_BUILT_TAG%"${LLAMA_BUILT_TAG##*[![:space:]]}"}"
	fi
	if [ -n "$LLAMA_LATEST_TAG" ] && [ "$LLAMA_LATEST_TAG" != "null" ]; then
		if [ -z "$LLAMA_BUILT_TAG" ] || [ "$LLAMA_BUILT_TAG" != "$LLAMA_LATEST_TAG" ]; then
			NEED_INSTALL=1
		fi
	fi
fi

if [ "$NEED_INSTALL" -eq 1 ]; then
	info_log "llama.cpp updating to ${LLAMA_LATEST_TAG:-latest} prebuilt (openvino)..."
	LLAMA_ASSET_URL="$(curl -fsSL "https://api.github.com/repos/ggml-org/llama.cpp/releases/tags/$LLAMA_LATEST_TAG" 2>/dev/null | jq -r '.assets[] | select(.name | test("bin-ubuntu-openvino-.*-x64\\.tar\\.gz$")) | .browser_download_url' 2>/dev/null | head -1 || true)"
	if [ -z "$LLAMA_ASSET_URL" ]; then
		info_log 'No prebuilt ubuntu-openvino asset found, skipping.'
	else
		rm -rf "$LLAMA_DIR"
		mkdir -p "$LLAMA_DIR"
		curl -fL --retry 3 --retry-delay 2 "$LLAMA_ASSET_URL" -o /tmp/llama-openvino.tar.gz
		tar xz -C "$LLAMA_DIR" -f /tmp/llama-openvino.tar.gz
		rm -f /tmp/llama-openvino.tar.gz
		echo "$LLAMA_LATEST_TAG" >"$BUILT_TAG_FILE"
	fi
else
	info_log "llama.cpp ${LLAMA_BUILT_TAG:-current} is up to date, skipping."
fi
mkdir -p "$HOME/.local/bin"
LLAMA_BIN_DIR="$(dirname "$(find "$LLAMA_DIR" -maxdepth 2 -name llama-server -type f 2>/dev/null | head -1 || true)" 2>/dev/null || true)"
if [ -n "$LLAMA_BIN_DIR" ] && [ -d "$LLAMA_BIN_DIR" ]; then
	for bin in llama-server llama-cli llama-bench llama-perplexity llama-mtmd-cli llama-gguf llama-imatrix llama-quantize; do
		[ -f "$LLAMA_BIN_DIR/$bin" ] && ln -sf "$LLAMA_BIN_DIR/$bin" "$HOME/.local/bin/$bin"
	done
fi

sudo dnf update -y

sudo systemctl enable --now mariadb
sudo mariadb -u root <<'EOF'
DELETE FROM mysql.global_priv WHERE User='';
DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF

if ! flatpak remotes --columns=name | grep -qxF flathub; then
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi
sudo flatpak install -y flathub com.discordapp.Discord
sudo flatpak install -y flathub com.github.finefindus.eyedropper
sudo flatpak install -y flathub io.github.cmus.cmus
sudo flatpak install -y flathub io.github.swordpuffin.rewaita
sudo flatpak install -y flathub org.telegram.desktop

sudo flatpak update -y

sudo dnf autoremove -y
sudo flatpak uninstall --unused -y

if ! command -v rustup >/dev/null 2>&1; then
	rustup-init --profile complete -y
else
	rustup update || true
fi

sudo npm install -g @opencode/cli@latest prettier@latest eslint@latest typescript-language-server@latest typescript@latest svelte-language-server@latest

curl -fsSL https://raw.githubusercontent.com/lunarmodules/luacheck/master/luacheck-dev-1.rockspec -o /tmp/luacheck-dev-1.rockspec
luarocks install --local --force /tmp/luacheck-dev-1.rockspec
rm -f /tmp/luacheck-dev-1.rockspec

cargo install cargo-update || true
cargo install stylua --features luajit || true
cargo install-update -a || true

go install github.com/nao1215/gup@latest || true
go install github.com/reteps/dockerfmt@latest || true
go install sigs.k8s.io/yaml/yamlfmt@latest || true
gup update || true

pipx install --force mbake || true
pipx upgrade-all || true

install_ollama() {
	curl -fsSL https://ollama.com/install.sh -o /tmp/ollama-install.sh
	sed -i 's/--progress-bar/--silent/g' /tmp/ollama-install.sh
	sh /tmp/ollama-install.sh
	rm -f /tmp/ollama-install.sh
}
if command -v ollama >/dev/null 2>&1; then
	OLLAMA_CUR="$(ollama --version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
	OLLAMA_LATEST="$(curl -fsSL https://api.github.com/repos/ollama/ollama/releases/latest 2>/dev/null | jq -r '.tag_name' 2>/dev/null | sed 's/^v//' | head -1 || true)"
	if [ -n "$OLLAMA_CUR" ] && [ -n "$OLLAMA_LATEST" ] && [ "$OLLAMA_CUR" = "$OLLAMA_LATEST" ]; then
		info_log "ollama $OLLAMA_CUR is already the latest, skipping install/update."
	elif [ -z "$OLLAMA_LATEST" ] || [ "$OLLAMA_LATEST" = "null" ]; then
		info_log "ollama $OLLAMA_CUR present, could not check latest, skipping."
	else
		info_log "ollama $OLLAMA_CUR -> ${OLLAMA_LATEST:-unknown}, updating..."
		install_ollama
	fi
else
	info_log "ollama not found, installing..."
	install_ollama
fi

sudo mkdir -p /etc/systemd/system/ollama.service.d
echo -e "[Service]\nEnvironment=\"OLLAMA_IGPU_ENABLE=1\"" | sudo tee /etc/systemd/system/ollama.service.d/override.conf >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable --now ollama 2>/dev/null || sudo systemctl restart ollama 2>/dev/null || true

mbake init --force 2>/dev/null || true
BAKE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/bake.toml"
if [ -f "$HOME/.bake.toml" ]; then
	mv "$HOME/.bake.toml" "$HOME/.bake.toml.bak"
fi
if [ -f "$BAKE_CONFIG" ]; then
	sed -i 's/auto_insert_phony_declarations = false/auto_insert_phony_declarations = true/' "$BAKE_CONFIG" || true
	sed -i 's/group_phony_declarations = false/group_phony_declarations = true/' "$BAKE_CONFIG" || true
	sed -i 's/phony_at_top = false/phony_at_top = true/' "$BAKE_CONFIG" || true
	sed -i 's/max_consecutive_empty_lines = 2/max_consecutive_empty_lines = 1/' "$BAKE_CONFIG" || true
	sed -i 's/indent_nested_conditionals = false/indent_nested_conditionals = true/' "$BAKE_CONFIG" || true
	sed -i 's/tab_width = 2/tab_width = 4/' "$BAKE_CONFIG" || true
	sed -i 's/align_variable_assignments = false/align_variable_assignments = true/' "$BAKE_CONFIG" || true
	sed -i 's/align_across_comments = false/align_across_comments = true/' "$BAKE_CONFIG" || true
fi

mkdir -p "$HOME/.local/bin" "$HOME/.local/share/"{lua-language-server,google-java-format,checkstyle,jdtls}

LUA_LS_VER=$(curl -fsSL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest 2>/dev/null | jq -r '.tag_name' 2>/dev/null || true)
rm -rf "$HOME/.local/share/lua-language-server"
mkdir -p "$HOME/.local/share/lua-language-server"
curl -fsSL "https://github.com/LuaLS/lua-language-server/releases/download/$LUA_LS_VER/lua-language-server-$LUA_LS_VER-linux-x64.tar.gz" | tar xz -C "$HOME/.local/share/lua-language-server"
ln -sf "$HOME/.local/share/lua-language-server/bin/lua-language-server" "$HOME/.local/bin/lua-language-server"

GJF_VER=$(curl -fsSL https://api.github.com/repos/google/google-java-format/releases/latest 2>/dev/null | jq -r '.tag_name' 2>/dev/null | cut -c2- || true)
rm -f "$HOME/.local/share/google-java-format/"*.jar
curl -fsSL "https://github.com/google/google-java-format/releases/download/v$GJF_VER/google-java-format-$GJF_VER-all-deps.jar" -o "$HOME/.local/share/google-java-format/google-java-format-$GJF_VER-all-deps.jar"
printf '#!/bin/bash\nexec java -jar "%s" "$@"\n' "$HOME/.local/share/google-java-format/google-java-format-$GJF_VER-all-deps.jar" >"$HOME/.local/bin/google-java-format"
chmod +x "$HOME/.local/bin/google-java-format"

CS_TAG=$(curl -fsSL https://api.github.com/repos/checkstyle/checkstyle/releases/latest 2>/dev/null | jq -r '.tag_name' 2>/dev/null || true)
CS_VER=${CS_TAG#checkstyle-}
rm -f "$HOME/.local/share/checkstyle/"*.jar
curl -fsSL "https://github.com/checkstyle/checkstyle/releases/download/$CS_TAG/checkstyle-$CS_VER-all.jar" -o "$HOME/.local/share/checkstyle/checkstyle-$CS_VER-all.jar"
printf '#!/bin/bash\nexec java -jar "%s" "$@"\n' "$HOME/.local/share/checkstyle/checkstyle-$CS_VER-all.jar" >"$HOME/.local/bin/checkstyle"
chmod +x "$HOME/.local/bin/checkstyle"

rm -rf "$HOME/.local/share/jdtls"
mkdir -p "$HOME/.local/share/jdtls"
curl -fsSL "https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz" | tar xz -C "$HOME/.local/share/jdtls"
ln -sf "$HOME/.local/share/jdtls/bin/jdtls" "$HOME/.local/bin/jdtls"

sudo mkdir -p /usr/share/java/lombok
sudo curl -fsSL "https://projectlombok.org/downloads/lombok.jar" -o /usr/share/java/lombok/lombok.jar

JDB_VSIX=$(curl -fsSL https://open-vsx.org/api/vscjava/vscode-java-debug 2>/dev/null | jq -r '.files.download' 2>/dev/null || true)
sudo mkdir -p /usr/share/java-debug
sudo find /usr/share/java-debug -maxdepth 1 -name '*.jar' -delete
curl -fsSL "$JDB_VSIX" -o /tmp/vscjava.vscode-java-debug.vsix
sudo unzip -o -j /tmp/vscjava.vscode-java-debug.vsix "extension/server/*.jar" -d /usr/share/java-debug
rm -f /tmp/vscjava.vscode-java-debug.vsix

if [ "$(getent passwd "$DEFAULT_USERNAME" | cut -d: -f7)" != "/usr/bin/fish" ]; then
	grep -qxF /usr/bin/fish /etc/shells || echo /usr/bin/fish | sudo tee -a /etc/shells
	sudo chsh -s /usr/bin/fish "$DEFAULT_USERNAME"
fi

sudo usermod -aG docker "$DEFAULT_USERNAME"

mkdir -p "$HOME/.config" "$HOME/Pictures" "$HOME/.config/environment.d" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/nvim" "$HOME/.config/fish/functions" "$HOME/.config/tmux" "$HOME/.config/opencode" "$HOME/.config/conky" "$HOME/.config/htop"

cat >"$HOME/.config/environment.d/qt-gtk.conf" <<'EOF'
QT_QPA_PLATFORMTHEME=gtk3
EOF

cat >"$HOME/.config/gtk-3.0/settings.ini" <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
EOF

cat >"$HOME/.config/gtk-4.0/settings.ini" <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
EOF

nohup flatpak run io.github.swordpuffin.rewaita >/dev/null 2>&1 &

curl -fL --retry 3 --retry-delay 2 -z "$HOME/Pictures/background.png" https://raw.githubusercontent.com/231tr0n/config/main/backgrounds/background.png -o "$HOME/Pictures/background.png" || true
curl -fL --retry 3 --retry-delay 2 -z "$HOME/Pictures/grub.png" https://raw.githubusercontent.com/231tr0n/config/main/backgrounds/grub.png -o "$HOME/Pictures/grub.png" || true
curl -fL --retry 3 --retry-delay 2 -z "$HOME/Pictures/profile.png" https://raw.githubusercontent.com/231tr0n/config/main/backgrounds/profile.png -o "$HOME/Pictures/profile.png" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/conky/conky.conf -o "$HOME/.config/conky/conky.conf" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/conky/conky-ncurses.conf -o "$HOME/.config/conky/conky-ncurses.conf" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/conky/usage -o "$HOME/.config/conky/usage" && chmod +x "$HOME/.config/conky/usage" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/conky/conky-tui -o "$HOME/.local/bin/conky-tui" && chmod +x "$HOME/.local/bin/conky-tui" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/fish/config.fish -o "$HOME/.config/fish/config.fish" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_mode_prompt.fish -o "$HOME/.config/fish/functions/fish_mode_prompt.fish" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_prompt.fish -o "$HOME/.config/fish/functions/fish_prompt.fish" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_user_key_bindings.fish -o "$HOME/.config/fish/functions/fish_user_key_bindings.fish" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/git/.gitconfig -o "$HOME/.gitconfig" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/htop/htoprc -o "$HOME/.config/htop/htoprc" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.lua -o "$HOME/.config/nvim/init.lua" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.vim -o "$HOME/.vimrc" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/opencode/cli.json -o "$HOME/.config/opencode/cli.json" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/tmux/tmux.conf -o "$HOME/.config/tmux/tmux.conf" || true

PROFILE_UUID=$(gsettings get org.gnome.Ptyxis default-profile-uuid 2>/dev/null | tr -d "'" | tr -d ' ' || true)
set +e
if [ -n "$PROFILE_UUID" ]; then
	dconf write /org/gnome/Ptyxis/Profiles/"$PROFILE_UUID"/label "'default'"
	dconf write /org/gnome/Ptyxis/Profiles/"$PROFILE_UUID"/limit-scrollback false
	dconf write /org/gnome/Ptyxis/Profiles/"$PROFILE_UUID"/opacity 1.0
	dconf write /org/gnome/Ptyxis/Profiles/"$PROFILE_UUID"/palette "'Everforest'"
fi

gsettings set org.gnome.Ptyxis enable-a11y true
gsettings set org.gnome.Ptyxis inhibit-logout false
gsettings set org.gnome.desktop.a11y always-show-universal-access-status true
gsettings set org.gnome.desktop.a11y.interface show-status-shapes true
gsettings set org.gnome.desktop.a11y.keyboard togglekeys-enable true
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/background.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Pictures/background.png"
gsettings set org.gnome.desktop.background primary-color '#000000000000'
gsettings set org.gnome.desktop.background secondary-color '#000000000000'
gsettings set org.gnome.desktop.break-reminders selected-breaks "['eyesight']"
gsettings set org.gnome.desktop.break-reminders.eyesight play-sound true
gsettings set org.gnome.desktop.break-reminders.movement duration-seconds 300
gsettings set org.gnome.desktop.break-reminders.movement interval-seconds 1800
gsettings set org.gnome.desktop.break-reminders.movement play-sound true
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.desktop.interface accent-color 'green'
gsettings set org.gnome.desktop.interface clock-format '24h'
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface enable-hot-corners true
gsettings set org.gnome.desktop.interface locate-pointer true
gsettings set org.gnome.desktop.interface monospace-font-name 'Cascadia Code NF 12'
gsettings set org.gnome.desktop.interface overlay-scrolling false
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.privacy report-technical-problems true
gsettings set org.gnome.desktop.screensaver picture-uri "file://$HOME/Pictures/background.png"
gsettings set org.gnome.desktop.screensaver primary-color '#000000000000'
gsettings set org.gnome.desktop.screensaver secondary-color '#000000000000'
gsettings set org.gnome.desktop.session idle-delay 30
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.wm.preferences num-workspaces 9
gsettings set org.gnome.desktop.wm.preferences visual-bell true
gsettings set org.gnome.desktop.wm.preferences visual-bell-type 'frame-flash'
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.nautilus.list-view use-tree-view true
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 0.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 0.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4500
gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 5
gsettings set org.gnome.shell always-show-log-out true
gsettings set org.gnome.shell favorite-apps "@as []"
gsettings set org.gnome.shell.extensions.just-perfection panel false
gsettings set org.gnome.shell.extensions.just-perfection panel-in-overview true
gsettings set org.gnome.shell.extensions.user-theme name 'rewaita'
gsettings set org.gnome.system.location enabled true

busctl call org.freedesktop.Accounts "/org/freedesktop/Accounts/User$(id -u "$DEFAULT_USERNAME")" org.freedesktop.Accounts.User SetIconFile s "$HOME/Pictures/profile.png"

gdctl set -P -L --monitor "$(gdctl show | grep -oP 'Monitor\s+\K\S+')" --primary --scale 2

gnome-extensions disable background-logo@fedorahosted.org || true
gnome-extensions enable launch-new-instance@gnome-shell-extensions.gcampax.github.com || true
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com || true
gnome-extensions enable just-perfection-desktop@just-perfection || true
set -e

info_log 'Setup finished. Log out or reboot to apply all changes.'
