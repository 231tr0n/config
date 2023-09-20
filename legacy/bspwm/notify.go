package main

import (
	"os"
	"os/exec"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"
	"log"
)

var lowNotified bool
var highNotified bool
var lowerLimit int
var upperLimit int

func bash(args ...string) string {
	args = append([]string{"-c"}, args...)
	output, _ := exec.Command("bash", args...).Output()
	return string(output)
}

func init() {
	lowNotified = false
	highNotified = false
	if len(os.Args) == 3 {
		var err error
		if lowerLimit, err = strconv.Atoi(os.Args[1]); err != nil {
			log.Fatalln("Argument 1 not an integer")
		}
		if !(lowerLimit >= 0 && lowerLimit <= 100) {
			log.Fatalln("Argument 1 not in between 0 and 100")
		}
		if upperLimit, err = strconv.Atoi(os.Args[2]); err != nil {
			log.Fatalln("Argument 2 not an integer")
		}
		if !(upperLimit >= 0 && upperLimit <= 100) {
			log.Fatalln("Argument 2 not in between 0 and 100")
		}
	} else {
		log.Fatalln("Program accepts 2 arguments")
	}
}

func batteryStatus() int {
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
			return percentInt
		}
	}
	log.Fatalln("Error parsing acpi information")
	return 0
}
func batteryNotifier(battery int) {
	if battery < lowerLimit {
		if !lowNotified {
			bash("notify-send --urgency=critical 'Battery Low.'")
			lowNotified = true
		}
	} else if battery > upperLimit {
		if !highNotified {
			bash("notify-send --urgency=critical 'Battery High.'")
			highNotified = true
		}
	} else {
		lowNotified = false
		highNotified = false
	}
}

func main() {
	go (func() {
		interrupt := make(chan os.Signal)
		signal.Notify(interrupt, os.Interrupt, syscall.SIGTERM, syscall.SIGINT)
		<-interrupt
		os.Exit(0)
	})()
	for {
		batteryNotifier(batteryStatus())
		time.Sleep(time.Second)
	}
}
