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
sudo dnf install -y htop inxi ncdu btop util-linux
sudo dnf install -y glib2-devel grub2-breeze-theme xdg-desktop-portal xdg-desktop-portal-gnome gnome-tweaks gnome-extensions-app gnome-music plasma-breeze-common qadwaitadecorations-qt5 cascadia-code-nf-fonts cascadia-mono-nf-fonts gnome-shell-extension-forge gnome-shell-extension-common gnome-shell-extension-appindicator gnome-shell-extension-just-perfection gnome-shell-extension-user-theme gtk-murrine-engine mpd ncmpc firefox google-chrome-stable
sudo dnf install -y --setopt=install_weak_deps=false plasma-integration
sudo dnf install -y ollama llama-cpp
sudo dnf install -y docker-cli runc

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

SET_GDM="/usr/local/bin/set-gdm-wallpaper"
sudo curl -sSLo "$SET_GDM" https://raw.githubusercontent.com/kem-a/gnome-gdm-wallpaper/main/set-gdm-wallpaper
sudo chmod +x "$SET_GDM"
sudo "$SET_GDM" -i "$HOME/Pictures/grub.png" -b 8 || true

echo -e 'user-db:user\nsystem-db:gdm\nfile-db:/usr/share/gdm/greeter-dconf-defaults' | sudo tee /etc/dconf/profile/gdm >/dev/null
echo -e '[org/gnome/desktop/interface]\naccent-color='\''green'\''' | sudo tee /etc/dconf/db/gdm.d/01-accent-color >/dev/null
sudo dconf update

gsettings set org.gnome.desktop.interface monospace-font-name "Cascadia Code NF 12"

GTK4_CSS="$HOME/.config/gtk-4.0/gtk.css"
GTK3_CSS="$HOME/.config/gtk-3.0/gtk.css"
SHELL_THEME_DIR="$HOME/.local/share/themes/Everforest-Shell"
SHELL_CSS="$SHELL_THEME_DIR/gnome-shell/gnome-shell.css"

mkdir -p "$HOME/.config/gtk-4.0"
mkdir -p "$HOME/.config/gtk-3.0"
mkdir -p "$SHELL_THEME_DIR/gnome-shell"

cat >"$GTK4_CSS" <<'GTK4EOF'
/* Everforest Medium — libadwaita */

@media (prefers-color-scheme: light) {
  :root {
    --window-bg-color: #fdf6e3;
    --window-fg-color: #5c6a72;
    --view-bg-color: #efebd4;
    --view-fg-color: #5c6a72;
    --headerbar-bg-color: #fdf6e3;
    --headerbar-fg-color: #5c6a72;
    --headerbar-backdrop-color: #fdf6e3;
    --headerbar-border-color: rgba(92, 106, 114, 0.15);
    --headerbar-shade-color: rgba(0, 0, 0, 0.07);
    --sidebar-bg-color: #f4f0d9;
    --sidebar-fg-color: #5c6a72;
    --sidebar-backdrop-color: #fdf6e3;
    --sidebar-border-color: rgba(0, 0, 0, 0.07);
    --sidebar-shade-color: rgba(0, 0, 0, 0.07);
    --secondary-sidebar-bg-color: #f4f0d9;
    --secondary-sidebar-fg-color: #5c6a72;
    --secondary-sidebar-backdrop-color: #fdf6e3;
    --secondary-sidebar-border-color: rgba(0, 0, 0, 0.07);
    --secondary-sidebar-shade-color: rgba(0, 0, 0, 0.07);
    --card-bg-color: #f4f0d9;
    --card-fg-color: #5c6a72;
    --card-shade-color: rgba(0, 0, 0, 0.07);
    --dialog-bg-color: #f4f0d9;
    --dialog-fg-color: #5c6a72;
    --popover-bg-color: #fdf6e3;
    --popover-fg-color: #5c6a72;
    --popover-shade-color: rgba(0, 0, 0, 0.07);
    --thumbnail-bg-color: #e6e2cc;
    --thumbnail-fg-color: #5c6a72;
    --overview-bg-color: #f4f0d9;
    --overview-fg-color: #5c6a72;
    --active-toggle-bg-color: #ffffff;
    --active-toggle-fg-color: #5c6a72;
    --accent-bg-color: #3a94c5;
    --accent-fg-color: #ffffff;
    --accent-color: #3a94c5;
    --destructive-bg-color: #f85552;
    --destructive-fg-color: #ffffff;
    --destructive-color: #f85552;
    --success-bg-color: #8da101;
    --success-fg-color: #ffffff;
    --success-color: #8da101;
    --warning-bg-color: #dfa000;
    --warning-fg-color: #ffffff;
    --warning-color: #dfa000;
    --error-bg-color: #f85552;
    --error-fg-color: #ffffff;
    --error-color: #f85552;
    --shade-color: rgba(0, 0, 0, 0.07);
    --scrollbar-outline-color: #ffffff;
  }
}

@media (prefers-color-scheme: dark) {
  :root {
    --window-bg-color: #2d353b;
    --window-fg-color: #d3c6aa;
    --view-bg-color: #232a2e;
    --view-fg-color: #d3c6aa;
    --headerbar-bg-color: #232a2e;
    --headerbar-fg-color: #d3c6aa;
    --headerbar-backdrop-color: #232a2e;
    --headerbar-border-color: rgba(211, 198, 170, 0.15);
    --headerbar-shade-color: rgba(0, 0, 0, 0.36);
    --sidebar-bg-color: #232a2e;
    --sidebar-fg-color: #d3c6aa;
    --sidebar-backdrop-color: #2d353b;
    --sidebar-border-color: rgba(0, 0, 0, 0.36);
    --sidebar-shade-color: rgba(0, 0, 0, 0.25);
    --secondary-sidebar-bg-color: #2d353b;
    --secondary-sidebar-fg-color: #d3c6aa;
    --secondary-sidebar-backdrop-color: #343f44;
    --secondary-sidebar-border-color: rgba(0, 0, 0, 0.36);
    --secondary-sidebar-shade-color: rgba(0, 0, 0, 0.25);
    --card-bg-color: #343f44;
    --card-fg-color: #d3c6aa;
    --card-shade-color: rgba(0, 0, 0, 0.36);
    --dialog-bg-color: #343f44;
    --dialog-fg-color: #d3c6aa;
    --popover-bg-color: #232a2e;
    --popover-fg-color: #d3c6aa;
    --popover-shade-color: rgba(0, 0, 0, 0.25);
    --thumbnail-bg-color: #3d484d;
    --thumbnail-fg-color: #d3c6aa;
    --overview-bg-color: #2d353b;
    --overview-fg-color: #d3c6aa;
    --active-toggle-bg-color: rgba(255, 255, 255, 0.15);
    --active-toggle-fg-color: #d3c6aa;
    --accent-bg-color: #7fbbb3;
    --accent-fg-color: #232a2e;
    --accent-color: #7fbbb3;
    --destructive-bg-color: #e67e80;
    --destructive-fg-color: #232a2e;
    --destructive-color: #e67e80;
    --success-bg-color: #a7c080;
    --success-fg-color: #232a2e;
    --success-color: #a7c080;
    --warning-bg-color: #dbbc7f;
    --warning-fg-color: #232a2e;
    --warning-color: #dbbc7f;
    --error-bg-color: #e67e80;
    --error-fg-color: #232a2e;
    --error-color: #e67e80;
    --shade-color: rgba(0, 0, 0, 0.25);
    --scrollbar-outline-color: rgba(0, 0, 0, 0.50);
  }
}
GTK4EOF

cat >"$GTK3_CSS" <<'GTK3EOF'
/* Everforest Medium — GTK3 overrides */

@media (prefers-color-scheme: light) {
  @define-color window_bg_color #fdf6e3;
  @define-color window_fg_color #5c6a72;
  @define-color view_bg_color #efebd4;
  @define-color view_fg_color #5c6a72;
  @define-color headerbar_bg_color #fdf6e3;
  @define-color headerbar_fg_color #5c6a72;
  @define-color headerbar_backdrop_color #fdf6e3;
  @define-color sidebar_bg_color #f4f0d9;
  @define-color sidebar_fg_color #5c6a72;
  @define-color card_bg_color #f4f0d9;
  @define-color card_fg_color #5c6a72;
  @define-color dialog_bg_color #f4f0d9;
  @define-color dialog_fg_color #5c6a72;
  @define-color popover_bg_color #fdf6e3;
  @define-color popover_fg_color #5c6a72;
  @define-color accent_bg_color #3a94c5;
  @define-color accent_fg_color #ffffff;
  @define-color accent_color #3a94c5;
  @define-color destructive_bg_color #f85552;
  @define-color success_bg_color #8da101;
  @define-color warning_bg_color #dfa000;
  @define-color error_bg_color #f85552;
  @define-color theme_bg_color #fdf6e3;
  @define-color theme_fg_color #5c6a72;
  @define-color theme_base_color #efebd4;
  @define-color theme_text_color #5c6a72;
  @define-color theme_selected_bg_color #3a94c5;
  @define-color theme_selected_fg_color #ffffff;
  @define-color insensitive_bg_color #f0ebd5;
  @define-color insensitive_fg_color rgba(92, 106, 114, 0.5);
  @define-color borders rgba(0, 0, 0, 0.12);
  @define-color theme_unfocused_bg_color #fdf6e3;
  @define-color theme_unfocused_fg_color #5c6a72;
  @define-color theme_unfocused_base_color #efebd4;
  @define-color theme_unfocused_text_color #5c6a72;
  @define-color theme_unfocused_selected_bg_color #3a94c5;
  @define-color theme_unfocused_selected_fg_color #ffffff;
  @define-color insensitive_base_color #efebd4;
  @define-color unfocused_insensitive_color #f0ebd5;
  @define-color unfocused_borders rgba(0, 0, 0, 0.12);
}

@media (prefers-color-scheme: dark) {
  @define-color window_bg_color #2d353b;
  @define-color window_fg_color #d3c6aa;
  @define-color view_bg_color #232a2e;
  @define-color view_fg_color #d3c6aa;
  @define-color headerbar_bg_color #232a2e;
  @define-color headerbar_fg_color #d3c6aa;
  @define-color headerbar_backdrop_color #232a2e;
  @define-color sidebar_bg_color #232a2e;
  @define-color sidebar_fg_color #d3c6aa;
  @define-color card_bg_color #343f44;
  @define-color card_fg_color #d3c6aa;
  @define-color dialog_bg_color #343f44;
  @define-color dialog_fg_color #d3c6aa;
  @define-color popover_bg_color #232a2e;
  @define-color popover_fg_color #d3c6aa;
  @define-color accent_bg_color #7fbbb3;
  @define-color accent_fg_color #232a2e;
  @define-color accent_color #7fbbb3;
  @define-color destructive_bg_color #e67e80;
  @define-color success_bg_color #a7c080;
  @define-color warning_bg_color #dbbc7f;
  @define-color error_bg_color #e67e80;
  @define-color theme_bg_color #2d353b;
  @define-color theme_fg_color #d3c6aa;
  @define-color theme_base_color #232a2e;
  @define-color theme_text_color #d3c6aa;
  @define-color theme_selected_bg_color #7fbbb3;
  @define-color theme_selected_fg_color #232a2e;
  @define-color insensitive_bg_color #2a3238;
  @define-color insensitive_fg_color rgba(211, 198, 170, 0.5);
  @define-color borders rgba(211, 198, 170, 0.15);
  @define-color theme_unfocused_bg_color #2d353b;
  @define-color theme_unfocused_fg_color #d3c6aa;
  @define-color theme_unfocused_base_color #232a2e;
  @define-color theme_unfocused_text_color #d3c6aa;
  @define-color theme_unfocused_selected_bg_color #7fbbb3;
  @define-color theme_unfocused_selected_fg_color #232a2e;
  @define-color insensitive_base_color #232a2e;
  @define-color unfocused_insensitive_color #2a3238;
  @define-color unfocused_borders rgba(211, 198, 170, 0.15);
}
GTK3EOF

cat >"$SHELL_THEME_DIR/index.theme" <<'INDEXEOF'
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=Everforest-Shell
Comment=Everforest Medium color scheme for GNOME Shell

[X-GNOME-Metatheme]
ShellTheme=Everforest-Shell
INDEXEOF

gresource extract /usr/share/gnome-shell/gnome-shell-theme.gresource \
	/org/gnome/shell/theme/gnome-shell.css >"$SHELL_CSS"

cat >>"$SHELL_CSS" <<'SHELLEOF'
/* Everforest Medium — Shell overrides */
@media (prefers-color-scheme: light) {
  #panel, .panel { background-color: #fdf6e3 !important; color: #5c6a72 !important; }
  #panel .panel-button { color: #5c6a72 !important; }
  .panel-button .clock { color: #5c6a72 !important; }
  #dash, .dash-background { background-color: #f4f0d9 !important; }
  .popup-menu, .popup-sub-menu { background-color: #fdf6e3 !important; color: #5c6a72 !important; }
  .popup-menu-item { color: #5c6a72 !important; }
  .notification-banner, .notification-banner:hover { background-color: #f4f0d9 !important; color: #5c6a72 !important; }
  .notification-banner .notification-button { color: #5c6a72 !important; }
  .workspace-background { background-color: #fdf6e3 !important; }
}

@media (prefers-color-scheme: dark) {
  #panel, .panel { background-color: #232a2e !important; color: #d3c6aa !important; }
  #panel .panel-button { color: #d3c6aa !important; }
  .panel-button .clock { color: #d3c6aa !important; }
  #dash, .dash-background { background-color: #232a2e !important; }
  .popup-menu, .popup-sub-menu { background-color: #343f44 !important; color: #d3c6aa !important; }
  .popup-menu-item { color: #d3c6aa !important; }
  .notification-banner, .notification-banner:hover { background-color: #343f44 !important; color: #d3c6aa !important; }
  .notification-banner .notification-button { color: #d3c6aa !important; }
  .workspace-background { background-color: #2d353b !important; }
}
SHELLEOF

ensure_everforest_terminal_profile() {
	local name="$1"
	local palette="$2"
	local bg="$3"
	local fg="$4"
	local uuid

	# Check if profile with this name already exists
	existing=$(dconf read /org/gnome/terminal/legacy/profiles:/list 2>/dev/null | tr -d '[]' | tr ',' '\n' | tr -d " '" | while read -r id; do
		if [ -n "$id" ] && [ "$(dconf read "/org/gnome/terminal/legacy/profiles:/:$id/visible-name" 2>/dev/null)" = "'$name'" ]; then
			echo "$id"
			break
		fi
	done)

	if [ -n "$existing" ]; then
		echo "$existing"
		return
	fi

	uuid=$(uuidgen)
	dconf write "/org/gnome/terminal/legacy/profiles:/:$uuid/visible-name" "'$name'"
	dconf write "/org/gnome/terminal/legacy/profiles:/:$uuid/palette" "$palette"
	dconf write "/org/gnome/terminal/legacy/profiles:/:$uuid/background-color" "'$bg'"
	dconf write "/org/gnome/terminal/legacy/profiles:/:$uuid/foreground-color" "'$fg'"
	dconf write "/org/gnome/terminal/legacy/profiles:/:$uuid/bold-color" "'$fg'"
	dconf write "/org/gnome/terminal/legacy/profiles:/:$uuid/cursor-color" "'$fg'"
	dconf write "/org/gnome/terminal/legacy/profiles:/:$uuid/use-theme-colors" "false"
	dconf write "/org/gnome/terminal/legacy/profiles:/:$uuid/bold-color-same-as-fg" "true"
	dconf write "/org/gnome/terminal/legacy/profiles:/:$uuid/scrollbar-policy" "'never'"
	dconf write "/org/gnome/terminal/legacy/profiles:/:$uuid/cursor-shape" "'ibeam'"
	dconf write "/org/gnome/terminal/legacy/profiles:/:$uuid/font" "'Cascadia Code NF 12'"

	echo "$uuid"
}

DARK_PALETTE="['#475258', '#e67e80', '#a7c080', '#dbbc7f', '#7fbbb3', '#d699b6', '#83c092', '#d3c6aa', '#7a8478', '#e67e80', '#a7c080', '#dbbc7f', '#7fbbb3', '#d699b6', '#83c092', '#9da9a0']"
LIGHT_PALETTE="['#5c6a72', '#f85552', '#8da101', '#dfa000', '#3a94c5', '#df69ba', '#35a77c', '#e6e2cc', '#a6b0a0', '#f85552', '#8da101', '#dfa000', '#3a94c5', '#df69ba', '#35a77c', '#829181']"

DARK_ID=$(ensure_everforest_terminal_profile "Everforest Dark" "$DARK_PALETTE" "#2d353b" "#d3c6aa")
ensure_everforest_terminal_profile "Everforest Light" "$LIGHT_PALETTE" "#fdf6e3" "#5c6a72" >/dev/null

dconf write /org/gnome/terminal/legacy/profiles:/default "'$DARK_ID'"

sudo flatpak override --filesystem=xdg-config/gtk-4.0
sudo flatpak override --filesystem=xdg-config/gtk-3.0

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
