#!/bin/bash

#####################
### DEPENDENCIES: ###
#####################

# This script was tested on Debian 13 (Stable). All the packages used by this script came preinstalled on Debian.
# The packages needed to be able to use this script are (names based on the Debian repositories):
# util-linux
# dmidecode
# lm-sensors
# grep, sed, awk and coreutils (probably installed by default on any distro).

# Colors:
GREEN='\033[0;32m'
BLUE='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NOCOLOR='\033[0m'

##########################
### DEFINING VARIABLES ###
##########################

MANUFACTURER=$(sudo dmidecode -t processor | grep "Manufacturer" | sed 's/.*: *//')
MODELNAME=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//')
CORES=$(lscpu | grep -E "socket|por soquete" | awk '{print $4}')
THREADS=$(lscpu | grep "^CPU(s):" | head -n1 | awk '{print $2}')
SOCKET=$(sudo dmidecode -t processor | grep "Upgrade:" | cut -d: -f2 | sed -e 's/^[ \t]*//')
VOLTAGE=$(sudo dmidecode -t processor | grep "Voltage" | sed 's/.*: *//')
FAMILYNUMBER=$(grep -m1 "cpu family" /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//')
MODELNUMBER=$(grep -m1 "model" /proc/cpuinfo | cut -d: -f2 | grep -v "name" | sed -e 's/^[ \t]*//')
STEPPING=$(grep -m1 "stepping" /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//')
INSTRUCTIONS=$(lscpu | grep -E "Opções|Flags|Options" | sed 's/.*: *//')
MAXCLOCK=$(sudo dmidecode -t processor | grep "Max Speed" | sed 's/.*: *//')
CACHEL1D=$(lscpu | grep -E "L1d" | sed 's/.*: *//')
CACHEL1I=$(lscpu | grep -E "L1i" | sed 's/.*: *//')
CACHEL2=$(lscpu | grep -E "L2" | sed 's/.*: *//')
CACHEL3=$(lscpu | grep -E "L3" | sed 's/.*: *//')

#########################
### FORMATTING OUTPUT ###
#########################

sudo clear

while true; do


    CPUTEMP=$(sensors | grep "Tctl:" | awk '{print $2}' | tr -d '+')
    CLOCK=$(grep "cpu MHz" /proc/cpuinfo | head -n1 | cut -d: -f2 | sed -e 's/^[ \t]*//')
    MULTIPLIER=$(grep "cpu MHz" /proc/cpuinfo | head -n1 | cut -d: -f2 | awk '{printf "x%.1f\n", $1/100}')

    tput cup 0 0

echo -e "${BLUE}#########################################################${NOCOLOR}"
echo -e "${BLUE}##############       CPU INFORMATION       ##############${NOCOLOR}"
echo -e "${BLUE}#########################################################${NOCOLOR}"

echo -e "\n${BLUE}Static Information:${NOCOLOR}\n"

echo -e "Manufacturer:                 $MANUFACTURER"
echo -e "Model Name:                   $MODELNAME"
echo -e "Number of Cores:              $CORES"
echo -e "Number of Threads:            $THREADS"
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
echo -e "$INSTRUCTIONS"

echo -e "\n${BLUE}Realtime information:${NOCOLOR}\n"

echo -e "Current Temperature:          $CPUTEMP"
echo -e "Current Clock Speed:          $CLOCK"
echo -e "Multiplier:                   $MULTIPLIER"

echo -e "\n${YELLOW}Press CTRL+C to exit.${NOCOLOR}"

sleep 1
done
