#!/usr/bin/env bash

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

ToolsDir=~/tools
mkdir -p $ToolsDir
cd $ToolsDir

if [ ! -d $ToolsDir/utilities ]; then
    cd $ToolsDir/utilities-small/dotfiles
elif [ ! -d $ToolsDir/utilities-small ]; then
    cd $ToolsDir/utilities/dotfiles
fi
cat aliases >> ~/.bash_aliases
# cat bashrc >> ~/.bashrc
cat nanorc >> ~/.nanorc
cat tmux.conf >> ~/.tmux.conf
cat vimrc >> ~/.vimrc
