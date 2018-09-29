#!/bin/bash

# Check if you can connect 
if [ -z "$1" ]; then
    echo "Missing target IP adress"
elif [ -z "$2" ]; then
    echo "Missing Share Directory"
else
    if [ -z "$3" ]; then
        smbclient //"$1"/"$2" -U guest%    
    else
        smbclient //"$1"/"$2" -U "$3"
    fi
fi
