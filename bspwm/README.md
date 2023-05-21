Packages to install
```
bspwm
picom
volumeicon-alsa
xdotool
feh
dunst
firefox
gnome-terminal
nemo
maim
rofi
grabc
lxappearance
bluez
bluez-tools
blueman
xscreensaver
brightnessctl
acpi
xfce4-notifyd
network-manager
network-manager-gnome
ranger
connman
connman-gtk
font-manager
fonts-font-awesome
polybar
suckless-tools
slock
```

Rename this file as .bak after you install dunst:-
```
/usr/share/dbus-1/services/org.knopwob.dunst.service
/usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service
```
Also after you install brightnessctl, run this command:-
```
sudo chmod +s /usr/bin/brightnessctl
```
Also build the notify program using `go build notify.go`
