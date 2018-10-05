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


function confirm() {
    if [ "$yes" != "1" ] && [ "$no" != "1" ]; then
        echo ""
        while true; do
            # call with a prompt string or use a default
            read -r -p "${1:-Are you sure? [y/N]} " response
            case "$response" in
                [yY][eE][sS]|[yY])
                    echo "true"
                    break
                    ;;
                [nN][oO]|[nN])
                    echo "false"
                    break
                    ;;
                *)  continue
                    ;;
            esac
        done
    elif [ "$yes" == "1" ]; then
        echo "true"
    elif [ "$no" == "1" ]; then
        echo "false"
    else
        >&2 echo -e "${RED}Error: Should never get here. Check conditionals.${NC}"
        echo "false"
    fi
}

DELETE="sudo rm -rf /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock"
small=1

ARGS=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    echo -e "${BOLD}`basename "$0"`${NORM} [options]"
    echo -e "  ${BOLD}-l${NORM}    Large repository"
    echo -e "  ${BOLD}-u${NORM}    If you want to ${BOLD}upgrade${NORM} as well as run the script"
    echo -e "  ${BOLD}-v${NORM}    Setup OpenVAS"
    echo -e "  ${BOLD}-ldm${NORM}  Install lightdm"
    echo -e "  ${BOLD}-32${NORM}   Add i386 arch (aka 32-bit)"
    echo -e "  ${BOLD}-sub${NORM}  Install Sublime Text & Sublime Merge"
    exit
    shift # past argument
    ;;

    -y|--yes|-d|--distup|-u|--upgrade|--dist-upgrade)
    distup=1
    shift # past argument
    ;;

    -sub|--sublime)
    subl=1
    shift # past argument
    ;;

    -ldm|--light|--lightdm)
    light=1
    shift # past argument
    ;;

    -32|--32|-i|--i386|-86|--86)
    i386=1
    shift # past argument
    ;;

    -l|--large|--larger)
    small=0
    shift # past argument
    ;;

    -v|--vas|--openvas)
    vas=1
    shift # past argument
    ;;
esac
done
set -- "${ARGS[@]}" # restore positional parameters



mkdir -p ~/.local/bin
export PATH=~/.local/bin:$PATH
cp /etc/apt/sources.list /etc/apt/sources.list~
sed -i 's|kali-rolling.*|kali-rolling main non-free contrib|g' /etc/apt/sources.list


ToolsDir=~/tools
mkdir -p $ToolsDir
cd $ToolsDir

## Install updates & upgrades
`${DELETE}`
echo -e "${PURPLE}--  INFO: Updating sytem  --${NC}"
sudo apt-get update
`${DELETE}`
echo -e "${PURPLE}--  INFO: Installing apt-fast  --${NC}"
sudo apt-get install -y curl aria2 git python3 python3-pip screen 
`${DELETE}`
#Install apt-fast
/bin/bash -c "$(curl -sL https://git.io/vokNn)"
`${DELETE}`
sudo mkdir -p /var/cache/apt-fast /var/cache/apt/archives
sudo sed -i "s|^#_APTMGR=apt-get|_APTMGR=apt|;s|^#DOWNLOADBEFORE=true|DOWNLOADBEFORE=true|;s|^#_MAXNUM=5|_MAXNUM=8|;s|^#DLLIST|DLLIST|;s|^#_DOWNLOADER|_DOWNLOADER|;s|--timeout=600 -m0|--timeout=600 -m0 --header \"Accept: \*/\*\"|;s|^#DLDIR.*|DLDIR=/var/cache/apt-fast|;s|^#APTCACHE|APTCACHE|" /etc/apt-fast.conf



echo -e "${PURPLE}--  INFO: Installing CPAN packages in the background  --${NC}"
screen -dmS CPAN bash -c "yes | cpan install File::Spec File::Path XML::Simple WWW::Mechanize WWW::Mechanize::Plugin::FollowMetaRedirect -y 2>&1"
echo -e "${PURPLE}--  INFO: Installing Pip for Python 3 in the background  --${NC}"
screen -dmS p3 bash -c "python3 -m pip install --upgrade pip setuptools wheel; python3 -m pip install --upgrade psutil"
# Make local directories for local builds
mkdir -p ~/.local/bin
ln -sf ~/.local ~/local
## Get everything
echo -e "${PURPLE}--  INFO: Install all GitHub packages  --${NC}"
if [[ "${small}" -ne 1 ]]; then
    REPO=utilities
    git clone --recursive https://github.com/404NetworkError/utilities.git
else
    REPO=utilities-small
    git clone --recursive https://github.com/404NetworkError/utilities-small.git
fi
# Peace of mind keyboard shortcut
screen -dmS keycs bash -c "python3 $ToolsDir/${REPO}/bin/set_customshortcut.py 'System Monitor' 'gnome-system-monitor' '<Control><Shift>Escape'"
# Fix executor permissions
chmod -R 700 $ToolsDir/${REPO}/tools/executor/*
chmod -R 400 $ToolsDir/${REPO}/tools/executor/ini/*
# Symlinks
ln -sf $ToolsDir/${REPO}/bin/* /usr/local/bin/; ln -sf $ToolsDir/${REPO}/scripts/* /usr/local/bin/; ln -sf $ToolsDir/${REPO}/tools/executor $ToolsDir/; (IFS='
'; for folder in `ls $ToolsDir/${REPO}/tools/`; do ln -sf $ToolsDir/${REPO}/tools/${folder}/* /usr/local/bin/; done); ln -sf $ToolsDir/${REPO}/tools/SecLists /usr/share/wordlists/; (cd /usr/share/wordlists/; ln -sf SecLists seclists; cd $ToolsDir); ln -sf $ToolsDir/${REPO}/tools/Probable-Wordlists /usr/share/wordlists/; (cd /usr/share/wordlists/; ln -sf Probable-Wordlists probable-wordlists; ln -sf probable-wordlists probable; cd $ToolsDir)



# Upgrade ??
if [[ "${distup}" -eq 1 ]]; then
    if [[ `confirm "Do you want to upgrade NOW? [y/N] This can be done later." | tr -d '\r' | tr -d '\n'` == "true" ]]; then
        sudo apt-get upgrade
        `${DELETE}`
        distup=0
    fi
fi



# Programs to download
echo -e "${PURPLE}--  INFO: Installing all the programs  --${NC}"
`${DELETE}`
sudo apt-fast install -y terminator openvas openvpn virtualenv masscan jq lftp ftp htop p7zip-full pigz pbzip2 pixz \
                         dconf-editor python2 python-pip python2-dev libssl-dev libffi-dev build-essential openssl \
                         swig swig3.0 libssl-dev python2-dev libjpeg-dev xvfb phantomjs neovim tmux screen ncurses-dev \
                         libpython3-dev libyaml-dev metasploit-framework exploitdb apt-transport-https ncdu
`${DELETE}`
if [[ "${light}" -eq 1 ]]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-fast install -y lightdm
    sudo dpkg-reconfigure -f noninteractive lightdm
fi
`${DELETE}`
#sudo apt-fast install -y kali-linux-all
#`${DELETE}`
if [[ "${i386}" -eq 1 ]]; then
    echo -e "${PURPLE}--  INFO: Add x32 Architecture  --${NC}"
    sudo dpkg --add-architecture i386 && sudo apt-fast update
fi
`${DELETE}`

if [[ "${subl}" -eq 1 ]]; then
    # Other useful GUI tools
    echo -e "${PURPLE}--  INFO: Installing Sublime Text & Merge  --${NC}"
    #https://www.sublimetext.com/docs/3/linux_repositories.html
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt-fast update; sudo apt-fast install sublime-text sublime-merge
fi



# Background tasks
echo -e "${PURPLE}--  INFO: Starting PostgreSQL & Metasploit Database in the background  --${NC}"
screen -dmS msf bash -c "echo 'PostgreSQL starting...'; sudo systemctl start postgresql; echo 'Finished'; msfdb init; msfconsole -x 'db_connect -y /usr/share/metasploit-framework/config/database.yml; db_rebuild_cache; exit' 2>&1"

echo -e "${PURPLE}--  INFO: Updating searchsploit in the background  --${NC}"
screen -dmS ss bash -c "searchsploit -u"

echo -e "${PURPLE}--  INFO: Updating wpscan database in the background  --${NC}"
screen -dmS ss bash -c "wpscan --update"

echo -e "${PURPLE}--  INFO: Installing Pip for Python 2 in the background  --${NC}"
screen -dmS p2 bash -c "python2 -m pip install --upgrade pip setuptools wheel; python2 -m pip install --upgrade pwntools"



# Donwload Variables
url_cut=$(curl -s -L https://api.github.com/repos/radareorg/cutter/releases/latest | grep --color=never 'browser_download_url' | cut -d'"' -f 4 | grep --color=never 'AppImage')
name_cut=$(echo "${url_cut}" | rev | cut -d'/' -f 1 | rev | sed -e 's|^"||;s|"$||')
url_rip=$(curl -s -L https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep --color=never browser_download_url | cut -d '"' -f 4 | grep --color=never '.deb')
url_gob=$(curl -s -L https://api.github.com/repos/OJ/gobuster/releases/latest | grep --color=never browser_download_url | cut -d '"' -f 4 | grep --color=never 'linux-amd64')
name_gob=$(echo "${url_gob}" | rev | cut -d'/' -f 1 | rev | sed -e 's|^"||;s|"$||')
url_gron=$(curl -s -L https://api.github.com/repos/tomnomnom/gron/releases | grep --color=never 'browser_download_url' | grep --color=never 'linux-amd64' | cut -d'"' -f4 | head -n 1)
name_gron=$(echo \"${url_gron}\" | rev | cut -d'/' -f 1 | rev | sed -e 's|^"||;s|"$||')

echo -e "${PURPLE}--  INFO: Installing Cutter in the background  --${NC}"
if [[ "${small}" -ne 1 ]]; then ## Not small
    screen -dmS Cutter bash -c "cat $ToolsDir/${REPO}/packages/Cutter.aa $ToolsDir/${REPO}/packages/Cutter.ab > $ToolsDir/${REPO}/packages/Cutter-v1.7.1-x86_64.AppImage; rm $ToolsDir/${REPO}/packages/Cutter.a*; chmod +x $ToolsDir/${REPO}/packages/Cutter-v1.7.1-x86_64.AppImage; ln -sf $ToolsDir/${REPO}/packages/Cutter-v1.7.1-x86_64.AppImage /usr/local/bin/"
    echo -e "${PURPLE}--  INFO: Installing ripgrep  --${NC}"
    sudo dpkg -i $ToolsDir/${REPO}/packages/ripgrep_0.10.0_amd64.deb
else
    screen -dmS Cutter bash -c "cd $ToolsDir/${REPO}/packages/; curl -#LO \"${url_cut}\"; chmod +x ${name_cut}; ln -sf $ToolsDir/${REPO}/packages/\"${name_cut}\" /usr/local/bin/"
    echo -e "${PURPLE}--  INFO: Installing ripgrep  --${NC}"
    cd $ToolsDir/${REPO}/packages/
    curl -#LO "${url_rip}"
    sudo dpkg -i $(echo "${url_rip}" | rev | cut -d '/' -f 1 | rev)
    cd $ToolsDir
    echo -e "${PURPLE}--  INFO: Installing gobuster in the background  --${NC}"
    screen -dmS gob bash -c "cd $ToolsDir/${REPO}/bin/; curl -#LO \"${url_gob}\"; 7z x \"${name_gob}\" -aoa -y; rm -f \"${name_gob}\"; mv gobuster-linux-amd64/* ./; rm -rf gobuster-linux-amd64; chmod +x gobuster"
fi
cd $ToolsDir

echo -e "${PURPLE}--  INFO: Installing HTTPScreenshot Pip Requirements in the background  --${NC}"
screen -dmS http bash -c "cd $ToolsDir/${REPO}/tools/httpscreenshot; python2 -m pip install -r requirements.txt"
cd $ToolsDir

if [[ "${small}" -eq 1 ]]; then
    echo -e "${PURPLE}--  INFO: Installing geckodriver in the background  --${NC}"
    screen -dmS gecko bash -c "cd $ToolsDir/${REPO}/bin/; wget -nc https://github.com/mozilla/geckodriver/releases/download/v0.15.0/geckodriver-v0.15.0-linux64.tar.gz; tar xzvf geckodriver-v0.15.0-linux64.tar.gz; rm -f geckodriver-v0.15.0-linux64.tar.gz; cd $ToolsDir; echo -e '${PURPLE}--  INFO: Linking geckodriver  --${NC}'; sudo ln -sf $ToolsDir/${REPO}/bin/geckodriver /usr/bin/geckodriver"
else
    echo -e "${PURPLE}--  INFO: Linking geckodriver  --${NC}"
    sudo ln -sf $ToolsDir/${REPO}/bin/geckodriver /usr/bin/geckodriver
fi


#Greppable JSON 
if [[ "${small}" -eq 1 ]]; then
    echo -e "${PURPLE}--  INFO: Installing gron [Greppable JSON] in the background  --${NC}"
    screen -dmS gron bash -c "cd $ToolsDir/${REPO}/bin/; curl -#LO \"${url_gron}\"; tar xzvf ${name_gron}; rm -f \"${name_gron}\"; cd $ToolsDir; echo -e '${PURPLE}--  INFO: Linking gron [Greppable JSON]  --${NC}'; sudo ln -sf $ToolsDir/${REPO}/bin/gron /usr/bin/"
    cd $ToolsDir
else
    echo -e "${PURPLE}--  INFO: Linking gron [Greppable JSON]  --${NC}"
    sudo ln -sf $ToolsDir/${REPO}/bin/gron /usr/bin/
    cd $ToolsDir
fi

# Web-app vuln & version scanner
# echo -e "${PURPLE}--  INFO: Installing pyfiscan Pip Requirements in the background  --${NC}"
# screen -dmS pyfi bash -c "cd $ToolsDir/${REPO}/tools/pyfiscan; python3 -m pip install -r requirements.lst"
# cd $ToolsDir



# Interactive stuff
#IDA Pro (Free 7.0)
echo -e "${PURPLE}--  INFO: Installing IDA Free 7  --${NC}"
if [[ "${small}" -eq 1 ]]; then
    screen -dmS ida bash -c "cd $ToolsDir/${REPO}/bin; curl -#LO https://out7.hex-rays.com/files/idafree70_linux.run; chmod +x idafree70_linux.run; $ToolsDir/${REPO}/bin/idafree70_linux.run --mode unattended; ln -sf /opt/idafree-7.0/ida64 /usr/local/bin; cp ~/Desktop/IDA\ Free.desktop /usr/share/applications/"
else
    screen -dmS ida bash -c "$ToolsDir/${REPO}/bin/idafree70_linux.run --mode unattended; ln -sf /opt/idafree-7.0/ida64 /usr/local/bin; cp ~/Desktop/IDA\ Free.desktop /usr/share/applications/"
fi

if [[ "${vas}" -eq 1 ]]; then
    echo -e "${PURPLE}--  INFO: Setting up OpenVAS in the background  --${NC}"
    screen -dmS vas bash -c "openvas-setup"
fi

# Setup Lazy script
screen -dmS lscript bash -c "ln -sf $ToolsDir/${REPO}/tools/lscript /root/; chmod +x install.sh; yes i | /root/lscript/install.sh"
screen -dmS peda bash -c "echo 'source $ToolsDir/${REPO}/tools/peda/peda.py' >> ~/.gdbinit"


if [[ "${distup}" -eq 1 ]]; then
    echo -e "${PURPLE}--  INFO: Upgrading System  --${NC}"
    sudo apt-fast -y upgrade
    `${DELETE}`
fi



echo ""
echo -e "${GREEN}There may still be processes running the background. Run the command ${BHIYELLOW}\`screen -ls\` ${GREEN}to check.${NC}"
echo -e "${GREEN}Script is complete.${NC}"
