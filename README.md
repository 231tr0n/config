# config
All the config here is basically for linuxmint since I use that distro and install bspwm.

Also commands for mounting to be added to .profile
```bash
if ! cat /proc/mounts | grep -q /dev/sda4
then
	gio mount -d /dev/sda4
fi
```
