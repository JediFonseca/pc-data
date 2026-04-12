#!/bin/bash

# Dependencies:

# This script was tested on Debian 13 (Stable). All the packages used by this script came preinstalled on Debian.
# The packages needed to be able to use this script are (names based on the Debian repositories):
# util-linux
# dmidecode
# lm-sensors
# upower
# grep, sed, awk and coreutils (probably installed by default on any distro).

# Colors:
GREEN='\033[0;32m'
BLUE='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NOCOLOR='\033[0m'

export LC_ALL=C

case "$1" in
    "--help")

    clear

    echo -e "${BLUE}How to use this script:${NOCOLOR}\n"

    echo -e "Run \"./pcdata.sh\" for basic system and hardware information.\n"

    echo -e "${BLUE}For more details, use the following flags:${NOCOLOR}"
    echo -e "--cpu: for advanced CPU information."
    echo -e "--ram: for advanced RAM information."

    echo -e "\n${BLUE}DEPENDENCIES:${NOCOLOR}"
    echo -e "${BLUE}For this script to work properly, you'll need the following packages:${NOCOLOR}"
    echo -e "dmidecode, lm-sensors, util-linux, upower and pciutils. (Package names based on Debian 13.)"
    echo "All of them are default on many distros, including Debian, but you may need to"
    echo "install some of them manually, specially in more minimalistic distros."

    ;;

    "--cpu") # BEGINNING OF THE "--cpu" FLAG CODE.

        echo -e "${YELLOW}This script requires administrator privileges to read hardware data.${NOCOLOR}"

        sudo -v || { echo -e "${RED}Authentication failed!${NOCOLOR}"; exit 1; }

        # Setting global variables.

        MANUFACTURER=$(sudo dmidecode -t processor | grep "Manufacturer" | sed 's/.*: *//')
        MODELNAME=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//')
        CORES=$(lscpu | grep "Core(s) per socket:" | awk '{print $4}')
        THREADS=$(lscpu | grep "^CPU(s):" | head -n1 | awk '{print $2}')
        GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
        SOCKET=$(sudo dmidecode -t processor | grep "Upgrade:" | cut -d: -f2 | sed -e 's/^[ \t]*//')
        VOLTAGE=$(sudo dmidecode -t processor | grep "Voltage" | sed 's/.*: *//')
        FAMILYNUMBER=$(grep -m1 "cpu family" /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//')
        MODELNUMBER=$(grep "^model" /proc/cpuinfo | grep -v "model name" | head -n1 | cut -d: -f2 | sed 's/^[ \t]*//')
        STEPPING=$(grep -m1 "stepping" /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//')
        INSTRUCTIONS=$(lscpu | grep -E "Flags|Options" \
            | grep -iowE "mmx|sse|sse2|sse3|ssse3|sse4_1|sse4_2|avx|avx2|avx512|fma|aes|sha|vmx|svm|lm" \
            | tr '[:lower:]' '[:upper:]' | tr '_' '.' | sort -u | xargs | sed 's/ /, /g')
        MAXCLOCK=$(sudo dmidecode -t processor | grep "Max Speed" | sed 's/.*: *//')
        CACHEL1D=$(lscpu | grep -E "L1d" | sed 's/.*: *//')
        CACHEL1I=$(lscpu | grep -E "L1i" | sed 's/.*: *//')
        CACHEL2=$(lscpu | grep -E "L2" | sed 's/.*: *//')
        CACHEL3=$(lscpu | grep -E "L3" | sed 's/.*: *//')

        # Formatting output and loop for the realtime information.

    while true; do

        # Variables for the realtime information.
        CPUTEMP=$(sensors | grep -E "Tctl:|Package id 0:" | awk '{print $4 ? $4 : $2}' \
            | tr -d '+') && CPUTEMP=${CPUTEMP:-"N/A (Install 'lm_sensors' and run the 'sensors-detect' command.)"}
        CLOCK=$(grep "cpu MHz" /proc/cpuinfo | head -n1 | cut -d: -f2 | sed -e 's/^[ \t]*//')
        MULTIPLIER=$(grep "cpu MHz" /proc/cpuinfo | head -n1 | cut -d: -f2 | awk '{printf "x%.1f\n", $1/100}')

        clear

        tput cup 0 0

        echo -e "${BLUE}------------------------ CPU INFORMATION ------------------------${NOCOLOR}"

        echo -e "\n${BLUE}Static Information:${NOCOLOR}"
        echo -e "Manufacturer:                 $MANUFACTURER"
        echo -e "Model Name:                   $MODELNAME"
        echo -e "Number of Cores:              $CORES"
        echo -e "Number of Threads:            $THREADS"
        echo -e "Governor (Power mode):        $GOVERNOR"
        echo -e "Socket:                       $SOCKET"
        echo -e "Default Voltage:              $VOLTAGE"
        echo -e "Family Number:                $FAMILYNUMBER"
        echo -e "Model Number:                 $MODELNUMBER"
        echo -e "Stepping:                     $STEPPING"
        echo -e "Maximum Clock Speed:          $MAXCLOCK"
        echo -e "Cache L1d:                    $CACHEL1D"
        echo -e "Cache L1i:                    $CACHEL1I"
        echo -e "Cache L2:                     $CACHEL2"
        echo -e "Cache L3:                     $CACHEL3"
        echo -e "Instructions:"
        echo -e "$INSTRUCTIONS" | fmt -w 75

        echo -e "\n${BLUE}Realtime information:${NOCOLOR}"
        echo -e "Current Temperature:          $CPUTEMP"
        echo -e "Current Clock Speed:          $CLOCK"
        echo -e "Current Multiplier:           $MULTIPLIER"

        echo -e "\n${YELLOW}Press CTRL+C to exit.${NOCOLOR}"

    sleep 1
    done
        ;;

    "--ram") # BEGINNING OF THE "--ram" FLAG CODE.

        echo -e "${YELLOW}This script requires administrator privileges to read hardware data.${NOCOLOR}"

        sudo -v || { echo -e "${RED}Authentication failed!${NOCOLOR}"; exit 1; }

        # Defining variables.

        MEMCMD=$(sudo dmidecode -t 17)

        # RAM size per slot, from 1 to 6:
        MEMSIZE01=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==2 {print}' | grep -w "Size:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMSIZE02=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==3 {print}' | grep -w "Size:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMSIZE03=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==4 {print}' | grep -w "Size:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMSIZE04=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==5 {print}' | grep -w "Size:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMSIZE05=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==6 {print}' | grep -w "Size:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMSIZE06=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==7 {print}' | grep -w "Size:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')

        # Memory type per slot, from 1 to 6:
        MEMTYPE01=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==2 {print}' | grep -w "Type:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMTYPE02=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==3 {print}' | grep -w "Type:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMTYPE03=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==4 {print}' | grep -w "Type:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMTYPE04=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==5 {print}' | grep -w "Type:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMTYPE05=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==6 {print}' | grep -w "Type:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMTYPE06=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==7 {print}' | grep -w "Type:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')

        # Memory speed per slot, from 1 to 6:
        MEMSPEED01=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==2 {print}' \
            | grep -w "Speed:" | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMSPEED02=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==3 {print}' \
            | grep -w "Speed:" | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMSPEED03=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==4 {print}' \
            | grep -w "Speed:" | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMSPEED04=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==5 {print}' \
            | grep -w "Speed:" | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMSPEED05=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==6 {print}' \
            | grep -w "Speed:" | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
        MEMSPEED06=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==7 {print}' | grep -w "Speed:" \
            | grep -vE "Unknown|No Module Installed" | head -n1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')

        # Memory default voltage per slot, from 1 to 6:
        MEMVOLTAGE01=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==2 {print}' \
            | grep "Configured Voltage:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMVOLTAGE02=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==3 {print}' \
            | grep "Configured Voltage:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMVOLTAGE03=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==4 {print}' \
            | grep "Configured Voltage:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMVOLTAGE04=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==5 {print}' \
            | grep "Configured Voltage:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMVOLTAGE05=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==6 {print}' \
            | grep "Configured Voltage:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMVOLTAGE06=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==7 {print}' \
            | grep "Configured Voltage:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')

        # Memory serial number per slot, from 1 to 6:
        MEMSN01=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==2 {print}' \
            | grep "Serial Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMSN02=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==3 {print}' \
            | grep "Serial Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMSN03=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==4 {print}' \
            | grep "Serial Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMSN04=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==5 {print}' \
            | grep "Serial Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMSN05=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==6 {print}' \
            | grep "Serial Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMSN06=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==7 {print}' \
            | grep "Serial Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')

        # Memory part number per slot, from 1 to 6:
        MEMPN01=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==2 {print}' \
            | grep "Part Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMPN02=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==3 {print}' \
            | grep "Part Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMPN03=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==4 {print}' \
            | grep "Part Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMPN04=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==5 {print}' \
            | grep "Part Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMPN05=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==6 {print}' \
            | grep "Part Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')
        MEMPN06=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==7 {print}' \
            | grep "Part Number:" | grep -vE "Unknown|No Module Installed" \
            | head -n1 | awk '{$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')

        # Memory Form Factor per slot, from 1 to 6:
        MEMFF01=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==2 {print}' \
            | grep "Form Factor:" | grep -v "Unknown" | awk '{print $3}')
        MEMFF02=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==3 {print}' \
            | grep "Form Factor:" | grep -v "Unknown" | awk '{print $3}')
        MEMFF03=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==4 {print}' \
            | grep "Form Factor:" | grep -v "Unknown" | awk '{print $3}')
        MEMFF04=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==5 {print}' \
            | grep "Form Factor:" | grep -v "Unknown" | awk '{print $3}')
        MEMFF05=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==6 {print}' \
            | grep "Form Factor:" | grep -v "Unknown" | awk '{print $3}')
        MEMFF06=$(echo "$MEMCMD" | awk 'BEGIN{RS="Memory Device"} NR==7 {print}' \
            | grep "Form Factor:" | grep -v "Unknown" | awk '{print $3}')

        # Formatting output

        clear

        echo -e "${BLUE}------------------------ RAM INFORMATION ------------------------${NOCOLOR}"

        echo -e "\n${BLUE}Memory size per slot:${NOCOLOR}"
        [[ -n "$MEMSIZE01" ]] && echo -e "Slot 01: $MEMSIZE01${NOCOLOR}"
        [[ -n "$MEMSIZE02" ]] && echo -e "Slot 02: $MEMSIZE02${NOCOLOR}"
        [[ -n "$MEMSIZE03" ]] && echo -e "Slot 03: $MEMSIZE03${NOCOLOR}"
        [[ -n "$MEMSIZE04" ]] && echo -e "Slot 04: $MEMSIZE04${NOCOLOR}"
        [[ -n "$MEMSIZE05" ]] && echo -e "Slot 05: $MEMSIZE05${NOCOLOR}"
        [[ -n "$MEMSIZE06" ]] && echo -e "Slot 06: $MEMSIZE06${NOCOLOR}"

        echo -e "\n${BLUE}Memory type per slot:${NOCOLOR}"
        [[ -n "$MEMTYPE01" ]] && echo -e "Slot 01: $MEMTYPE01${NOCOLOR}"
        [[ -n "$MEMTYPE02" ]] && echo -e "Slot 02: $MEMTYPE02${NOCOLOR}"
        [[ -n "$MEMTYPE03" ]] && echo -e "Slot 03: $MEMTYPE03${NOCOLOR}"
        [[ -n "$MEMTYPE04" ]] && echo -e "Slot 04: $MEMTYPE04${NOCOLOR}"
        [[ -n "$MEMTYPE05" ]] && echo -e "Slot 05: $MEMTYPE05${NOCOLOR}"
        [[ -n "$MEMTYPE06" ]] && echo -e "Slot 06: $MEMTYPE06${NOCOLOR}"

        echo -e "\n${BLUE}Memory speed per slot:${NOCOLOR}"
        [[ -n "$MEMSPEED01" ]] && echo -e "Slot 01: $MEMSPEED01${NOCOLOR}"
        [[ -n "$MEMSPEED02" ]] && echo -e "Slot 02: $MEMSPEED02${NOCOLOR}"
        [[ -n "$MEMSPEED03" ]] && echo -e "Slot 03: $MEMSPEED03${NOCOLOR}"
        [[ -n "$MEMSPEED04" ]] && echo -e "Slot 04: $MEMSPEED04${NOCOLOR}"
        [[ -n "$MEMSPEED05" ]] && echo -e "Slot 05: $MEMSPEED05${NOCOLOR}"
        [[ -n "$MEMSPEED06" ]] && echo -e "Slot 06: $MEMSPEED06${NOCOLOR}"

        echo -e "\n${BLUE}Memory Form Factor per slot:${NOCOLOR}"
        [[ -n "$MEMFF01" ]] && echo -e "Slot 01: $MEMFF01${NOCOLOR}"
        [[ -n "$MEMFF02" ]] && echo -e "Slot 02: $MEMFF02${NOCOLOR}"
        [[ -n "$MEMFF03" ]] && echo -e "Slot 03: $MEMFF03${NOCOLOR}"
        [[ -n "$MEMFF04" ]] && echo -e "Slot 04: $MEMFF04${NOCOLOR}"
        [[ -n "$MEMFF05" ]] && echo -e "Slot 05: $MEMFF05${NOCOLOR}"
        [[ -n "$MEMFF06" ]] && echo -e "Slot 06: $MEMFF06${NOCOLOR}"

        echo -e "\n${BLUE}Memory default voltage per slot:${NOCOLOR}"
        [[ -n "$MEMVOLTAGE01" ]] && echo -e "Slot 01: $MEMVOLTAGE01${NOCOLOR}"
        [[ -n "$MEMVOLTAGE02" ]] && echo -e "Slot 02: $MEMVOLTAGE02${NOCOLOR}"
        [[ -n "$MEMVOLTAGE03" ]] && echo -e "Slot 03: $MEMVOLTAGE03${NOCOLOR}"
        [[ -n "$MEMVOLTAGE04" ]] && echo -e "Slot 04: $MEMVOLTAGE04${NOCOLOR}"
        [[ -n "$MEMVOLTAGE05" ]] && echo -e "Slot 05: $MEMVOLTAGE05${NOCOLOR}"
        [[ -n "$MEMVOLTAGE06" ]] && echo -e "Slot 06: $MEMVOLTAGE06${NOCOLOR}"

        echo -e "\n${BLUE}Memory serial number per slot:${NOCOLOR}"
        [[ -n "$MEMSN01" ]] && echo -e "Slot 01: $MEMSN01${NOCOLOR}"
        [[ -n "$MEMSN02" ]] && echo -e "Slot 02: $MEMSN02${NOCOLOR}"
        [[ -n "$MEMSN03" ]] && echo -e "Slot 03: $MEMSN03${NOCOLOR}"
        [[ -n "$MEMSN04" ]] && echo -e "Slot 04: $MEMSN04${NOCOLOR}"
        [[ -n "$MEMSN05" ]] && echo -e "Slot 05: $MEMSN05${NOCOLOR}"
        [[ -n "$MEMSN06" ]] && echo -e "Slot 06: $MEMSN06${NOCOLOR}"

        echo -e "\n${BLUE}Memory part number per slot:${NOCOLOR}"
        [[ -n "$MEMPN01" ]] && echo -e "Slot 01: $MEMPN01${NOCOLOR}"
        [[ -n "$MEMPN02" ]] && echo -e "Slot 02: $MEMPN02${NOCOLOR}"
        [[ -n "$MEMPN03" ]] && echo -e "Slot 03: $MEMPN03${NOCOLOR}"
        [[ -n "$MEMPN04" ]] && echo -e "Slot 04: $MEMPN04${NOCOLOR}"
        [[ -n "$MEMPN05" ]] && echo -e "Slot 05: $MEMPN05${NOCOLOR}"
        [[ -n "$MEMPN06" ]] && echo -e "Slot 06: $MEMPN06${NOCOLOR}"
        ;;

    *)
        # Defining variables:

        OSNAME=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
        DENAME=$(echo $XDG_CURRENT_DESKTOP)
        KERNELNAME=$(uname -r)
        UPTIME=$(uptime -p | sed 's/up //')
        SHELLNAME=$(echo "${SHELL##*/} $( $SHELL --version | grep -oE '[0-9]+\.[0-9.]+' | head -n1 )")
        CPUNAME=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//')
        GPUNAME=$(lspci | grep -iE 'vga|3d|display' | sed -E 's/.*\[(.*)\].*/\1/' | xargs | sed 's/ /, /g')
        TOTALRAM=$(free -k | grep "Mem:" | awk '{printf "%.1f GiB\n", $2/1024/1024}')
        TOTALSWAP=$(free -h | awk '/^Swap:/ {print $2}')
        MYDISKS=$(df -h --output=source,used,size,pcent,target,fstype | grep "^/dev/" \
            | sed 's/  */,/g; s/,fuseblk/,ntfs/g; s/,ntfs3/,ntfs/g' \
            | awk -v color="$BLUE" -v nc="$NOCOLOR" -F, \
            '{printf "%sDisk (%s):%s %s / %s (%s) em %s [%s]\n", color, $1, nc, $2, $3, $4, $5, $6}')
        MYMONITORS=$(xrandr --query 2>/dev/null | awk -v color="$BLUE" -v \
            nc="$NOCOLOR" '/ connected/ {p=$1} /\*/ {res=$1; freq=$2; gsub(/[*+]/, "", \
            freq); printf "%s%s:%s %s @ %sHz\n", color, p, nc, res, freq}')
        MYIP=$(ip -br addr show | grep UP | awk '{print $3}' | cut -d/ -f1)
        VIDEODRIVER=$(lspci -k | grep -EiA 3 "vga|video|3d" | grep "in use" | sed 's/.*: //')
        IFBAT=$(upower -i $(upower -e 2>/dev/null | grep 'BAT') 2>/dev/null | grep 'percentage' | awk '{print $2}')

        # Formatting output

        clear

        echo -e "${BLUE}------------------ GENERAL SYSTEM INFORMATION ------------------${NOCOLOR}\n"

        echo -e "${BLUE}OS:${NOCOLOR} $OSNAME"
        echo -e "${BLUE}DE:${NOCOLOR} $DENAME"
        echo -e "${BLUE}Kernel:${NOCOLOR} $KERNELNAME"
        echo -e "${BLUE}Uptime:${NOCOLOR} $UPTIME"
        echo -e "${BLUE}Shell:${NOCOLOR} $SHELLNAME"
        echo -e "${BLUE}CPU:${NOCOLOR} $CPUNAME"
        echo -e "${BLUE}Total RAM:${NOCOLOR} $TOTALRAM"
        echo -e "${BLUE}Total swap:${NOCOLOR} $TOTALSWAP"
        echo -e "${BLUE}GPU:${NOCOLOR} $GPUNAME"
        echo -e "${BLUE}Video driver in use:${NOCOLOR} $VIDEODRIVER"
        echo -e "$MYMONITORS"
        echo -e "${BLUE}Local IP:${NOCOLOR} $MYIP"
        [[ -n "$IFBAT" ]] && echo -e "${BLUE}Battery percentage:${NOCOLOR} $IFBAT"
        echo -e "$MYDISKS"


        echo -e "\n${YELLOW}Run \"./pcdata.sh --help\" for dependencies and more information on how to use it.${NOCOLOR}"
        ;;
esac
