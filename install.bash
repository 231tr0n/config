sudo apt update && sudo apt upgrade && sudo apt autoremove
sudo apt install apt-transport-https curl software-properties-common gnupg-agent
sudo apt install -y python3-pip default-jdk gnome-terminal cmus netcat fzf ttf-mscorefonts-installer w3m kcolorchooser vim neovim stacer cmatrix hollywood htop kazam mpv pavucontrol ranger vlc vokoscreen webcamoid cheese bat nmap ruby ffmpeg git mariadb-server imagemagick tesseract-ocr xclip minify ncdu ssh sqlite3 tlp tmate john tmux pandoc vim-scripts ncat vim-doc atool arc arj lzip lzop nomarch rar rpm unace unalz caca-utils highlight libarchive-tools calibre mediainfo exiftool odt2txt jq openscad xdotool wmctrl feh progress ppa-purge lynx zeal maim upower sox zenity rofi volumeicon-alsa picom thermald zip vim-gtk3 openssl openvpn gummi texlive-science qutebrowser grabc pavucontrol-qt chromium lxappearance wireshark bluez bluez-tools blueman apktool adb brightnessctl kamoso telnet libpcap-dev gobuster sqlmap espeak gnome-clocks dconf-editor acpi go-exploitdb jsonlint xscreensaver xfce4-notifyd lightdm rpi-imager shutter bpytop ifstat bspwm suckless-tools doncf-cli fonts-font-awesome polybar ripgrep

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(. /etc/os-release; echo "$UBUNTU_CODENAME") stable"
sudo apt update
sudo apt install docker.io

# Install fish-shell
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update
sudo apt install fish

# Install audio-recorder
sudo apt-add-repository ppa:audio-recorder/ppa
sudo apt update
sudo apt install audio-recorder

# Install font-manager
sudo add-apt-repository ppa:font-manager/staging
sudo apt update
sudo apt install font-manager

# Install golang & golang-x-tools
sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt update
sudo apt install golang-go golang-golang-x-tools

# Install vim
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update
sudo apt install vim

# Install neovim
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt update
sudo apt install neovim

# Install nodejs and npm
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs

# Install brave browser
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser

# Install nikto
git clone https://github.com/sullo/nikto.git
cd nikto
sudo docker build -t sullo/nikto .

# Install nala
echo "deb https://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg > /dev/null
sudo apt update && sudo apt install nala

# Install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# npm installs
sudo npm install -g npm@latest
sudo npm install -g nodemon pm2 forever express-generator snyk eslint prettier prettier-eslint-cli hexo-cli typescript ts-node gulp-cli javascript-obfuscator workbox-cli webpack-cli sequelize-cli file-type-cli node-notifier-cli gatsby-cli @electron-forge/cli figlet-cli localtunnel typescript-language-server npm-check-updates fastify-cli typescript-formatter js-beautify

#pip3 installs
sudo pip3 install --upgrade pip
sudo pip3 install numpy pandas tensorflow torch keras ufw seaborn wpm matplotlib scipy scikit-learn tesseract opencv-python chardet notebook youtube-dl torchvision nltk frida-tools sentence-transformers sqlmap pylint yapf isort autopep8 wfuzz pipreqs autoreqs merge_requirements

# go installs
go install -v github.com/klauspost/asmfmt/cmd/asmfmt@latest
go install -v github.com/koron/iferr@latest
go install -v github.com/fatih/motion@latest
go install -v github.com/segmentio/golines@latest
go install -v github.com/fatih/gomodifytags@latest
go install -v github.com/jstemmer/gotags@latest
go install -v github.com/kisielk/errcheck@latest
go install -v github.com/davidrjenni/reftools/cmd/fillstruct@latest
go install -v github.com/rogpeppe/godef@latest
go install -v honnef.co/go/tools/cmd/keyify@latest
go install -v golang.org/x/tools/cmd/gorename@latest
go install -v golang.org/x/tools/cmd/goimports@latest
go install -v github.com/mgechev/revive@latest
go install -v github.com/josharian/impl@latest
go install -v github.com/ffuf/ffuf@latest
go install -v golang.org/x/tools/cmd/guru@latest
go install -v github.com/rverton/webanalyze/cmd/webanalyze@latest
go install -v honnef.co/go/tools/cmd/staticcheck@latest
go install -v github.com/go-delve/delve/cmd/dlv@latest
go install -v golang.org/x/tools/gopls@latest
go install -v github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install -v github.com/nao1215/gup@latest
go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/tlsx/cmd/tlsx@latest
go install -v github.com/projectdiscovery/proxify/cmd/proxify@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install github.com/tsenart/vegeta@latest
env CGO_ENABLED=0 go install -ldflags="-s -w" go install -v github.com/gokcehan/lf@latest

# Install google chrome
# Install protonvpn
# Install nordvpn
# Install pacstall
# Install matlab and matlab-support
# Install ocs-url
# Install RPI Imager
# Install Discord
# Install telegram
# Install Teams
# Install drawio
# Install Android Studio
# Install GenyMotion
# Install JD-GUI
# Install dex2jar
# Install rockyou.txt
# Install burp_suite
# Install Jadx
# Install metasploit
# Install owasp zap
