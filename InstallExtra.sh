#!/bin/bash

# Enable debug output if DEBUG=true is passed in the environment
DEBUG=${DEBUG:-true}

debug() {
	if [ "${DEBUG}" = "true" ]; then
		echo -e "DEBUG: $*"
	fi
}

debug "'set'ting the script to be less verbose/quiet and remember commands that were used for faster calling"
set +bvx -h
clear

debug "Defining errB4 and Aftr"
export errB4="We're sorry but it appears that "
export errAftr=", from personal experience, I will recommend doing further reading into what you want to be doing in order to prevent inoperablity to and data loss on your system. Have a nice day!"

debug "Check: Running in Desktop Mode or ssh / virtual tty session"
xdpyinfo &> /dev/null
if [ $? -eq 0 ]
then
	debug "SUCCUSS! Script is running in Desktop Mode"
else
	echo -e "${errB4}this is not being ran in Desktop mode${errAftr}"
	exit
fi

export missProg="a required program was not installed suggesting that this is not being ran on SteamOS nor SteamFork"
debug "Check: zenity Exist?"
if ! command -v zenity >/dev/null 2>&1
then
	errMsgs "${missProg}"
	# insert script self removal call here
	exit 1
fi
debug "SUCCUSS! zenity Exists\n	Break out of if, continue"

errMsgs() {
	echo -e "${errB4}$*${errAftr}"
	zenity --error --text="${errB4}$*${errAftr}"
}

debug "Check: pacman Exist?"
if ! command -v pacman >/dev/null 2>&1
then
	errMsgs "${missProg}"
	# insert script self removal call here
	exit 1
fi
debug "SUCCUSS! pacman Exists\n	Break out of if, continue"

# -------

export notReady="${errB4}this script is not ready for use. Have a nice day!"
debug "${notReady}"
zenity --error --text="${notReady}"
exit 1

# -------

debug "Check: current 'whoami' 'passwd' is set against 'sudo'"
if [ "$(passwd --status $(whoami) | tr -s " " | cut -d " " -f 2)" == "P" ]
then
	debug "Checking if the sudo password is correct"
	zenity --password | sudo -S -k ls &> /dev/null

	if [ $? -eq 0 ]
	then
		debug "SUCCUSS! The provided Administorator (sudo) password is correct! Go psycho!"
		errMsgs "The provided Administorator (sudo) password is correct! Go psycho!"
		# Will continue past this 'if then'
	else
		errMsgs "the password you've entered is incorrect"
		# insert script self removal call here
		exit 1
	fi
else
	errMsgs "the Administrator (sudo) password has not been set"
	# insert script self removal call here
	# "passwd"
	exit 1
fi

# Insert code here
# inspect /etc/pacman.conf for broken and comment them out (without revertion) :
	# [steamfork]
	# Server = file:///home/fewtarius/distribution/release/repos/3.7/os/x86_64
	# Include = /etc/pacman.d/steamfork-mirrorlist
sudo sed -e '/\[steamfork\]/s/^/#/;/^#\[steamfork\]/{n;s/^/#/};/^#Server/{n;s/^/#/}' -i /etc/pacman.conf

# check saved date in: /etc/pacman.d/mirrorlist

sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sudo pacman -S reflector
sudo reflector --protocol https --sort rate --connection-timeout 1 --download-timeout 1 --threads 1 --age 1 --delay 1 --completion-percent 100 --save /etc/pacman.d/mirrorlist
sudo cp /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist

# Temporarly replace [testing] for [extra] and remove # from #Include = /etc/pacman.d/mirrorlist
sudo sed -e 's/#\[testing\]/\[extra\]/;/\[extra]/{N;s/\n#/\n/}' -i /etc/pacman.conf


# Replace [extra] for [testing] and add # from #Include = /etc/pacman.d/mirrorlist
sudo sed -e 's/\[extra\]/#\[testing\]/;/^#\[testing\]/{n;s/^/#/}' -i /etc/pacman.conf

#for precision: sed -e 's/\[extra\]/#\[testing\]/' -e '/^#\[testing\]/,/Include/s/^\s*Include/#Include/'



if [ ! $? = 0 ]; then
	debug "USER: Operation cancelled by the user"
	# insert script self removal call here
	exit 0
fi

# commands to add: sudo steamos-readonly disable && sudo pacman-key --init && sudo pacman-key --populate archlinux && sudo pacman-key --populate holo && sudo pacman -S <linker>
