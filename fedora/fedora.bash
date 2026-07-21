#!/bin/bash

set -xe

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
	echo -ne "[\e[1;36mINFO\e[1;0m] "
	echo -e "$1"
}

if [ -z "$DEFAULT_USERNAME" ]; then
	info_log 'Default username is not set.'
	exit 1
fi

sudo tee /usr/lib/systemd/system-sleep/iwlwifi.bash >/dev/null <<'SHSCRIPT'
#!/bin/bash

WIFI_PCI=$(grep -l iwlmld /sys/bus/pci/devices/*/driver 2>/dev/null | head -1)
WIFI_PCI=${WIFI_PCI%/driver}
WIFI_PCI=${WIFI_PCI##*/}

d3cold_off() {
	[ -n "$WIFI_PCI" ] && [ -w "/sys/bus/pci/devices/$WIFI_PCI/d3cold_allowed" ] && echo 0 > "/sys/bus/pci/devices/$WIFI_PCI/d3cold_allowed"
}

case $1 in
pre)
	d3cold_off
	rfkill block wifi
	modprobe -r iwlmld iwlwifi 2>/dev/null
	;;
post)
	d3cold_off
	sleep 2
	modprobe iwlwifi
	modprobe iwlmld
	rfkill unblock wifi
	;;
esac
SHSCRIPT
sudo chmod +x /usr/lib/systemd/system-sleep/iwlwifi.bash

sudo tee /etc/udev/rules.d/80-disable-wifi-d3cold.rules >/dev/null <<'SHSCRIPT'
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x272b", ATTR{d3cold_allowed}="0"
SHSCRIPT
sudo udevadm control --reload

if [ ! -f "$HOME/.ssh/id_rsa" ]; then
	ssh-keygen -t rsa -f "$HOME/.ssh/id_rsa" -N "$SSH_PASSPHRASE"
fi

sudo dnf update -y
flatpak update -y

sudo dnf install -y tree-sitter-cli diff-so-fancy vim neovim tmux fish fzf ripgrep fd-find git jq yq zoxide bat patch ctags
sudo dnf install -y go luajit delve nodejs npm gcc python3 python3-pip pipx texlive-scheme-basic make gdb meson java maven rustup
sudo dnf install -y shfmt shellcheck gofumpt black pylint golangci-lint gopls clang-format texlive-latexindent clang-tools-extra clangd
sudo dnf install -y texlive-roboto texlive-enumitem texlive-titlesec texlive-wrapfig texlive-xstring
sudo dnf install -y yt-dlp ffmpeg ImageMagick
sudo dnf install -y htop inxi ncdu btop telnet bleachbit
sudo dnf install -y wl-clipboard gnome-tweaks gnome-extensions-app cascadia-code-nf-fonts cascadia-mono-nf-fonts google-chrome-stable mpv
sudo dnf install -y ollama llama-cpp
sudo dnf install -y docker-cli runc toolbox distrobox

flatpak install -y flathub com.github.finefindus.eyedropper
flatpak install -y flathub io.github.cmus.cmus
flatpak install -y flathub org.telegram.desktop
flatpak install -y flathub com.discordapp.Discord

sudo dnf autoremove -y
flatpak uninstall --unused -y

rustup-init --profile complete -y

sudo npm install -g opencode-ai prettier eslint typescript-language-server typescript svelte-language-server

luarocks install --local luacheck

cargo install stylua

sudo chsh -s /usr/bin/fish "$DEFAULT_USERNAME"

sudo usermod -aG docker "$DEFAULT_USERNAME"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/fish/functions"
mkdir -p "$HOME/.config/tmux"
mkdir -p "$HOME/.config/opencode"
mkdir -p "$HOME/.local/share/gnome-shell/extensions/panel-dim@oled-protect"

cat >"$HOME/.local/share/gnome-shell/extensions/panel-dim@oled-protect/extension.js" <<'EOF'
import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";
import * as Main from "resource:///org/gnome/shell/ui/main.js";

const MIN_BRIGHTNESS = 0x77;
const MAX_BRIGHTNESS = 0xff;
const INTERVAL = 1000;
const STEP_DELTA = (MAX_BRIGHTNESS - MIN_BRIGHTNESS) / 720;

export default class OledProtect extends Extension {
  enable() {
    this._brightness = MIN_BRIGHTNESS;
    this._direction = 1;
    this._apply();
    this._timer = setTimeout(() => this._cycle(), INTERVAL);
  }

  disable() {
    if (this._timer) {
      clearTimeout(this._timer);
      this._timer = null;
    }

    for (let widget of Object.values(Main.panel.statusArea)) {
      widget?.set_style?.("");
    }
  }

  _cycle() {
    this._brightness += this._direction * STEP_DELTA;
    if (this._brightness >= MAX_BRIGHTNESS) {
      this._brightness = MAX_BRIGHTNESS;
      this._direction = -1;
    } else if (this._brightness <= MIN_BRIGHTNESS) {
      this._brightness = MIN_BRIGHTNESS;
      this._direction = 1;
    }
    this._apply();
    this._timer = setTimeout(() => this._cycle(), INTERVAL);
  }

  _apply() {
    let level = Math.round(this._brightness);
    let hex = `#${level.toString(16).padStart(2, "0").repeat(3)}`;
    for (let widget of Object.values(Main.panel.statusArea)) {
      widget?.set_style?.(`color: ${hex};`);
    }
    let activitiesBtn = Main.panel.statusArea.activities;
    if (activitiesBtn?.first_child) {
      for (let child of activitiesBtn.first_child.get_children()) {
        if (child._dot) child._dot.set_style(`background-color: ${hex};`);
      }
    }
  }
}
EOF

cat >"$HOME/.local/share/gnome-shell/extensions/panel-dim@oled-protect/metadata.json" <<'EOF'
{
	"name": "OLED Panel Protect",
	"description": "Cycles panel text brightness to prevent OLED burn-in",
	"uuid": "panel-dim@oled-protect",
	"shell-version": ["50", "51"]
}
EOF

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
gsettings set org.gnome.desktop.interface enable-hot-corners false
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
gsettings set org.gnome.system.location enabled true

busctl call org.freedesktop.Accounts "/org/freedesktop/Accounts/User$(id -u "$DEFAULT_USERNAME")" org.freedesktop.Accounts.User SetIconFile s "$HOME/Pictures/profile.png"

gdctl set -P -L --monitor "$(gdctl show | grep -oP 'Monitor\s+\K\S+')" --primary --scale 2

gnome-extensions disable background-logo@fedorahosted.org
gnome-extensions enable panel-dim@oled-protect
