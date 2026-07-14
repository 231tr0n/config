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

sudo dnf update

sudo dnf install -y tree-sitter-cli diff-so-fancy vim neovim tmux fish bash fzf ripgrep fd-find git jq yq zoxide bat
sudo dnf install -y go delve nodejs npm gcc gdb make meson java maven rustup
sudo dnf install -y shfmt shellcheck gofumpt golangci-lint gopls clang-format clang-tools-extra clangd
sudo dnf install -y yt-dlp ffmpeg ImageMagick
sudo dnf install -y htop inxi ncdu btop util-linux
sudo dnf install -y glib2-devel grub2-breeze-theme xdg-desktop-portal xdg-desktop-portal-gnome gnome-tweaks gnome-extensions-app gnome-music mpv vlc kcolorchooser plasma-breeze-common qadwaitadecorations-qt5 cascadia-code-nf-fonts cascadia-mono-nf-fonts gnome-shell-extension-forge gnome-shell-extension-common gnome-shell-extension-appindicator gnome-shell-extension-just-perfection
sudo dnf install -y --setopt=install_weak_deps=false plasma-integration
sudo dnf install -y ollama llama-cpp
sudo dnf install -y docker-cli

sudo dnf autoremove -y
flatpak uninstall --unused -y

rustup-init --profile complete -y
sudo npm install -g opencode-ai prettier eslint typescript-language-server typescript svelte-language-server

[ "$SHELL" != "/usr/bin/fish" ] && chsh -s /usr/bin/fish

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/fish/functions"
mkdir -p "$HOME/.config/tmux"
mkdir -p "$HOME/.config/opencode"

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
curl https://raw.githubusercontent.com/231tr0n/config/main/backgrounds/background.png -o "$HOME/Pictures/background.png"
curl https://raw.githubusercontent.com/231tr0n/config/main/backgrounds/grub.png -o "$HOME/Pictures/grub.png"
curl https://raw.githubusercontent.com/231tr0n/config/main/backgrounds/profile.png -o "$HOME/Pictures/profile.png"

SET_GDM="/usr/local/bin/set-gdm-wallpaper"
sudo curl -sSLo "$SET_GDM" https://raw.githubusercontent.com/kem-a/gnome-gdm-wallpaper/main/set-gdm-wallpaper
sudo chmod +x "$SET_GDM"
sudo "$SET_GDM" -i "$HOME/Pictures/grub.png" -b 8 || true

sudo sed -i 's/^GRUB_TERMINAL_OUTPUT="console"/GRUB_TERMINAL_OUTPUT="gfxterm"/' /etc/default/grub
grep -qxF 'GRUB_THEME="/boot/grub2/themes/breeze/theme.txt"' /etc/default/grub ||
	echo 'GRUB_THEME="/boot/grub2/themes/breeze/theme.txt"' | sudo tee -a /etc/default/grub >/dev/null
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

gsettings set org.gnome.desktop.interface monospace-font-name "Cascadia Code NF 15"

grep -qxF 'QT_QPA_PLATFORMTHEME=kde' /etc/environment || echo 'QT_QPA_PLATFORMTHEME=kde' | sudo tee -a /etc/environment >/dev/null
grep -qxF 'QT_STYLE_OVERRIDE=Fusion' /etc/environment || echo 'QT_STYLE_OVERRIDE=Fusion' | sudo tee -a /etc/environment >/dev/null

if [ ! -f "$HOME/.config/kdeglobals" ]; then
	cat >"$HOME/.config/kdeglobals" <<'EOF'
[General]
widgetStyle=Fusion
ColorScheme=BreezeDark
AccentColor=Green
EOF
fi
