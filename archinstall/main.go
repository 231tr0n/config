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
	// Cli arguments variables
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

	// Internal variables
	pacmanPackages = []string{"base", "base-devel", "linux", "linux-headers",
		"linux-firmware", "linux-lts", "sudo", "vim",
		"git", "networkmanager", "dhcpcd",
		"pacman-contrib", "fish", "terminus-font",
		"pipewire-audio", "wireplumber", "jack2",
		"sway", "bemenu-wayland", "blueman",
		"brightnessctl", "chromium", "firefox",
		"conky", "wget", "curl", "discord",
		"telegram-desktop", "pcmanfm", "ffmpeg",
		"yt-dlp", "python", "python-pipx",
		"nodejs", "npm", "fileroller",
		"font-manager", "xreader", "gcolor3",
		"gnome-calculator", "gnome-calendar",
		"libreoffice", "go", "gnome-disk-utility",
		"bpytop", "lxappearance", "helvum", "htop",
		"imagemagick", "imv", "kontrast", "copyq",
		"ly", "mako", "man-db", "mpv",
		"haruna", "neovim", "network-manager-applet",
		"networkmanager-openvpn", "okular", "openvpn",
		"pacman-contrib", "pavucontrol", "polkit-gnome",
		"thunderbird", "wl-clipboard", "wl-mirror",
		"wlroots", "xdg-desktop-portal", "xdg-desktop-portal-wlr",
		"xdg-user-dirs", "xdg-user-dirs-gtk", "zathura",
		"acpi", "pipewire", "pipewire-pulse",
	}
	services     = []string{"NetworkManager", "dhcpcd", "systemd-timesyncd", "ly"}
	userServices = []string{"pipewire", "pipewire-pulse", "wireplumber"}
	aurPackages  = []string{"themix-full-git", "pix", "ocs-url",
		"hyprpicker", "swaysettings-git", "wlogout",
		"whatsapp-for-linux-bin", "brave-bin",
	}
	installer = []func() error{
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
		installMicroCode,
		installBootLoader,
		installAurHepler,
		aurPkgInstall,
		systemctlServiceEnable,
		systemctlUserServiceEnable,
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
	repoCount = flag.Int("repo-count", 5, "Number of repos to be added to the mirrorlist of pacman.")
	parallelDownloads = flag.Int("parallel-downloads", 5, "Number of downloads pacman can do at a time.")
	hostname = flag.String("hostname", "xeltron", "Set the hostname of the system.")
	username = flag.String("username", "zeltron", "Set the username of the system.")
	zone = flag.String("zone", "Asia", "Set the zone for system time.")
	subZone = flag.String("sub-zone", "Kolkata", "Set the sub-zone for system time.")
	amd = flag.Bool("amd", false, "Use this flag to install micro-code for amd chips.")
	intel = flag.Bool("intel", false, "Use this flag to install micro-code for intel chips.")
	userPwd = flag.String("user-pwd", "", "Set user password. (required)")
	rootPwd = flag.String("root-pwd", "", "Set root password. (required)")

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
	cmd.Stdin = os.Stdin
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
	args := append([]string{"-Sy", "--needed", "--noconfirm"}, packages...)
	return runCommand("pacman", args...)
}

func chrootPacmanInstall(packages ...string) error {
	args := append([]string{"-Syu", "--needed", "--noconfirm"}, packages...)
	return chrootRunCommand("pacman", args...)
}

func chrootAurInstall(packages ...string) error {
	args := append([]string{"-Syu", "--needed", "--noconfirm"}, packages...)
	return chrootRunCommand("yay", args...)
}

func mount(source string, destination string) error {
	return runCommand("mount", "--mkdir", source, destination)
}

func unmountSystem() error {
	return runCommand("umount", "-R", *mountPoint)
}

func pacstrap() error {
	args := append([]string{"-K", *mountPoint}, pacmanPackages...)
	if err := runCommand("pacstrap", args...); err != nil {
		return err
	}
	return nil
}

func systemctlServiceEnable() error {
	args := append([]string{"enable"}, services...)
	if err := chrootRunCommand("systemctl", args...); err != nil {
		return err
	}
	return nil
}

func systemctlUserServiceEnable() error {
	args := append([]string{"--user", "enable"}, userServices...)
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
	if err := pacmanInstall("reflector"); err != nil {
		return err
	}
	if err := runCommand("mv", filepath.Join("/etc", "pacman.d", "mirrorlist"), filepath.Join("/etc", "pacman.d", "mirrorlist.bak")); err != nil {
		return err
	}
	if err := runCommand("reflector", "--latest", strconv.Itoa(*repoCount), "--country", *country, "--protocol", "https", "--sort", "rate", "--save", filepath.Join("/etc", "pacman.d", "mirrorlist")); err != nil {
		return err
	}
	if err := runCommand("bash", "-c", "sed -i 's/#ParallelDownloads = 5/ParallelDownloads = "+strconv.Itoa(*parallelDownloads)+"/g' "+filepath.Join("/etc", "pacman.conf")); err != nil {
		return err
	}
	if err := runCommand("bash", "-c", "echo >> "+filepath.Join("/etc", "pacman.conf")); err != nil {
		return err
	}
	if err := runCommand("bash", "-c", "echo '[multilib]' >> "+filepath.Join("/etc", "pacman.conf")); err != nil {
		return err
	}
	if err := runCommand("bash", "-c", "echo 'Include = "+filepath.Join("/etc", "pacman.d", "mirrorlist")+"' >> "+filepath.Join("/etc", "pacman.conf")); err != nil {
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
	if err := chrootAurInstall(aurPackages...); err != nil {
		return err
	}
	return nil
}

func main() {
	// Installer code
	for _, j := range installer {
		if err := j(); err != nil {
			log.Fatalln(err)
			os.Exit(1)
		}
	}
}
