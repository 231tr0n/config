package main

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"text/tabwriter"
)

// Base install.
var (
	baseHooks = [][]string{
		{"systemctlServiceEnable", "dhcpcd"},
		{"systemctlServiceEnable", "NetworkManager"},
	}
	basePackages = []string{
		"base",
		"base-devel",
		"dhcpcd",
		"git",
		"linux",
		"linux-firmware",
		"linux-headers",
		"networkmanager",
		"pacman-contrib",
		"sudo",
		"terminus-font",
		"vim",
	}
)

// Desktop install.
var (
	desktopHooks = [][]string{
		{"chrootUserBashRunCommand", "echo -e \"" + *userPwd + "\" | sudo chmod +s $(which brightnessctl)"},
		{"systemctlUserServiceEnable", "pipewire"},
		{"systemctlUserServiceEnable", "pipewire-pulse"},
		{"systemctlUserServiceEnable", "wireplumber"},
		{"systemctlServiceEnable", "tlp"},
		{"systemctlServiceEnable", "ly"},
	}
	desktopPackages = []string{
		"acpi",
		"bat",
		"bemenu-wayland",
		"blueman",
		"bpytop",
		"brightnessctl",
		"calibre",
		"chromium",
		"clamav",
		"clamtk",
		"cmus",
		"code",
		"conky",
		"connman",
		"copyq",
		"curl",
		"discord",
		"docker",
		"dosfstools",
		"drawing",
		"emacs",
		"ffmpeg",
		"file-roller",
		"firefox",
		"fish",
		"font-manager",
		"foot",
		"gcc",
		"gcolor3",
		"glfw-wayland",
		"gnome-calculator",
		"gnome-calendar",
		"gnome-console",
		"gnome-disk-utility",
		"gnome-multi-writer",
		"gnome-nettool",
		"gnome-notes",
		"gnome-photos",
		"grim",
		"gthumb",
		"gufw",
		"haruna",
		"helvum",
		"htop",
		"imagemagick",
		"imv",
		"jack2",
		"jdk-openjdk",
		"kontrast",
		"lf",
		"libreoffice",
		"linux-lts",
		"lxappearance",
		"ly",
		"mako",
		"man-db",
		"meld",
		"mpv",
		"neofetch",
		"neovim",
		"network-manager-applet",
		"networkmanager-openvpn",
		"obsidian",
		"okular",
		"openssh",
		"openvpn",
		"pacman-contrib",
		"parted",
		"pavucontrol",
		"pcmanfm",
		"pipewire",
		"pipewire-audio",
		"pipewire-pulse",
		"podman",
		"polkit-gnome",
		"slurp",
		"subversion",
		"sway",
		"telegram-desktop",
		"thunderbird",
		"tlp",
		"tmux",
		"ufw",
		"wayland",
		"wget",
		"wireplumber",
		"wl-clipboard",
		"wl-mirror",
		"wlroots",
		"woff2",
		"xdg-desktop-portal",
		"xdg-desktop-portal-wlr",
		"xdg-user-dirs",
		"xdg-user-dirs-gtk",
		"xreader",
		"yt-dlp",
		"zathura",
	}
)

// Go install.
var (
	goHooks    = [][]string{}
	goPackages = []string{
		"github.com/davidrjenni/reftools/cmd/fillstruct@latest",
		"github.com/fatih/gomodifytags@latest",
		"github.com/go-delve/delve/cmd/dlv@latest",
		"github.com/go-task/task/v3/cmd/task@latest",
		"github.com/golang/mock/mockgen@latest",
		"github.com/golangci/golangci-lint/cmd/golangci-lint@latest",
		"github.com/google/gops@latest",
		"github.com/goreleaser/goreleaser@latest",
		"github.com/josharian/impl@latest",
		"github.com/jstemmer/gotags@latest",
		"github.com/kisielk/errcheck@latest",
		"github.com/klauspost/asmfmt/cmd/asmfmt@latest",
		"github.com/nao1215/gup@latest",
		"github.com/rogpeppe/godef@latest",
		"github.com/rverton/webanalyze/cmd/webanalyze@latest",
		"github.com/segmentio/golines@latest",
		"github.com/tsenart/vegeta@latest",
		"golang.org/x/pkgsite/cmd/pkgsite@latest",
		"golang.org/x/tools/cmd/godoc@latest",
		"golang.org/x/tools/cmd/goimports@latest",
		"golang.org/x/tools/cmd/gorename@latest",
		"golang.org/x/tools/cmd/guru@latest",
		"golang.org/x/tools/go/analysis/passes/shadow/cmd/shadow@latest",
		"golang.org/x/tools/gopls@latest",
		"istio.io/tools/cmd/license-lint@latest",
		"mvdan.cc/gofumpt@latest",
	}
)

// Gcc packages install.
var (
	gccHooks    = [][]string{}
	gccPackages = []string{
		"clang",
		"gdb",
		"glfw-wayland",
		"raylib",
		"valgrind",
	}
)

// Node install.
var (
	npmHooks    = [][]string{}
	npmPackages = []string{
		"forever",
		"localtunnel",
		"nodemon",
		"npm-check-updates",
	}
)

// Python install.
var (
	pipHooks    = [][]string{}
	pipPackages = []string{
		"wpm",
	}
)

// Rust install.
var (
	cargoHooks    = [][]string{}
	cargoPackages = []string{}
)

// Aur install.
var (
	aurHooks    = [][]string{}
	aurPackages = []string{
		"brave-bin",
		"drawio-desktop-bin",
		"google-chrome",
		"hyprpicker",
		"ocs-url",
		"stacer-bin",
		"swaysettings-git",
		"themix-full-git",
		"webapp-manager",
		"whatsapp-for-linux-bin",
		"wlogout",
	}
)

// Config install.
var (
	configHooks    = [][]string{}
	configPaths    = map[string]string{}
	configPackages = []string{
		"arc-gtk-theme",
		"arc-icon-theme",
		"grub-theme-vimix",
		"capitaine-cursors",
	}
)

// Log file name.
const (
	logFile = "goarchinstall.log"
)

// Errors.
var (
	errEspNotSet     = errors.New("main: esp partition not set")
	errInstall       = errors.New("main: installation error")
	errInstaller     = errors.New("main: installer has unknown command")
	errInstallerArgs = errors.New("main: installer has incorrect number of arguments.")
	errRootNotSet    = errors.New("main: root partition not set")
	errRootPwdNotSet = errors.New("main: root passwd not set")
	errUserPwdNotSet = errors.New("main: user passwd not set")
)

// Cli arguments variables.
var (
	amd               = flag.Bool("amd", false, "Use this flag to install micro-code for amd chips.")
	cargoPkgs         = flag.Bool("cargo-pkgs", false, "Install required cargo packages.")
	country           = flag.String("country", "India", "Sets the country whose repos are added to the mirrorlist of pacman.")
	desktop           = flag.Bool("desktop", false, "Install desktop environment.")
	esp               = flag.String("esp", "", "Set the esp partition. (required)")
	formatEsp         = flag.Bool("format-esp", false, "Format the esp partition. Do this if you have created a new esp partition. Do not use it when you are using the windows esp partition for dual booting.")
	gccPkgs           = flag.Bool("gcc-pkgs", false, "Install required gcc packages.")
	goPkgs            = flag.Bool("go-pkgs", false, "Install required go packages.")
	home              = flag.String("home", "", "Set the home partition.")
	hostname          = flag.String("hostname", "xeltron", "Set the hostname of the system.")
	intel             = flag.Bool("intel", false, "Use this flag to install micro-code for intel chips.")
	list              = flag.Bool("list", false, "Use this flag to list all the commands which will be run.")
	mountPoint        = flag.String("mount-point", "/mnt", "Build the arch filesystem by using this partition for mounting.")
	npmPkgs           = flag.Bool("npm-pkgs", false, "Install required npm packages.")
	parallelDownloads = flag.Int("parallel-downloads", 5, "Number of downloads pacman can do at a time.")
	pipPkgs           = flag.Bool("pip-pkgs", false, "Install required pip packages.")
	repoCount         = flag.Int("repo-count", 10, "Number of repos to be added to the mirrorlist of pacman.")
	root              = flag.String("root", "", "Set the root partition. (required)")
	rootPwd           = flag.String("root-pwd", "", "Set root password. (required)")
	start             = flag.Int("start", 0, "Command from which the installer should start executing.")
	subZone           = flag.String("sub-zone", "Kolkata", "Set the sub-zone for system time.")
	swap              = flag.String("swap", "", "Set the swap partition.")
	unmountFS         = flag.Bool("unmount-fs", false, "Use this flag to unmount the filesystem automatically after installation.")
	userPwd           = flag.String("user-pwd", "", "Set user password. (required)")
	username          = flag.String("username", "zeltron", "Set the username of the system.")
	zone              = flag.String("zone", "Asia", "Set the zone for system time.")
)

// Installer variable.
var (
	installer = [][]string{}
)

// Tabwriter config.
var (
	tabw = tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', tabwriter.DiscardEmptyColumns)
)

func init() {
	// Logger Setup.
	log.SetFlags(0)
	log.SetOutput(os.Stdout)
	log.SetPrefix("[\033[91mLOG\033[0m] ")

	// Flag parsing setup.
	flag.Parse()
	if parsed := flag.Parsed(); !parsed {
		log.Fatalln(errors.New("Flags not parsed. Wrong flags given."))
	}
	flag.CommandLine.SetOutput(os.Stdout)

	// Remove any log file present.
	if err := os.RemoveAll(logFile); err != nil {
		log.Fatalln(err)
	}

	// Installer building.
	// Set bigger font.
	appendInstaller("runCommand", "setfont", "ter-132b")
	// Format and mount root.
	if *root == "" {
		log.Fatalln(errRootNotSet)
	}
	appendInstaller("runCommand", "mkfs.ext4", *root)
	appendInstaller("mount", *root, *mountPoint)
	// Format and mount esp.
	if *esp == "" {
		log.Fatalln(errEspNotSet)
	}
	if *formatEsp {
		appendInstaller("runCommand", "mkfs.fat", "-F", "32", *esp)
	}
	appendInstaller("mount", *esp, filepath.Join(*mountPoint, "boot", "efi"))
	// Format and mount home.
	if *home != "" {
		appendInstaller("runCommand", "mkfs.ext4", *home)
		appendInstaller("mount", *home, filepath.Join(*mountPoint, "home"))
	}
	// Format and set swap.
	if *swap != "" {
		appendInstaller("runCommand", "mkswap", *swap)
		appendInstaller("runCommand", "swapon", *swap)
	}
	// Setup pacman config.
	appendInstaller("runCommand", "mv", filepath.Join("/etc", "pacman.d", "mirrorlist"), filepath.Join("/etc", "pacman.d", "mirrorlist.bak"))
	appendInstaller("runCommand", "reflector", "--fastest", strconv.Itoa(*repoCount), "--country", *country, "--protocol", "https", "--sort", "rate", "--save", filepath.Join("/etc", "pacman.d", "mirrorlist"))
	appendInstaller("runBashCommand", "sed -i 's/#ParallelDownloads = 5/ParallelDownloads = "+strconv.Itoa(*parallelDownloads)+"/g' "+filepath.Join("/etc", "pacman.conf"))
	appendInstaller("runBashCommand", "sed -i \"/\\[multilib\\]/,/Include/\"'s/^# //' "+filepath.Join("/etc", "pacman.conf"))
	// Pacstrap setup.
	appendInstaller(append([]string{"runCommand", "pacstrap", "-K", *mountPoint}, basePackages...)...)
	// Gen FS table.
	appendInstaller("runCommand", "genfstab", "-U", *mountPoint, filepath.Join(*mountPoint, "etc", "fstab"))
	// Synchronize time zone.
	appendInstaller("chrootRunCommand", "ln", "-sf", filepath.Join("/usr", "share", "zoneinfo", *zone, *subZone), filepath.Join("/etc", "localtime"))
	appendInstaller("chrootRunCommand", "hwclock", "--systohc")
	// appendInstaller("chrootRunCommand", "timedatectl", "set-ntp", "true")
	appendInstaller("systemctlServiceEnable", "systemd-timesyncd")
	// Generate locale.
	appendInstaller("chrootBashRunCommand", "echo 'en_IN.UTF-8 UTF-8' >> "+filepath.Join("/etc", "locale.gen"))
	appendInstaller("chrootBashRunCommand", "echo 'LANG=en_IN.UTF-8' >> "+filepath.Join("/etc", "locale.conf"))
	appendInstaller("chrootRunCommand", "locale-gen")
	// Set hostname.
	appendInstaller("chrootBashRunCommand", "echo "+*hostname+" >> "+filepath.Join("/etc", "hostname"))
	// Set Root passwd.
	if *rootPwd == "" {
		log.Fatalln(errRootPwdNotSet)
	}
	appendInstaller("chrootBashRunCommand", "echo -e \""+*rootPwd+"\\n"+*rootPwd+"\" | passwd")
	// Configure user groups.
	appendInstaller("chrootRunCommand", "groupadd", "sudo")
	appendInstaller("chrootBashRunCommand", "echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)")
	appendInstaller("chrootBashRunCommand", "echo '%wheel ALL=(ALL:ALL) ALL' | (EDITOR='tee -a' visudo)")
	// Create user.
	if *userPwd == "" {
		log.Fatalln(errUserPwdNotSet)
	}
	appendInstaller("chrootRunCommand", "useradd", "-m", *username)
	appendInstaller("chrootBashRunCommand", "echo -e \""+*userPwd+"\\n"+*userPwd+"\" | passwd "+*username)
	appendInstaller("chrootRunCommand", "usermod", "-aG", "wheel", *username)
	// Run base hooks.
	for _, val := range baseHooks {
		appendInstaller(val...)
	}
	// Copy pacman config to install.
	appendInstaller("runCommand", "mv", filepath.Join(*mountPoint, "etc", "pacman.conf"), filepath.Join(*mountPoint, "etc", "pacman.conf.bak"))
	appendInstaller("runCommand", "cp", filepath.Join("/etc", "pacman.conf"), filepath.Join(*mountPoint, "etc", "pacman.conf"))
	// Install microcode.
	if *amd {
		appendInstaller("chrootPacmanInstall", "amd-ucode")
	}
	if *intel {
		appendInstaller("chrootPacmanInstall", "intel-ucode")
	}
	// Install bootloader.
	appendInstaller("chrootPacmanInstall", "efibootmgr", "grub")
	appendInstaller("chrootBashRunCommand", "echo 'GRUB_DISABLE_OS_PROBER=false' >> "+filepath.Join("/etc", "default", "grub"))
	appendInstaller("chrootPacmanInstall", "os-prober")
	if *formatEsp {
		appendInstaller("chrootRunCommand", "grub-install", "--target=x86_64-efi", "--bootloader-id=GRUB", "--removable")
	} else {
		appendInstaller("chrootRunCommand", "grub-install", "--target=x86_64-efi", "--bootloader-id=GRUB", "--recheck")
	}
	appendInstaller("chrootRunCommand", "grub-mkconfig", "-o", filepath.Join("/boot", "grub", "grub.cfg"))
	// Install Aurhelper.
	appendInstaller("chrootTempBashRunCommand", "cd ~ && rm -rf yay-bin && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -sic --noconfirm && cd .. && rm -rf yay-bin")
	// Go packages install.
	if *goPkgs {
		appendInstaller("chrootPacmanInstall", "go")
		for _, val := range goPackages {
			appendInstaller("chrootUserBashRunCommand", "go install -v "+val)
		}
		for _, val := range goHooks {
			appendInstaller(val...)
		}
	}
	// Python packages install.
	if *pipPkgs {
		appendInstaller("chrootPacmanInstall", "python", "python-pip", "python-pipx")
		for _, val := range pipPackages {
			appendInstaller("chrootUserBashRunCommand", "pipx install "+val)
		}
		for _, val := range pipHooks {
			appendInstaller(val...)
		}
	}
	// Nodejs packages install.
	if *npmPkgs {
		appendInstaller("chrootPacmanInstall", "nodejs", "npm")
		for _, val := range npmPackages {
			appendInstaller("chrootRunCommand", "npm", "install", "-g", val)
		}
		for _, val := range npmHooks {
			appendInstaller(val...)
		}
	}
	// Rust packages install.
	if *cargoPkgs {
		appendInstaller("chrootPacmanInstall", "rust", "cargo")
		for _, val := range cargoPackages {
			appendInstaller("chrootUserBashRunCommand", "cargo install "+val)
		}
		for _, val := range cargoHooks {
			appendInstaller(val...)
		}
	}
	// C packages install.
	if *gccPkgs {
		appendInstaller("chrootPacmanInstall", "gcc")
		appendInstaller(append([]string{"chrootPacmanInstall"}, gccPackages...)...)
		for _, val := range gccHooks {
			appendInstaller(val...)
		}
	}
	// Aur packages install.
	if *desktop {
		appendInstaller("chrootTempBashRunCommand", "yay -Syu --needed --noconfirm "+strings.Join(aurPackages, " "))
		for _, val := range aurHooks {
			appendInstaller(val...)
		}
		appendInstaller(append([]string{"chrootPacmanInstall"}, desktopPackages...)...)
		for _, val := range desktopHooks {
			appendInstaller(val...)
		}
		// Config setup.
		for key, val := range configPaths {
			appendInstaller("chrootRunCommand", "cp", key, val)
		}
		appendInstaller(append([]string{"chrootPacmanInstall"}, configPackages...)...)
		for _, val := range configHooks {
			appendInstaller(val...)
		}
	}
	// Unmount system.
	if *unmountFS {
		appendInstaller("unmount", *mountPoint)
	}
}

func appendInstaller(cmds ...string) {
	installer = append(installer, cmds)
}

func runCommand(name string, args ...string) error {
	tempArgs := make([]any, len(args))
	for i, j := range args {
		tempArgs[i] = j
	}
	log.Println("----------------------------")
	log.Println(append([]any{name}, tempArgs...)...)
	log.Println("----------------------------")

	file, err := os.OpenFile(logFile, os.O_WRONLY|os.O_CREATE|os.O_APPEND, os.ModePerm)
	defer file.Close()
	if err != nil {
		log.Fatalln("Cannot create log file: ", err)
	}
	stdoutMW := io.MultiWriter(os.Stdout, file)
	stderrMW := io.MultiWriter(os.Stderr, file)

	_, err = file.WriteString("\n----------------------------\n")
	if err != nil {
		log.Fatalln(err)
	}
	_, err = file.WriteString(name + " " + strings.Join(args, " "))
	if err != nil {
		log.Fatalln(err)
	}
	_, err = file.WriteString("\n----------------------------\n")
	if err != nil {
		log.Fatalln(err)
	}

	cmd := exec.Command(name, args...)
	cmd.Stdout = stdoutMW
	cmd.Stderr = stderrMW
	if err := cmd.Run(); err != nil {
		return err
	}
	return nil
}

func runBashCommand(cmd string) error {
	return runCommand("bash", "-c", cmd)
}

func chrootRunCommand(name string, args ...string) error {
	newArgs := append([]string{*mountPoint, name}, args...)
	return runCommand("arch-chroot", newArgs...)
}

func chrootUserBashRunCommand(cmd string) error {
	return chrootRunCommand("su", *username, "-s", "/bin/bash", "-c", cmd)
}

func chrootTempBashRunCommand(cmd string) error {
	if err := chrootRunCommand("useradd", "-m", "temp"); err != nil {
		return err
	}
	if err := chrootRunCommand("usermod", "-aG", "sudo", "temp"); err != nil {
		return err
	}
	err := chrootRunCommand("su", "temp", "-s", "/bin/bash", "-c", cmd)
	if err := chrootRunCommand("userdel", "-r", "temp"); err != nil {
		return err
	}
	return err
}

func chrootBashRunCommand(cmd string) error {
	return chrootRunCommand("bash", "-c", cmd)
}

func pacmanInstall(packages ...string) error {
	args := append([]string{"-Sy", "--needed", "--noconfirm"}, packages...)
	return runCommand("pacman", args...)
}

func chrootPacmanInstall(packages ...string) error {
	args := append([]string{"-Syu", "--needed", "--noconfirm"}, packages...)
	return chrootRunCommand("pacman", args...)
}

func mount(source, destination string) error {
	return runCommand("mount", "--mkdir", source, destination)
}

func unmount(source string) error {
	return runCommand("umount", "-R", source)
}

func systemctlServiceEnable(services ...string) error {
	args := append([]string{"enable"}, services...)
	if err := chrootRunCommand("systemctl", args...); err != nil {
		return err
	}
	return nil
}

func systemctlUserServiceEnable(services ...string) error {
	args := append([]string{"--user", "enable"}, services...)
	if err := chrootRunCommand("systemctl", args...); err != nil {
		return err
	}
	return nil
}

func main() {
	// Installer code
	if *list {
		fmt.Fprintln(tabw, "Index\tMode\tCommand")
		fmt.Fprintln(tabw, "-----\t----\t-------")
		for i, j := range installer[*start:] {
			if len(j) < 2 {
				log.Fatalln(errInstallerArgs)
			}
			fmt.Fprintln(tabw, strconv.Itoa(i+*start)+"\t"+j[0]+"\t"+strings.Join(j[1:], " "))
		}
		tabw.Flush()
	} else {
		for _, j := range installer[*start:] {
			if len(j) < 2 {
				log.Fatalln(errInstallerArgs)
			}
			switch j[0] {
			case "runCommand":
				if len(j[1:]) < 1 {
					log.Fatalln(errInstallerArgs)
				}
				if err := runCommand(j[1], j[2:]...); err != nil {
					log.Fatalln(errInstall)
				}
			case "runBashCommand":
				if len(j[1:]) != 1 {
					log.Fatalln(errInstallerArgs)
				}
				if err := runBashCommand(j[1]); err != nil {
					log.Fatalln(errInstall)
				}
			case "mount":
				if len(j[1:]) != 2 {
					log.Fatalln(errInstallerArgs)
				}
				if err := mount(j[1], j[2]); err != nil {
					log.Fatalln(errInstall)
				}
			case "unmount":
				if len(j[1:]) != 1 {
					log.Fatalln(errInstallerArgs)
				}
				if err := unmount(j[1]); err != nil {
					log.Fatalln(errInstall)
				}
			case "pacmanInstall":
				if len(j[1:]) < 1 {
					log.Fatalln(errInstallerArgs)
				}
				if err := pacmanInstall(j[1:]...); err != nil {
					log.Fatalln(errInstall)
				}
			case "chrootRunCommand":
				if len(j[1:]) < 1 {
					log.Fatalln(errInstallerArgs)
				}
				if err := chrootRunCommand(j[1], j[2:]...); err != nil {
					log.Fatalln(errInstall)
				}
			case "chrootBashRunCommand":
				if len(j[1:]) != 1 {
					log.Fatalln(errInstallerArgs)
				}
				if err := chrootBashRunCommand(j[1]); err != nil {
					log.Fatalln(errInstall)
				}
			case "chrootPacmanInstall":
				if len(j[1:]) < 1 {
					log.Fatalln(errInstallerArgs)
				}
				if err := chrootPacmanInstall(j[1:]...); err != nil {
					log.Fatalln(errInstall)
				}
			case "chrootUserBashRunCommand":
				if len(j[1:]) != 1 {
					log.Fatalln(errInstallerArgs)
				}
				if err := chrootUserBashRunCommand(j[1]); err != nil {
					log.Fatalln(errInstall)
				}
			case "chrootTempBashRunCommand":
				if len(j[1:]) != 1 {
					log.Fatalln(errInstallerArgs)
				}
				if err := chrootTempBashRunCommand(j[1]); err != nil {
					log.Fatalln(errInstall)
				}
			case "systemctlServiceEnable":
				if len(j[1:]) < 1 {
					log.Fatalln(errInstallerArgs)
				}
				if err := systemctlServiceEnable(j[1:]...); err != nil {
					log.Fatalln(errInstall)
				}
			case "systemctlUserServiceEnable":
				if len(j[1:]) < 1 {
					log.Fatalln(errInstallerArgs)
				}
				if err := systemctlUserServiceEnable(j[1:]...); err != nil {
					log.Fatalln(errInstall)
				}
			default:
				log.Fatalln(errInstaller)
			}
		}
	}
}
