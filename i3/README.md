Packages to install

```
sudo pacman -S i3 picom volumeicon xdotool feh dunst firefox gnome-terminal nemo maim rofi lxappearance-gtk3 blueman bluez xfce4-notifyd network-manager-applet ranger connman connman-gtk dmenu xclip light-locker lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings lightdm-slick-greeter polkit-gnome
```

Rename these files to .bak accordingly:-
```
/usr/share/dbus-1/services/org.knopwob.dunst.service
/usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service
```
Also after you install brightnessctl, run this command:-
```
sudo chmod +s /usr/bin/brightnessctl
```

Also build the status.go program using `go build status.go` if you are using it.
