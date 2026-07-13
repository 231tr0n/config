#!/bin/bash

set -xe

DEFAULT_USERNAME=""

while getopts 'u:h' opt; do
	case "$opt" in
	u)
		DEFAULT_USERNAME="$OPTARG"
		;;
	h | ?)
		printf "Help\n
    -u: system username
    -h: print help
    \n"
		exit
		;;
	esac
done

function info_log {
	echo -ne "[\e[1;36mINFO\e[1;0m] "
	echo -e "$1"
}

if [ -z "$DEFAULT_USERNAME" ]; then
	info_log 'Default username is not set.'
	exit 1
fi

sudo modprobe i2c-i801
sudo modprobe i2c-dev

if [ ! -f "/usr/lib/systemd/system-sleep/iwlwifi.bash" ]; then
	sudo tee /usr/lib/systemd/system-sleep/iwlwifi.bash >/dev/null <<'EOF'
#!/bin/bash

case $1 in
pre)
	rfkill block wifi
	modprobe -r iwlmld iwlwifi 2>/dev/null
	;;
post)
	sleep 2
	modprobe iwlwifi
	modprobe iwlmld
	rfkill unblock wifi
	;;
esac
EOF
	chmod +x /usr/lib/systemd/system-sleep/iwlwifi.bash
fi

if [ ! -f "/home/$DEFAULT_USERNAME/.ssh/id_rsa" ]; then
	ssh-keygen -t rsa
fi

sudo dnf install tree-sitter-cli diff-so-fancy vim neovim tmux fish bash fzf ripgrep fd-find git jq yq zoxide bat
sudo dnf install go delve nodejs npm gcc gdb make meson java maven
sudo dnf install shfmt shellcheck gofumpt clang-format clang-tools-extra
sudo dnf install yt-dlp ffmpeg ImageMagick
sudo dnf install htop inxi ncdu btop util-linux
sudo dnf install qadwaitadecorations-qt5 qt6ct
sudo dnf install cascadia-code-nf-fonts cascadia-mono-nf-fonts
sudo dnf install gnome-tweaks gnome-extensions-app gnome-music kcolorchooser

sudo dnf autoremove
flatpak uninstall --unused

sudo npm install -g opencode-ai prettier

[ "$SHELL" != "/usr/bin/fish" ] && chsh -s /usr/bin/fish

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/fish/functions"
mkdir -p "$HOME/.config/tmux"
mkdir -p "$HOME/.config/opencode"
mkdir -p "$HOME/.config/qt6ct"

curl https://raw.githubusercontent.com/231tr0n/config/main/git/.gitconfig -o "$HOME/.gitconfig"
curl https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.lua -o "$HOME/.config/nvim/init.lua"
curl https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.vim -o "$HOME/.vimrc"
curl https://raw.githubusercontent.com/231tr0n/config/main/tmux/tmux.conf -o "$HOME/.config/tmux/tmux.conf"
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/config.fish -o "$HOME/.config/fish/config.fish"
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_prompt.fish -o "$HOME/.config/fish/functions/fish_prompt.fish"
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_user_key_bindings.fish -o "$HOME/.config/fish/functions/fish_user_key_bindings.fish"
curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_mode_prompt.fish -o "$HOME/.config/fish/functions/fish_mode_prompt.fish"
curl https://raw.githubusercontent.com/231tr0n/config/main/opencode/tui.json -o "$HOME/.config/opencode/tui.json"
curl https://raw.githubusercontent.com/231tr0n/config/main/opencode/opencode.json -o "$HOME/.config/opencode/opencode.json"

gsettings set org.gnome.desktop.interface monospace-font-name "Cascadia Code NF 15"

grep -qxF 'QT_QPA_PLATFORMTHEME=qt6ct' /etc/environment || echo 'QT_QPA_PLATFORMTHEME=qt6ct' | sudo tee -a /etc/environment >/dev/null

grep -qF '[Appearance]' "$HOME/.config/qt6ct/qt6ct.conf" >/dev/null || cat >>"$HOME/.config/qt6ct/qt6ct.conf" <<'EOF'
[Appearance]
style=Fusion
color_scheme_path=/usr/share/qt6ct/colors/darker.conf
standard_dialogs=desktop
EOF
