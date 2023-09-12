package main

import (
	"errors"
	"flag"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
)

const (
	logFile = "goarchinstall.log"
)

var (
	// Cli arguments variables.
	errRootNotSet     = errors.New("main: root partition not set")
	errEspNotSet      = errors.New("main: esp partition not set")
	errRootPwdNotSet  = errors.New("main: root passwd not set")
	errUserPwdNotSet  = errors.New("main: user passwd not set")
	root              *string
	home              *string
	swap              *string
	esp               *string
	formatEsp         *bool
	repoCount         *int
	country           *string
	mountPoint        *string
	parallelDownloads *int
	hostname          *string
	username          *string
	zone              *string
	subZone           *string
	amd               *bool
	intel             *bool
	rootPwd           *string
	userPwd           *string
	goPkgs            *bool
	pipPkgs           *bool
	npmPkgs           *bool
	desktop           *bool

	// Internal variables.
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
	baseServices = []string{
		"dhcpcd",
		"NetworkManager",
		"systemd-timesyncd",
	}
	desktopPackages = map[string]func() error{
		"acpi":           nil,
		"bat":            nil,
		"bemenu-wayland": nil,
		"blueman":        nil,
		"bpytop":         nil,
		"brightnessctl": func() error {
			if err := chrootRunCommand("su", *username, "-s", "/bin/bash", "-c", "echo -e \""+*userPwd+"\" | sudo chmod +s $(which brightnessctl)"); err != nil {
				return err
			}
			return nil
		},
		"calibre":            nil,
		"chromium":           nil,
		"clamav":             nil,
		"clamtk":             nil,
		"cmus":               nil,
		"code":               nil,
		"conky":              nil,
		"copyq":              nil,
		"curl":               nil,
		"discord":            nil,
		"docker":             nil,
		"dosfstools":         nil,
		"drawing":            nil,
		"emacs":              nil,
		"ffmpeg":             nil,
		"file-roller":        nil,
		"firefox":            nil,
		"fish":               nil,
		"font-manager":       nil,
		"foot":               nil,
		"gcc":                nil,
		"gcolor3":            nil,
		"glfw-wayland":       nil,
		"gnome-calculator":   nil,
		"gnome-calendar":     nil,
		"gnome-console":      nil,
		"gnome-disk-utility": nil,
		"gnome-multi-writer": nil,
		"gnome-nettool":      nil,
		"gnome-notes":        nil,
		"gnome-photos":       nil,
		"go":                 nil,
		"grim":               nil,
		"gthumb":             nil,
		"gufw":               nil,
		"haruna":             nil,
		"helvum":             nil,
		"htop":               nil,
		"imagemagick":        nil,
		"imv":                nil,
		"jack2":              nil,
		"jdk-openjdk":        nil,
		"kontrast":           nil,
		"lf":                 nil,
		"libreoffice":        nil,
		"linux-lts":          nil,
		"lxappearance":       nil,
		"ly": func() error {
			if err := systemctlServiceEnable("ly"); err != nil {
				return err
			}
			return nil
		},
		"mako":                   nil,
		"man-db":                 nil,
		"meld":                   nil,
		"mpv":                    nil,
		"neofetch":               nil,
		"neovim":                 nil,
		"network-manager-applet": nil,
		"networkmanager-openvpn": nil,
		"nodejs":                 nil,
		"npm":                    nil,
		"obsidian":               nil,
		"okular":                 nil,
		"openssh":                nil,
		"openvpn":                nil,
		"pacman-contrib":         nil,
		"parted":                 nil,
		"pavucontrol":            nil,
		"pcmanfm":                nil,
		"pipewire": func() error {
			if err := systemctlUserServiceEnable("pipewire"); err != nil {
				return err
			}
			return nil
		},
		"pipewire-audio": nil,
		"pipewire-pulse": func() error {
			if err := systemctlUserServiceEnable("pipewire-pulse"); err != nil {
				return err
			}
			return nil
		},
		"podman":           nil,
		"polkit-gnome":     nil,
		"python":           nil,
		"python-pipx":      nil,
		"slurp":            nil,
		"subversion":       nil,
		"sway":             nil,
		"telegram-desktop": nil,
		"thunderbird":      nil,
		"tlp": func() error {
			if err := systemctlServiceEnable("tlp"); err != nil {
				return err
			}
			return nil
		},
		"tmux":    nil,
		"ufw":     nil,
		"wayland": nil,
		"wget":    nil,
		"wireplumber": func() error {
			if err := systemctlUserServiceEnable("wireplumber"); err != nil {
				return err
			}
			return nil
		},
		"wl-clipboard":           nil,
		"wl-mirror":              nil,
		"wlroots":                nil,
		"woff2":                  nil,
		"xdg-desktop-portal":     nil,
		"xdg-desktop-portal-wlr": nil,
		"xdg-user-dirs":          nil,
		"xdg-user-dirs-gtk":      nil,
		"xreader":                nil,
		"yt-dlp":                 nil,
		"zathura":                nil,
	}
	goPackages = map[string]func() error{
		"github.com/davidrjenni/reftools/cmd/fillstruct@latest":          nil,
		"github.com/fatih/gomodifytags@latest":                           nil,
		"github.com/go-delve/delve/cmd/dlv@latest":                       nil,
		"github.com/go-task/task/v3/cmd/task@latest":                     nil,
		"github.com/golang/mock/mockgen@latest":                          nil,
		"github.com/golangci/golangci-lint/cmd/golangci-lint@latest":     nil,
		"github.com/google/gops@latest":                                  nil,
		"github.com/goreleaser/goreleaser@latest":                        nil,
		"github.com/josharian/impl@latest":                               nil,
		"github.com/jstemmer/gotags@latest":                              nil,
		"github.com/kisielk/errcheck@latest":                             nil,
		"github.com/klauspost/asmfmt/cmd/asmfmt@latest":                  nil,
		"github.com/nao1215/gup@latest":                                  nil,
		"github.com/rogpeppe/godef@latest":                               nil,
		"github.com/rverton/webanalyze/cmd/webanalyze@latest":            nil,
		"github.com/segmentio/golines@latest":                            nil,
		"github.com/tsenart/vegeta@latest":                               nil,
		"golang.org/x/pkgsite/cmd/pkgsite@latest":                        nil,
		"golang.org/x/tools/cmd/godoc@latest":                            nil,
		"golang.org/x/tools/cmd/goimports@latest":                        nil,
		"golang.org/x/tools/cmd/gorename@latest":                         nil,
		"golang.org/x/tools/cmd/guru@latest":                             nil,
		"golang.org/x/tools/go/analysis/passes/shadow/cmd/shadow@latest": nil,
		"golang.org/x/tools/gopls@latest":                                nil,
		"istio.io/tools/cmd/license-lint@latest":                         nil,
		"mvdan.cc/gofumpt@latest":                                        nil,
	}
	npmPackages = map[string]func() error{
		"forever":           nil,
		"localtunnel":       nil,
		"nodemon":           nil,
		"npm-check-updates": nil,
	}
	pipPackages = map[string]func() error{
		"wpm": nil,
	}
	aurPackages = map[string]func() error{
		"brave-bin":              nil,
		"drawio-desktop-bin":     nil,
		"google-chrome":          nil,
		"hyprpicker":             nil,
		"ocs-url":                nil,
		"stacer-bin":             nil,
		"swaysettings-git":       nil,
		"themix-full-git":        nil,
		"webapp-manager":         nil,
		"whatsapp-for-linux-bin": nil,
		"wlogout":                nil,
	}
	configPath = map[string]string{}
	installer  = []func() error{
		setBiggerFont,
		formatAndMountSystem,
		pacmanConfigSetup,
		pacstrap,
		genFSTab,
		synchronizeTimeZone,
		genLocale,
		setHostName,
		setRootPasswd,
		configureUserGroups,
		createUser,
		baseServicesEnable,
		copyPacmanConfigToInstall,
		installMicroCode,
		installBootLoader,
		installAurHepler,
		goPkgInstall,
		pipPkgInstall,
		npmPkgInstall,
		desktopInstall,
		aurPkgInstall,
		unmountSystem,
	}
)

func init() {
	// Logger Setup
	log.SetFlags(0)
	log.SetOutput(os.Stdout)
	log.SetPrefix("[\033[91mLOG\033[0m] ")

	// Cli arguments parsing setup
	mountPoint = flag.String("mount-point", "/mnt", "Build the arch filesystem by using this partition for mounting.")
	root = flag.String("root", "", "Set the root partition. (required)")
	home = flag.String("home", "", "Set the home partition.")
	swap = flag.String("swap", "", "Set the swap partition.")
	esp = flag.String("esp", "", "Set the esp partition. (required)")
	formatEsp = flag.Bool("format-esp", false, "Format the esp partition. Do this if you have created a new esp partition. Do not use it when you are using the windows esp partition for dual booting.")
	country = flag.String("country", "India", "Sets the country whose repos are added to the mirrorlist of pacman.")
	repoCount = flag.Int("repo-count", 10, "Number of repos to be added to the mirrorlist of pacman.")
	parallelDownloads = flag.Int("parallel-downloads", 5, "Number of downloads pacman can do at a time.")
	hostname = flag.String("hostname", "xeltron", "Set the hostname of the system.")
	username = flag.String("username", "zeltron", "Set the username of the system.")
	zone = flag.String("zone", "Asia", "Set the zone for system time.")
	subZone = flag.String("sub-zone", "Kolkata", "Set the sub-zone for system time.")
	amd = flag.Bool("amd", false, "Use this flag to install micro-code for amd chips.")
	intel = flag.Bool("intel", false, "Use this flag to install micro-code for intel chips.")
	userPwd = flag.String("user-pwd", "", "Set user password. (required)")
	rootPwd = flag.String("root-pwd", "", "Set root password. (required)")
	goPkgs = flag.Bool("go-pkgs", false, "Install required go packages.")
	pipPkgs = flag.Bool("pip-pkgs", false, "Install required pip packages.")
	npmPkgs = flag.Bool("npm-pkgs", false, "Install required npm packages.")
	desktop = flag.Bool("desktop", false, "Install desktop environment.")

	flag.Parse()
	if parsed := flag.Parsed(); !parsed {
		log.Fatalln(errors.New("Flags not parsed. Wrong flags given."))
	}
	flag.CommandLine.SetOutput(os.Stdout)

	// Remove any log file present
	if err := os.RemoveAll(logFile); err != nil {
		log.Fatalln(err)
	}

	// Log and exit if any required arguments are missing
	if *root == "" {
		log.Fatalln(errRootNotSet)
	}
	if *esp == "" {
		log.Fatalln(errEspNotSet)
	}
	if *userPwd == "" {
		log.Fatalln(errUserPwdNotSet)
	}
	if *rootPwd == "" {
		log.Fatalln(errRootPwdNotSet)
	}
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

func chrootRunCommand(name string, args ...string) error {
	newArgs := append([]string{*mountPoint, name}, args...)
	return runCommand("arch-chroot", newArgs...)
}

func pacmanInstall(packages ...string) error {
	if len(packages) == 0 {
		return nil
	}
	args := append([]string{"-Sy", "--needed", "--noconfirm"}, packages...)
	return runCommand("pacman", args...)
}

func chrootPacmanInstall(packages ...string) error {
	if len(packages) == 0 {
		return nil
	}
	args := append([]string{"-Syu", "--needed", "--noconfirm"}, packages...)
	return chrootRunCommand("pacman", args...)
}

func chrootAurInstall(packages ...string) error {
	if len(packages) == 0 {
		return nil
	}
	args := append([]string{"-Syu", "--needed", "--noconfirm"}, packages...)
	return chrootRunCommand("yay", args...)
}

func mount(source, destination string) error {
	return runCommand("mount", "--mkdir", source, destination)
}

func unmountSystem() error {
	return runCommand("umount", "-R", *mountPoint)
}

func pacstrap() error {
	args := append([]string{"-K", *mountPoint}, basePackages...)
	if err := runCommand("pacstrap", args...); err != nil {
		return err
	}
	return nil
}

func baseServicesEnable() error {
	if err := systemctlServiceEnable(baseServices...); err != nil {
		return err
	}
	return nil
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

func formatAndMountRoot() error {
	if err := runCommand("mkfs.ext4", *root); err != nil {
		return err
	}
	if err := mount(*root, *mountPoint); err != nil {
		return err
	}
	return nil
}

func formatAndSetSwap() error {
	if err := runCommand("mkswap", *swap); err != nil {
		return err
	}
	if err := runCommand("swapon", *swap); err != nil {
		return err
	}
	return nil
}

func formatAndMountHome() error {
	if err := runCommand("mkfs.ext4", *home); err != nil {
		return err
	}
	if err := mount(*home, filepath.Join(*mountPoint, "home")); err != nil {
		return err
	}
	return nil
}

func formatAndMountEsp() error {
	if *formatEsp {
		if err := runCommand("mkfs.fat", "-F", "32", *esp); err != nil {
			return err
		}
	}
	if err := mount(*esp, filepath.Join(*mountPoint, "boot", "efi")); err != nil {
		return err
	}
	return nil
}

func pacmanConfigSetup() error {
	if err := runCommand("mv", filepath.Join("/etc", "pacman.d", "mirrorlist"), filepath.Join("/etc", "pacman.d", "mirrorlist.bak")); err != nil {
		return err
	}
	if err := runCommand("reflector", "--latest", strconv.Itoa(*repoCount), "--country", *country, "--protocol", "https", "--sort", "rate", "--save", filepath.Join("/etc", "pacman.d", "mirrorlist")); err != nil {
		return err
	}
	if err := runCommand("bash", "-c", "sed -i 's/#ParallelDownloads = 5/ParallelDownloads = "+strconv.Itoa(*parallelDownloads)+"/g' "+filepath.Join("/etc", "pacman.conf")); err != nil {
		return err
	}
	if err := runCommand("bash", "-c", "sed -i \"/\\[multilib\\]/,/Include/\"'s/^# //' "+filepath.Join("/etc", "pacman.conf")); err != nil {
		return err
	}
	return nil
}

func copyPacmanConfigToInstall() error {
	if err := runCommand("mv", filepath.Join(*mountPoint, "etc", "pacman.conf"), filepath.Join(*mountPoint, "etc", "pacman.conf.bak")); err != nil {
		return err
	}
	if err := runCommand("cp", filepath.Join("/etc", "pacman.conf"), filepath.Join(*mountPoint, "etc", "pacman.conf")); err != nil {
		return err
	}
	return nil
}

func genFSTab() error {
	if err := runCommand("genfstab", "-U", *mountPoint, filepath.Join(*mountPoint, "etc", "fstab")); err != nil {
		return err
	}
	return nil
}

func formatAndMountSystem() error {
	if *root == "" {
		return errRootNotSet
	}
	if *esp == "" {
		return errEspNotSet
	}
	if err := formatAndMountRoot(); err != nil {
		return err
	}
	if err := formatAndMountEsp(); err != nil {
		return err
	}
	if *home != "" {
		if err := formatAndMountHome(); err != nil {
			return err
		}
	}
	if *swap != "" {
		if err := formatAndSetSwap(); err != nil {
			return err
		}
	}
	return nil
}

func setBiggerFont() error {
	return runCommand("setfont", "ter-132b")
}

func synchronizeTimeZone() error {
	if err := chrootRunCommand("ln", "-sf", filepath.Join("/usr", "share", "zoneinfo", *zone, *subZone), filepath.Join("/etc", "localtime")); err != nil {
		return err
	}
	if err := chrootRunCommand("hwclock", "--systohc"); err != nil {
		return err
	}
	if err := chrootRunCommand("timedatectl", "set-ntp", "true"); err != nil {
		return err
	}
	if err := systemctlServiceEnable("systemd-timesyncd"); err != nil {
		return err
	}
	return nil
}

func genLocale() error {
	if err := chrootRunCommand("bash", "-c", "echo 'en_IN.UTF-8 UTF-8' >> "+filepath.Join("/etc", "locale.gen")); err != nil {
		return err
	}
	if err := chrootRunCommand("bash", "-c", "echo 'LANG=en_IN.UTF-8' >> "+filepath.Join("/etc", "locale.conf")); err != nil {
		return err
	}
	if err := chrootRunCommand("locale-gen"); err != nil {
		return err
	}
	return nil
}

func setHostName() error {
	if err := chrootRunCommand("bash", "-c", "echo "+*hostname+" >> "+filepath.Join("/etc", "hostname")); err != nil {
		return err
	}
	return nil
}

func setRootPasswd() error {
	if *rootPwd == "" {
		return errRootPwdNotSet
	}
	if err := chrootRunCommand("bash", "-c", "echo -e \""+*rootPwd+"\\n"+*rootPwd+"\" | passwd"); err != nil {
		return err
	}
	return nil
}

func configureUserGroups() error {
	if err := chrootRunCommand("groupadd", "sudo"); err != nil {
		return err
	}
	if err := chrootRunCommand("bash", "-c", "echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)"); err != nil {
		return err
	}
	if err := chrootRunCommand("bash", "-c", "echo '%wheel ALL=(ALL:ALL) ALL' | (EDITOR='tee -a' visudo)"); err != nil {
		return err
	}
	return nil
}

func createUser() error {
	if *userPwd == "" {
		return errUserPwdNotSet
	}
	if err := chrootRunCommand("useradd", "-m", *username); err != nil {
		return err
	}
	if err := chrootRunCommand("bash", "-c", "echo -e \""+*userPwd+"\\n"+*userPwd+"\" | passwd "+*username); err != nil {
		return err
	}
	if err := chrootRunCommand("usermod", "-aG", "wheel", *username); err != nil {
		return err
	}
	return nil
}

func installBootLoader() error {
	if err := chrootPacmanInstall("efibootmgr", "grub"); err != nil {
		return err
	}
	if err := chrootRunCommand("bash", "-c", "echo 'GRUB_DISABLE_OS_PROBER=false' >> "+filepath.Join("/etc", "default", "grub")); err != nil {
		return err
	}
	if err := chrootPacmanInstall("os-prober"); err != nil {
		return err
	}
	if *formatEsp {
		if err := chrootRunCommand("grub-install", "--target=x86_64-efi", "--bootloader-id=GRUB", "--recheck", "--removable"); err != nil {
			return err
		}
	} else {
		if err := chrootRunCommand("grub-install", "--target=x86_64-efi", "--bootloader-id=GRUB", "--recheck"); err != nil {
			return err
		}
	}
	if err := chrootRunCommand("grub-mkconfig", "-o", filepath.Join("/boot", "grub", "grub.cfg")); err != nil {
		return err
	}
	return nil
}

func installMicroCode() error {
	if *amd {
		return chrootPacmanInstall("amd-ucode")
	}
	if *intel {
		return chrootPacmanInstall("intel-ucode")
	}
	return nil
}

func installAurHepler() error {
	if err := chrootRunCommand("useradd", "-m", "temp"); err != nil {
		return err
	}
	if err := chrootRunCommand("usermod", "-aG", "sudo", "temp"); err != nil {
		return err
	}
	if err := chrootRunCommand("su", "temp", "-s", "/bin/bash", "-c", "cd ~ && rm -rf yay-bin && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -sic --noconfirm && cd .. && rm -rf yay-bin"); err != nil {
		return err
	}
	if err := chrootRunCommand("userdel", "-r", "temp"); err != nil {
		return err
	}
	return nil
}

func aurPkgInstall() error {
	if !*desktop || len(aurPackages) == 0 {
		return nil
	}
	i := 0
	ks := make([]string, len(aurPackages))
	fs := make([]func() error, len(aurPackages))
	for k, f := range aurPackages {
		ks[i] = k
		if f != nil {
			fs[i] = f
		}
		i++
	}
	if err := chrootAurInstall(ks...); err != nil {
		return err
	}
	for _, val := range fs {
		if val == nil {
			break
		}
		if err := val(); err != nil {
			return err
		}
	}
	return nil
}

func goPkgInstall() error {
	if !*goPkgs {
		return nil
	}
	if err := chrootPacmanInstall("go"); err != nil {
		return err
	}
	if len(goPackages) == 0 {
		return nil
	}
	i := 0
	ks := make([]string, len(goPackages))
	fs := make([]func() error, len(goPackages))
	for k, f := range goPackages {
		ks[i] = k
		if f != nil {
			fs[i] = f
		}
		i++
	}
	if err := chrootAurInstall(ks...); err != nil {
		return err
	}
	for _, val := range fs {
		if val == nil {
			break
		}
		if err := val(); err != nil {
			return err
		}
	}
	return nil
}

func pipPkgInstall() error {
	if !*pipPkgs {
		return nil
	}
	if err := chrootPacmanInstall("python", "python-pip"); err != nil {
		return err
	}
	if len(pipPackages) == 0 {
		return nil
	}
	i := 0
	ks := make([]string, len(pipPackages))
	fs := make([]func() error, len(pipPackages))
	for k, f := range pipPackages {
		ks[i] = k
		if f != nil {
			fs[i] = f
		}
		i++
	}
	if err := chrootAurInstall(ks...); err != nil {
		return err
	}
	for _, val := range fs {
		if val == nil {
			break
		}
		if err := val(); err != nil {
			return err
		}
	}
	return nil
}

func npmPkgInstall() error {
	if !*npmPkgs {
		return nil
	}
	if err := chrootPacmanInstall("nodejs", "npm"); err != nil {
		return err
	}
	if len(npmPackages) == 0 {
		return nil
	}
	i := 0
	ks := make([]string, len(npmPackages))
	fs := make([]func() error, len(npmPackages))
	for k, f := range npmPackages {
		ks[i] = k
		if f != nil {
			fs[i] = f
		}
		i++
	}
	if err := chrootAurInstall(ks...); err != nil {
		return err
	}
	for _, val := range fs {
		if val == nil {
			break
		}
		if err := val(); err != nil {
			return err
		}
	}
	return nil
}

func desktopInstall() error {
	if !*desktop || len(desktopPackages) == 0 {
		return nil
	}
	i := 0
	ks := make([]string, len(desktopPackages))
	fs := make([]func() error, len(desktopPackages))
	for k, f := range desktopPackages {
		ks[i] = k
		if f != nil {
			fs[i] = f
		}
		i++
	}
	if err := chrootAurInstall(ks...); err != nil {
		return err
	}
	for _, val := range fs {
		if val == nil {
			break
		}
		if err := val(); err != nil {
			return err
		}
	}
	return nil
}

func CopyConfig() error {
	for key, val := range configPath {
		if err := chrootRunCommand("cp", key, val); err != nil {
			return err
		}
	}
	return nil
}

func main() {
	// Installer code
	for _, j := range installer {
		if err := j(); err != nil {
			log.Fatalln(err)
		}
	}
}
