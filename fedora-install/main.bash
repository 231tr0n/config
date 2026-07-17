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

sudo dnf install -y tree-sitter-cli diff-so-fancy vim neovim tmux fish bash fzf ripgrep fd-find git jq yq zoxide bat patch
sudo dnf install -y go delve nodejs npm gcc gdb make meson java maven rustup
sudo dnf install -y shfmt shellcheck gofumpt golangci-lint gopls clang-format clang-tools-extra clangd
sudo dnf install -y yt-dlp ffmpeg ImageMagick
sudo dnf install -y htop inxi ncdu btop util-linux bleachbit
sudo dnf install -y glib2-devel grub2-breeze-theme xdg-desktop-portal xdg-desktop-portal-gnome gnome-tweaks gnome-extensions-app gnome-music plasma-breeze-common qadwaitadecorations-qt5 cascadia-code-nf-fonts cascadia-mono-nf-fonts gnome-shell-extension-common gnome-shell-extension-appindicator gnome-shell-extension-just-perfection gnome-shell-extension-user-theme gnome-shell-extension-apps-menu gnome-shell-extension-launch-new-instance gnome-shell-extension-places-menu gnome-shell-extension-window-list gtk-murrine-engine mpd ncmpc firefox google-chrome-stable
sudo dnf install -y --setopt=install_weak_deps=false plasma-integration
sudo dnf install -y ollama llama-cpp
sudo dnf install -y docker-cli runc toolbox

flatpak install -y flathub com.github.finefindus.eyedropper
flatpak install -y flathub org.gtk.Gtk3theme.Adwaita-dark

sudo dnf autoremove -y
flatpak uninstall --unused -y

rustup-init --profile complete -y
sudo npm install -g opencode-ai prettier eslint typescript-language-server typescript svelte-language-server

[ "$SHELL" != "/usr/bin/fish" ] && chsh -s /usr/bin/fish

sudo usermod -aG docker "$USER"

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

PROFILE_UUID=$(gsettings get org.gnome.Ptyxis default-profile-uuid 2>/dev/null | tr -d "'" | tr -d ' ')
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
gsettings set org.gnome.desktop.background color-shading-type 'solid'
gsettings set org.gnome.desktop.background picture-options 'zoom'
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/background.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Pictures/background.png"
gsettings set org.gnome.desktop.background primary-color '#000000000000'
gsettings set org.gnome.desktop.background secondary-color '#000000000000'
gsettings set org.gnome.desktop.break-reminders selected-breaks "['eyesight']"
gsettings set org.gnome.desktop.break-reminders.eyesight play-sound true
gsettings set org.gnome.desktop.break-reminders.movement duration-seconds uint32 300
gsettings set org.gnome.desktop.break-reminders.movement interval-seconds uint32 1800
gsettings set org.gnome.desktop.break-reminders.movement play-sound true
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.desktop.interface accent-color 'green'
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface locate-pointer true
gsettings set org.gnome.desktop.interface monospace-font-name 'Cascadia Code NF 12'
gsettings set org.gnome.desktop.interface overlay-scrolling false
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.privacy report-technical-problems true
gsettings set org.gnome.desktop.screensaver color-shading-type 'solid'
gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
gsettings set org.gnome.desktop.screensaver picture-uri "file://$HOME/Pictures/background.png"
gsettings set org.gnome.desktop.screensaver primary-color '#000000000000'
gsettings set org.gnome.desktop.screensaver secondary-color '#000000000000'
gsettings set org.gnome.desktop.search-providers enabled "['org.gnome.Weather.desktop', 'com.github.finefindus.eyedropper.desktop']"
gsettings set org.gnome.desktop.session idle-delay 120
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.preferences visual-bell true
gsettings set org.gnome.desktop.wm.preferences visual-bell-type 'frame-flash'
gsettings set org.gnome.nautilus.list-view use-tree-view true
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 0.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 0.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3700
gsettings set org.gnome.shell disabled-extensions "['window-list@gnome-shell-extensions.gcampax.github.com']"
gsettings set org.gnome.shell enabled-extensions "['places-menu@gnome-shell-extensions.gcampax.github.com', 'launch-new-instance@gnome-shell-extensions.gcampax.github.com', 'apps-menu@gnome-shell-extensions.gcampax.github.com', 'just-perfection-desktop@just-perfection', 'appindicatorsupport@rgcjonas.gmail.com', 'user-theme@gnome-shell-extensions.gcampax.github.com']"
gsettings set org.gnome.shell favorite-apps "@as []"
gsettings set org.gnome.shell last-selected-power-profile 'power-saver'
gsettings set org.gnome.shell.extensions.appindicator compact-mode-enabled false
gsettings set org.gnome.shell.extensions.just-perfection panel false
gsettings set org.gnome.shell.extensions.just-perfection panel-in-overview true
gsettings set org.gnome.shell.extensions.just-perfection support-notifier-type 0
gsettings set org.gnome.shell.extensions.user-theme name ''
gsettings set org.gnome.system.location enabled true

SET_GDM="/usr/local/bin/set-gdm-wallpaper"
sudo curl -sSLo "$SET_GDM" https://raw.githubusercontent.com/kem-a/gnome-gdm-wallpaper/main/set-gdm-wallpaper
sudo chmod +x "$SET_GDM"
sudo "$SET_GDM" -i "$HOME/Pictures/grub.png" -b 8 || true

echo -e 'user-db:user\nsystem-db:gdm\nfile-db:/usr/share/gdm/greeter-dconf-defaults' | sudo tee /etc/dconf/profile/gdm >/dev/null
echo -e '[org/gnome/desktop/interface]\naccent-color='\''green'\''' | sudo tee /etc/dconf/db/gdm.d/01-accent-color >/dev/null
sudo dconf update

sudo sed -i 's/^GRUB_TERMINAL_OUTPUT="console"/GRUB_TERMINAL_OUTPUT="gfxterm"/' /etc/default/grub
grep -qxF 'GRUB_THEME="/boot/grub2/themes/breeze/theme.txt"' /etc/default/grub ||
	echo 'GRUB_THEME="/boot/grub2/themes/breeze/theme.txt"' | sudo tee -a /etc/default/grub >/dev/null
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

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
