## Gnome Terminal Config

Gnome terminal uses dconf to store its config. Its config is located in /org/gnome/terminal.
To install dconf run the following command:-
```bash
sudo pacman -S dconf dconf-editor
```
To dump the config to a file use the following command:-
```bash
dconf dump /org/gnome/terminal/ > config
```
To load the config use the following command:-
```bash
cat config | dconf load /org/gnome/terminal/
```
