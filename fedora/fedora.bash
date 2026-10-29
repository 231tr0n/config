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
# Intel Graphics (Arc/Integrated) - Video accel, Vulkan, VA-API
sudo dnf install -y libva-intel-media-driver libva-utils vulkan-loader vulkan-tools mesa-vulkan-drivers
# Intel compute/OpenCL for Vulkan/Ollama backends
sudo dnf install -y ocl-icd intel-compute-runtime intel-opencl opencl-headers spirv-tools
# Vulkan shader compiler (needed for GGML_VULKAN)
sudo dnf install -y glslc glslang vulkan-headers libshaderc-devel spirv-headers-devel
# Intel NPU (Core Ultra) - Level Zero runtime & tools
sudo dnf install -y intel-level-zero oneapi-level-zero oneapi-level-zero-devel intel-level-zero-devel
# OpenVINO for Intel GPU + NPU
sudo dnf install -y openvino openvino-devel python3-openvino intel-npu-compiler
# Build deps for llama.cpp
sudo dnf install -y cmake make gcc-c++ git pkg-config libusb1-devel ocl-icd-devel

# llama.cpp - build latest from source with Vulkan + OpenVINO support
LLAMA_DIR="$HOME/.local/share/llama.cpp"
if [ ! -f "$LLAMA_DIR/build/bin/llama-server" ]; then
	info_log 'Building llama.cpp from source...'
	if [ ! -d "$LLAMA_DIR/.git" ]; then
		rm -rf "$LLAMA_DIR"
		git clone --depth 1 https://github.com/ggml-org/llama.cpp.git "$LLAMA_DIR"
	fi
	cd "$LLAMA_DIR"
	git pull --ff-only 2>/dev/null || true
	cmake -B build \
		-DCMAKE_BUILD_TYPE=Release \
		-DGGML_NATIVE=ON \
		-DGGML_VULKAN=ON \
		-DGGML_OPENVINO=ON \
		-DOpenCL_LIBRARY=/usr/lib64/libOpenCL.so.1 \
		-DOpenCL_INCLUDE_DIR=/usr/include
	cmake --build build --config Release -j"$(nproc)"
	cd - >/dev/null
else
	info_log 'llama.cpp already built, skipping.'
fi
mkdir -p "$HOME/.local/bin"
for bin in llama-server llama-cli llama-bench llama-perplexity llama-mtmd-cli llama-gguf llama-imatrix; do
	[ -f "$LLAMA_DIR/build/bin/$bin" ] && ln -sf "$LLAMA_DIR/build/bin/$bin" "$HOME/.local/bin/$bin"
done

sudo dnf update -y

sudo systemctl enable --now mariadb
# Fedora initializes root@localhost with unix_socket auth, so sudo mariadb -u root
# works without a password. These mirror mariadb-secure-installation with no auth
# or root password change, while removing anonymous users, remote root logins, and
# the test database.
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

rustup-init --profile complete -y
rustup update

sudo npm install -g @opencode/cli@latest prettier@latest eslint@latest typescript-language-server@latest typescript@latest svelte-language-server@latest

curl -fsSL https://raw.githubusercontent.com/lunarmodules/luacheck/master/luacheck-dev-1.rockspec -o /tmp/luacheck-dev-1.rockspec
luarocks install --local --force /tmp/luacheck-dev-1.rockspec
rm -f /tmp/luacheck-dev-1.rockspec

cargo install cargo-update
cargo install stylua --features luajit
cargo install-update -a

go install github.com/nao1215/gup@latest
go install github.com/reteps/dockerfmt@latest
go install sigs.k8s.io/yaml/yamlfmt@latest
gup update

pipx install mbake
pipx upgrade-all

# Ollama
if command -v ollama >/dev/null 2>&1; then
	OLLAMA_CUR="$(ollama --version 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
	OLLAMA_LATEST="$(curl -fsSL https://api.github.com/repos/ollama/ollama/releases/latest 2>/dev/null | jq -r '.tag_name' | sed 's/^v//' | head -1)"
	if [ -n "$OLLAMA_CUR" ] && [ -n "$OLLAMA_LATEST" ] && [ "$OLLAMA_CUR" = "$OLLAMA_LATEST" ]; then
		info_log "ollama $OLLAMA_CUR is already the latest, skipping install/update."
	else
		info_log "ollama $OLLAMA_CUR -> ${OLLAMA_LATEST:-unknown}, updating..."
		curl -fsSL https://ollama.com/install.sh -o /tmp/ollama-install.sh
		sed -i 's/--progress-bar/--silent/g' /tmp/ollama-install.sh
		sh /tmp/ollama-install.sh
		rm -f /tmp/ollama-install.sh
	fi
else
	info_log "ollama not found, installing..."
	curl -fsSL https://ollama.com/install.sh -o /tmp/ollama-install.sh
	sed -i 's/--progress-bar/--silent/g' /tmp/ollama-install.sh
	sh /tmp/ollama-install.sh
	rm -f /tmp/ollama-install.sh
fi

sudo mkdir -p /etc/systemd/system/ollama.service.d
echo -e "[Service]\nEnvironment=\"OLLAMA_IGPU_ENABLE=1\"" | sudo tee /etc/systemd/system/ollama.service.d/override.conf >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable --now ollama 2>/dev/null || sudo systemctl restart ollama 2>/dev/null || true

mbake init --force
BAKE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/bake.toml"
# mbake 1.5 prefers a legacy ~/.bake.toml over the XDG config; move it aside so
# the config edited here is the one mbake actually reads.
if [ -f "$HOME/.bake.toml" ]; then
	mv "$HOME/.bake.toml" "$HOME/.bake.toml.bak"
fi
sed -i 's/auto_insert_phony_declarations = false/auto_insert_phony_declarations = true/' "$BAKE_CONFIG"
sed -i 's/group_phony_declarations = false/group_phony_declarations = true/' "$BAKE_CONFIG"
sed -i 's/phony_at_top = false/phony_at_top = true/' "$BAKE_CONFIG"
sed -i 's/max_consecutive_empty_lines = 2/max_consecutive_empty_lines = 1/' "$BAKE_CONFIG"
sed -i 's/indent_nested_conditionals = false/indent_nested_conditionals = true/' "$BAKE_CONFIG"
sed -i 's/tab_width = 2/tab_width = 4/' "$BAKE_CONFIG"
sed -i 's/align_variable_assignments = false/align_variable_assignments = true/' "$BAKE_CONFIG"
sed -i 's/align_across_comments = false/align_across_comments = true/' "$BAKE_CONFIG"

mkdir -p "$HOME/.local/bin" "$HOME/.local/share/"{lua-language-server,google-java-format,checkstyle,jdtls}

LUA_LS_VER=$(curl -fsSL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest | jq -r '.tag_name')
rm -rf "$HOME/.local/share/lua-language-server"
mkdir -p "$HOME/.local/share/lua-language-server"
curl -fsSL "https://github.com/LuaLS/lua-language-server/releases/download/$LUA_LS_VER/lua-language-server-$LUA_LS_VER-linux-x64.tar.gz" | tar xz -C "$HOME/.local/share/lua-language-server"
ln -sf "$HOME/.local/share/lua-language-server/bin/lua-language-server" "$HOME/.local/bin/lua-language-server"

GJF_VER=$(curl -fsSL https://api.github.com/repos/google/google-java-format/releases/latest | jq -r '.tag_name' | cut -c2-)
rm -f "$HOME/.local/share/google-java-format/"*.jar
curl -fsSL "https://github.com/google/google-java-format/releases/download/v$GJF_VER/google-java-format-$GJF_VER-all-deps.jar" -o "$HOME/.local/share/google-java-format/google-java-format-$GJF_VER-all-deps.jar"
printf '#!/bin/bash\nexec java -jar "%s" "$@"\n' "$HOME/.local/share/google-java-format/google-java-format-$GJF_VER-all-deps.jar" >"$HOME/.local/bin/google-java-format"
chmod +x "$HOME/.local/bin/google-java-format"

CS_TAG=$(curl -fsSL https://api.github.com/repos/checkstyle/checkstyle/releases/latest | jq -r '.tag_name')
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

JDB_VSIX=$(curl -fsSL https://open-vsx.org/api/vscjava/vscode-java-debug | jq -r '.files.download')
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

mkdir -p "$HOME/.config"
mkdir -p "$HOME/Pictures"
mkdir -p "$HOME/.config/environment.d"
mkdir -p "$HOME/.config/gtk-3.0"
mkdir -p "$HOME/.config/gtk-4.0"
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/fish/functions"
mkdir -p "$HOME/.config/tmux"
mkdir -p "$HOME/.config/opencode"
mkdir -p "$HOME/.config/conky"
mkdir -p "$HOME/.config/htop"

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

curl -fL --retry 3 --retry-delay 2 https://raw.githubusercontent.com/231tr0n/config/main/backgrounds/background.png -o "$HOME/Pictures/background.png" || true
curl -fL --retry 3 --retry-delay 2 https://raw.githubusercontent.com/231tr0n/config/main/backgrounds/grub.png -o "$HOME/Pictures/grub.png" || true
curl -fL --retry 3 --retry-delay 2 https://raw.githubusercontent.com/231tr0n/config/main/backgrounds/profile.png -o "$HOME/Pictures/profile.png" || true
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/conky/conky.conf -o "$HOME/.config/conky/conky.conf"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/conky/conky-ncurses.conf -o "$HOME/.config/conky/conky-ncurses.conf"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/conky/usage -o "$HOME/.config/conky/usage" && chmod +x "$HOME/.config/conky/usage"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/conky/conky-tui -o "$HOME/.local/bin/conky-tui" && chmod +x "$HOME/.local/bin/conky-tui"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/fish/config.fish -o "$HOME/.config/fish/config.fish"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_mode_prompt.fish -o "$HOME/.config/fish/functions/fish_mode_prompt.fish"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_prompt.fish -o "$HOME/.config/fish/functions/fish_prompt.fish"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_user_key_bindings.fish -o "$HOME/.config/fish/functions/fish_user_key_bindings.fish"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/git/.gitconfig -o "$HOME/.gitconfig"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/htop/htoprc -o "$HOME/.config/htop/htoprc"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.lua -o "$HOME/.config/nvim/init.lua"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.vim -o "$HOME/.vimrc"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/opencode/cli.json -o "$HOME/.config/opencode/cli.json"
curl -fsSL https://raw.githubusercontent.com/231tr0n/config/main/tmux/tmux.conf -o "$HOME/.config/tmux/tmux.conf"

PROFILE_UUID=$(gsettings get org.gnome.Ptyxis default-profile-uuid 2>/dev/null | tr -d "'" | tr -d ' ' || true)
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

info_log 'Setup finished. Log out or reboot to apply all changes.'
