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
)

func init() {
	// Logger Setup
	log.SetFlags(0)
	log.SetPrefix("[\033[91mLOG\033[0m]")

	// Arguments parsing setup
	root = flag.String("root", "", "Set the root partition.")
	home = flag.String("home", "", "Set the home partition.")
	swap = flag.String("swap", "", "Set the swap partition.")
	esp = flag.String("esp", "", "Set the esp partition. Do not use this incase you are installing archlinux in a vm.")
	formatEsp = flag.Bool("format-esp", false, "Format the esp partition. Do this if you have created a new esp partition. Do not use it when you are using the windows esp partition for dual booting.")
	country = flag.String("country", "India", "Sets the country whose repos are added to the mirrorlist of pacman.")
	repoCount = flag.Int("repo-count", 5, "Number of repos to be added to the mirrorlist of pacman.")
	parallelDownloads = flag.Int("parallel-downloads", 5, "Number of downloads pacman can do at a time.")
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

func FormatAndMountRoot(partition string) error {
	if err := RunCommand("mkfs.ext4", partition); err != nil {
		return err
	}
	if err := Mount(partition, filepath.Join(*mountPoint)); err != nil {
		return err
	}
	return nil
}

func FormatAndSetSwap(partition string) error {
	if err := RunCommand("mkswap", partition); err != nil {
		return err
	}
	if err := RunCommand("swapon", partition); err != nil {
		return err
	}
	return nil
}

func FormatAndMountHome(partition string) error {
	if err := RunCommand("mkfs.ext4", partition); err != nil {
		return err
	}
	if err := Mount(partition, filepath.Join(*mountPoint, "home")); err != nil {
		return err
	}
	return nil
}

func FormatAndMountEsp(partition string) error {
	if *formatEsp {
		if err := RunCommand("mkfs.fat", "-F", "32", partition); err != nil {
			return err
		}
	}
	if err := Mount(partition, filepath.Join(*mountPoint, "boot", "efi")); err != nil {
		return err
	}
	return nil
}

func PacmanConfigSetup() error {
	if err := PacmanInstall("reflector"); err != nil {
		return err
	}
	if err := RunCommand("mv", "/etc/pacman.d/mirrorlist", "/etc/pacman.d/mirrorlist.bak"); err != nil {
		return err
	}
	if err := RunCommand("reflector", "--latest", string(*repoCount), "--country", *country, "--protocol", "https", "--sort", "rate", "--save", "/etc/pacman.d/mirrorlist"); err != nil {
		return err
	}
	if err := RunCommand("bash", "-c", "echo 'ParallelDownloads = 5' >> /etc/pacman.conf"); err != nil {
		return err
	}
	if err := RunCommand("bash", "-c", "echo >> /etc/pacman.conf"); err != nil {
		return err
	}
	if err := RunCommand("bash", "-c", "echo '[multilib]' >> /etc/pacman.conf"); err != nil {
		return err
	}
	if err := RunCommand("bash", "-c", "echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf"); err != nil {
		return err
	}
	return nil
}

func Pacstrap(packages ...string) error {
	args := append([]string{"-K", *mountPoint}, packages...)
	if err := RunCommand("pacstrap", args...); err != nil {
		return err
	}
	return nil
}

func FormatAndMountSystem() error {
	if *root == "" {
		return ErrRootNotSet
	}
	if err := FormatAndMountRoot(*root); err != nil {
		return err
	}
	if *home != "" {
		if err := FormatAndMountHome(*home); err != nil {
			return err
		}
	}
	if *swap != "" {
		if err := FormatAndSetSwap(*swap); err != nil {
			return err
		}
	}
	if *esp != "" {
		if err := FormatAndMountEsp(*esp); err != nil {
			return err
		}
	}
	return nil
}

func SetBiggerFont() error {
	return RunCommand("setfont", "ter-132b")
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
}
