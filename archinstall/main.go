package main

import (
	"errors"
	"flag"
	"io"
	"log"
	"log/slog"
	"os"
	"os/exec"
	"path/filepath"
)

const ()

var (
	ErrRootNotSet     error = errors.New("main: root partition not set")
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
)

func init() {
	// Logger Setup
	log.SetFlags(0)
	log.SetPrefix("[\033[91mLOG\033[0m] ")

	// Arguments parsing setup
	mountPoint = flag.String("mount-point", "/mnt", "Build the arch filesystem by using this partition for mounting.")
	root = flag.String("root", "", "Set the root partition.")
	home = flag.String("home", "", "Set the home partition.")
	swap = flag.String("swap", "", "Set the swap partition.")
	esp = flag.String("esp", "", "Set the esp partition. Do not use this incase you are installing archlinux in a vm.")
	formatEsp = flag.Bool("format-esp", false, "Format the esp partition. Do this if you have created a new esp partition. Do not use it when you are using the windows esp partition for dual booting.")
	country = flag.String("country", "India", "Sets the country whose repos are added to the mirrorlist of pacman.")
	repoCount = flag.Int("repo-count", 5, "Number of repos to be added to the mirrorlist of pacman.")
	parallelDownloads = flag.Int("parallel-downloads", 5, "Number of downloads pacman can do at a time.")
	hostname = flag.String("hostname", "xeltron", "Set the hostname of the system.")
	username = flag.String("username", "zeltron", "Set the username of the system.")
	zone = flag.String("zone", "Asia", "Set the zone for system time.")
	subZone = flag.String("sub-zone", "Kolkata", "Set the sub-zone for system time.")
	amd = flag.Bool("amd", false, "Use this flag to install micro-code for amd chips instead of intel.")
	flag.Parse()
	if parsed := flag.Parsed(); !parsed {
		log.Fatalln(errors.New("Flags not parsed. Wrong flags given."))
	}
	// flag.CommandLine.SetOutput(os.Stdout)
}

func fatalLog(err error) {
	slog.Error(err.Error())
	os.Exit(1)
}

func RunCommand(name string, args ...string) error {
	slog.Info(name, args)
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	if err := cmd.Run(); err != nil {
		return err
	}
	return nil
}

func ChrootRunCommand(name string, args ...string) error {
	newArgs := append([]string{*mountPoint, name}, args...)
	return RunCommand("arch-chroot", newArgs...)
}

func PacmanInstall(packages ...string) error {
	args := append([]string{"-S", "--needed", "--noconfirm"}, packages...)
	return RunCommand("pacman", args...)
}

func ChrootPacmanInstall(packages ...string) error {
	args := append([]string{"-S", "--needed", "--noconfirm"}, packages...)
	return ChrootRunCommand("pacman", args...)
}

func Mount(source string, destination string) error {
	return RunCommand("mount", "--mkdir", source, destination)
}

func Unmount(source string) error {
	return RunCommand("umount", "-R", source)
}

func Pacstrap(packages ...string) error {
	args := append([]string{"-K", *mountPoint}, packages...)
	if err := RunCommand("pacstrap", args...); err != nil {
		return err
	}
	return nil
}

func SystemctlServiceEnable(services ...string) error {
	for _, j := range services {
		if err := ChrootRunCommand("systemctl", "enable", j); err != nil {
			return err
		}
	}
	return nil
}

func FormatAndMountRoot() error {
	if err := RunCommand("mkfs.ext4", *root); err != nil {
		return err
	}
	if err := Mount(*root, *mountPoint); err != nil {
		return err
	}
	return nil
}

func FormatAndSetSwap() error {
	if err := RunCommand("mkswap", *swap); err != nil {
		return err
	}
	if err := RunCommand("swapon", *swap); err != nil {
		return err
	}
	return nil
}

func FormatAndMountHome() error {
	if err := RunCommand("mkfs.ext4", *home); err != nil {
		return err
	}
	if err := Mount(*home, filepath.Join(*mountPoint, "home")); err != nil {
		return err
	}
	return nil
}

func FormatAndMountEsp() error {
	if *formatEsp {
		if err := RunCommand("mkfs.fat", "-F", "32", *esp); err != nil {
			return err
		}
	}
	if err := Mount(*esp, filepath.Join(*mountPoint, "boot", "efi")); err != nil {
		return err
	}
	return nil
}

func PacmanConfigSetup() error {
	if err := PacmanInstall("reflector"); err != nil {
		return err
	}
	if err := RunCommand("mv", filepath.Join("/etc", "pacman.d", "mirrorlist"), filepath.Join("/etc", "pacman.d", "mirrorlist.bak")); err != nil {
		return err
	}
	if err := RunCommand("reflector", "--latest", string(*repoCount), "--country", *country, "--protocol", "https", "--sort", "rate", "--save", filepath.Join("/etc", "pacman.d", "mirrorlist")); err != nil {
		return err
	}
	if err := RunCommand("bash", "-c", "echo 'ParallelDownloads = "+string(*parallelDownloads)+"' >> "+filepath.Join("/etc", "pacman.conf")); err != nil {
		return err
	}
	if err := RunCommand("bash", "-c", "echo >> "+filepath.Join("/etc", "pacman.conf")); err != nil {
		return err
	}
	if err := RunCommand("bash", "-c", "echo '[multilib]' >> "+filepath.Join("/etc", "pacman.conf")); err != nil {
		return err
	}
	if err := RunCommand("bash", "-c", "echo 'Include = "+filepath.Join("/etc", "pacman.d", "mirrorlist")+"' >> "+filepath.Join("/etc", "pacman.conf")); err != nil {
		return err
	}
	return nil
}

func GenFSTab() error {
	if err := RunCommand("genfstab", "-U", *mountPoint, filepath.Join(*mountPoint, "etc", "fstab")); err != nil {
		return err
	}
	return nil
}

func FormatAndMountSystem() error {
	if *root == "" {
		return ErrRootNotSet
	}
	if err := FormatAndMountRoot(); err != nil {
		return err
	}
	if *home != "" {
		if err := FormatAndMountHome(); err != nil {
			return err
		}
	}
	if *swap != "" {
		if err := FormatAndSetSwap(); err != nil {
			return err
		}
	}
	if *esp != "" {
		if err := FormatAndMountEsp(); err != nil {
			return err
		}
	}
	return nil
}

func SetBiggerFont() error {
	return RunCommand("setfont", "ter-132b")
}

func SynchronizeTimeZone() error {
	if err := ChrootRunCommand("ln", "-sf", filepath.Join("/usr", "share", "zoneinfo", *zone, *subZone), filepath.Join("/etc", "localtime")); err != nil {
		return err
	}
	if err := ChrootRunCommand("hwclock", "--systohc"); err != nil {
		return err
	}
	return nil
}

func GenLocale() error {
	if err := ChrootRunCommand("bash", "-c", "echo 'en_IN.UTF-8 UTF-8' >> "+filepath.Join("/etc", "locale.gen")); err != nil {
		return err
	}
	if err := ChrootRunCommand("bash", "-c", "echo 'LANG=en_IN.UTF-8' >> "+filepath.Join("/etc", "locale.conf")); err != nil {
		return err
	}
	if err := ChrootRunCommand("locale-gen"); err != nil {
		return err
	}
	return nil
}

func SetHostName() error {
	if err := ChrootRunCommand("bash", "-c", "echo "+*hostname+" >> "+filepath.Join("/etc", "hostname")); err != nil {
		return err
	}
	return nil
}

func SetRootPasswd() error {
	if err := ChrootRunCommand("passwd"); err != nil {
		return err
	}
	return nil
}

func CreateUser() error {
	if err := ChrootRunCommand("useradd", "-m", *username); err != nil {
		return err
	}
	if err := ChrootRunCommand("passwd", *username); err != nil {
		return err
	}
	if err := ChrootRunCommand("bash", "-c", "echo '%wheel ALL=(ALL:ALL) ALL' | (EDITOR='tee -a' visudo)"); err != nil {
		return err
	}
	if err := ChrootRunCommand("usermod", "-aG", "wheel", *username); err != nil {
		return err
	}
	return nil
}

func InstallBootLoader() error {
	if err := ChrootPacmanInstall("efibootmgr", "grub"); err != nil {
		return err
	}
	if err := ChrootRunCommand("bash", "-c", "echo 'GRUB_DISABLE_OS_PROBER=false' >> "+filepath.Join("/etc", "default", "grub")); err != nil {
		return err
	}
	if err := ChrootPacmanInstall("os-prober"); err != nil {
		return err
	}
	if *formatEsp {
		if err := ChrootRunCommand("grub-install", "--target=x86_64-efi", "--bootloader-id=GRUB", "--recheck", "--removable"); err != nil {
			return err
		}
	} else {
		if err := ChrootRunCommand("grub-install", "--target=x86_64-efi", "--bootloader-id=GRUB", "--recheck"); err != nil {
			return err
		}
	}
	if err := ChrootRunCommand("grub-mkconfig", "-o", filepath.Join("/boot", "grub", "grub.cfg")); err != nil {
		return err
	}
	return nil
}

func InstallMicroCode() error {
	if *amd {
		return ChrootPacmanInstall("amd-ucode")
	}
	return ChrootPacmanInstall("intel-ucode")
}

func main() {
	// Logger setup
	file, err := os.OpenFile("goarchinstall.log", os.O_WRONLY|os.O_CREATE, os.ModePerm)
	defer file.Close()
	if err != nil {
		log.Fatalln("Cannot create log file:", err)
	}
	multiWriter := io.MultiWriter(os.Stdout, file)
	log.SetOutput(multiWriter)

	// Installer code
	if err := SetBiggerFont(); err != nil {
		fatalLog(err)
	}
	if err := FormatAndMountSystem(); err != nil {
		fatalLog(err)
	}
	if err := PacmanConfigSetup(); err != nil {
		fatalLog(err)
	}
	if err := Pacstrap("base", "base-devel", "linux", "linux-lts", "linux-headers", "linux-lts-headers", "linux-firmware", "sudo", "vim", "git", "networkmanager", "dhcpcd", "pacman-contrib", "fish"); err != nil {
		fatalLog(err)
	}
	// if err := Pacstrap("base", "base-devel", "linux", "linux-lts", "linux-headers", "linux-lts-headers", "linux-firmware", "sudo", "vim", "git", "networkmanager", "dhcpcd", "pipewire", "blueman", "bluez-utils", "wayland", "xdg-desktop-portal", "pacman-contrib", "polkit-gnome", "kitty", "fish"); err != nil {
	// 	fatalLog(err)
	// }
	if err := GenFSTab(); err != nil {
		fatalLog(err)
	}
	if err := SynchronizeTimeZone(); err != nil {
		fatalLog(err)
	}
	if err := GenLocale(); err != nil {
		fatalLog(err)
	}
	if err := SetHostName(); err != nil {
		fatalLog(err)
	}
	if err := CreateUser(); err != nil {
		fatalLog(err)
	}
	if err := InstallMicroCode(); err != nil {
		fatalLog(err)
	}
	if err := InstallBootLoader(); err != nil {
		fatalLog(err)
	}
	if err := SystemctlServiceEnable("dhcpcd", "NetworkManager"); err != nil {
		fatalLog(err)
	}
	if err := Unmount(*mountPoint); err != nil {
		fatalLog(err)
	}
}
