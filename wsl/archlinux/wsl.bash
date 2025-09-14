#!/bin/bash

set -xe

DEFAULT_USERNAME="zeltron"
DEFAULT_USER_PASSWORD="zeltron"
ROOT_PASSWORD="$DEFAULT_USER_PASSWORD"
SSH_KEY_PASSWORD="$DEFAULT_USER_PASSWORD"
WSL_CONFIG_CHANGED="No"

while getopts 's:r:u:p:hw' opt; do
	case "$opt" in
	r)
		ROOT_PASSWORD="$OPTARG"
		;;
	p)
		DEFAULT_USER_PASSWORD="$OPTARG"
		;;
	u)
		DEFAULT_USERNAME="$OPTARG"
		;;
	s)
		SSH_KEY_PASSWORD="$OPTARG"
		;;
	h | ?)
		printf "Help\n
    -s: ssh-key password
    -r: root password
    -u: system username
    -p: system password
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

if [ "$(id -u)" -ne 0 ]; then
	info_log "Please run this script as super user"
	exit 1
fi

if grep "default=$DEFAULT_USERNAME" /etc/wsl.conf &>/dev/null; then
	WSL_CONFIG_CHANGED="Yes"
fi

if [ "$WSL_CONFIG_CHANGED" = "No" ]; then
	if ! grep "default=$DEFAULT_USERNAME" /etc/wsl.conf &>/dev/null; then
		WSL_CONFIG_CHANGED="Yes"
		printf "\n[user]\ndefault=%s" "$DEFAULT_USERNAME" >>/etc/wsl.conf
	fi
fi

sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i 's/NoProgressBar/#NoProgressBar/g' /etc/pacman.conf
sed -i 's/ParallelDownloads = 5/ParallelDownloads = 3/g' /etc/pacman.conf

pacman -Syu --noconfirm --needed reflector sudo fish
if ! [ -f "/etc/pacman.d/mirrorlist.bak" ]; then
	mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
fi
reflector --fastest 5 --protocol https --country India --sort rate --save /etc/pacman.d/mirrorlist

if ! id -u "$DEFAULT_USERNAME" &>/dev/null; then
	echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)
	echo '%wheel ALL=(ALL:ALL) ALL' | (EDITOR='tee -a' visudo)

	useradd -m -s /usr/bin/fish -G wheel "$DEFAULT_USERNAME"
fi

passwd -s <<<"$ROOT_PASSWORD"

passwd -s "$DEFAULT_USERNAME" <<<"$DEFAULT_USER_PASSWORD"

function default_user_cmd {
	local args=""
	for arg in "$@"; do
		args="$args $arg"
	done
	args=${args# }
	su - "$DEFAULT_USERNAME" -c "$args"
}

echo "$DEFAULT_USERNAME $HOSTNAME= NOPASSWD: /usr/bin/pacman,/usr/sbin/pacman" | (EDITOR='tee -a' visudo)

reflector --fastest 5 --protocol https --country India --sort rate --save /etc/pacman.d/mirrorlist

if ! command -v yay &>/dev/null; then
	pacman -Syu --noconfirm --needed git base-devel less
	default_user_cmd 'rm -rf $HOME/yay-bin'
	default_user_cmd 'git clone https://aur.archlinux.org/yay-bin.git $HOME/yay-bin'
	default_user_cmd 'cd $HOME/yay-bin && makepkg -sic --noconfirm'
	default_user_cmd 'rm -rf $HOME/yay-bin'
	default_user_cmd 'mkdir -p $HOME/.config/yay'
	default_user_cmd 'echo "{\"answerdiff\": \"All\"}" > $HOME/.config/yay/config.json'
fi

PACKAGES=(
	"ttf-cascadia-code-nerd"
	"libsecret"
	"gnome-keyring"
	"xsel"
	"glibc-locales"
	"git"
	"base-devel"
	"fish"
	"sudo"
	"reflector"
	"go"
	"jdk8-openjdk"
	"jdk11-openjdk"
	"jdk17-openjdk"
	"jdk21-openjdk"
	"jdk-openjdk"
	"openjdk8-src"
	"openjdk8-doc"
	"openjdk11-src"
	"openjdk11-doc"
	"openjdk17-src"
	"openjdk17-doc"
	"openjdk21-src"
	"openjdk21-doc"
	"openjdk-doc"
	"openjdk-src"
	"python"
	"python-pip"
	"python-pipx"
	"curl"
	"wget"
	"ca-certificates"
	"openssl"
	"openssh"
	"inxi"
	"htop"
	"man-db"
	"jq"
	"vim"
	"neovim"
	"tree-sitter-cli"
	"tmux"
	"tmate"
	"libgit2"
	"fuse"
	"rustup"
	"docker"
	"docker-buildx"
	"docker-compose"
	"bat"
	"fzf"
	"fd"
	"ripgrep"
	"lsd"
	"fastfetch"
	"nodejs-lts"
	"npm"
	"clang"
	"gcc"
	"typescript"
	"luajit"
	"texlive"
	"texlab"
	"ts-node"
	"delve"
	"python-debugpy"
	"lldb"
	"gdb"
	"make"
	"cmake"
	"meson"
	"maven"
	"gradle"
	"ninja"
	"luarocks"
	"woff2"
	"ctags"
	"ffmpeg"
	"mpv"
	"zoxide"
	"evince"
	"net-tools"
	"sysstat"
	"axel"
	"tldr"
	"ncdu"
	"firefox"
	"google-chrome"
	"chromium"
	"bash-completion"
	"shellcheck"
	"luacheck"
	"python-pylint"
	"yamllint"
	"sqlfluff"
	"coursier"
	"java-debug"
	"jdtls"
	"pyright"
	"basedpyright-bin"
	"yaml-language-server"
	"sql-language-server"
	"svelte-language-server"
	"eslint-language-server"
	"lua-language-server"
	"typescript-language-server"
	"bash-language-server"
	"dockerfile-language-server"
	"vim-language-server"
	"lemminx"
	"vtsls"
	"marksman"
	"vscode-html-languageserver"
	"vscode-css-languageserver"
	"vscode-json-languageserver"
	"vscode-js-debug-bin"
	"tidy"
	"libxml2"
	"golangci-lint-langserver-bin"
	"golangci-lint-bin"
	"eslint"
	"python-black"
	"yamlfmt"
	"gofumpt"
	"shfmt"
	"stylua"
	"yamlfix"
	"google-java-format"
	"checkstyle-bin"
	"git-delta"
	"hurl"
	"cargo-update"
	"diff-so-fancy"
	"gup"
	"lazygit"
	"python-pylatexenc"
	"nodejs-nodemon"
	"ollama"
	"kubectl"
	"minikube"
	"helm"
	"inetutils"
	"prettier"
	"codespell"
	"perl-yaml-tiny"
	"perl-file-homedir"
	"yt-dlp"
	"vi"
	"visual-studio-code-bin"
	"mariadb"
)

default_user_cmd "yay -Syu --noconfirm --needed ${PACKAGES[*]}"

mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

npm install -g npm-groovy-lint@latest

archlinux-java set java-21-openjdk

default_user_cmd 'mkdir -p $HOME/.config'
default_user_cmd 'mkdir -p $HOME/.config/nvim'
default_user_cmd 'mkdir -p $HOME/.config/fish'
default_user_cmd 'mkdir -p $HOME/.config/fish/functions'
default_user_cmd 'mkdir -p $HOME/.config/tmux'

default_user_cmd 'curl https://raw.githubusercontent.com/231tr0n/config/main/git/.gitconfig -o $HOME/.gitconfig'
default_user_cmd 'curl https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.lua -o $HOME/.config/nvim/init.lua'
default_user_cmd 'curl https://raw.githubusercontent.com/231tr0n/config/main/nvim/init.vim -o $HOME/.vimrc'
default_user_cmd 'curl https://raw.githubusercontent.com/231tr0n/config/main/tmux/tmux.conf -o $HOME/.config/tmux/tmux.conf'
default_user_cmd 'curl https://raw.githubusercontent.com/231tr0n/config/main/fish/config.fish -o $HOME/.config/fish/config.fish'
default_user_cmd 'curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_prompt.fish -o $HOME/.config/fish/functions/fish_prompt.fish'
default_user_cmd 'curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_user_key_bindings.fish -o $HOME/.config/fish/functions/fish_user_key_bindings.fish'
default_user_cmd 'curl https://raw.githubusercontent.com/231tr0n/config/main/fish/functions/fish_mode_prompt.fish -o $HOME/.config/fish/functions/fish_mode_prompt.fish'
default_user_cmd 'curl https://raw.githubusercontent.com/231tr0n/config/main/wsl/archlinux/wsl.bash -o $HOME/wsl.bash'

default_user_cmd "rustup update stable"

default_user_cmd "coursier setup -y"
default_user_cmd "coursier install metals"

groupadd -f docker
usermod -aG docker "$DEFAULT_USERNAME"

systemctl enable docker
systemctl enable ollama

if ! [ -d "/home/$DEFAULT_USERNAME/.ssh" ]; then
	default_user_cmd "ssh-keygen -t rsa -N $SSH_KEY_PASSWORD -f \$HOME/.ssh/id_rsa"
fi

default_user_cmd "nvim --headless -c '+lua MiniDeps.update(nil, { force = true })' '+TSUpdate' '+qa'"

default_user_cmd 'yay -Rnsu --noconfirm $(yay -Qtdq) || true'

default_user_cmd "yay -Scc --noconfirm"

sed -i "/\/usr\/sbin\/pacman/d" /etc/sudoers

VSCODE_PLUGINS=(
	"ms-vscode.cpptools-extension-pack"
	"mesonbuild.mesonbuild"
	"llvm-vs-code-extensions.vscode-clangd"
	"ms-python.python"
	"ms-python.debugpy"
	"ms-python.vscode-pylance"
	"ms-python.black-formatter"
	"ms-python.pylint"
	"ms-python.isort"
	"ms-python.mypy-type-checker"
	"golang.go"
	"scala-lang.scala"
	"scalameta.metals"
	"scala-lang.scala-snippets"
	"vscjava.vscode-java-pack"
	"davidanson.vscode-markdownlint"
	"vmware.vscode-boot-dev-pack"
	"redhat.vscode-quarkus"
	"ms-vscode.js-debug"
	"ms-vscode.js-debug-companion"
	"vscodevim.vim"
	"svelte.svelte-vscode"
	"angular.ng-template"
	"dbaeumer.vscode-eslint"
	"esbenp.prettier-vscode"
	"antfu.vite"
	"vitest.explorer"
	"johnnymorganz.stylua"
	"sumneko.lua"
	"msjsdiag.vscode-react-native"
	"redhat.vscode-yaml"
	"redhat.vscode-xml"
	"mads-hartmann.bash-ide-vscode"
	"timonwong.shellcheck"
	"ms-azuretools.vscode-containers"
	"usernamehw.errorlens"
	"eamodio.gitlens"
	"ms-azuretools.vscode-docker"
	"docker.docker"
	"asvetliakov.vscode-neovim"
	"github.github-vscode-theme"
	"github.copilot"
	"github.copilot-chat"
	"redhat.vscode-community-server-connector"
	"ms-toolsai.jupyter"
	"mechatroner.rainbow-csv"
	"ms-kubernetes-tools.vscode-kubernetes-tools"
	"ms-vscode.remote-repositories"
	"ms-vscode-remote.vscode-remote-extensionpack"
	"oracle.mysql-shell-for-vs-code"
	"mtxr.sqltools"
	"mtxr.sqltools-driver-sqlite"
	"mtxr.sqltools-driver-pg"
	"mtxr.sqltools-driver-mysql"
	"ms-windows-ai-studio.windows-ai-studio"
)

default_user_cmd "printf \"%s\n\" ${VSCODE_PLUGINS[*]} | DONT_PROMPT_WSL_INSTALL=No_Prompt_please xargs -I {} code --install-extension {} --force"

info_log "Run 'wsl --terminate archlinux' to apply all changes\n"
