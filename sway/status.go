package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"runtime/debug"
	"strconv"
	"strings"
	"sync"
	"time"
)

const (
	tick = 1
)

var (
	lastRx            = 1
	lastTx            = 1
	lastCpuIdleTime   = 0
	lastCpuTotalTime  = 0
	batteryNotified   = false
	batteryUpperLimit = 90
	batteryLowerLimit = 15
	bmu               = &sync.Mutex{}
)

var (
	ErrLog          = errors.New("main: Cannot write to log file.")
	ErrBatteryLimit = errors.New("main: Upper limit of battery lower than or equal to lower limit.")
)

func init() {
	if batteryUpperLimit <= batteryLowerLimit {
		panic(ErrBatteryLimit)
	}
	file, err := os.OpenFile(filepath.Join(os.Getenv("HOME"), ".config", "sway", "status.log"), os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		panic(ErrLog)
	}

	log.SetFlags(0)
	log.SetOutput(file)
	log.SetPrefix("[\033[91mLOG\033[0m] ")

	version, err := json.Marshal(version{
		Version: 1,
	})
	if err != nil {
		panic(err)
	}

	fmt.Println(string(version))
	fmt.Println("[")
}

type version struct {
	Version int `json:"version"`
}

type part struct {
	FullText            string `json:"full_text"`
	ShortText           string `json:"short_text,omitempty"`
	Color               string `json:"color,omitempty"`
	Border              string `json:"border,omitempty"`
	BorderTop           int    `json:"border_top"`
	BorderBottom        int    `json:"border_bottom"`
	BorderLeft          int    `json:"border_left"`
	BorderRight         int    `json:"border_right"`
	MinWidth            int    `json:"min_width"`
	Background          string `json:"background,omitempty"`
	Separator           bool   `json:"separator"`
	SeparatorBlockWidth int    `json:"separator_block_width"`
	Align               string `json:"align"`
	Markup              string `json:"markup"`
}

func identifier(identifier string) part {
	return part{
		FullText:            identifier,
		Color:               "#F96743",
		Border:              "#808080",
		BorderTop:           2,
		BorderBottom:        2,
		BorderLeft:          2,
		BorderRight:         1,
		MinWidth:            0,
		Background:          "#1C1C1C",
		Separator:           false,
		SeparatorBlockWidth: 0,
		Align:               "center",
		Markup:              "none",
	}
}

func middleValue(value string) part {
	return part{
		FullText:            value,
		Color:               "#B2B2B2",
		Border:              "#808080",
		BorderTop:           2,
		BorderBottom:        2,
		BorderLeft:          1,
		BorderRight:         1,
		MinWidth:            0,
		Background:          "#1C1C1C",
		Separator:           false,
		SeparatorBlockWidth: 0,
		Align:               "center",
		Markup:              "none",
	}
}

func value(value string) part {
	return part{
		FullText:            value,
		Color:               "#B2B2B2",
		Border:              "#808080",
		BorderTop:           2,
		BorderBottom:        2,
		BorderLeft:          1,
		BorderRight:         2,
		MinWidth:            0,
		Background:          "#1C1C1C",
		Separator:           false,
		SeparatorBlockWidth: 0,
		Align:               "center",
		Markup:              "none",
	}
}

func spacer() part {
	return part{
		FullText:            " ",
		Color:               "#00000000",
		Border:              "#00000000",
		BorderTop:           0,
		BorderBottom:        0,
		BorderLeft:          0,
		BorderRight:         0,
		MinWidth:            0,
		Background:          "#00000000",
		Separator:           false,
		SeparatorBlockWidth: 0,
		Align:               "center",
		Markup:              "none",
	}
}

func cmd(args ...string) string {
	output, err := exec.Command(args[0], args[1:]...).Output()
	if err != nil {
		panic(err)
	}
	return string(output)
}

func bash(args ...string) string {
	args = append([]string{"-c"}, args...)
	output, err := exec.Command("bash", args...).Output()
	if err != nil {
		panic(err)
	}
	return string(output)
}

func dateTime() string {
	return time.Now().Format("02-01-2006 15:04:05 Jan Mon")
}

func disk() string {
	return strings.Fields(strings.Split(cmd("df", "-h", "/"), "\n")[1])[4]
}

func brightness() string {
	temp := strings.Fields(strings.Split(cmd("brightnessctl"), "\n")[1])[3]
	return temp[1 : len(temp)-1]
}

func sinkVolume() string {
	temp := strings.Fields(strings.Split(cmd("wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"), "\n")[0])[1]
	f, err := strconv.ParseFloat(temp, 64)
	if err != nil {
		panic(err)
	}
	return strconv.Itoa(int(f*100)) + "%"
}

func sourceVolume() string {
	temp := strings.Fields(strings.Split(cmd("wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"), "\n")[0])[1]
	f, err := strconv.ParseFloat(temp, 64)
	if err != nil {
		panic(err)
	}
	return strconv.Itoa(int(f*100)) + "%"
}

func network() (string, string) {
	rx := 0
	tx := 0

	data, err := os.ReadFile("/proc/net/dev")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(strings.TrimSpace(string(data)), "\n")
	lines = lines[2:]

	for _, val := range lines {
		fields := strings.Fields(val)
		tempRx, err := strconv.Atoi(fields[1])
		if err != nil {
			panic(err)
		}
		rx += tempRx

		tempTx, err := strconv.Atoi(fields[9])
		if err != nil {
			panic(err)
		}
		tx += tempTx
	}

	download := (rx - lastRx) / tick
	upload := (tx - lastTx) / tick

	lastRx = rx
	lastTx = tx

	notations := []string{"B", "KB", "MB", "GB", "TB"}
	rxNotationIndex := 0
	for download >= 1000 {
		rxNotationIndex += 1
		download = download / 1000
	}

	txNotationIndex := 0
	for upload >= 1000 {
		txNotationIndex += 1
		upload = upload / 1000
	}

	return strconv.Itoa(download) + notations[rxNotationIndex], strconv.Itoa(upload) + notations[txNotationIndex]
}

func batteryNotifier(capacity int) {
	bmu.Lock()
	defer bmu.Unlock()

	if capacity < batteryLowerLimit {
		if !batteryNotified {
			cmd("swaynag", "-t", "error", "-m", "Battery Low")
			batteryNotified = true
		}
		return
	} else if capacity > batteryUpperLimit {
		if !batteryNotified {
			cmd("swaynag", "-t", "warning", "-m", "Battery High")
			batteryNotified = true
		}
		return
	} else {
		batteryNotified = false
	}
}

func battery() (string, bool) {
	batDir := "BAT0"
	if _, err := os.Stat("/sys/class/power_supply/" + batDir); err != nil {
		batDir = "BAT1"
		if _, err := os.Stat("/sys/class/power_supply/" + batDir); err != nil {
			return "", false
		}
	}
	data, err := os.ReadFile("/sys/class/power_supply/" + batDir + "/capacity")
	if err != nil {
		panic(err)
	}

	status, err := os.ReadFile("/sys/class/power_supply/" + batDir + "/status")
	if err != nil {
		panic(err)
	}

	capacity, err := strconv.Atoi(strings.TrimSpace(string(data)))
	if err != nil {
		panic(err)
	}
	go batteryNotifier(capacity)

	if strings.Contains(strings.TrimSpace(string(status)), "Charging") {
		return strings.TrimSpace(string(data)) + "%", true
	}
	return strings.TrimSpace(string(data)) + "%", false
}

func cpu() string {
	data, err := os.ReadFile("/proc/stat")
	if err != nil {
		panic(err)
	}

	fields := strings.Fields(strings.Split(strings.TrimSpace(string(data)), "\n")[0])

	idleTime, err := strconv.Atoi(fields[4])
	if err != nil {
		panic(err)
	}

	totalTime := 0
	for _, val := range fields[1:] {
		temp, err := strconv.Atoi(val)
		if err != nil {
			panic(err)
		}

		totalTime += temp
	}

	deltaIdleTime := idleTime - lastCpuIdleTime
	deltaTotalTime := totalTime - lastCpuTotalTime

	lastCpuIdleTime = idleTime
	lastCpuTotalTime = totalTime

	usage := (1.0 - (float64(deltaIdleTime) / float64(deltaTotalTime))) * 100.0

	return strconv.Itoa(int(usage)) + "%"
}

func ram() string {
	data, err := os.ReadFile("/proc/meminfo")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(strings.TrimSpace(string(data)), "\n")[0:2]

	memTotal, err := strconv.Atoi(strings.Fields(lines[0])[1])
	if err != nil {
		panic(err)
	}

	memFree, err := strconv.Atoi(strings.Fields(lines[1])[1])
	if err != nil {
		panic(err)
	}

	usage := (float64(memTotal-memFree) / float64(memTotal)) * 100.0

	return strconv.Itoa(int(usage)) + "%"
}

func main() {
	defer func() {
		if err := recover(); err != nil {
			log.Println(err)
			log.Println("stacktrace from panic: \n" + string(debug.Stack()))
		}
	}()

	for {
		rx, tx := network()

		builder := []part{
			identifier("NETWORK"),
			middleValue(""),
			middleValue(rx),
			middleValue(""),
			value(tx),
			spacer(),
			identifier("CPU"),
			value(cpu()),
			spacer(),
			identifier("RAM"),
			value(ram()),
			spacer(),
			identifier("AUDIO"),
			middleValue("󰕾"),
			middleValue(sinkVolume()),
			middleValue("󰍬"),
			value(sourceVolume()),
			spacer(),
			identifier("BRIGHTNESS"),
			value(brightness()),
			spacer(),
			identifier("TIME"),
			value(dateTime()),
			spacer(),
			identifier("DISK"),
			value(disk()),
			spacer(),
		}

		capacity, status := battery()
		if capacity != "" {
			stat := "󰁹"
			if status {
				stat = "󰂄"
			}
			builder = append(builder, []part{
				identifier("BATTERY"),
				middleValue(stat),
				value(capacity),
				spacer(),
			}...)
		}

		time.Sleep(tick * time.Second)
		builded, err := json.MarshalIndent(builder, "", "  ")
		if err != nil {
			panic(err)
		}

		fmt.Println(string(builded) + ",")
	}
}
