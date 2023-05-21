package main

import (
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"
)

var lowNotified bool
var highNotified bool
var lowerLimit int
var upperLimit int
var lastRx int
var lastTx int
var interfaces []string
var batteryIndicator bool

func init() {
	lowNotified = false
	highNotified = false
	if len(os.Args) == 3 {
		lowerLimit, _ = strconv.Atoi(os.Args[1])
		upperLimit, _ = strconv.Atoi(os.Args[2])
		batteryIndicator = true
	} else {
		batteryIndicator = false
	}
	temp := bash("ls /sys/class/net | grep -E '^(eno|enp|ens|enx|eth|wlan|wlp)'")
	interfaces = strings.Split(strings.Trim(temp, "\n "), "\n")
	tempRx := 0
	tempTx := 0
	for _, i := range interfaces {
		rxFile, _ := os.ReadFile("/sys/class/net/" + i + "/statistics/rx_bytes")
		txFile, _ := os.ReadFile("/sys/class/net/" + i + "/statistics/tx_bytes")
		iRx, _ := strconv.Atoi(strings.Trim(string(rxFile), "\n "))
		iTx, _ := strconv.Atoi(strings.Trim(string(txFile), "\n "))
		tempRx += iRx
		tempTx += iTx
	}
	lastRx = tempRx
	lastTx = tempTx
}

func bash(args ...string) string {
	args = append([]string{"-c"}, args...)
	output, _ := exec.Command("bash", args...).Output()
	return string(output)
}

func uploadDownloadCalculator() string {
	tempRx := 0
	tempTx := 0
	for _, i := range interfaces {
		rxFile, _ := os.ReadFile("/sys/class/net/" + i + "/statistics/rx_bytes")
		txFile, _ := os.ReadFile("/sys/class/net/" + i + "/statistics/tx_bytes")
		iRx, _ := strconv.Atoi(strings.Trim(string(rxFile), "\n "))
		iTx, _ := strconv.Atoi(strings.Trim(string(txFile), "\n "))
		tempRx += iRx
		tempTx += iTx
	}
	rx := tempRx - lastRx
	tx := tempTx - lastTx
	lastRx = tempRx
	lastTx = tempTx
	output := ""
	rxkb := rx / 1000
	txkb := tx / 1000
	if rxkb > 1000 {
		output += fmt.Sprintf("🖧: %vMB↓", rxkb / 1000)
	} else {
		output += fmt.Sprintf("🖧: %vKB↓", rxkb)
	}
	output += "-"
	if txkb > 1000 {
		output += fmt.Sprintf("%vMB↑", txkb / 1000)
	} else {
		output += fmt.Sprintf("%vKB↑", txkb)
	}
	return output
}

func presentTime() string {
	return "⌛: " + time.Now().Format("Mon Jan 02-01-2006 15:04:05")
}

func memoryUsage() string {
	output := bash("free")
	lines := strings.Split(output, "\n")
	for _, i := range lines {
		if strings.Contains(i, "Mem:") {
			temp := strings.Fields(i)
			total, _ := strconv.Atoi(temp[1])
			used, _ := strconv.Atoi(temp[2])
			return "RAM: " + strconv.Itoa((used * 100) / total) + "%"
		}
	}
	return "error"
}

func cpuUsage() string {
	data, _ := os.ReadFile("/proc/stat")
	lines := strings.Split(string(data), "\n")
	fields := strings.Fields(lines[0])
	var stats []int
	for _, i := range fields {
		temp, err := strconv.Atoi(i)
		if err == nil {
			stats = append(stats, temp)
		}
	}
	return "CPU: " + strconv.Itoa(100 - ((stats[3] * 100) / (stats[0] + stats[1] + stats[2] + stats[3] + stats[4] + stats[5] + stats[6] + stats[7] + stats[8]))) + "%"
}

func brightness() string {
	output := bash("brightnessctl")
	lines := strings.Split(output, "\n")
	percent := ""
	for _, line := range lines {
		if strings.Contains(line, "Current brightness") {
			temp := strings.Split(line, " ")
			percent = temp[3][1 : len(temp[3])-1]
		}
	}
	return "💡: " + percent
}

func capsDetector() string {
	output := bash("xset -q")
	caps := ""
	lines := strings.Split(output, "\n")
	for _, line := range lines {
		if strings.Contains(line, "Caps Lock:") {
			caps = strings.Fields(line)[3]
			break
		}
	}
	if strings.ToUpper(caps) == "OFF" {
		return "🄰"
	} else {
		return "⬆️"
	}
}

func batteryStatus() (string, int) {
	output := bash("acpi -i")
	lines := strings.Split(output, "\n")
	battery := ""
	for _, line := range lines {
		if strings.Contains(line, "design capacity") {
			elements := strings.Split(line, ":")
			battery = elements[0]
		}
	}
	output = bash("acpi")
	lines = strings.Split(output, "\n")
	percent := ""
	for _, line := range lines {
		if strings.Contains(line, battery) {
			elements := strings.Split(line, " ")
			percent = strings.Split(elements[3], ",")[0]
			percentInt, _ := strconv.Atoi(percent[:len(percent)-1])
			if strings.Contains(line, "Discharging") {
				return fmt.Sprintf("🔋: %s", percent), percentInt
			} else if strings.Contains(line, "Charging") {
				return fmt.Sprintf("⚡: %s", percent), percentInt
			} else if strings.Contains(line, "Full") {
				return fmt.Sprintf("🔋: %s", percent), percentInt
			}
			return fmt.Sprintf("🔋: %s", percent), percentInt
		}
	}
	return "", 0
}

func volumeStatus() string {
	output := bash("amixer -D pulse sget Master")
	lines := strings.Split(output, "\n")
	volume := ""
	for _, line := range lines {
		if strings.Contains(line, "Front Left:") {
			args := strings.Fields(line)
			volume = args[4][1 : len(args[4])-1]
			break
		}
	}
	return fmt.Sprintf("🎧: %s", volume)
}

func batteryNotifier(battery int) {
	if battery < lowerLimit {
		if !lowNotified {
			bash("i3-msg 'exec i3-nagbar -t warning -m \"Battery Low.\"'; notify-send 'Battery Low.'")
			lowNotified = true
		}
	} else if battery > upperLimit {
		if !highNotified {
			bash("i3-msg 'exec i3-nagbar -t warning -m \"Battery High.\"'; notify-send 'Battery High.'")
			highNotified = true
		}
	} else {
		lowNotified = false
		highNotified = false
	}
}

func diskStorage() string {
	output := bash("df -h -T /")
	temp := strings.Split(output, "\n")
	temp1 := strings.Split(temp[1], " ")
	return "💾: " + temp1[16]
}

func main() {
	run := true
	seperator := " ｜ "
	go (func() {
		interrupt := make(chan os.Signal)
		signal.Notify(interrupt, os.Interrupt, syscall.SIGTERM, syscall.SIGINT)
		<-interrupt
		run = false
	})()
	for run {
		if batteryIndicator {
			battery, percentInt := batteryStatus()
			batteryNotifier(percentInt)
			fmt.Println(strings.Join([]string{capsDetector(), presentTime(), memoryUsage(), cpuUsage(), uploadDownloadCalculator(), volumeStatus(), battery, brightness(), diskStorage()}, seperator) + seperator[:len(seperator) - 1])
		} else {
			fmt.Println(strings.Join([]string{capsDetector(), presentTime(), memoryUsage(), cpuUsage(), uploadDownloadCalculator(), volumeStatus(), brightness(), diskStorage()}, seperator) + seperator[:len(seperator) - 1])
		}
		time.Sleep(time.Second)
	}
}
