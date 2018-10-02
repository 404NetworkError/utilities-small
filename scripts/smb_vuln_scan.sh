#!/bin/bash

trap ctrl_c SIGINT

ctrl_c () {
    echo "" # For newline
    exit
}

readonly BOLD=$(tput bold)
readonly NORM=$(tput sgr0)

readonly BLACK='\x1B[0;30m'
readonly RED='\x1B[0;31m'
readonly GREEN='\x1B[0;32m'
readonly ORANGE='\x1B[0;33m'
readonly BLUE='\x1B[0;34m'
readonly PURPLE='\x1B[0;35m'
readonly CYAN='\x1B[0;36m'
readonly LIGHTGREY='\x1B[0;37m'
readonly NC='\x1B[0m' # No Color

# High intensity yellow
readonly HIYELLOW='\x1B[0;93m'
readonly BHIYELLOW='\x1B[1;93m'


usage () {
    echo -e "${RED}ERR:${NC} Missing host file"
    echo -e "Usage: ${BOLD}`basename "$0"`${NORM} <file name>"
    echo "  <file name>  Contains a newline separated list of IP addresses"
}

if [[ "$#" -ne 1 ]]; then
    usage
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "ERR: File ${1} doesn't exist"
    usage
    exit 1
fi

#Test script to check for SMB vulns using nmap
#Input is a file comprised of an ip address on each line

while read line
do
    echo scanning $line
    nmap --script smb-vuln-* -p 445 $line | grep '|'
done <$1

